class IC_NMA_Functions
{
    endScript := false

    DirectedInputNoCritical(hold := 1, release := 1, s* )
    {
        timeout := 33
        directedInputStart := A_TickCount
        hwnd := g_SF.Hwnd
        ControlFocus,, ahk_id %hwnd%
        values := s
        if(IsObject(values))
        {
            if(hold)
            {
                for k, v in values
                {
                    g_InputsSent++
                    key := g_KeyMap[v]
                    SendMessage, 0x0100, %key%, 0,, ahk_id %hwnd%,,%timeout%
                }
            }
            if(release)
            {
                for k, v in values
                {
                    key := g_KeyMap[v]
                    SendMessage, 0x0101, %key%, 0xC0000001,, ahk_id %hwnd%,,%timeout%
                }
            }
        }
        else
        {
            key := g_KeyMap[values]
            if(hold)
            {
                g_InputsSent++
                SendMessage, 0x0100, %key%, 0,, ahk_id %hwnd%,,%timeout%
            }
            if(release)
                SendMessage, 0x0101, %key%, 0xC0000001,, ahk_id %hwnd%,,%timeout%
        }
    }

    GetHeroDefines()
    {
        start := A_TickCount
        defines := {}
        g_SF.Memory.OpenProcessReader()
        ;iterate through every hero in memory
        heroCount := g_SF.Memory.ReadChampListSize() ;heroCount := g_SF.Memory.GameManager.Game.gameInstances[0].Controller.UserData.HeroHandler.heroes.size.Read()
        if (heroCount < 100)
            msgbox, "There may have been an error loading data. Reloading the script may fix the error. Error: Unexpected heroCount"
        champID := 0
        upgStartTimer := champStartTimer := startTimer := A_TickCount
        foundSpec := {}
        loop %heroCount%
        {
            ++champID
            ;only include owned heroes
            isOwned := g_SF.Memory.ReadHeroIsOwned() ;GameManager.Game.gameInstances[0].Controller.UserData.HeroHandler.heroes[champID -1].Owned.Read()
            if (!isOwned OR champID == 107)
                Continue
            name := g_SF.Memory.ReadChampNameByID(champID)
            seat := g_SF.Memory.ReadChampSeatByID(champID)
            defines[champID] := new IC_NMA_Functions.HeroDefine(champID, name, seat)
            upgradeCount := g_SF.Memory.ReadHeroUpgradesSize(champID)
            upgIndex := 0
            ;iterate through every upgrade for that hero
            loop %upgradeCount%
            {
                requiredLvl := g_SF.Memory.ReadHeroUpgradeRequiredLevel(champID, upgIndex)
                ;some upgrades with required level of 9999
                if (requiredLvl < 9999)
                    defines[champID].MaxLvl := Max(requiredLvl, defines[champID].MaxLvl)
                isSpec := g_SF.Memory.ReadHeroUpgradeIsSpec(champID, upgIndex)
                if isSpec
                {
                    upgradeID := g_SF.Memory.ReadHeroUpgradeID(champID, upgIndex)
                    requiredUpgradeID := g_SF.Memory.ReadHeroUpgradeRequiredUpgradeID(champID, upgIndex)
                    specName := g_SF.Memory.ReadHeroUpgradeSpecializationName(champID, upgIndex)
                    defines[champID].SpecDefines.AddSpec(upgradeID, requiredLvl, requiredUpgradeID, specName)
                    foundSpec[champID] := True
                }
                ++upgIndex
                ; OutputDebug, % "upgIndex " upgIndex . ": " . (A_TickCount - upgStartTimer) / 1000 . "s"
                ; upgStartTimer := A_TickCount
            }
            OutputDebug, % "Champ " champID . ": " . (A_TickCount - champStartTimer) / 1000 . "s"
            if(!foundSpec[champID])
                OutputDebug, % name . " (" . champID . ") failed to find a specialization."
            champStartTimer := A_TickCount
            defines[champID].SpecDefines.SortSpecList()
        }
        OutputDebug, % "TotalTime: " . (A_TickCount - startTimer) / 1000 . "s"
        defines.TimeStamp := A_MMMM . " " . A_DD . ", " . A_YYYY . " at " . A_Hour . ":" . A_Min . ":" . A_Sec
        defines.LoadTime := A_TickCount - start
        ;a bit easier to debug from json file
        g_SF.WriteObjectToJSON(A_LineFile . "\..\HeroDefines.JSON", defines)
        return defines
    }

    class HeroDefine
    {
        __new(heroID, heroName, seat)
        {
            this.HeroID := heroID
            this.HeroName := heroName
            this.MaxLvl := 1
            this.Seat := seat
            this.SpecDefines := new IC_NMA_Functions.SpecDefineSets
            return this
        }
    }

    class SpecDefine
    {
        __new(upgradeID, requiredLvl, requiredUpgradeID, specName)
        {
            this.UpgradeID := upgradeID
            this.RequiredLvl := requiredLvl
            this.RequiredUpgradeID := requiredUpgradeID
            this.SpecName := specName
            return this
        }
    }

    class SpecDefineSets
    {
        ;each item is an array of spec upgrades associated with a given level and required upgrade.
        specList := {}
        specListSize := 0
        ;an array that mimics specList, but consists of strings for drop down list gui elements.
        ddlList := {}
        ;each item is an object of data to know which items from specList to use based on level and required upgrade data.
        setList := {}
        setListSize := 0

        AddSpec(upgID, reqLvl, reqUpgID, specName)
        {
            isNewSet := true
            for k, v in this.setList
            {
                if (reqLvl == v.reqLvl)
                {
                    isNewSet := false
                    ;this handles spec sets like Morg and Selise that change based on previous choices
                    if !v.listIndex.HasKey(reqUpgID)
                    {
                        index := this.createNewSpecListEntry()
                        v.AddNewReqUpgID(index, reqUpgID)
                    }
                    else
                        index := v.listIndex[reqUpgID]
                    ;following should not be possible, but leaving here just in case
                    ;if !IsObject(this.specList[index])
                    ;    this.createNewSpecListEntry(index)
                    this.pushSpec(index, upgID, reqLvl, reqUpgID, specName, k)
                    break
                }
            }
            if isNewSet
            {
                index := this.createNewSpecListEntry()
                this.setList.Push(new IC_NMA_Functions.SetData(index, reqLvl, reqUpgID))
                this.setListSize := this.setList.Count()
                this.pushSpec(index, upgID, reqLvl, reqUpgID, specName, k)
            }
        }

        pushSpec(index, upgID, reqLvl, reqUpgID, specName, k)
        {
            this.specList[index].Push(new IC_NMA_Functions.SpecDefine(upgID, reqLvl, reqUpgID, specName))
        }

        createNewSpecListEntry()
        {
            this.specListSize += 1
            this.specList[this.specListSize] := {}
            this.ddlList[this.specListSize] := ""
            return this.specListSize
        }

        SortSpecList()
        {
            for k, v in this.specList
            {
                ;insertion sort
                i := 1
                while (i <= v.Count())
                {
                    j := i
                    while (j > 1 AND v[j-1].UpgradeID > v[j].UpgradeID)
                    {
                        temp := v[j].Clone()
                        v[j] := v[j-1].Clone()
                        v[j-1] := temp.Clone()
                        --j
                    }
                    ++i
                }
            }
        }

        SpecDefineList[reqLvl, reqUpgID]
        {
            get
            {
                index := this.getIndex(reqLvl, reqUpgID)
                if (index == -1)
                    return ""
                else
                    return this.specList[index]
            }
        }

        DDL[reqLvl, reqUpgID]
        {
            get
            {
                index := this.getIndex(reqLvl, reqUpgID)
                if (index == -1)
                    return ""
                else
                {
                    string := ""
                    for k, v in this.specList[index]
                    {
                        string .= v.SpecName . "|"
                    }
                    return string
                }
            }
        }

        getIndex(reqLvl, reqUpgID)
        {
            for k, v in this.setList
            {
                if (reqLvl == v.reqLvl)
                {
                    if v.listIndex.HasKey(0)
                        return v.listIndex[0]
                    else
                        return v.listIndex[reqUpgID]
                }
            }
            return -1
        }
    }

    ;an object for all the spec upgrades associated with a particular level.
    class SetData
    {
        listIndex := {}
        listCount := 0

        __new(index, reqLvl, reqUpgID)
        {
            this.reqLvl := reqLvl
            this.AddNewReqUpgID(index, reqUpgID)
            return this
        }

        AddNewReqUpgID(index, reqUpgID)
        {
            this.listIndex[reqUpgID] := index
            this.listCount += 1
        }
    }

    LevelAndSpec(champID, targetLvl, maxLvlData, specSettings)
    {
        seat := g_SF.Memory.ReadChampSeatByID(champID)
        inputKey := "{F" . seat . "}"
        if !targetLvl
            targetLvl := maxLvlData[champID]
        while (targetLvl > (currChampLevel := g_SF.Memory.ReadChampLvlByID(champID)) AND !(this.endScript))
        {
            if(currChampLevel == lastChampLevel) ; leveling failed, wait for next call
                break
            lastChampLevel := currChampLevel
            this.DirectedInputNoCritical(,, inputKey)
            for k, v in specSettings[champID]
            {
                if (v.RequiredLvl == g_SF.Memory.ReadChampLvlByID(champID))
                    this.PickSpec(v.Choice, v.Choices, v.UpgradeID)
            }
        }
        return
    }

    IsSpec(champID, champLvl, specSettings)
    {
        for k, v in specSettings[champID]
        {
            if (v.RequiredLvl == champLvl)
                return true
        }
        return false
    }

    PickSpec(champID, champLvl, specSettings)
    {
        static lastUpgrade := 0
        static clickCount := 0
        if (clicCount > 10)
        {
            msgbox, 4,, The script has failed specializing in %clicCount% consecutive attempts. Continue?
            IfMsgBox No
               global g_NMADoAdventuring := True
        }
        isPurchased := g_SF.Memory.ReadHeroUpgradeIsPurchased(champID, specSettings[champID][1]["UpgradeID"])
        if (isPurchased)
        {
            clickCount := 0
            return
        }
        for k, v in specSettings[champID]
        {
            if (v.RequiredLvl == champLvl)
            {
                choice := v.Choice
                choices := v.Choices
                upgradeID := v.UpgradeID
            }
        }
        ScreenCenterX := (g_SF.Memory.ReadScreenWidth(1) / 2)
        ScreenCenterY := (g_SF.Memory.ReadScreenHeight(1) / 2)
        yClick := ScreenCenterY + 245
        ButtonWidth := 70
        ButtonSpacing := 180
        TotalWidth := (ButtonWidth * Choices) + (ButtonSpacing * (Choices - 1))
        xFirstButton := ScreenCenterX - (TotalWidth / 2)
        xClick := xFirstButton + 35 + (250 * (Choice - 1))
        StartTime := A_TickCount
        ElapsedTime := 0
        WinActivate, ahk_exe IdleDragons.exe
        MouseClick, Left, xClick, yClick, 1
        clickCount++
        Sleep, 10
        return
    }
        
    NMA_CheckForReset()
    {
        if(g_SF.Memory.ReadCurrentZone() > g_NMAResetZone)
        {
            g_SF.ResetServerCall()
            g_SF.CurrentAdventure := g_SF.Memory.ReadCurrentObjID()
            g_SF.RestartAdventure("Adventure Complete")
            return True
        }
        return False
    }

    NMA_GetChampionsToLevel(formationKey)
    {
        for k,v in formationKey
        {
            if(NMA_CB%k%)
            {
                champArray := g_SF.Memory.GetFormationByFavorite(k)
                size := champArray.MaxIndex()
                Loop, %size%
                {
                    g_NMAChampsToLevel[champArray[A_Index]] := False
                }
            }
        }
        return g_NMAChampsToLevel
    }

    NMA_LevelAndSpec(formationID, champID)
    {
        if (g_NMAChampsToLevel[champID]) ; when set to true, champions is done leveling
            return
        champLvl := g_SF.Memory.ReadChampLvlByID(champID)
        seat := g_SF.Memory.ReadChampSeatByID(champID)
        inputKey := "{F" . seat . "}"
        this.DirectedInputNoCritical(,, inputKey)
        sleep, 33
        global g_NMAlvlObj
        if (g_NMAlvlObj.IsSpec(champID, champLvl, g_NMASpecSettings))
            g_NMAlvlObj.PickSpec(champID, champLvl, g_NMASpecSettings)
        if (!(g_NMAMaxLvl[champID] > champLvl))
            g_NMAChampsToLevel[champID] := True
    }

    NMA_UseUltimates(formation)
    {
        global NMA_FireUlts
        for k,v in g_NMAChampsToLevel
        {
            if(k AND k != -1 AND NMA_FireUlts)
            {
                ultButton := g_SF.GetUltimateButtonByChampID(k)
                this.DirectedInputNoCritical(,, ultButton)
            }   
        }
    }

    ; Unused test for if champions are finished leveling.
    NMA_CheckForLevelingDone()
    {
        for k,v in g_NMAChampsToLevel
        {
            if(k AND k != -1 AND v == False)
                return False
        }
        return True
    }
}
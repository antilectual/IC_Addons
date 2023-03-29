#include %A_LineFile%\..\IC_NoModronAdventuring_Functions.ahk

GUIFunctions.AddTab("No Modron Adventuring")

global g_NMAHeroDefines
global g_NMAChampsToLevel := {}
global g_NMAResetZone := 500
global g_NMADoAdventuring := True
global g_NMAlvlObj

global g_NMASpecSettings := g_SF.LoadObjectFromJSON( A_LineFile . "\..\SpecSettings.json" )
if !IsObject(g_NMASpecSettings)
{
    g_NMASpecSettings := {}
    g_NMASpecSettings.TimeStamp := ""
}
global g_NMAMaxLvl := g_SF.LoadObjectFromJSON( A_LineFile . "\..\MaxLvl.json" )
if !IsObject(g_NMAMaxLvl)
{
    g_NMAMaxLvl := {}
    g_NMAMaxLvl.TimeStamp := ""
}

Gui, ICScriptHub:Tab, No Modron Adventuring
Gui, ICScriptHub:Font, w700
Gui, ICScriptHub:Add, Text, x15 y80, BETA No Modron Adventure
Gui, ICScriptHub:Add, Text, x15 y+2, No Modron Leveling, Specing, Ulting, and Resetting
Gui, ICScriptHub:Font, w400
Gui, ICScriptHub:Add, Text, x15 y+5, NOTE: This add on will take control of the mouse to select specializations.
Gui, ICScriptHub:Add, Text, x15 y+10, Specialization Settings Status: 
Gui, ICScriptHub:Add, Text, x+5 vNMA_Settings w300, % g_NMASpecSettings.TimeStamp ? "Loaded and dated " . g_NMASpecSettings.TimeStamp : "Not Loaded"
Gui, ICScriptHub:Add, Button, x15 y+10 w160 gNMA_SpecSettings, Select/Create Spec. Settings
Gui, ICScriptHub:Add, Text, x15 y+10, Max. Level Data Status: 
Gui, ICScriptHub:Add, Text, x+5 vNMA_MaxLvl w300, % g_NMAMaxLvl.TimeStamp ? "Loaded and dated " . g_NMAMaxLvl.TimeStamp : "Not Loaded"
Gui, ICScriptHub:Add, Button, x15 y+10 w160 gNMA_BuildMaxLvlData, Load Max. Level Data
Gui, ICScriptHub:Add, Text, x15 y+15, Choose area to restart the adventure at:
Gui, ICScriptHub:Add, Edit, vNMA_RestartZone x15 y+10 w50, % g_NMAResetZone
Gui, ICScriptHub:Add, Checkbox, vNMA_CB1 x15 y+5 Checked Hidden, "Q"
Gui, ICScriptHub:Add, Checkbox, x15 y+5 vNMA_LevelClick , Upgrade Click Damage
Gui, ICScriptHub:Add, Checkbox, x15 y+5 vNMA_FireUlts , Fire Ultimates
Gui, ICScriptHub:Add, Button, x15 y+10 w160 gNMA_RunAdventuring, Start Modronless Adventuring
Gui, ICScriptHub:Add, Text, x15 y+15 w300, Stop Adventuring button may need to be pushed multple times. Click until box pops up.
Gui, ICScriptHub:Add, Button, x15 y+10 w100 gNMA_StopAdventuring, Stop Adventuring

NMA_StopAdventuring()
{
    global g_NMADoAdventuring := False
}

NMA_RunAdventuring()
{
    global
    g_NMADoAdventuring := True
    if !(g_NMAMaxLvl.TimeStamp)
    {
        msgbox, Max level data not found, click Load Max. Level Data prior to running this script.
        return
    }
    if !(g_NMASpecSettings.TimeStamp)
    {
        msgbox, Specialization settings not found, click Select/Create Spec. Settings prior to running this script.
        return
    }
    g_SF.Hwnd := WinExist("ahk_exe " . g_UserSettings[ "ExeName" ])
    g_SF.Memory.OpenProcessReader()
    g_NMAlvlObj := new IC_NMA_Functions
    Gui, ICScriptHub:Submit, NoHide
    g_NMAResetZone := NMA_RestartZone
    formationKey := {1:"q"} ; {1:"q", 2:"w", 3:"e"}
    favoriteFormation := 1
    g_NMAchampsToLevel := g_NMAlvlObj.NMA_GetChampionsToLevel(formationKey)
    while (g_NMADoAdventuring)
    {
        isLevelingDone := False
        isReset := False
        while (!isLevelingDone AND !isReset AND g_NMADoAdventuring)
        {
            g_NMAlvlObj.DirectedInputNoCritical(,, formationKey[favoriteFormation])
            for k, v in g_NMAChampsToLevel
            { 
                Sleep, 20
                if (k == -1 OR !k)
                    continue
                name := g_SF.Memory.ReadChampNameByID(k)
                g_NMAlvlObj.NMA_LevelAndSpec(favoriteFormation, k)
            }
            if (NMA_LevelClick)
                g_NMAlvlObj.DirectedInputNoCritical(,, "{ClickDmg}")
            if (!Mod( g_SF.Memory.ReadCurrentZone(), 5 ) AND Mod( g_SF.Memory.ReadHighestZone(), 5 ) AND !g_SF.Memory.ReadTransitioning())
                g_SF.ToggleAutoProgress( 1, true ) ; Toggle autoprogress to skip boss bag
            g_SF.ToggleAutoProgress(1,false)
            if(NMA_FireUlts)
                g_NMAlvlObj.NMA_UseUltimates(favoriteFormation)
            isReset := g_NMAlvlObj.NMA_CheckForReset()
            if(isReset)
            {
                g_SF.SafetyCheck()
                g_NMAchampsToLevel := g_NMAlvlObj.NMA_GetChampionsToLevel(formationKey)
                break
            }
            isLevelingDone := g_NMAlvlObj.NMA_CheckForLevelingDone()
            g_SF.SafetyCheck()
            Sleep, 100
        }
        while (!isReset AND g_NMADoAdventuring)
        {
            isReset := g_NMAlvlObj.NMA_CheckForReset()
            g_SF.SafetyCheck()
            g_NMAchampsToLevel := g_NMAlvlObj.NMA_GetChampionsToLevel(formationKey)
            if (NMA_LevelClick)
                g_NMAlvlObj.DirectedInputNoCritical(,, "{ClickDmg}")
            g_SF.ToggleAutoProgress(0)
            g_SF.ToggleAutoProgress(1)
            if(NMA_FireUlts)
                g_NMAlvlObj.NMA_UseUltimates(favoriteFormation)
            Sleep, 100
        }
        g_SF.SafetyCheck()
        g_NMAchampsToLevel := g_NMAlvlObj.NMA_GetChampionsToLevel(formationKey)
        if !(g_NMADoAdventuring)
        {
            msgbox, Adventuring Stopped.
            return
        }
    }
}

NMA_SpecSettings()
{
    GuiControl, ICScriptHub:, NMA_Settings, Processing data, please wait...
    g_NMAHeroDefines := IC_NMA_Functions.GetHeroDefines()
    NMA_BuildSpecSettingsGUI()
    Gui, SpecSettingsGUI:Show
    GuiControl, ICScriptHub:, NMA_Settings, % g_NMASpecSettings.TimeStamp ? "Loaded and dated " . g_NMASpecSettings.TimeStamp : "Not Loaded"
}

NMA_BuildMaxLvlData()
{
    GuiControl, ICScriptHub:, NMA_MaxLvl, Processing data, please wait...
    g_NMAHeroDefines := IC_NMA_Functions.GetHeroDefines()
    g_NMAMaxLvl := {}
    for k, v in g_NMAHeroDefines
    {
        if v.MaxLvl
            g_NMAMaxLvl[k] := v.MaxLvl
    }
    g_NMAMaxLvl.TimeStamp := A_MMMM . " " . A_DD . ", " . A_YYYY . ", " . A_Hour . ":" . A_Min . ":" . A_Sec
    g_SF.WriteObjectToJSON(A_LineFile . "\..\MaxLvl.JSON", g_NMAMaxLvl)
    GuiControl, ICScriptHub:, NMA_MaxLvl, % g_NMAMaxLvl.TimeStamp ? "Loaded and dated " . g_NMAMaxLvl.TimeStamp : "Not Loaded"
}

NMA_BuildSpecSettingsGUI()
{
    global
    Gui, SpecSettingsGUI:New
    Gui, SpecSettingsGUI:+Resize -MaximizeBox
    Gui, SpecSettingsGUI:Font, q5
    Gui, SpecSettingsGUI:Add, Button, x554 y25 w60 gNMA_SaveClicked, Save
    Gui, SpecSettingsGUI:Add, Button, x554 y+25 w60 gNMA_CloseClicked, Close
    Gui, SpecSettingsGUI:Add, Tab3, x5 y5 w539, Seat 1|Seat 2|Seat 3|Seat 4|Seat 5|Seat 6|Seat 7|Seat 8|Seat 9|Seat 10|Seat 11|Seat 12|
    seat := 1
    loop, 12
    {
        Gui, Tab, Seat %seat%
        Gui, SpecSettingsGUI:Font, w700 s11
        Gui, SpecSettingsGUI:Add, Text, x15 y35, Seat %Seat% Champions:
        Gui, SpecSettingsGUI:Font, w400 s9
        for champID, define in g_NMAHeroDefines
        {
            if (define.Seat == seat)
            {
                name := define.HeroName
                Gui, SpecSettingsGUI:Font, w700
                Gui, SpecSettingsGUI:Add, Text, x15 y+10, Name: %name%    `ID: %champID%
                Gui, SpecSettingsGUI:Font, w400
                prevUpg := 0
                for key, set in define.SpecDefines.setList
                {
                    reqLvl := set.reqLvl
                    ddlString := define.SpecDefines.DDL[reqLvl, prevUpg]
                    choice := 0
                    for k, v in g_NMASpecSettings[champID]
                    {
                        if (v.requiredLvl == reqLvl)
                            choice := v.Choice
                    }
                    if !choice
                        choice := 1
                    Gui, SpecSettingsGUI:Add, DropDownList, x15 y+5 vNMA_%champID%Spec%reqLvl% Choose%choice% AltSubmit gNMA_UpdateDDL, %ddlString%
                    prevUpg := define.SpecDefines.SpecDefineList[reqLvl, prevUpg][choice].UpgradeID
                }
            }
        }
        ++seat
    }
    Return
}

;close spec settings GUI
NMA_CloseClicked()
{
    Gui, SpecSettingsGUI:Hide
    Return
}

;save button function from GUI built as part of NMA_BuildSpecSettingsGUI()
NMA_SaveClicked()
{
    Gui, SpecSettingsGUI:Submit, NoHide
    For champID, define in g_NMAHeroDefines
    {
        g_NMASpecSettings[champID] := {}
        prevUpg := 0
        for k, v in define.SpecDefines.setList
        {
            reqLvl := v.reqLvl
            choice := NMA_%champID%Spec%reqLvl%
            position := g_NMASpecSettings[champID].Push(define.SpecDefines.SpecDefineList[reqLvl, prevUpg][choice].Clone())
            g_NMASpecSettings[champID][position].Choice := choice
            g_NMASpecSettings[champID][position].Choices := define.SpecDefines.SpecDefineList[reqLvl, prevUpg].Count()
            prevUpg := g_NMASpecSettings[champID][position].UpgradeID
        }
    }
    g_NMASpecSettings.TimeStamp := A_MMMM . " " . A_DD . ", " . A_YYYY . ", " . A_Hour . ":" . A_Min . ":" . A_Sec
    g_SF.WriteObjectToJSON(A_LineFile . "\..\SpecSettings.JSON", g_NMASpecSettings)
    GuiControl, ICScriptHub:, NMA_Settings, % g_NMASpecSettings.TimeStamp ? "Loaded and dated " . g_NMASpecSettings.TimeStamp : "Not Loaded"
    Return
}

NMA_UpdateDDL()
{
    Gui, SpecSettingsGUI:Submit, NoHide
    choice := %A_GuiControl%
    foundPos := InStr(A_GuiControl, "S")
    champID := SubStr(A_GuiControl, 5, foundPos - 5) + 0
    foundPos := InStr(A_GuiControl, "Spec")
    reqLvl := SubStr(A_GuiControl, foundPos + 4) + 0
    ;need previous upgrade id to get current upgrade id
    prevUpg := 0
    for k, v in g_NMASpecSettings[champID]
    {
        if (v.requiredLvl < reqLvl)
            prevUpg := v.UpgradeID
    }
    prevUpg := g_NMAHeroDefines[champID].SpecDefines.SpecDefineList[reqLvl, prevUpg][choice].UpgradeID
    for k, v in g_NMAHeroDefines[champID].SpecDefines.setList
    {
        requiredLvl := v.reqLvl
        if (v.listCount > 1 AND requiredLvl > reqLvl)
        {
            ddlString := "|"
            ddlString .= g_NMAHeroDefines[champID].SpecDefines.DDL[requiredLvl, prevUpg]
            GuiControl, SpecSettingsGUI:, NMA_%champID%Spec%requiredLvl%, %ddlString%
            GuiControl, SpecSettingsGUI:Choose, NMA_%champID%Spec%requiredLvl%, 1
            prevUpg := g_NMAHeroDefines[champID].SpecDefines.SpecDefineList[requiredLvl, prevUpg][1].UpgradeID
        }
    } 
}

;$SC045::
;Pause

Hotkey, SC045, NMA_Pause

NMA_Pause()
{
    Pause
}
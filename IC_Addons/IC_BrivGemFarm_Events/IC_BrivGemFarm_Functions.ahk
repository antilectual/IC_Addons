class IC_BrivEventsSharedFunctions_Class
{
    /*  WaitForFirstGold - A function that will wait for the first gold drop then return the amount dropped.

        Parameters:
        maxLoopTime ;Maximum time, in milliseconds, the loop will continue.

        Returns:
        gold value

        Special: This function is modified from its original to add notifications for 
    */
    ; WaitForFirstGold( maxLoopTime := 30000 )
    ; {
    ;     ; Make sure there are enough stacks to complete the run and get to min stack zone in next run.
    ;     hasteStacks := g_SF.Memory.ReadHasteStacks()
    ;     neededStacks := g_SF.CalculateBrivStacksLeftAtTargetZone(g_BrivUserSettings[ "MinStackZone" ] + 49 + 5)
    ;     if(g_SF.CalculateBrivStacksLeftAtTargetZone(g_BrivUserSettings[ "MinStackZone" ] + 49 + 5) <= 49 )
    ;         MsgBox, Stacking required to `continue event runs. Set modron core's reset area to min stack zone + 2 skips `and press `OK to `continue.
    ;     else if(this.Memory.GetCoreTargetAreaByInstance(1) >= g_BrivUserSettings[ "MinStackZone" ])
    ;         MsgBox, Stacking complete. Set modron back to 50.
    ;     g_SharedData.LoopString := "Waiting for first gold"
    ;     StartTime := A_TickCount
    ;     ElapsedTime := 0
    ;     counter := 0
    ;     sleepTime := 250
    ;     this.DirectedInput(,, "{q}")
    ;     gold := this.ConvQuadToDouble( this.Memory.ReadGoldFirst8Bytes(), this.Memory.ReadGoldSecond8Bytes() )
    ;     while ( gold == 0 AND ElapsedTime < maxLoopTime )
    ;     {
    ;         ElapsedTime := A_TickCount - StartTime
    ;         if( ElapsedTime > (counter * sleepTime)) ; input limiter..
    ;         {
    ;             this.DirectedInput(,, "{q}" )
    ;             counter++
    ;         }
    ;         gold := this.ConvQuadToDouble( this.Memory.ReadGoldFirst8Bytes(), this.Memory.ReadGoldSecond8Bytes() )
    ;     }
    ;     return gold
    ; }
}

class IC_BrivEventsGemFarm_Class
{
        DoPartySetup()
    {
        formationFavorite1 := g_SF.Memory.GetFormationByFavorite( 1 )
        isShandieInFormation := g_SF.IsChampInFormation( 47, formationFavorite1 )
        g_SF.LevelChampByID( 58, 170, 7000, "{q}") ; level briv
        if(isShandieInFormation)
            g_SF.LevelChampByID( 47, 230, 7000, "{q}") ; level shandie
        isHavilarInFormation := g_SF.IsChampInFormation( 56, formationFavorite1 )
        if(isHavilarInFormation)
        {
            g_SF.LevelChampByID( 56, 15, 7000, "{q}") ; level havi
            ultButton := g_SF.GetUltimateButtonByChampID(56)
            if (ultButton != -1)
                g_SF.DirectedInput(,, ultButton)
        }
        if(g_BrivUserSettings[ "Fkeys" ])
        {
            keyspam := g_SF.GetFormationFKeys(g_SF.Memory.GetActiveModronFormation()) ; level other formation champions
            keyspam.Push("{ClickDmg}")
            g_SF.DirectedInput(,release :=0, keyspam*) ;keysdown
        }
        g_SF.ModronResetZone := g_SF.Memory.GetCoreTargetAreaByInstance(g_SF.Memory.ReadActiveGameInstance()) ; once per zone in case user changes it mid run.
        if(g_SF.CalculateBrivStacksLeftAtTargetZone(g_BrivUserSettings[ "MinStackZone" ] + 49 + 5) <= 49 )
            MsgBox, Stacking required to `continue event runs. Set modron core's reset area to min stack zone + 2 skips `and press `OK to `continue.
        else if(g_SF.ModronResetZone >= g_BrivUserSettings[ "MinStackZone" ])
            MsgBox, Stacking complete. Set modron back to 50.
        if (g_SF.ShouldDashWait())
            g_SF.DoDashWait( Max(g_SF.ModronResetZone - g_BrivUserSettings[ "DashWaitBuffer" ], 0) )
        g_SF.ToggleAutoProgress( 1, false, true )
    }
}

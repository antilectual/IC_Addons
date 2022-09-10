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
            g_SF.LevelChampByID( 56, 15, 7000, "{q}") ; level havi
        if(g_BrivUserSettings[ "Fkeys" ])
        {
            keyspam := g_SF.GetFormationFKeys(g_SF.Memory.GetActiveModronFormation()) ; level other formation champions
            keyspam.Push("{ClickDmg}")
            g_SF.DirectedInput(,release :=0, keyspam*) ;keysdown
        }
        g_SF.ModronResetZone := g_SF.Memory.GetModronResetArea() ; once per zone in case user changes it mid run.
        g_SF.Memory.ActiveEffectKeyHandler.Refresh()
        reqStacks := g_SF.CalculateBrivStacksLeftAtTargetZone(1, g_BrivUserSettings[ "MinStackZone" ] + 49 + 5) 
        if(reqStacks <= 49 )
            MsgBox, Stacking required to `continue event runs. Set modron core's reset area to min stack zone + 2 skips. Press `OK to `continue.
        else if(g_SF.ModronResetZone >= g_BrivUserSettings[ "MinStackZone" ])
            MsgBox, Stacking complete. Set modron back to 50.
        if (g_SF.ShouldDashWait())
            g_SF.DoDashWait( Max(g_SF.ModronResetZone - g_BrivUserSettings[ "DashWaitBuffer" ], 0) )
        g_SF.ToggleAutoProgress( 1, false, true )
    }
}

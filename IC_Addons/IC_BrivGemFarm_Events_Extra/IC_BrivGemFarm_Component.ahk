#include %A_LineFile%\..\IC_BrivGemFarm_Functions.ahk
class IC_BrivGemFarm_Events_Component
{
    InjectAddon()
    {
        splitStr := StrSplit(A_LineFile, "\")
        addonDirLoc := splitStr[(splitStr.Count()-1)]
        addonLoc := "#include *i %A_LineFile%\..\..\" . addonDirLoc . "\IC_BrivGemFarm_Addon.ahk`n"
        FileAppend, %addonLoc%, %g_BrivFarmModLoc%
    }
}
IC_BrivGemFarm_Events_Component.InjectAddon()
GuiControl, ICScriptHub: +cF18500, Warning_Imports_Bad,
GuiControl, ICScriptHub:Text, Warning_Imports_Bad, % "Warning: Events BrivGemFarm addon is currently enabled."
;Add GUI fields to Briv Gem Farm tab.
Gui, ICScriptHub:Tab, About
GuiControlGet, pos, ICScriptHub:Pos, VersionStringID
posY += aboutGroupBoxHeight
Gui, ICScriptHub:Add, Button, x15 y%posY% w160 vButtonOpenMemoryUpdaterGui gMemory_Updater_Launch, Check for Updates

Memory_Updater_Launch()
{
    memoryUpdaterLoc := A_LineFile . "\..\IC_MemoryUpdater_GUI.ahk"
    Run, %memoryUpdaterLoc%
    ExitApp
}
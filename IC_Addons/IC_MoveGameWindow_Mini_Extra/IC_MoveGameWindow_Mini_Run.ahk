#SingleInstance force
#NoTrayIcon
#Persistent

#include %A_LineFile%\..\IC_MoveGameWindow_Mini_Component.ahk
#include %A_LineFile%\..\..\..\SharedFunctions\ObjRegisterActive.ahk
#include %A_LineFile%\..\..\..\SharedFunctions\IC_SharedFunctions_Class.ahk

global g_MoveGameWindow_Mini := new IC_MoveGameWindow_Mini
global g_UserSettings := g_MoveGameWindow_Mini.SF.LoadObjectFromJSON(A_LineFile . "\..\..\..\settings.json")

g_MoveGameWindow_Mini.CreateTimedFunctions()
g_MoveGameWindow_Mini.StartTimedFunctions()

ObjRegisterActive(g_MoveGameWindow_Mini, A_Args[1])

ComObjectRevoke()
{
    ObjRegisterActive(g_MoveGameWindow_Mini, "")
    ExitApp
}
return

OnExit(ComObjectRevoke())



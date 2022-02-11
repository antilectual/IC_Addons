#SingleInstance force
#NoTrayIcon
#Persistent

#include %A_LineFile%\..\IC_MoveGameWindow_Mini_Component.ahk
#include %A_LineFile%\..\..\..\SharedFunctions\ObjRegisterActive.ahk
#include %A_LineFile%\..\..\..\SharedFunctions\IC_SharedFunctions_Class.ahk


global g_MoveGameWindow_Mini := new IC_MoveGameWindow_Mini

g_MoveGameWindow_Mini.CreateTimedFunctions()
g_MoveGameWindow_Mini.StartTimedFunctions()

ObjRegisterActive(g_MoveGameWindow_Mini, "{1007D57F-0EA0-402F-A30A-55972194009D}")

ComObjectRevoke()
{
    ObjRegisterActive(g_MoveGameWindow_Mini, "")
    ExitApp
}
return

OnExit(ComObjectRevoke())



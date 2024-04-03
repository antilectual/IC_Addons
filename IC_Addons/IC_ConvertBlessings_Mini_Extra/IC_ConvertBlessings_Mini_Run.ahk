#SingleInstance force
#NoTrayIcon
#Persistent

#include %A_LineFile%\..\IC_ConvertBlessings_Mini_Component.ahk
#include %A_LineFile%\..\..\..\SharedFunctions\ObjRegisterActive.ahk
#include %A_LineFile%\..\..\IC_Core\IC_SharedFunctions_Class.ahk
#include %A_LineFile%\..\..\..\ServerCalls\IC_ServerCalls_Class.ahk

global g_ConvertBlessings_Mini := new IC_ConvertBlessings_Mini

g_ConvertBlessings_Mini.CreateTimedFunctions()
g_ConvertBlessings_Mini.StartTimedFunctions()

ObjRegisterActive(g_ConvertBlessings_Mini, A_Args[1])

ComObjectRevoke()
{
    ObjRegisterActive(g_ConvertBlessings_Mini, "")
    ExitApp
}
return

OnExit(ComObjectRevoke())
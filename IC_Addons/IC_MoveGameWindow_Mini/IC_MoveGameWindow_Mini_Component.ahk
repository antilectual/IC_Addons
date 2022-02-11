g_Miniscripts["{1007D57F-0EA0-402F-A30A-55972194009D}"] := A_LineFile . "\..\IC_MoveGameWindow_Mini_Run.ahk"
class IC_MoveGameWindow_Mini
{
    SF := new IC_SharedFunctions_Class ; includes MemoryFunctions in g_SF.Memory

    __new() {
        this.SF := new IC_SharedFunctions_Class ; includes MemoryFunctions in g_SF.Memory
    }

    CreateTimedFunctions() {
        this.fncToCallOnTimer :=  ObjBindMethod(this, "MoveIdleDragonsWindow")
    }

    ; Starts functions that need to be run in a separate thread such as GUI Updates.
    StartTimedFunctions() {
        fncCall := this.fncToCallOnTimer
        SetTimer, %fncCall%, 2000, 0
    }

    Close() {
        ExitApp
    }

    MoveIdleDragonsWindow() {
        if((Hwnd := WinExist( "ahk_exe IdleDragons.exe" )) AND Hwnd != this.SF.Hwnd )
        {
                this.SF.Hwnd := Hwnd
                this.SF.Memory.OpenProcessReader()
                WinGetPos, X, Y, Width, Height, ahk_id %Hwnd%
                WinMove, A_ScreenWidth - (Width - 8), 0 ;A_ScreenHeight = 0 and top of the screen 
        }
    }
}
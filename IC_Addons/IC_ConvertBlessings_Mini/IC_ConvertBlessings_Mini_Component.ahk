g_Miniscripts["{CC6FC77B-2E35-494C-A28F-64226DFEE811}"] := A_LineFile . "\..\IC_ConvertBlessings_Mini_Run.ahk"

class IC_ConvertBlessings_Mini
{
    CreateTimedFunctions()
    {
        this.fncToCallOnTimer :=  ObjBindMethod(this, "ForcedConversionCheck")
    }

    ; Starts functions that need to be run in a separate thread such as GUI Updates.
    StartTimedFunctions()
    {
        fncCall := this.fncToCallOnTimer
        SetTimer, %fncCall%, 5000, 0
    }

    StopTimedFunctions()
    {
        fncCall := this.fncToCallOnTimer
        SetTimer, %fncCall%, Off
        SetTimer, %fncCall%, Delete
    }

    Close()
    {
        ExitApp
    }

    ForcedConversionCheck()
    {
        g_SF := new IC_SharedFunctions_Class ; includes MemoryFunctions in g_SF.Memory
        convertToBlessing := 1
        if (g_SF.Memory.GetForceConvertFavor())
        {
            MsgBox 4,, Forced Conversion Detected, Restart IC?
            IfMsgBox Yes
            {
                convertFromBlessing := g_SF.Memory.GetBlessingsCurrency()
                g_SF.ResetServerCall()
                g_SF.CloseIC("Forced Blessings Conversion Detected")
                g_ServerCall.CallConverCurrency(convertToBlessing, convertFromBlessing) 
                g_SF.SafetyCheck()
            }
            IfMsgBox No
                return
        }
    }
}


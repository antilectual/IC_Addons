g_Miniscripts["{CC6FC77B-2E35-494C-A28F-64226DFEE811}"] := A_LineFile . "\..\IC_ConvertBlessings_Mini_Run.ahk"

class IC_ConvertBlessings_Mini
{
    SF := new IC_SharedFunctions_Class ; includes MemoryFunctions in g_SF.Memory

    __new()
    {
        this.SF := new IC_SharedFunctions_Class ; includes MemoryFunctions in g_SF.Memory
    }

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

    Close()
    {
        ExitApp
    }

    ForcedConversionCheck()
    {
        convertToBlessing := 1
        this.SF.Memory.OpenProcessReader()
        if (this.SF.Memory.GetForceConvertFavor())
        {
            convertFromBlessing := g_SF.Memory.GetBlessingsCurrency()
            this.SF.ResetServerCall()
            this.SF.CloseIC("Forced Blessings Conversion Detected")
            ServerCall.CallConverCurrency(convertToBlessing, convertFromBlessing) 
            this.SF.SafetyCheck()
        }
    }
}


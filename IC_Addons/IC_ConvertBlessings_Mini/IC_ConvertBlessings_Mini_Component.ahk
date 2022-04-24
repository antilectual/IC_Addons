g_Miniscripts["{CC6FC77B-2E35-494C-A28F-64226DFEE811}"] := A_LineFile . "\..\IC_ConvertBlessings_Mini_Run.ahk"
global g_ServerCall
class IC_ConvertBlessings_Mini
{
    SF := new IC_SharedFunctions_Class ; includes MemoryFunctions in g_SF.Memory
    blessingToCovertTo := 1 ; Edit this to change blessing/favor chosen to convert to. 1 = Torm

    __new() {
        this.SF := new IC_SharedFunctions_Class ; includes MemoryFunctions in g_SF.Memory
    }

    CreateTimedFunctions() {
        this.fncToCallOnTimer :=  ObjBindMethod(this, "ForcedConversionCheck")
    }

    ; Starts functions that need to be run in a separate thread such as GUI Updates.
    StartTimedFunctions() {
        fncCall := this.fncToCallOnTimer
        SetTimer, %fncCall%, 5000, 0
    }

    Close() {
        ExitApp
    }

    ForcedConversionCheck() {
        this.SF.Memory.OpenProcessReader()
        if (this.SF.Memory.GetForceConvertFavor())
        {
            convertFromBlessing := this.SF.Memory.GetBlessingsCurrency()
            this.SF.CloseIC("Forced Blessings Conversion Detected")
            g_ServerCall.CallConverCurrency(this.blessingToCovertTo, convertFromBlessing) 
            this.SF.SafetyCheck()
        }
    }
}
local ENT = {}
ENT.Type = "anim"
ENT.Base = "Tstatus_base"

ENT.Ephemeral = true

TAccessorFuncDT(ENT, "Duration", "Float", 0)
TAccessorFuncDT(ENT, "StartTime", "Float", 4)
return ENT
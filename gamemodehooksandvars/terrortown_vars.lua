local GM = GM or GAMEMODE
local meta = FindMetaTable( "Player" )

--todo:write nw functions

meta.CanHavePalsy = true
meta.PalsyThreshold = 25
meta.PalsyStrengthMultiplier = 1

meta.CanBeKnockeddown = true
meta.FallingKnockdown = true
meta.FallingKnockdownDamageThreshold = 25
meta.FallingKnockdownDamageTimeMult = 0.05
meta.CanBeGoombad = true
meta.GoombaKnockdownDamageThreshold = 15
meta.GoombaKnockdownDamageTimeMult = 0.075


---knockdown triggers
hook.Add("PostEntityTakeDamage", "palsycheck", function(ent, dmginfo, took)
    if ent:IsPlayer() and ent:Alive() then
        if ent:Health() <= ent.PalsyThreshold and (ent:Health() - dmginfo:GetDamage()) > 0 then
            ent:GiveTStatus("palsy", -1 )
        end
    end
end)

hook.Add("OnPlayerHitGround", "fallknockdownandgoombacheck", function(ply, in_water, on_floater, speed)
    local damage = math.pow(0.05 * (speed - 420), 1.75)
    local isgoombing = ply:GetGroundEntity():IsPlayer() and ply:GetGroundEntity():IsPlayer() or false

    if isgoombing then
        local goomb = ply:GetGroundEntity()
        if goomb.CanBeGoombad and damage > goomb.GoombaKnockdownDamageThreshold and (goomb:Health() - damage)  > 0 then
            goomb:GiveTStatus("knockdown", damage * ply.GoombaKnockdownDamageTimeMult )
        end
        damage = damage / 3
    end

    if ply.CanBeKnockeddown and damage > ply.FallingKnockdownDamageThreshold and (ply:Health() - damage) > 0 then
            ply:GiveTStatus("knockdown", damage * ply.FallingKnockdownDamageTimeMult )
    end
end)
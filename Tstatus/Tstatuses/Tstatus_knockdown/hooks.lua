hook.Add( "OnPlayerHitGround", "FallKnockdown", function(ply, in_water, on_floater, speed)
    --this is the fall damage code from TTT 
    local damage = math.pow(0.05 * (speed - 420), 1.75)
    if damage > GAMEMODE.FallKnockdownThreshold then
        ply:GiveTStatus("knockdown",damage * 0.05)
    end
end )
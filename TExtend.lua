--This file holds all the shit that is necessary for Tstatuses to work properly without overwriting existing gamemode functions.

local meta = FindMetaTable("Player")

if SERVER then

    function TAccessorFuncDT(tab, membername, type, id)
        local emeta = FindMetaTable("Entity")
        local setter = emeta["SetDT"..type]
        local getter = emeta["GetDT"..type]
    
        tab["Set"..membername] = function(me, val)
            setter(me, id, val)
        end
    
        tab["Get"..membername] = function(me)
            return getter(me, id)
        end
    end

    function meta:RemoveEphemeralTStatuses()
        for _, status in pairs(ents.FindByClass("Tstatus_*")) do
            if status.Ephemeral and status:IsValid() and status:GetOwner() == self then
                status:Remove()
            end
        end
    end

    function meta:RemoveAllTStatus(bSilent, bInstant)
        if bInstant then
            for _, ent in pairs(ents.FindByClass("Tstatus_*")) do
                if not ent.NoRemoveOnDeath and ent:GetOwner() == self then
                    ent:Remove()
                end
            end
        else
            for _, ent in pairs(ents.FindByClass("Tstatus_*")) do
                if not ent.NoRemoveOnDeath and ent:GetOwner() == self then
                    ent.SilentRemove = bSilent
                    ent:SetDie()
                end
            end
        end
    end
    
    function meta:RemoveTStatus(sType, bSilent, bInstant, sExclude)
        local removed
        for _, ent in pairs(ents.FindByClass("Tstatus_"..sType)) do
            if ent:GetOwner() == self and not (sExclude and ent:GetClass() == "Tstatus_"..sExclude) then
                if bInstant then
                    ent:Remove()
                else
                    ent.SilentRemove = bSilent
                    ent:SetDie()
                end
                removed = true
            end
        end
        return removed
    end

    function meta:GetTStatus(sType)
        local ent = self["Tstatus_"..sType]
        if ent and ent:IsValid() and ent:GetOwner() == self then return ent end
    end 

    function meta:GiveTStatus(sType, fDie, giver)
        local cur = self:GetTStatus(sType)
        if cur then
            if fDie then
                cur:SetDie(fDie)
            end
            cur:SetPlayer(self, true)
            return cur
        else
            local ent = ents.Create("Tstatus_"..sType)
            if ent:IsValid() then
                ent:Spawn()
                if giver then
                    ent.Giver = giver
                end
                if fDie then
                    ent:SetDie(fDie)
                end
                ent:SetPlayer(self)
                return ent
            end
        end
    end
    
    hook.Add("DoPlayerDeath", "RemoveEphemeralTstatuses", function(ply)
        ply:RemoveEphemeralStatuses()
    end)

end

if CLIENT then

    --don't ask questions...
    function TAccessorFuncDT(tab, membername, type, id)
        local emeta = FindMetaTable("Entity")
        local setter = emeta["SetDT"..type]
        local getter = emeta["GetDT"..type]
    
        tab["Set"..membername] = function(me, val)
            setter(me, id, val)
        end
    
        tab["Get"..membername] = function(me)
            return getter(me, id)
        end
    end

    function meta:RemoveAllTStatus(bSilent, bInstant)
    end
    
    function meta:RemoveTStatus(sType, bSilent, bInstant, sExclude)
    end

    function meta:GetTStatus(sType)
        local ent = self["Tstatus_"..sType]
        if ent and ent:GetOwner() == self then return ent end
    end

    function meta:GiveTStatus(sType, fDie)
    end

end
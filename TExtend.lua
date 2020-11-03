--This file holds all the shit that is necessary for Tstatuses to work properly without overwriting existing gamemode functions.
local GM = GM or GAMEMODE
local game = engine.ActiveGamemode()
local foldername = GM.FolderName
local path = foldername.."/gamemode/tropical-core/gamemodehooksandvars/"

if game == foldername then
    if file.Exists(path..foldername.."_hooks.lua","LUA") and file.Exists(path..foldername.."_vars.lua","LUA") then
        AddCSLuaFile(path..foldername.."_vars.lua")
        AddCSLuaFile(path..foldername.."_hooks.lua")
        include(path..foldername.."_vars.lua")
        include(path..foldername.."_hooks.lua")
    end
end

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
        for _, status in pairs(ents.FindByClass("tstatus_*")) do
            if status.Ephemeral and status:IsValid() and status:GetOwner() == self then
                status:Remove()
            end
        end
    end

    function meta:RemoveAllTStatus(bSilent, bInstant)
        if bInstant then
            for _, ent in pairs(ents.FindByClass("tstatus_*")) do
                if not ent.NoRemoveOnDeath and ent:GetOwner() == self then
                    ent:Remove()
                end
            end
        else
            for _, ent in pairs(ents.FindByClass("tstatus_*")) do
                if not ent.NoRemoveOnDeath and ent:GetOwner() == self then
                    ent.SilentRemove = bSilent
                    ent:SetDie()
                end
            end
        end
    end
    
    function meta:RemoveTStatus(sType, bSilent, bInstant, sExclude)
        local removed
        for _, ent in pairs(ents.FindByClass("tstatus_"..sType)) do
            if ent:GetOwner() == self and not (sExclude and ent:GetClass() == "tstatus_"..sExclude) then
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
        local ent = self["tstatus_"..sType]
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
            local ent = ents.Create("tstatus_"..sType)
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
        ply:RemoveEphemeralTStatuses()
    end)

end

if CLIENT then

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
        local ent = self["tstatus_"..sType]
        if ent and ent:GetOwner() == self then return ent end
    end

    function meta:GiveTStatus(sType, fDie)
    end

end

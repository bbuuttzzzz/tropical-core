local gamemode = engine.ActiveGamemode()
local path = GM.FolderName.. "/gamemode/tropical-core/Tstatus/TstatusRegistry/"..gamemode..".lua"
if file.Exists(path, "LUA") then include(path) else return false end

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

local meta = FindMetaTable("Player")

if CLIENT then
	function meta:GetTStatus(sType)
		local ent = self["Tstatus_"..sType]
		if ent and ent:GetOwner() == self then return ent end
	end

	function meta:GiveTStatus(sType, fDie)
	end
end

if SERVER then
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
end
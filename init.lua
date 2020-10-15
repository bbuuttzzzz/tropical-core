--####################
-- Clientside AddCSLua
--####################
AddCSLuaFile("cl_gui.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("sh_serialization.lua")

-- panel
AddCSLuaFile("panel/pBrickGrid.lua")

-- mapvote
AddCSLuaFile("mapvote/cl_mapvote.lua")
AddCSLuaFile("mapvote/sh_mapvote.lua")
AddCSLuaFile("mapvote/pmapvote.lua")

--###################
-- Serverside Include
--###################
include("sh_serialization.lua")

-- mapvote
include("mapvote/sh_mapvote.lua")
include("mapvote/sv_mapvote.lua")

-- When the player passed the postentity step, call PlayerReady
concommand.Add("initpostentity", function(sender, command, arguments)
	if not sender.DidInitPostEntity then
		sender.DidInitPostEntity = true

		gamemode.Call("PlayerReady", sender)
	end
end)

-- This function is called whenever the player is ready to play after joining
function GM:PlayerReady(pl)
	self:PlayerReadyMapTable(pl)
end

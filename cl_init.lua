--###################
-- Clientside Include
--###################

include("cl_gui.lua")
include("sh_serialization.lua")

-- panel
include("panel/pBrickGrid.lua")

-- mapvote
include("mapvote/sh_mapvote.lua")
include("mapvote/cl_mapvote.lua")
include("mapvote/pmapvote.lua")

-- when the player is PostEntity, inform the server
hook.Add("InitPostEntity", "GetLocal", function()
	GAMEMODE.HookGetLocal = GAMEMODE.HookGetLocal or function(g) end
	gamemode.Call("HookGetLocal", LocalPlayer())
	RunConsoleCommand("initpostentity")
end)

include("Tstatus_sharedutil.lua")

local entitiespath = GM.FolderName.."/gamemode/tropical-core/Tstatus/Tstatuses/"
local files,folders = file.Find(entitiespath.."*","LUA")

for _,foldername in pairs(folders) do
    local ENT = {}
   	local ENTFolder = entitiespath..foldername

    if file.Exists(ENTFolder.."/init.lua", "LUA") and SERVER then
        table.Merge(ENT,include(ENTFolder.."/init.lua"))
    end
    
    if file.Exists(ENTFolder.."/cl_init.lua", "LUA") then
        if SERVER then
            AddCSLuaFile(ENTFolder.."/cl_init.lua")
        else
            table.Merge(ENT,include(ENTFolder.."/cl_init.lua"))
        end
    end
    
    if file.Exists(ENTFolder.."/shared.lua", "LUA") then
        if SERVER then
            AddCSLuaFile(ENTFolder.."/shared.lua", "LUA")
        end
        table.Merge(ENT,include(ENTFolder.."/shared.lua", "LUA"))
    end
    
    scripted_ents.Register(ENT,foldername)
    PrintTable(ENT, 1)
    if SERVER then
        if file.Exists(ENTFolder.."/hooks.lua", "LUA") then
            include(ENTFolder.."/hooks.lua")
        end
    end
end
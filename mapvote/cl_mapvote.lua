MAPTAG_COLORS = {
  [MAPTAG_BARRICADE] = Color(70,200,200,255),
  [MAPTAG_RUN_AND_GUN] = Color(70,70,200,255)
}
MAPTAG_GROUP_COLORS = {
  [MAPTAGGROUP_SIZE] = Color(200,200,70,255),
  [MAPTAGGROUP_MESH] = Color(200,200,200,255),
  [MAPTAGGROUP_SCALE] = Color(200,70,70,255)
}

GM.MapTable = {}

function GM:GetMapTagColor(tag)
  return MAPTAG_COLORS[tag] or MAPTAG_GROUP_COLORS[self:GetMapTagGroup(tag)] or Color(255,0,255,255)
end

net.Receive("trop_map_table_init", function(length)
  local table = net.ReadTable()

  GAMEMODE.MapTable = table
end)

net.Receive("trop_votemap_start", function(length)
	GAMEMODE:OpenMapVote()
end)

net.Receive("trop_votemap_update", function(length)
  if not GAMEMODE.MapVotes then GAMEMODE.MapVotes = {} end

  local updateCount = net.ReadUInt(8)

  for n = 1, updateCount do
    GAMEMODE.MapVotes[net.ReadString()] = net.ReadUInt(16)
  end

  GAMEMODE:UpdateMapVoteCounts()
end)

net.Receive("trop_forcemap_open", function(length)
  GAMEMODE:OpenForceMap()
end)

MAPTAG_SIZE_HUGE = 1
MAPTAG_SIZE_BIG = 2
MAPTAG_SIZE_MEDIUM = 3
MAPTAG_SIZE_SMALL = 4
MAPTAG_SIZE_TINY = 5
MAPTAG_MESH_NO = 6
MAPTAG_MESH_YES = 7
MAPTAG_BARRICADE = 8
MAPTAG_RUN_AND_GUN = 9
MAPTAG_CLOSED = 10
MAPTAG_OPEN = 11
MAPTAG_NAMES = {
  [MAPTAG_SIZE_HUGE] = "Huge",
  [MAPTAG_SIZE_BIG] = "Big",
  [MAPTAG_SIZE_MEDIUM] = "Medium",
  [MAPTAG_SIZE_SMALL] = "Small",
  [MAPTAG_SIZE_TINY] = "Tiny",
  [MAPTAG_MESH_NO] = "No Navmesh",
  [MAPTAG_MESH_YES] = "Navmesh",
  [MAPTAG_BARRICADE] = "Barricade Friendly",
  [MAPTAG_RUN_AND_GUN] = "Run-and-Gun Friendly",
  [MAPTAG_CLOSED] = "Lots of Dead-ends",
  [MAPTAG_OPEN] = "Few Dead-ends"
}
MAPTAG_SIGNATURES = {
  [MAPTAG_SIZE_HUGE] = "huge",
  [MAPTAG_SIZE_BIG] = "big",
  [MAPTAG_SIZE_MEDIUM] = "medium",
  [MAPTAG_SIZE_SMALL] = "small",
  [MAPTAG_SIZE_TINY] = "tiny",
  [MAPTAG_MESH_NO] = "no_navmesh",
  [MAPTAG_MESH_YES] = "navmesh",
  [MAPTAG_BARRICADE] = "barricade",
  [MAPTAG_RUN_AND_GUN] = "run_and_gun",
  [MAPTAG_CLOSED] = "closed",
  [MAPTAG_OPEN] = "open"
}

--maptags in the same group are disjoint: one map can't be both huge and tiny.
MAPTAGGROUP_SIZE = 1
MAPTAGGROUP_MESH = 2
MAPTAGGROUP_SCALE = 3
MAPTAG_GROUPS = {
  [MAPTAGGROUP_SIZE] = {
    [MAPTAG_SIZE_HUGE] = true,
    [MAPTAG_SIZE_BIG] = true,
    [MAPTAG_SIZE_MEDIUM] = true,
    [MAPTAG_SIZE_SMALL] = true,
    [MAPTAG_SIZE_TINY] = true
  },
  [MAPTAGGROUP_MESH] = {
    [MAPTAG_MESH_NO] = true,
    [MAPTAG_MESH_YES] = true
  },
  [MAPTAGGROUP_SCALE] = {
    [MAPTAG_CLOSED] = true,
    [MAPTAG_OPEN] = true
  }
}


function GM:GetMapTagGroup(tag)
  for groupIndex, group in pairs(MAPTAG_GROUPS) do
    if group[tag] then return groupIndex end
  end
end

function GM:DeserializeMapList(contents)
  contents = Deserialize(contents)

  if not contents then
    print("error: failed to deserialize")
    return {}
  end

  return contents
end

TROPICAL_MAP_VOTE_TIME = 20
MAP_TABLE_FILENAME_DEFAULT = "tropicalmaptable.txt"
GM.MapNominations = {}
util.AddNetworkString("trop_votemap_start")
util.AddNetworkString("trop_votemap_update")
util.AddNetworkString("trop_forcemap_open")
util.AddNetworkString("trop_map_table_init")

function GM:TropicalLoadNextMap()
  self.MapVoteInProgress = true
  self.MapVotes = {}

  timer.Simple(TROPICAL_MAP_VOTE_TIME, function()
    self:PostLoadNextMap()
  end)
  timer.Simple(TROPICAL_MAP_VOTE_TIME + 1, function()
    RunConsoleCommand("changelevel", self.WinningMap or game.GetMap())
  end)
  timer.Simple(TROPICAL_MAP_VOTE_TIME + 2, function()
    RunConsoleCommand("changelevel", game.GetMap())
  end)

  --tell everyone it's time to votemap
  net.Start("trop_votemap_start")
  net.Broadcast()
end

function GM:PostLoadNextMap()
  --first get the map that one
  local votes = GAMEMODE:CountVotesForMaps()

  local winner
  local winnerVotes = 0
  for map, num in pairs(votes) do
    if num > winnerVotes then
      winner = map
      winnerVotes = num
    end
  end

  self.WinningMap = winner
end

function GM:PlayerVotedForMap(voter, mapName)
  if not self.MapVoteInProgress or not voter or not mapName then return end

  local oldvote = self.MapVotes[voter]

  self.MapVotes[voter] = mapName

  net.Start("trop_votemap_update")
    net.WriteUInt(oldvote and 2 or 1, 8)
    net.WriteString(mapName)
    net.WriteUInt(self:CountVotesForMap(mapName),16)
    if oldvote then
      net.WriteString(oldvote)
      net.WriteUInt(self:CountVotesForMap(oldvote),16)
    end
  net.Broadcast()
end

function GM:CountVotesForMap(mapName)
  local count = 0
  for voter, map in pairs(self.MapVotes) do
    if mapName == map then
      count = count + 1
    end
  end
  return count
end

function GM:CountVotesForMaps()
  local counts = {}
  for voter, map in pairs(self.MapVotes) do
    counts[map] = (counts[map] or 0) + 1
  end

  return counts
end

function GM:LogVotes()
    local votes = self:CountVotesForMaps()
    print("# MAP VOTES ####################")
    for map, count in pairs(votes) do
        print(map .. " with " .. count .. " votes")
    end
    print("################################")
end

--don't really have a reason to make a bunch of changes to the map list
--it's cool to just load the list in the rare case that we need it
function GM:LoadMapList()
  if not file.Exists(MAP_TABLE_FILENAME or MAP_TABLE_FILENAME_DEFAULT, "DATA") then
    print("error: map table file not found")
    return {}
  end

  local contents = file.Read(MAP_TABLE_FILENAME or MAP_TABLE_FILENAME_DEFAULT, "DATA")
  if not contents or #contents <= 0 then
    print("error: map table file empty / failed to read")
    return {}
  end

  contents = Deserialize(contents)
  if not contents then
    print("error: failed to deserialize")
    return {}
  end

  return contents
end

function GM:SaveMapList(maplist)
  file.CreateDir(string.GetPathFromFilename(MAP_TABLE_FILENAME or MAP_TABLE_FILENAME_DEFAULT))
  file.Write(MAP_TABLE_FILENAME or MAP_TABLE_FILENAME_DEFAULT, Serialize(maplist))
end

function GM:FixMapListTags()
  local maplist = self:LoadMapList()
  for mapname, maptab in pairs(maplist) do
    table.sort(maptab.tags)
  end
  self:SaveMapList(maplist)
end

function GM:AddMapToList(mapname, tagTable)
  local maplist = self:LoadMapList()
  print(table.ToString(maplist))
  if not tagTable then
    tagTable = {}
  end

  table.sort(tagTable,function(a,b) return a < b end)

  maplist[mapname] = {
    tags = tagTable
  }

  print("\n\n\n")
  print(table.ToString(maplist))
  self:SaveMapList(maplist)
end

function GM:ValidateTags(tagTable)
  local groups = {}  --a list of seen groups

  --for every tag on the list
  for i, tag in ipairs(tagTable) do
    --and every group on the list
    for k, group in ipairs(MAPTAG_GROUPS) do
      --if this tag belongs to this group
      if group[tag] then
        --if we have already seen this group
        if groups[group] then
          --duplicate tag. exit.
          return false
        end
        --we haven't seen this group yet, so add it to the groups we've seen
        groups[group] = true

        --we found the group for this tag, so exit
        break
      end
    end
  end

  return true
end

function GM:AddMapTag(mapname, newTag)
  local maplist = self:LoadMapList()
  local mapTable = maplist[mapname]
  if not mapTable then return end

  --see if we already have a tag in the same group
  local tagGroup = self:GetMapTagGroup(newTag)
  local foundTag = false
  for i, tag in ipairs(mapTable.tags) do
    if MAPTAG_GROUPS[tagGroup][tag] then
      --assume our table doesn't already have 2 same-grouped tags
      --so we found the only wrong tag
      mapTable.tags[i] = newTag
      foundTag = true
      break
    end
  end

  --if we didnt find a conflicting tag just add this tag
  if not foundTag then
    table.insert(mapTable.tags,newTag)
  end

  table.sort(mapTable.tags,function(a,b) return a < b end)

  self:SaveMapList(maplist)
end

function GM:RemoveMapTag(mapname, removeTag)
  local maplist = self:LoadMapList()
  local mapTable = maplist[mapname]

  for i, tag in ipairs(mapTablet.tags) do
    if tag == removeTag then
      table.remove(mapTable.tags,i)
      return true
    end
  end
  return false
end

function GM:NominateMap(mapname, nominator)
  --too many nominations, return.
  if #self.MapNominations >= self.MaxNominations then return false end

  local noms = 0
  for k, v in ipairs(self.MapNominations) do
    if v.mapname == mapname then
      --duplicate map. return
      return false
    end
    if nominator and v.nominator == nominator then
      noms = noms + 1
      if noms >= self.MaxPlayerNominations then
        --too many nominations from this player, return
        return false
      end
    end
  end

  self.MapNominations[#self.MapNominations+1] = {
    mapname = mapname,
    nominator = nominator
  }
end

function GM:ChooseVoteMaps(tempMapList)
  local maps = {}
  tempMapList = tempMapList or self:LoadMapList() --do NOT re-save this list!!!

  --start with however many nominations there were
  for k, v in ipairs(self.MapNominations) do
    if #maps > self.MaxNominations or #maps > self.VoteMapCount then
      --ran out of nomination slots, or ran out of map vote slots
      --ignore the rest
      break
    end

    --if this is a real map, then just add it
    if tempMapList[v.mapname] then
      maps[#maps+1] = v.mapname
      tempMapList[v.mapname] = nil
    end
  end

  --grab the rest of the entries from the table (the nominated maps are excluded)
  local n = table.Count(tempMapList) --number of maps in the list
  local k = self.VoteMapCount - #maps --number of maps to pick from the list

  --pick k random entries from tempMapList[1..n] with no repeats
  --------------------------------------------------------------

  --change tempMapList from table = {mapName, mapTable} to {i, mapName}
  local i = 1
  local orderedMapList = {}
  for mapName, mapTable in pairs(tempMapList) do
    orderedMapList[i] = mapName
    i = i + 1
  end

  --shuffle that table
  for i = n, 2, -1 do
    local j = math.random(1,i-1)
    local temp = orderedMapList[i]
    orderedMapList[i] = orderedMapList[j]
    orderedMapList[j] = temp
  end

  --pick the, now random, first k elements
  for i = 1, k do
    maps[#maps + 1] = orderedMapList[i]
  end

  return maps
end

function GM:PlayerReadyMapTable(pl)
  local table = self:LoadMapList()

  net.Start("trop_map_table_init")
    net.WriteTable(table)
  net.Send(pl)
end

function GM:IsMapEnabled(mapname)
  local maplist = self:LoadMapList()

  if maplist[mapname] then return true end

  return false
end

concommand.Add("trop_votemap", function(sender, command, arguments)
	GAMEMODE:PlayerVotedForMap(sender,arguments[1])
end)

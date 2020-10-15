local mapvotex = 1620
local mapvotey = 900

local mapx = 520
local mapy = 160

local mapiconx = 160
local mapicony = 120

MAP_COLORS_HOVERED = 1
MAP_COLORS_VOTE = 2
MAP_COLORS = {
  [0] = Color(50,50,50,255),
  [MAP_COLORS_HOVERED] = Color(100,100,100,255),
  [MAP_COLORS_VOTE] = Color(50,100,50,255),
  [MAP_COLORS_VOTE + MAP_COLORS_HOVERED] = Color(125,200,125,255)
}


local function DrawMapIcon(parent, mapname)
  local pan = vgui.Create( "DImage", parent)

  if file.Exists("tropical/mapicons/" .. mapname .. ".jpg","DATA") then
    --we already have this icon, so just draw it
    local mat = Material("data/tropical/mapicons/" ..mapname .. ".jpg")
    pan:SetMaterial(mat)
  else
    --first check if the github has the icon
    local githuburl = "https://kklluuttzz.github.io/tropical-map-icons/" .. mapname .. ".jpg"
    http.Fetch(githuburl,function(body, size, headers, code)
      if code < 400 then
        print("found icon for " .. mapname .. " on the github")
        file.CreateDir("tropical/mapicons")
        file.Write("tropical/mapicons/" .. mapname .. ".jpg",body)

        local mat = Material("data/tropical/mapicons/" ..mapname .. ".jpg")
        pan:SetMaterial(mat)
      else
        --couldnt find it on the github, try gametracker
        local gametrackerurl = "https://image.gametracker.com/images/maps/160x120/garrysmod/" .. mapname .. ".jpg"
        http.Fetch(gametrackerurl,function(body, size, headers, code)
          if code < 400 then
            print("found icon for " ..  mapname .. " on gametracker")
            file.CreateDir("tropical/mapicons")
            file.Write("tropical/mapicons/" .. mapname .. ".jpg",body)

            local mat = Material("data/tropical/mapicons/" ..mapname .. ".jpg")
            pan:SetMaterial(mat)
          else
            --couldn't find it anywhere, give it a boring thumb
            print("couldnt find an icon for " .. mapname .. ". gave boring thumb")
            local mat = Material("materials/tropical/nomapthumb.jpg")
            pan:SetMaterial(mat)
          end
        end)
      end
    end)
  end

  return pan
end

function GM:OpenMapVote()
  if self.MapVotePanel and self.MapVotePanel:IsValid() then
    if debug then
      self.MapVotePanel:Remove()
    else
      self.MapVotePanel:SetVisible(true)
      self.MapVotePanel:CenterMouse()
      return
    end
  end
  if not self.MapVotes then self.MapVotes = {} end

  self.MapVotePanel = self:MakeMapViewer("Vote for a Map", function(entryTab)
    RunConsoleCommand("trop_votemap",entryTab.MapName)
  end)

  self:UpdateMapVoteCounts()
end

function GM:OpenForceMap()
  local viewer
  viewer = self:MakeMapViewer("Click to change to map", function(entryTab)
    RunConsoleCommand("ulx","forcemap",entryTab.MapName)
    viewer:Remove()
  end)
end

function GM:UpdateMapVoteCounts()
  if not self.MapVotePanel or not self.MapVotePanel.MapEntries or not self.MapVotes then return end

  --get total amount of votes
  local numVotes = 0
  for map, votes in pairs(self.MapVotes) do
    numVotes = numVotes + votes
  end

  -- update fraction of votes for each map
  for map, tab in pairs(self.MapVotePanel.MapEntries) do
    tab.VoteFrac = (numVotes == 0) and 0 or (self.MapVotes[map] or 0) / numVotes
  end
end

function GM:MakeMapViewer(topText, ClickCallBack)
  --ClickCallBack called like ClickCallBack(entryTab)

  local scale = 1
  local wid, hei = scale * mapvotex, scale * mapvotey

  local color_unhovered = Color(0,0,0,200)
  local color_hovered = Color(100,100,100,200)

  --create the big box
  local frame = vgui.Create("DFrame")
  frame:SetSize(wid, hei)
  frame:Center()
  frame:SetDeleteOnClose(false)
  frame:SetTitle(" ")
  frame:SetDraggable(false)
  if frame.btnClose and frame.btnClose:IsValid() then frame.btnClose:SetVisible(false) end
  if frame.btnMinim and frame.btnMinim:IsValid() then frame.btnMinim:SetVisible(false) end
  if frame.btnMaxim and frame.btnMaxim:IsValid() then frame.btnMaxim:SetVisible(false) end
  frame.CenterMouse = ShopMenuCenterMouse
  frame.OnKeyCodePressed = function(self, keycode)
    local bind = input.LookupKeyBinding(keycode) or ""
    if string.match(bind,"gm_showhelp") or string.match(bind,"+menu") then
      frame:Remove()
    end
  end
  frame:MakePopup()

  --create top part
  local topSpaceHeight = 70
  local topSpace = vgui.Create("DPanel", frame)
  topSpace:SetWide(wid - 20 * scale)
  topSpace:SetTall(topSpaceHeight * scale)
  topSpace:AlignTop(10 * scale)
  topSpace:CenterHorizontal()
  topSpace.Paint = function(self, w, h)
    surface.SetDrawColor(color_unhovered)
    surface.DrawRect(0, 0, w, h)
  end

  --add text to the top part
  local textLabel = EasyLabel(topSpace,topText,"tcore_small",COLOR_WHITE)
  textLabel:CenterHorizontal()
  textLabel:CenterVertical()

  --create the close button
  local button = EasyButton(topSpace, "X", 8, 4)
  button:SetFont("tcore_small")
  button:SizeToContents()
  button.DoClick = function()
    frame:Remove()
  end
  button:AlignLeft(10 * scale)
  button:CenterVertical()
  frame.CloseButton = button

  --build the map window
  local mapsWindow = vgui.Create("DPanel",frame)
  mapsWindow:SetSize((mapvotex - 20) * scale,(mapvotey - topSpaceHeight - 20) * scale)
  mapsWindow.Paint = function(self, w, h)
    surface.SetDrawColor(color_unhovered)
    surface.DrawRect(0, 0, w, h)
  end
  mapsWindow:AlignBottom( 10 * scale )
  mapsWindow:CenterHorizontal() --( 5 * scale)

  --draw a DScrollPanel
  local scrollPanel = vgui.Create("DScrollPanel", mapsWindow)
  scrollPanel:Dock( FILL )
  --change how the bar looks
  local sbar = scrollPanel:GetVBar()
  local paint = function(self, w, h)
    surface.SetDrawColor(MAP_COLORS[MAP_COLORS_HOVERED  ])
    surface.DrawRect(0, 0, w, h)
  end
  function sbar.Paint() end
  sbar.btnUp.Paint = paint
  sbar.btnDown.Paint = paint
  sbar.btnGrip.Paint = paint

  --make grid
  local itemGrid = vgui.Create("DGrid", scrollPanel)
  itemGrid:SetPos(5 * scale,0)
  itemGrid:SetCols(3)
  itemGrid:SetColWide((mapx + 5) * scale)
  itemGrid:SetRowHeight((mapy + 5) * scale)

  local mapEntries = {}
  frame.MapEntries = mapEntries
  print(self.MapTable)
  for mapname, mapTab in pairs(self.MapTable) do
    --draw the background
    local base = vgui.Create("DPanel")
    base:SetSize( mapx * scale, mapy * scale )
    base.MapTable = mapTab
    base.MapName = mapname
    base.VoteFrac = 0
    base.Paint = function(self, w, h)
      local split = w * self.VoteFrac
      print(split)
      local hovered = self.Button:IsHovered()
      surface.SetDrawColor(MAP_COLORS[MAP_COLORS_VOTE + (hovered and MAP_COLORS_HOVERED or 0)])
      surface.DrawRect(0, 0, split, h)
      surface.SetDrawColor(MAP_COLORS[hovered and MAP_COLORS_HOVERED or 0])
      surface.DrawRect(split, 0, w-split, h)
    end
    itemGrid:AddItem(base)

    --draw the map window
    local mapIcon = DrawMapIcon(base, mapname)
    mapIcon:SetSize(mapiconx * scale,mapicony * scale)
    mapIcon:SetPos(5 * scale, 5 * scale)

    --draw the name below
    local nameTag = EasyLabel(base,mapname,"tcore_smallest", COLOR_WHITE)
    nameTag:SetContentAlignment(5)
    nameTag:SizeToContents()
    nameTag:AlignLeft( 5 * scale )
    nameTag:AlignBottom( 5 * scale)

    --draw the tag list
    local gridx = 35
    local tagGrid = vgui.Create("DBrickGrid",base)
    tagGrid:SetSize((mapx - mapiconx - 20) * scale, (mapy - 10) * scale)
    tagGrid:AlignTop(10 * scale)
    tagGrid:AlignRight(5 * scale)
    tagGrid:SetRowHeight(gridx * scale)
    tagGrid:SetSpacing(5 * scale)
    for i, tag in ipairs(mapTab.tags) do
      local tagFrame = vgui.Create("DPanel")
      tagFrame.Color = self:GetMapTagColor(tag)
      tagFrame.Paint = function(self, w, h)
        draw.RoundedBox(4,0,0,w,h,self.Color)
        draw.RoundedBox(4,1,1,w-2,h-2,MAP_COLORS[0])
      end
      tagFrame:SetTall((gridx - 5) * scale)

      local tagText = EasyLabel(tagFrame,MAPTAG_NAMES[tag] or "!badtag!","tcore_smallest",COLOR_WHITE)
      tagText:SizeToContents()
      tagText:CenterVertical()
      tagText:AlignLeft(5 * scale)
      tagFrame:SizeToChildren(true, false)
      tagFrame:SetWide(tagFrame:GetWide() + 10 * scale)

      tagGrid:AddItem(tagFrame)
    end

    --draw the button on top
    local button = vgui.Create("DButton", base)
    button:SetText("")
    button:Dock( FILL )
    button:SetZPos(1) --make sure this gets put above the map icon
    button.Paint = function(self, w, h)
    end
    button.DoClick = function()
      ClickCallBack(base)
    end
    base.Button = button

    mapEntries[mapname] = base
  end

  return frame
end

function GM:CloseMapVote()
  if not self.MapVotePanel then return end

  self.MapVotePanel:Remove()
end

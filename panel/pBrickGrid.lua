local BGRID = {}

function BGRID:Init()
	self.Items = {}
	self.InsertX = 0
	self.CurrentRow = 1
	self.Spacing = 0
end

local function PlaceFrame(self, frame)
	--first, check if there is room in this row for this frame
	if self.InsertX + frame:GetWide() > self:GetWide() then
		self.CurrentRow = self.CurrentRow + 1
		self.InsertX = 0
	end

	frame:SetPos(self.InsertX,self.RowHeight * (self.CurrentRow - 1))
	self.InsertX = self.InsertX + frame:GetWide() + self.Spacing
end

local function FixLayout(self)
	self.CurrentRow = 1
	self.InsertX = 0
	for i, frame in ipairs(self.Items) do
		PlaceFrame(self,frame)
	end
end

function BGRID:AddItem(frame)
	frame:SetParent(self)
	self.Items[#self.Items] = frame

	PlaceFrame(self,frame)
end

function BGRID:SetRowHeight(h)
	self.RowHeight = h
end

function BGRID:SetSpacing(s)
	self.Spacing = s
end

function BGRID:Paint(w, h)
end

vgui.Register("DBrickGrid", BGRID, "Panel")

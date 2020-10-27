-- tcore_* fonts
-- these replace ZSHUD fonts for the quick and dirty hud replacement
-- we will probably replace these later

surface.CreateFont("tcore_smallest", {font = "Trebuchet24", size = 28, weight = 1000})
surface.CreateFont("tcore_small", {font = "Trebuchet24", size = 36, weight = 1000})

-- This is a noxZS function
-- EasyLabel - Creates a panel with specified text on it
--- parent: the panel to parent the label to
--- text: a string to put on the label
--- font: the font to use
--- textcolor: the color
function EasyLabel(parent, text, font, textcolor)
	local dpanel = vgui.Create("DLabel", parent)
	if font then
		dpanel:SetFont(font or "DefaultFont")
	end
	dpanel:SetText(text)
	dpanel:SizeToContents()
	if textcolor then
		dpanel:SetTextColor(textcolor)
	end
	dpanel:SetKeyboardInputEnabled(false)
	dpanel:SetMouseInputEnabled(false)

	return dpanel
end

-- This is a noxZS function
function EasyButton(parent, text, xpadding, ypadding)
	local dpanel = vgui.Create("DButton", parent)
	if textcolor then
		dpanel:SetFGColor(textcolor or color_white)
	end
	if text then
		dpanel:SetText(text)
	end
	dpanel:SizeToContents()

	if xpadding then
		dpanel:SetWide(dpanel:GetWide() + xpadding * 2)
	end

	if ypadding then
		dpanel:SetTall(dpanel:GetTall() + ypadding * 2)
	end

	return dpanel
end

----------------------------------------- Data ----------------------------------------	

local ItemCount = 0; local TotalILevel = 0; local AVGILevel = 0;
local RED = 1; local GREEN = 1; local BLUE = 1;										-- Set color to White


----------------------------------------- Events ----------------------------------------
	
local function IL_Events(IL_self, IL_EventName)
		GetItemLevel()
		txtColor()
		Ilevelnr:SetFormattedText("%.1f", AVGILevel); Ilevelnr:SetTextColor(RED, GREEN, BLUE, 1)
end


----------------------------------------- Get Item Level ----------------------------------------

function GetItemLevel()
ItemCount = 0; TotalILevel = 0; AVGILevel = 0;										-- Reset variables

	for i = 1,18 do																	-- 1 to 19 = Items in inventory (4 = Shirt, 19 = Tarbard, we don't want those)
		if not ( i == 4 )then														-- Loop 18 times, but skip 4, so it will only loop 17 times.
			if (GetInventoryItemLink("player", i)) then                             -- Check if there is item in the slot, if true continue. (WoW API = GetInventoryItemLink)
			_, _, _, ItemLevel  = GetItemInfo(GetInventoryItemLink("player", i))    -- Grab Item level (number 4, so we assign nil to the first 3 values) (WoW API = GetItemInfo)
			ItemCount = ItemCount + 1; TotalILevel = TotalILevel + ItemLevel;		-- Get ItemCount and TotalILevel for AVGILevel.
			end
		end
	end	

	AVGILevel = TotalILevel / ItemCount; 											--Calculate AVG ILevel
		
end


---------------------------------------- Set Color ----------------------------------------

function txtColor()

	if (AVGILevel >= 219) then
	RED = 0.69; GREEN = 0.28; BLUE = 0.97;										--Purple if AVG ILevel is 219 or over
	
	elseif (AVGILevel >= 200) then
	RED = 0; GREEN = 0.50; BLUE = 1;											--Blue if AVG ILevel is 200 or over
	
	elseif (AVGILevel >= 180) then
	RED = 0.12; GREEN = 1; BLUE = 0;											--Green if AVG ILevel is 180 or over
	end
end


---------------------------------------- Create Event ----------------------------------------

local f = CreateFrame("Frame")
f:SetScript("OnEvent", IL_Events)
f:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
PaperDollFrame:HookScript("OnShow", IL_Events)


---------------------------------------- Item Level Number ----------------------------------------

PaperDollFrame:CreateFontString("Ilevelnr")
Ilevelnr:SetFont("Fonts\\FRIZQT__.TTF", 10)
Ilevelnr:SetFormattedText("%.1f", AVGILevel) 									--Same as SetText, but we set 1 decimal here. "%.1f"
Ilevelnr:SetTextColor(RED, GREEN, BLUE, 1)
Ilevelnr:SetPoint("BOTTOMRIGHT",PaperDollFrame,"TOPLEFT",295,-253)
Ilevelnr:Show()


---------------------------------------- Item Level Text ----------------------------------------

PaperDollFrame:CreateFontString("Ileveltxt")
Ileveltxt:SetFont("Fonts\\FRIZQT__.TTF", 10)
Ileveltxt:SetText("ItemLevel")
Ileveltxt:SetPoint("BOTTOMRIGHT",PaperDollFrame,"TOPLEFT",295,-265)
Ileveltxt:Show()
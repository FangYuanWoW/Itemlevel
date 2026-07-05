-- Itemlevel: average equipped item level on the character panel and the inspect frame.
-- Original by ZpiXDK (Warmane forums, Feb 12 2023). Fork maintained by FangYuanWoW.

---------------------------------------- Config ----------------------------------------

-- Color tiers, highest first: { threshold, r, g, b }.
-- Tuned for Triumvirate progression: green = level-60 dungeon gear,
-- blue = MC/BWL/ZG gear, purple = AQ40/Naxx/Karazhan gear. White below.
local COLOR_TIERS = {
	{ 90, 0.69, 0.28, 0.97 },
	{ 70, 0.00, 0.50, 1.00 },
	{ 55, 0.12, 1.00, 0.00 },
}

local INSPECT_POLL_INTERVAL = 0.5

---------------------------------------- Average ----------------------------------------

-- Slots 1-18 skipping 4 (shirt); tabard (19) is outside the loop.
-- GetItemInfo returns nil for items not yet in the local cache (common for
-- inspected players), so uncached items are left out of the average and
-- picked up on a later refresh instead of erroring.
local function AverageItemLevel(unit)
	local count, total = 0, 0
	for slot = 1, 18 do
		if slot ~= 4 then
			local link = GetInventoryItemLink(unit, slot)
			if link then
				local _, _, _, ilvl = GetItemInfo(link)
				if ilvl then
					count = count + 1
					total = total + ilvl
				end
			end
		end
	end
	if count == 0 then
		return 0
	end
	return total / count
end

local function TierColor(avg)
	for _, tier in ipairs(COLOR_TIERS) do
		if avg >= tier[1] then
			return tier[2], tier[3], tier[4]
		end
	end
	return 1, 1, 1
end

---------------------------------------- Display ----------------------------------------

local function AttachDisplay(parent)
	local value = parent:CreateFontString(nil, "OVERLAY")
	value:SetFont("Fonts\\FRIZQT__.TTF", 10)
	value:SetPoint("BOTTOMRIGHT", parent, "TOPLEFT", 295, -253)

	local label = parent:CreateFontString(nil, "OVERLAY")
	label:SetFont("Fonts\\FRIZQT__.TTF", 10)
	label:SetText("ItemLevel")
	label:SetPoint("BOTTOMRIGHT", parent, "TOPLEFT", 295, -265)

	return value
end

local playerValue = AttachDisplay(PaperDollFrame)

local function UpdatePlayer()
	local avg = AverageItemLevel("player")
	playerValue:SetFormattedText("%.1f", avg)
	playerValue:SetTextColor(TierColor(avg))
end

---------------------------------------- Inspect ----------------------------------------

local inspectValue

local function UpdateInspect()
	if not (inspectValue and InspectFrame and InspectFrame.unit) then
		return
	end
	local avg = AverageItemLevel(InspectFrame.unit)
	inspectValue:SetFormattedText("%.1f", avg)
	inspectValue:SetTextColor(TierColor(avg))
end

-- Inspected gear and item-cache data arrive from the server asynchronously,
-- so refresh on a short interval while the inspect frame is open.
local poller = CreateFrame("Frame")
poller:Hide()
local sincePoll = 0
poller:SetScript("OnUpdate", function(self, elapsed)
	if not (InspectFrame and InspectFrame:IsShown()) then
		self:Hide()
		return
	end
	sincePoll = sincePoll + elapsed
	if sincePoll >= INSPECT_POLL_INTERVAL then
		sincePoll = 0
		UpdateInspect()
	end
end)

local function OnInspectShow()
	sincePoll = 0
	UpdateInspect()
	poller:Show()
end

-- Blizzard_InspectUI is load-on-demand; attach once it exists.
local function HookInspectUI()
	if inspectValue or not InspectPaperDollFrame then
		return
	end
	inspectValue = AttachDisplay(InspectPaperDollFrame)
	InspectPaperDollFrame:HookScript("OnShow", OnInspectShow)
end

---------------------------------------- Events ----------------------------------------

local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("UNIT_INVENTORY_CHANGED")
events:SetScript("OnEvent", function(self, event, arg1)
	if event == "ADDON_LOADED" then
		if arg1 == "Blizzard_InspectUI" then
			HookInspectUI()
		end
	elseif event == "UNIT_INVENTORY_CHANGED" then
		if InspectFrame and InspectFrame:IsShown() and arg1 == InspectFrame.unit then
			UpdateInspect()
		end
	else
		UpdatePlayer()
	end
end)

PaperDollFrame:HookScript("OnShow", UpdatePlayer)
HookInspectUI()
UpdatePlayer()

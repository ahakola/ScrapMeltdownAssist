local ADDON_NAME = ...

local f = CreateFrame("Frame")
local astring, wstring

local function Print(text, ...)
	if text then
		if text:match("%%[dfqs%d%.]") then
			DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00".. ADDON_NAME ..":|r " .. format(text, ...))
		else
			DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00".. ADDON_NAME ..":|r " .. strjoin(" ", text, tostringall(...)))
		end
	end
end

local function _countEnhancements() -- Armor/Weapon Enhancements
	local armor, weapon
	if ScrapMeltdownAssistIncludeBank then
		armor = 9 * GetItemCount(114822, true) + 6 * GetItemCount(114808, true) + 3 * GetItemCount(114745, true) + 50 * GetItemCount(128314, true)
		weapon = 9 * GetItemCount(114131, true) + 6 * GetItemCount(114129, true) + 3 * GetItemCount(114128, true) + 50 * GetItemCount(128314, true)
	else
		-- Heavily Reinforced Armor Enhancement, Fortified Armor Enhancement, Braced Armor Enhancement, Frozen Arms of a Hero
		armor = 9 * GetItemCount(114822) + 6 * GetItemCount(114808) + 3 * GetItemCount(114745) + 50 * GetItemCount(128314)
		-- Power Overrun Weapon Enhancement, Striking Weapon Enhancement, Balanced Weapon Enhancement, Frozen Arms of a Hero
		weapon = 9 * GetItemCount(114131) + 6 * GetItemCount(114129) + 3 * GetItemCount(114128) + 50 * GetItemCount(128314)
	end

	return armor, weapon
end

local function _GetGUID() -- Returns npcID of target
	local guid = UnitGUID("target")
	if not guid then return end
	local unitType, _, _, _, _, npcID, _ = strsplit("-", guid);

	if npcID and unitType == "Creature" then
		return tonumber(npcID)
	else
		return nil
	end
end

local function _ShowNumbers()
	-- 77377 = Kristen Stoneforge, 79815 = Grun'lek
	if GetNumQuestChoices() == 2 and (_GetGUID() == 77377 or _GetGUID() == 79815) then
		f:SetFrameLevel(_G.QuestInfoRewardsFrameQuestInfoItem1:GetFrameLevel())

		astring = astring or f:CreateFontString(nil, "OVERLAY", "NumberFontNormalRight")
		wstring = wstring or f:CreateFontString(nil, "OVERLAY", "NumberFontNormalRight")
		astring:SetPoint("TOPRIGHT", _G.QuestInfoRewardsFrameQuestInfoItem1IconTexture, 2, -1)
		wstring:SetPoint("TOPRIGHT", _G.QuestInfoRewardsFrameQuestInfoItem2IconTexture, 2, -1)
		astring:Show()
		wstring:Show()

		local armor, weapon = _countEnhancements()
		astring:SetText(armor)
		wstring:SetText(weapon)
	end
end

SLASH_SCRAPMELTDOWNASSIST1 = "/scrapmeltdownastringsist"
SLASH_SCRAPMELTDOWNASSIST2 = "/scrapmeltdown"
SLASH_SCRAPMELTDOWNASSIST3 = "/sma"

SlashCmdList["SCRAPMELTDOWNASSIST"] = function(...)
	if (...) == "bank" then
		ScrapMeltdownAssistIncludeBank = not ScrapMeltdownAssistIncludeBank
	end

	-- Armor/Weapon Enhancements
	local armor, weapon = _countEnhancements()
	Print("Armor:", armor, "Weapon:", weapon)
	Print("Include Bank:", ScrapMeltdownAssistIncludeBank and "|cff00ff00true|r" or "|cffff0000false|r", "(Use '/sma bank' to change)")
end

f:SetScript("OnEvent", function(self, event, ...)
	if event == "ADDON_LOADED" then
		if (...) ~= ADDON_NAME then return end

		if type(ScrapMeltdownAssistIncludeBank) ~= "boolean" then
			ScrapMeltdownAssistIncludeBank = false
		end

		self:RegisterEvent("QUEST_COMPLETE")
		self:RegisterEvent("QUEST_FINISHED")
		self:RegisterEvent("QUEST_DETAIL")

		self:UnregisterEvent("ADDON_LOADED")
	elseif event == "QUEST_COMPLETE" then
		_ShowNumbers()
	elseif event == "QUEST_FINISHED" then
		if astring then astring:Hide() end
		if wstring then wstring:Hide() end
	elseif event == "QUEST_DETAIL" then
		_ShowNumbers()
	end
end)
f:RegisterEvent("ADDON_LOADED")
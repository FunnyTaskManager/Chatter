local mod = Chatter:NewModule("Scrollback")
local L = LibStub("AceLocale-3.0"):GetLocale("Chatter")
mod.modName = L["Scrollback"]
mod.toggleLabel = L["Enable Scrollback length modification"]

local defaults = {
	profile = {}
}

local options = {}
local original = {}

local cache = setmetatable({}, {__mode='k'})

local function acquire()
	local t = next(cache) or {}
	cache[t] = nil
	return t
end

local function reclaim(t)
	for k in pairs(t) do
		t[k] = nil
	end
	cache[t] = true
end

local chatTypeNames

local function setlines(frame, lines)
	if frame ~= COMBATLOG and lines and frame:GetMaxLines() ~= lines then
		original[frame] = original[frame] or frame:GetMaxLines()
		if not chatTypeNames then
			chatTypeNames = {}
			for chatType in pairs(ChatTypeInfo) do
				chatTypeNames[GetChatTypeIndex(chatType)] = chatType
			end
		end
		local colors = acquire()
		for regions = frame:GetNumRegions(),1,-1 do
			local region = select(regions, frame:GetRegions())
			if region:GetObjectType() == "FontString" and region:GetText() then
				colors[region:GetText()] = {region:GetTextColor()}
			end
		end
		local history = acquire()
		for i = 1, frame:GetNumMessages() do
			table.insert(history, {frame:GetMessageInfo(i)})
		end

		frame:SetMaxLines(lines or 250)

		Chatter.loading = true

		for _, v in ipairs(history) do
			local text, accessID, lineID, extraData = unpack(v)
			local info = ChatTypeInfo[chatTypeNames[lineID]]
			local color = colors[text] or info and {info.r, info.g, info.b} or {1, 1, 1}
			frame:AddMessage(text, color[1], color[2], color[3], lineID, false, accessID, extraData)
		end

		Chatter.loading = false

		reclaim(history)
		reclaim(colors)
	end
end

function mod:OnInitialize()
	self.db = Chatter.db:RegisterNamespace("Scrollback", defaults)
	for i = 1, NUM_CHAT_WINDOWS do
		local s = "FRAME_" .. i
		local frame = _G["ChatFrame" .. i]
		options[s] = {
			type = "range",
			name = L["Chat Frame "] .. i,
			desc = L["Chat Frame "] .. i,
			min = 250,
			max = 2500,
			step = 10,
			get = function() return self.db.profile[s] or frame:GetMaxLines() end,
			set = function(info, value)
				self.db.profile[s] = value
				setlines(frame, value)
			end
		}
		if frame == ChatFrame2 then
			options[s] = nil
		end
	end
end

function mod:OnEnable()
	for i = 1, NUM_CHAT_WINDOWS do
		setlines(_G["ChatFrame"..i], self.db.profile["FRAME_"..i])
	end
end

function mod:OnDisable()
	for i = 1, NUM_CHAT_WINDOWS do
		local frame = _G["ChatFrame"..i]
		setlines(frame, original[frame])
	end
end

function mod:GetOptions()
	return options
end

function mod:Info()
	return L["Lets you set the scrollback length of your chat frames."]
end

local mod = Chatter:NewModule("Tiny Chat")
local L = LibStub("AceLocale-3.0"):GetLocale("Chatter")
mod.modName = L["Tiny Chat"]

function mod:Info()
	return L["Allows you to make the chat frames much smaller than usual."]
end

function mod:Decorate(frame)
	frame:SetMinResize(50, 20)
	frame:SetMaxResize(5000, 5000)
end

function mod:OnEnable()
	for i = 1, NUM_CHAT_WINDOWS do
		local cf = _G["ChatFrame" .. i]
		cf:SetMinResize(50, 20)
		cf:SetMaxResize(5000, 5000)
	end
	for index,name in ipairs(self.TempChatFrames) do
		local cf = _G[name]
		if cf then
			cf:SetMinResize(50, 20)
			cf:SetMaxResize(5000, 5000)
		end
	end
end

function mod:OnDisable()
	for i = 1, NUM_CHAT_WINDOWS do
		local cf = _G["ChatFrame" .. i]
		cf:SetMinResize(CHAT_FRAME_MIN_WIDTH, CHAT_FRAME_NORMAL_MIN_HEIGHT)
		cf:SetMaxResize(1200, 700)
	end
	for index,name in ipairs(self.TempChatFrames) do
		local cf = _G[name]
		if cf then
			cf:SetMinResize(CHAT_FRAME_MIN_WIDTH, (cf.chatType == "BN_WHISPER" or cf.chatType == "BN_CONVERSATION") and CHAT_FRAME_BIGGER_MIN_HEIGHT or CHAT_FRAME_NORMAL_MIN_HEIGHT)
			cf:SetMaxResize(1200, 700)
		end
	end
end

local mod = Chatter:NewModule("Disable Buttons", "AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("Chatter")

mod.modName = L["Disable Buttons"]

local fmt = _G.string.format
local function hide(self)
	if not self.override then
		self:Hide()
	end
	self.override = nil
end

local defaults = { profile = {} }
function mod:OnInitialize()
	self.db = Chatter.db:RegisterNamespace("Buttons", defaults)
	self:SecureHook("FCF_RestorePositionAndDimensions")
end

function mod:Decorate(frame)
	-- Adjust the menu buttons
	self:ApplyFrameChanges(frame)
end

function mod:FCF_RestorePositionAndDimensions(chatFrame)
	if Chatter.db.profile.modules[mod:GetName()] then
		chatFrame:SetClampRectInsets(0, 0, 0, 0)
	end
end

local insets = {}

-- Fix the jump in
for i = 1, NUM_CHAT_WINDOWS do
	local f = _G["ChatFrame" .. i]
	insets[f] = {f:GetClampRectInsets()}
	f:SetClampRectInsets(0, 0, 0, 0)
end

function mod:ApplyFrameChanges(f)
	insets[f] = insets[f] or {f:GetClampRectInsets()}
	f:SetClampRectInsets(0, 0, 0, 0)
	local ff = _G[f:GetName() .. "ButtonFrame"]
	ff:Hide()
	ff:SetScript("OnShow", hide)
end

function mod:OnEnable()
	ChatFrameMenuButton:Hide()
	ChatFrameMenuButton:SetScript("OnShow", hide)
	FriendsMicroButton:Hide()
	FriendsMicroButton:SetScript("OnShow", hide)
	for i = 1, NUM_CHAT_WINDOWS do
		local f = _G["ChatFrame" .. i]
		self:ApplyFrameChanges(f)
	end
	for index,frame in ipairs(self.TempChatFrames) do
		local f = _G[frame]
		self:ApplyFrameChanges(f)
	end
	Chatter:AddMenuHook(self, {
		text = L["Chat Commands"],
		func = mod.ToggleMenu,
		notCheckable = 1
	})
end

function mod:UnDecorate(frame)
	frame:SetClampRectInsets(unpack(insets[frame] or {-35, 35, 26, -50}))
	-- Reset the postion so if the buttons were offscreen frame goes to where it should be
	if frame:IsMovable() then
		FCF_RestorePositionAndDimensions(frame)
	end
	local ff = _G[frame:GetName() .. "ButtonFrame"]
	ff:SetScript("OnShow", nil)
	ff:Show()
end

function mod:OnDisable()
	ChatFrameMenuButton:SetScript("OnShow", nil)
	ChatFrameMenuButton:Show()
	FriendsMicroButton:SetScript("OnShow", nil)
	FriendsMicroButton:Show()
	for i = 1, NUM_CHAT_WINDOWS do
		local f = _G["ChatFrame" .. i]
		self:UnDecorate(f)
	end
	for index,frame in ipairs(self.TempChatFrames) do
		local f = _G[frame]
		self:UnDecorate(f)
	end
	Chatter:RemoveMenuHook(self)
end

function mod:ToggleMenu()
	ChatFrameMenuButton:Click()
end

function mod:Info()
	return L["Hides the buttons attached to the chat frame"]
end

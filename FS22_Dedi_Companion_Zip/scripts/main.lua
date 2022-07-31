local modDirectory = g_currentModDirectory or ""
local modName = g_currentModName or "unknown"
local modEnvironmentChat
local modEnvironmentChatNoti
local modEnvironmentgetAdminLogin
local modEnvironmentNewJoin

---Init the mod.
local function init()
    -- Mod is loaded in to the game here.  Yay!
    print("Starting the Multiplayer Chat Companion");
  
	source(modDirectory .. "scripts/chatNoti.lua")
    source(modDirectory .. "scripts/chatLogger.lua")
	source(modDirectory .. "scripts/getAdminLogin.lua")
	source(modDirectory .. "scripts/getNewJoin.lua")

	-- Load all command files
	source(modDirectory .. "scripts/commands/forgetMe.lua")
	source(modDirectory .. "scripts/commands/getFarms.lua")
	source(modDirectory .. "scripts/commands/getUsers.lua")
	source(modDirectory .. "scripts/commands/help.lua")
	source(modDirectory .. "scripts/commands/makeAdmin.lua")
	source(modDirectory .. "scripts/commands/makeFM.lua")
	source(modDirectory .. "scripts/commands/meAdmin.lua")
	source(modDirectory .. "scripts/commands/rememberMe.lua")
	source(modDirectory .. "scripts/commands/removeAdmin.lua")

    assert(g_chatLogger == nil)
    modEnvironmentChat = ChatLogger:new(mission, g_i18n, modDirectory, modName)
    getfenv(0)["g_chatLogger"] = modEnvironmentChat
    addModEventListener(modEnvironmentChat)
	ChatDialog.onSendClick = Utils.overwrittenFunction(ChatDialog.onSendClick, ChatLogger.onSendClick)

    assert(g_chatNoti == nil)
    modEnvironmentChatNoti = ChatNoti:new()
    getfenv(0)["g_chatNoti"] = modEnvironmentChatNoti
    addModEventListener(modEnvironmentChatNoti)
	FSCareerMissionInfo.saveToXMLFile = Utils.appendedFunction(FSCareerMissionInfo.saveToXMLFile, ChatNoti.sendChatMessage)

    assert(g_getAdminLogin == nil)
    modEnvironmentgetAdminLogin = GetAdminLogin:new(baseDirectory, customMt)
    getfenv(0)["g_getAdminLogin"] = modEnvironmentgetAdminLogin
    addModEventListener(modEnvironmentgetAdminLogin)
	FSBaseMission.onMasterUserAdded = Utils.appendedFunction(FSBaseMission.onMasterUserAdded, GetAdminLogin.userNowAdminEvent)

    assert(g_getNewJoin == nil)
    modEnvironmentNewJoin = GetNewJoin:new(mission, g_i18n, modDirectory, modName)
    getfenv(0)["g_getNewJoin"] = modEnvironmentNewJoin
    addModEventListener(modEnvironmentNewJoin)
	FSBaseMission.onConnectionFinishedLoading = Utils.appendedFunction(FSBaseMission.onConnectionFinishedLoading, onConnectionFinishedLoading)

	HelpLineManager.loadMapData = Utils.overwrittenFunction(HelpLineManager.loadMapData, ChatLogger.loadMapDataHelpLineManager)

end

ChatLogger = {}

local ChatLogger_mt = Class(ChatLogger)

function ChatLogger:new(mission, i18n, modDirectory, modName)
	local self = setmetatable({}, ChatLogger_mt)

	self.lastScrollTime = 0
	self.returnScreenName = ""

	return self
end

function ChatLogger:onClose(superFunc)
	ChatLogger:superClass().onClose(self)

	if g_currentMission ~= nil then
		g_currentMission:scrollChatMessages(-9999999)
		g_currentMission:toggleChat(false)

		g_currentMission.isPlayerFrozen = false
	end

	self.textElement:abortIme()
	self.textElement:setForcePressed(false)
end

function ChatLogger:onSendClick(superFunc)

	if self.textElement.text ~= "" then
		local nickname = g_currentMission.playerNickname
		local farmId = g_currentMission:getFarmId()
		local isAllowed = true

		if GS_PLATFORM_TYPE == GS_PLATFORM_TYPE_GGP then
			isAllowed = getAllowTextCommunication()
		end

		if isAllowed then
			if g_server ~= nil then
				g_server:broadcastEvent(ChatEvent.new(self.textElement.text, nickname, farmId, g_currentMission.playerUserId))
				g_server:broadcastEvent(ChatEventSaver.new(self.textElement.text, nickname, farmId, g_currentMission.playerUserId))
                --print("g_server local")
            else
				g_client:getServerConnection():sendEvent(ChatEvent.new(self.textElement.text, nickname, farmId, g_currentMission.playerUserId))
				g_client:getServerConnection():sendEvent(ChatEventSaver.new(self.textElement.text, nickname, farmId, g_currentMission.playerUserId))
                --print("g_server client")
			end

			g_currentMission:addChatMessage(nickname, self.textElement.text, farmId, g_currentMission.playerUserId)
		end

		self.textElement:setText("")

	end

	g_gui:showGui("")
end

function ChatLogger:loadMapDataHelpLineManager(superFunc, ...)
    local ret = superFunc(self, ...)
    if ret then
        self:loadFromXML(Utils.getFilename("help/HelpMenu.xml", modDirectory))
        return true
    end
    return false
end

function onConnectionFinishedLoading(connection, ...)
	GetNewJoin.newUserJoin(...)
end


init()
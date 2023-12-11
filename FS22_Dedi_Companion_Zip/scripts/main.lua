local modDirectory = g_currentModDirectory or ""
local modName = g_currentModName or "unknown"
local modEnvironmentChat
local modEnvironmentChatNoti
local modEnvironmentgetAdminLogin
local modEnvironmentNewJoin

---Init the mod.
local function init()
  -- Mod is loaded for multiplayer.  Yay!
  dcDebug("Starting the Multiplayer Chat Companion")

  -- Load Chat and Admin Stuffs
	source(modDirectory .. "scripts/chatNoti.lua")
  source(modDirectory .. "scripts/chatLogger.lua")
	source(modDirectory .. "scripts/getAdminLogin.lua")
	source(modDirectory .. "scripts/getNewJoin.lua")

  -- Load Settings Menu Stuffs
  source(modDirectory .. "scripts/menu/inGameMenuDediSettings.lua")
  source(modDirectory .. "scripts/dediSettings.lua")

	-- Load all command files
	source(modDirectory .. "scripts/commands/forgetMe.lua")
	source(modDirectory .. "scripts/commands/getFarms.lua")
	source(modDirectory .. "scripts/commands/getUsers.lua")
	source(modDirectory .. "scripts/commands/makeAdmin.lua")
	source(modDirectory .. "scripts/commands/makeFM.lua")
	source(modDirectory .. "scripts/commands/meAdmin.lua")
	source(modDirectory .. "scripts/commands/rememberMe.lua")
	source(modDirectory .. "scripts/commands/removeAdmin.lua")
	source(modDirectory .. "scripts/commands/saveVehicles.lua")

  -- Register and over write base game functions
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

	FSBaseMission.updateGameStatsXML = Utils.overwrittenFunction(FSBaseMission.updateGameStatsXML, ChatLogger.dediStatsUpdate)

  FSBaseMission.sendInitialClientState = Utils.appendedFunction(FSBaseMission.sendInitialClientState, DediSettings.sendInitialClientState)

end

-- Start the chat logger process
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
                dcDebug("g_server local", false)
            else
				g_client:getServerConnection():sendEvent(ChatEvent.new(self.textElement.text, nickname, farmId, g_currentMission.playerUserId))
				g_client:getServerConnection():sendEvent(ChatEventSaver.new(self.textElement.text, nickname, farmId, g_currentMission.playerUserId))
                dcDebug("g_server client", false)
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

function ChatLogger:dediStatsUpdate(superFunc)
	if g_dedicatedServer ~= nil then
		local statsPath = g_dedicatedServer.gameStatsPath
		local key = "Server"
		local xmlFile = createXMLFile("serverStatsFile", statsPath, key)

		dcDebug("Game Stats Path: " .. statsPath)

		if xmlFile ~= nil and xmlFile ~= 0 then

			dcDebug("Dedi Stats Update!")

			local gameName = self.missionDynamicInfo.serverName or ""
			local mapName = "Unknown"
			local map = g_mapManager:getMapById(self.missionInfo.mapId)

			if map ~= nil then
				mapName = map.title
			end

			local dayTime = 0

			if self.environment ~= nil then
				dayTime = self.environment.dayTime
			end

			local mapSize = Utils.getNoNil(self.terrainSize, 2048)
			local numUsers = self.userManager:getNumberOfUsers()

			if g_dedicatedServer ~= nil then
				numUsers = numUsers - 1
			end

			local capacity = self.missionDynamicInfo.capacity or 0

			setXMLString(xmlFile, key .. "#game", "Farming Simulator 22")
			setXMLString(xmlFile, key .. "#version", g_gameVersionDisplay .. g_gameVersionDisplayExtra)
			setXMLString(xmlFile, key .. "#name", HTMLUtil.encodeToHTML(gameName))
			setXMLString(xmlFile, key .. "#mapName", HTMLUtil.encodeToHTML(mapName))
			setXMLInt(xmlFile, key .. "#dayTime", dayTime)
			setXMLString(xmlFile, key .. "#mapOverviewFilename", NetworkUtil.convertToNetworkFilename(self.mapImageFilename))
			setXMLInt(xmlFile, key .. "#mapSize", mapSize)
			setXMLInt(xmlFile, key .. ".Slots#capacity", capacity)
			setXMLInt(xmlFile, key .. ".Slots#numUsed", numUsers)

			local i = 0

			for _, user in ipairs(self.userManager:getUsers()) do
				local player = nil
				local connection = user:getConnection()

				if connection ~= nil then
					player = self.connectionsToPlayer[connection]
				end

				if user:getId() ~= self:getServerUserId() or g_dedicatedServer == nil then
					local playerKey = string.format("%s.Slots.Player(%d)", key, i)
					local playtime = (self.time - user:getConnectedTime()) / 60000

					setXMLBool(xmlFile, playerKey .. "#isUsed", true)
					setXMLBool(xmlFile, playerKey .. "#isAdmin", user:getIsMasterUser())
					setXMLInt(xmlFile, playerKey .. "#uptime", playtime)

					if player ~= nil and player.isControlled and player.rootNode ~= nil and player.rootNode ~= 0 then
						local x, y, z = getWorldTranslation(player.rootNode)

						setXMLFloat(xmlFile, playerKey .. "#x", x)
						setXMLFloat(xmlFile, playerKey .. "#y", y)
						setXMLFloat(xmlFile, playerKey .. "#z", z)
					end

					setXMLString(xmlFile, playerKey, HTMLUtil.encodeToHTML(user:getNickname(), true))

					i = i + 1
				end
			end

			for n = numUsers + 1, capacity do
				local playerKey = string.format("%s.Slots.Player(%d)", key, n)

				setXMLBool(xmlFile, playerKey .. "#isUsed", false)
			end

			i = 0

			for _, vehicle in pairs(self.vehicles) do
				local vehicleKey = string.format("%s.Vehicles.Vehicle(%d)", key, i)

				if vehicle:saveStatsToXMLFile(xmlFile, vehicleKey) then
					i = i + 1
				end
			end

			i = 0

			for _, mod in pairs(self.missionDynamicInfo.mods) do
				local modKey = string.format("%s.Mods.Mod(%d)", key, i)

				setXMLString(xmlFile, modKey .. "#name", HTMLUtil.encodeToHTML(mod.modName))
				setXMLString(xmlFile, modKey .. "#author", HTMLUtil.encodeToHTML(mod.author))
				setXMLString(xmlFile, modKey .. "#version", HTMLUtil.encodeToHTML(mod.version))
				setXMLString(xmlFile, modKey, HTMLUtil.encodeToHTML(mod.title, true))

				if mod.fileHash ~= nil then
					setXMLString(xmlFile, modKey .. "#hash", HTMLUtil.encodeToHTML(mod.fileHash))
				end

				i = i + 1
			end

			i = 0

			for _, farmland in pairs(g_farmlandManager:getFarmlands()) do
				local farmlandKey = string.format("%s.Farmlands.Farmland(%d)", key, i)

				setXMLString(xmlFile, farmlandKey .. "#name", tostring(farmland.name))
				setXMLInt(xmlFile, farmlandKey .. "#id", farmland.id)
				setXMLInt(xmlFile, farmlandKey .. "#owner", g_farmlandManager:getFarmlandOwner(farmland.id))
				setXMLFloat(xmlFile, farmlandKey .. "#area", farmland.areaInHa)
				setXMLInt(xmlFile, farmlandKey .. "#area", farmland.price)
				setXMLFloat(xmlFile, farmlandKey .. "#x", farmland.xWorldPos)
				setXMLFloat(xmlFile, farmlandKey .. "#z", farmland.zWorldPos)

				i = i + 1
			end

			i = 0

			for _, field in pairs(g_fieldManager:getFields()) do
				local fieldKey = string.format("%s.Fields.Field(%d)", key, i)

				setXMLString(xmlFile, fieldKey .. "#id", tostring(field.fieldId))
				setXMLFloat(xmlFile, fieldKey .. "#x", field.posX)
				setXMLFloat(xmlFile, fieldKey .. "#z", field.posZ)
				setXMLBool(xmlFile, fieldKey .. "#isOwned", not field.isAIActive)

				i = i + 1
			end

			local adminSettingsFolderPath = getUserProfileAppPath()  .. "modSettings/FS22_Chat_Companion"
			local adminSettingsFile = adminSettingsFolderPath .. "/Admins.xml"
      local adminsKey = "admins"
      local admins = {}
      -- Check if Admins.xml exists.
      if ( fileExists(adminSettingsFile) ) then
        local xmlFileAdsmins = XMLFile.load(adminsKey, adminSettingsFile)

        dcDebug(xmlFileAdsmins, "Table")

        xmlFileAdsmins:iterate(adminsKey .. ".admin", function (_, adminKey)
          dcDebug("adminKey: " .. adminKey)
          local admin = {
            adminName = xmlFileAdsmins:getString(adminKey .. "#adminName"),
            adminId = xmlFileAdsmins:getString(adminKey .. "#adminId"),
          }
          table.insert(admins, admin)
        end)

        dcDebug(admins, "Table")
      end

			i = 0

			for _, adminData in pairs(admins) do
				dcDebug("adminData.adminName: " .. adminData.adminName)
				local dcKey = string.format("%s.DediCompanionAdmins.Admins(%d)", key, i)
	
				setXMLString(xmlFile, dcKey .. "#adminName", tostring(adminData.adminName))
				setXMLString(xmlFile, dcKey .. "#adminId", tostring(adminData.adminId))
	
				i = i + 1
			end

			saveXMLFile(xmlFile)
			delete(xmlFile)
		
		end

	end

	self.gameStatsTime = self.time + self.gameStatsInterval
end

function onConnectionFinishedLoading(connection, ...)
	GetNewJoin.newUserJoin(...)
end

function dcDebug(data, action)
	if action ~= false and data ~= nil then
		if action == 'Table' then
			print("** Dedi Companion Debug Table **")
			DebugUtil.printTableRecursively(data, "  tabledata : ", 0, 1)
		else
			print("** Dedi Companion Debug ** : " .. data)
		end
	end
end

init()
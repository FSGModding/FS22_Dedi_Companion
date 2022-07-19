--print("chatNoti Class")

ChatNoti = {}
local ChatNoti_mt = Class(ChatNoti, Event)

InitEventClass(ChatNoti, "ChatNoti", EventIds.EVENT_SAVE)

function ChatNoti.emptyNew()
    --print("CN-EmptyNew")
	local self = Event.new(ChatNoti_mt)

	return self
end

function ChatNoti.new()
    --print("CN-New")
	local self = ChatNoti.emptyNew()

	return self
end

function ChatNoti.sendChatMessage()
    if g_server ~= nil then
        --print("========GAMESAVED==========")
        g_server:broadcastEvent(ChatEvent.new(g_i18n:getText("chat_game_saved"),g_currentMission.missionDynamicInfo.serverName,FarmManager.SPECTATOR_FARM_ID,0))

        --copy chatLogger.xml to savegame
        local savegameFolderPath = getUserProfileAppPath() .. "savegame" .. g_currentMission.missionInfo.savegameIndex
        local savegameFile       = savegameFolderPath .. "/ChatLogger.xml"

        local modSettingsFolderPath = getUserProfileAppPath()  .. "modSettings/FS22_Chat_Companion"
        local modSettingsFile = modSettingsFolderPath .. "/ChatLogger.xml"

        local key = "chatLogger"

        if ( fileExists(modSettingsFile) ) then

            local xmlFile = XMLFile.load(key, modSettingsFile)
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

        end

    end
end
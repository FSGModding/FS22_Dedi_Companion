print("RememberMeCommand Class")

RememberMeCommand = {}
local RememberMeCommand_mt = Class(RememberMeCommand, Event)

function RememberMeCommand.rememberMe(fromUser, fromUserId)
    print("*** Dedi Companion Debug *** Remember Me Command Start")
    -- Check to see if Remember Me folder exists
    local rememberMeFolderPath = getUserProfileAppPath()  .. "modSettings/FS22_Chat_Companion/rememberMe"
    local rememberMeFile = rememberMeFolderPath .. "/" .. fromUserId .. ".xml"
    local key = "admin"

    if ( not fileExists(rememberMeFolderPath) ) then
        createFolder(rememberMeFolderPath)
    end

    --save data to xml file
    newxmlFileRM = XMLFile.create(key, rememberMeFile, key)

    newxmlFileRM:setString(key .. "#adminName", tostring(fromUser.nickname))
    newxmlFileRM:setString(key .. "#adminId", tostring(fromUser.uniqueUserId))

    newxmlFileRM:save()
    newxmlFileRM:delete()			
    g_server:broadcastEvent(ChatEvent.new(fromUser.nickname .. g_i18n:getText("chat_rememberme"),g_currentMission.missionDynamicInfo.serverName,FarmManager.SPECTATOR_FARM_ID,0))
end
print("ForgetMeCommand Class")

ForgetMeCommand = {}
local ForgetMeCommand_mt = Class(ForgetMeCommand, Event)

function ForgetMeCommand.forgetMe(fromUser, fromUserId)
    print("*** Dedi Companion Debug *** Forget Me Command Start")
    -- Check to see if Forget Me folder exists
    local forgetMeFolderPath = getUserProfileAppPath()  .. "modSettings/FS22_Chat_Companion/rememberMe"
    local forgetMeFile = forgetMeFolderPath .. "/" .. fromUserId .. ".xml"
    local key = "admin"

    if fileExists(forgetMeFile) then
        deleteFile(forgetMeFile)
        if fileExists(forgetMeFile) then
            g_server:broadcastEvent(ChatEvent.new(fromUser.nickname .. g_i18n:getText("chat_forgetme_error"),g_currentMission.missionDynamicInfo.serverName,FarmManager.SPECTATOR_FARM_ID,0))
        else 
            g_server:broadcastEvent(ChatEvent.new(fromUser.nickname .. g_i18n:getText("chat_forgetme"),g_currentMission.missionDynamicInfo.serverName,FarmManager.SPECTATOR_FARM_ID,0))
        end
    end
end
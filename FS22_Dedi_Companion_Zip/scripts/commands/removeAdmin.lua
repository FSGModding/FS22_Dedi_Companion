print("RemoveAdminCommand Class")

RemoveAdminCommand = {}
local RemoveAdminCommand_mt = Class(RemoveAdminCommand, Event)

function RemoveAdminCommand.removeAdmin(fromUser)
    g_currentMission.userManager:removeMasterUser(fromUser)
    --Remove user from tables to trick into removing admin both backend and visually. 
    g_currentMission.userManager:removeUser(fromUser)
    --Add the user back as a non admin.
    g_currentMission.userManager:addUser(fromUser)
    --Need to figure out how to refresh the menus to reflect the user not being admin anymore. 
    g_server:broadcastEvent(ChatEvent.new(fromUser.nickname .. g_i18n:getText("chat_admin_removed"),g_currentMission.missionDynamicInfo.serverName,FarmManager.SPECTATOR_FARM_ID,0))
    print("Admin Removed")	
end
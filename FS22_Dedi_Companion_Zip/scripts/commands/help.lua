dcDebug("GetHelpCommand Class")

GetHelpCommand = {}
local GetHelpCommand_mt = Class(GetHelpCommand, Event)

function GetHelpCommand.getHelp(fromUser, args)
    local displayCommands = {}
    -- Non Admin Commands
    table.insert(displayCommands, "Command : Info")
    table.insert(displayCommands, g_i18n:getText("chat_command_help") .. " : " .. g_i18n:getText("chat_command_info_help"))
    table.insert(displayCommands, g_i18n:getText("chat_command_moo") .. " : " .. g_i18n:getText("chat_command_info_moo"))
    table.insert(displayCommands, g_i18n:getText("chat_command_me_admin") .. " : " .. g_i18n:getText("chat_command_me_admin"))
    
    -- Admin only commands
    if fromUser.isMasterUser then
        table.insert(displayCommands, g_i18n:getText("chat_command_remove_admin") .. " : " .. g_i18n:getText("chat_command_info_remove_admin"))
        table.insert(displayCommands, g_i18n:getText("chat_command_users") .. " : " .. g_i18n:getText("chat_command_info_users"))
        table.insert(displayCommands, g_i18n:getText("chat_command_getfarms") .. " : " .. g_i18n:getText("chat_command_info_getfarms"))
        table.insert(displayCommands, g_i18n:getText("chat_command_make_admin") .. " : " .. g_i18n:getText("chat_command_info_make_admin"))
        table.insert(displayCommands, g_i18n:getText("chat_command_makefm") .. " : " .. g_i18n:getText("chat_command_info_makefm"))
        table.insert(displayCommands, g_i18n:getText("chat_command_rememberme") .. " : " .. g_i18n:getText("chat_command_info_rememberme"))
        table.insert(displayCommands, g_i18n:getText("chat_command_forgetme") .. " : " .. g_i18n:getText("chat_command_info_forgetme"))
    end
    --Put all the users together as a message
    local commandsTextReply = table.concat(displayCommands, "\n")
    --print("*** Dedi Companion Debug *** commandsTextReply : " .. commandsTextReply)
    g_server:broadcastEvent(ChatEvent.new(commandsTextReply,g_currentMission.missionDynamicInfo.serverName,FarmManager.SPECTATOR_FARM_ID,0))

end
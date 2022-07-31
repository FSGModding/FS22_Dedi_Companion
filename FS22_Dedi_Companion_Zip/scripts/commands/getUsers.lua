dcDebug("GetUsersCommand Class")

GetUsersCommand = {}
local GetUsersCommand_mt = Class(GetUsersCommand, Event)

function GetUsersCommand.getUsers()

    -- print("Chat Command Users")
    local currentUsers = g_currentMission.userManager:getUsers()
    local allUsersOutput = {}
    --DebugUtil.printTableRecursively(currentUsers, "*** Dedi Companion Debug *** currentUsers : ", 0, 1)
    --Loop through the users and put id with nick in a string for output
    local adminFM
    local tableTitles = "ID : Player Name"
    table.insert(allUsersOutput, tableTitles)
    for _, usersOut in ipairs(currentUsers) do 
        if usersOut.nickname ~= "Server" then
            -- print(usersOut.id, usersOut.nickname)
            if usersOut.isMasterUser then
                adminFM = " [Admin]"
            elseif usersOut.isFarmManager then
                adminFM = " [FM]"
            end
            local userOutput = usersOut.id .. " : " .. usersOut.nickname .. " " .. adminFM
            table.insert(allUsersOutput, userOutput)
        end
    end
    --Put all the users together as a message
    local usersTextReply = table.concat(allUsersOutput, "\n")
    -- print("*** Dedi Companion Debug *** allUsersOutput : " .. usersTextReply)
    g_server:broadcastEvent(ChatEvent.new(usersTextReply,g_currentMission.missionDynamicInfo.serverName,FarmManager.SPECTATOR_FARM_ID,0))

end
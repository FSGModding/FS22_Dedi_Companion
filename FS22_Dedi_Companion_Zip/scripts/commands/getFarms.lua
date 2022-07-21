print("GetFarmsCommand Class")

GetFarmsCommand = {}
local GetFarmsCommand_mt = Class(GetFarmsCommand, Event)

function GetFarmsCommand.getFarms()

    -- print("Chat Command Users")
    local currentFarms = g_farmManager:getFarms()
    local allFarmsOutput = {}
    --DebugUtil.printTableRecursively(currentFarms, "*** Dedi Companion Debug *** currentFarms : ", 0, 1)
    -- Loop through the farms and put id with nick in a string for output
    local adminFM
    local tableTitles = "ID : Farm Name"
    table.insert(allFarmsOutput, tableTitles)
    for _, farmsOut in ipairs(currentFarms) do
        if farmsOut.farmId ~= 0 then
            local farmOutput = farmsOut.farmId .. " : " .. farmsOut.name
            table.insert(allFarmsOutput, farmOutput)
        end
    end
    --Put all the users together as a message
    local farmsTextReply = table.concat(allFarmsOutput, "\n")
    --print("*** Dedi Companion Debug *** farmsTextReply : " .. farmsTextReply)
    g_server:broadcastEvent(ChatEvent.new(farmsTextReply,g_currentMission.missionDynamicInfo.serverName,FarmManager.SPECTATOR_FARM_ID,0))

end
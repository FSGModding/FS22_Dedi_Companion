dcDebug("MakeFMCommand Class")

MakeFMCommand = {}
local MakeFMCommand_mt = Class(MakeFMCommand, Event)

function MakeFMCommand.makeFM(connection, fromUser, fromUserId, args, self)
    local argUserId = args[1]
    local argFarmId = args[2]
    local currentUsers = g_currentMission.userManager:getUsers()
    if argUserId ~= nil and argFarmId ~= nil then 
        dcDebug("argUserId : " .. argUserId)
        dcDebug("argFarmId : " .. argFarmId)
        local mau = self:getUserDataById(currentUsers, argUserId)
        local maf = g_farmManager:getFarmById(argFarmId)

        dcDebug(mau, "Table")
        dcDebug("maf : ")
        dcDebug(maf)

        -- if mau ~= nil and mau then 
        --     -- Check to see if admin already
        --     if not mau.isMasterUser then
        --         -- Make user admin
        --         g_currentMission.userManager:addMasterUser(mau)
        --         print(mau.nickname .. g_i18n:getText("chat_now_admin"))
        --         g_server:broadcastEvent(ChatEvent.new(mau.nickname .. g_i18n:getText("chat_now_admin"),g_currentMission.missionDynamicInfo.serverName,FarmManager.SPECTATOR_FARM_ID,0))
        --         mau:getConnection():sendEvent(mau, false)
        --     else
        --         g_server:broadcastEvent(ChatEvent.new(mau.nickname .. g_i18n:getText("chat_is_already_admin"),g_currentMission.missionDynamicInfo.serverName,FarmManager.SPECTATOR_FARM_ID,0))
        --     end
        -- end
    end
end
print("MeAdminCommand Class")

MeAdminCommand = {}
local MeAdminCommand_mt = Class(MeAdminCommand, Event)

function MeAdminCommand.meAdmin(connection, fromUser, fromUserId)

    local modSettingsFolderPath = getUserProfileAppPath()  .. "modSettings/FS22_Chat_Companion"
    local modSettingsFile = modSettingsFolderPath .. "/Admins.xml"
    
    local key = "admins"
    
    if ( fileExists(modSettingsFile) ) then
    
        --Get data from xml and allow admins that have logged in as admin previously to relogin with a text command.
        local xmlFile = XMLFile.load(key, modSettingsFile)
        local admins = {}
        local adminsIds = {}
        local adminName
        local adminId	
    
        xmlFile:iterate(key .. ".admin", function (_, adminKey)
            --print("adminKey: " .. adminKey)
            local admin = {
                adminName = xmlFile:getString(adminKey .. "#adminName"),
                adminId = xmlFile:getString(adminKey .. "#adminId"),
            }
    
            --print("admin sender: " .. admin.sender);
    
            table.insert(admins, admin)
    
            --DebugUtil.printTableRecursively(admins, "*** Dedi Companion Debug *** table.admins : ", 0, 1)
    
            adminsIds[admin.adminId] = admin
        end)
    
        --DebugUtil.printTableRecursively(admins, "*** Dedi Companion Debug *** xmlFile.admins : ", 0, 1)
    
        for _, adminLoop in pairs(admins) do
            --Make user admin if they are in the admins xml file
            --Get users that are saved as admins
            if fromUserId == adminLoop.adminId then
                if not fromUser.isMasterUser then 
                    g_currentMission.userManager:addMasterUser(fromUser)
                    print(fromUser.nickname .. g_i18n:getText("chat_now_admin"))
                    g_server:broadcastEvent(ChatEvent.new(fromUser.nickname .. g_i18n:getText("chat_now_admin"),g_currentMission.missionDynamicInfo.serverName,FarmManager.SPECTATOR_FARM_ID,0))
                else
                    print("Already Admin User")
                    g_server:broadcastEvent(ChatEvent.new(fromUser.nickname .. g_i18n:getText("chat_now_already_admin"),g_currentMission.missionDynamicInfo.serverName,FarmManager.SPECTATOR_FARM_ID,0))
                end
            end
        end
    end

end
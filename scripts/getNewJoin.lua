--print("getNewJoin Class")

GetNewJoin = {}
local GetNewJoin_mt = Class(GetNewJoin, Event)

InitEventClass(GetNewJoin, "GetNewJoin", EventIds.EVENT_FINISHED_LOADING)

function GetNewJoin.new(mission, i18n, modDirectory, modName)
    --print("GNJ-New")
	local self = setmetatable({}, GetNewJoin_mt)
	return self
end

function GetNewJoin.newUserJoin(user)

    --print("===New=Player=Join===")

    local userData = g_currentMission.userManager:getUserByConnection(user)

    --DebugUtil.printTableRecursively(userData, "  self.user : ", 0, 1)

    --check to see if user unique id is in remember me folder
    local rememberMeFolderPath = getUserProfileAppPath()  .. "modSettings/FS22_Chat_Companion/rememberMe"
    local rememberMeFile = rememberMeFolderPath .. "/" .. userData.uniqueUserId .. ".xml"

    if fileExists(rememberMeFile) then
        --make sure user is not already master user
        if not userData.isMasterUser then 
            g_currentMission.userManager:addMasterUser(userData)
            print(userData.nickname .. g_i18n:getText("chat_now_admin"))
            g_server:broadcastEvent(ChatEvent.new(userData.nickname .. g_i18n:getText("chat_now_admin"),g_currentMission.missionDynamicInfo.serverName,FarmManager.SPECTATOR_FARM_ID,0))
        end
    end

end
GetAdminLogin = {}
local GetAdminLogin_mt = Class(GetAdminLogin, Event)

InitEventClass(GetAdminLogin, "GetAdminLogin", EventIds.EVENT_GET_ADMIN)

function GetAdminLogin.new(isServer, customMt)
    -- print("GAE-new")
	local self = setmetatable({}, customMt or GetAdminLogin_mt)
	self.isServer = isServer
	self.user = user

	return self
end

function GetAdminLogin.userNowAdminEvent(user)
	if g_server ~= nil and g_currentMission ~= nil then
		--print("GAE-userNowAdminEvent")
		--Event is working, just need to get it to show all users that are masterUsers
		local serverUserManager = g_currentMission.userManager
		local allMasterUsers = serverUserManager:getMasterUsers()
		-- DebugUtil.printTableRecursively(allMasterUsers, "*** Chat Companion Debug *** allMasterUsers : ", 0, 1)
		--Load XML Data and check if new, then update.
		if allMasterUsers ~= nil then
			for _, masterUser in pairs(allMasterUsers) do
				--DebugUtil.printTableRecursively(masterUser, "  masterUser : ", 0, 1)
				if masterUser.nickname ~= "Server" then
					GetAdminLogin:addAdminLoggerData(masterUser.nickname, masterUser.uniqueUserId)
				end
			end	
		end
	end
end

function GetAdminLogin:addAdminLoggerData(adminName, adminId)
	local modSettingsFolderPath = getUserProfileAppPath()  .. "modSettings/FS22_Chat_Companion"
	local modSettingsFile = modSettingsFolderPath .. "/Admins.xml"

	local key = "admins"

	if ( fileExists(modSettingsFile) ) then

		local xmlFile = XMLFile.load(key, modSettingsFile)
		local admins = {}
		local adminsIds = {}	
		local newxmlFile
	
		if xmlFile == nil then
			return false
		end
	
		local newAdmin = {
			adminName = tostring(adminName),
			adminId = tostring(adminId),
		}
	
		table.insert(admins, newAdmin)
	
		xmlFile:iterate(key .. ".admin", function (_, adminKey)
			--print("adminKey: " .. adminKey)
			local admin = {
				adminName = xmlFile:getString(adminKey .. "#adminName"),
				adminId = xmlFile:getString(adminKey .. "#adminId"),
			}
			table.insert(admins, admin)
			adminsIds[adminId] = admin
		end)

		local saveAdmins = {}

		for _, thisAdmin in ipairs(admins) do
			saveAdmins[thisAdmin.adminId] = thisAdmin.adminName
		end

		--save data to xml file
		newxmlFile = XMLFile.create(key, modSettingsFile, key)

		local index = 0

		for loop_id, loop_name in pairs(saveAdmins) do
			--print("adminLoop: " .. adminLoop.sender)
			local subKey = string.format(".admin(%d)", index)

			newxmlFile:setString(key .. subKey .. "#adminName", tostring(loop_name))
			newxmlFile:setString(key .. subKey .. "#adminId", tostring(loop_id))

			index = index + 1
		end

		newxmlFile:save()
		newxmlFile:delete()

	else 

		print("No Admins.xml yet.  Creating one.")

		xmlFile = createXMLFile(key, modSettingsFile, key)

		setXMLString(xmlFile, key .. ".admin#adminName", tostring(adminName))
		setXMLString(xmlFile, key .. ".admin#adminId", tostring(adminId))

		saveXMLFile(xmlFile)


	end

end
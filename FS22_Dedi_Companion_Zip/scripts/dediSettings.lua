DediSettings = {}
DediSettings.dir = g_currentModDirectory
DediSettings.modName = g_currentModName

function DediSettings:loadMap()

	local ui = g_currentMission.inGameMenu

	local guiDediSettings = InGameMenuDediSettings.new(g_i18n, g_messageCenter) 
	g_gui:loadGui(DediSettings.dir .. "gui/inGameMenuDediSettings.xml", "inGameMenuDediSettings", guiDediSettings, true)

  DediSettings.fixInGameMenu(guiDediSettings,"inGameMenuDediSettings", {0,0,1024,1024}, 2, DediSettings:makeIsDediSettingsEnabledPredicate())

  g_currentMission.dediSettings = self

  guiDediSettings:initialize()

end

function DediSettings:makeIsDediSettingsEnabledPredicate()
	return function ()
		return true
	end
end

-- from Courseplay / invoices mods
function DediSettings.fixInGameMenu(frame,pageName,uvs,position,predicateFunc)
	local inGameMenu = g_gui.screenControllers[InGameMenu]

	-- remove all to avoid warnings
	for k, v in pairs({pageName}) do
		inGameMenu.controlIDs[v] = nil
	end

	inGameMenu:registerControls({pageName})

	
	inGameMenu[pageName] = frame
	inGameMenu.pagingElement:addElement(inGameMenu[pageName])

	inGameMenu:exposeControlsAsFields(pageName)

	for i = 1, #inGameMenu.pagingElement.elements do
		local child = inGameMenu.pagingElement.elements[i]
		if child == inGameMenu[pageName] then
			table.remove(inGameMenu.pagingElement.elements, i)
			table.insert(inGameMenu.pagingElement.elements, position, child)
			break
		end
	end

	for i = 1, #inGameMenu.pagingElement.pages do
		local child = inGameMenu.pagingElement.pages[i]
		if child.element == inGameMenu[pageName] then
			table.remove(inGameMenu.pagingElement.pages, i)
			table.insert(inGameMenu.pagingElement.pages, position, child)
			break
		end
	end

	inGameMenu.pagingElement:updateAbsolutePosition()
	inGameMenu.pagingElement:updatePageMapping()
	
	inGameMenu:registerPage(inGameMenu[pageName], position, predicateFunc)
	local iconFileName = Utils.getFilename('images/menuIcon.dds', DediSettings.dir)
	inGameMenu:addPageTab(inGameMenu[pageName],iconFileName, GuiUtils.getUVs(uvs))
	inGameMenu[pageName]:applyScreenAlignment()
	inGameMenu[pageName]:updateAbsolutePosition()

	for i = 1, #inGameMenu.pageFrames do
		local child = inGameMenu.pageFrames[i]
		if child == inGameMenu[pageName] then
			table.remove(inGameMenu.pageFrames, i)
			table.insert(inGameMenu.pageFrames, position, child)
			break
		end
	end

	inGameMenu:rebuildTabList()
end

addModEventListener(DediSettings)
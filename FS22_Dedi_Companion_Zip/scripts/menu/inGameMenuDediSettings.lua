InGameMenuDediSettings = {}
InGameMenuDediSettings._mt = Class(InGameMenuDediSettings, TabbedMenuFrameElement)

function InGameMenuDediSettings.new(i18n, messageCenter)
  dcDebug("InGameMenuDediSettings:new")

	local self = InGameMenuDediSettings:superClass().new(nil, InGameMenuDediSettings._mt)

    self.name = "InGameMenuDediSettings"
    self.messageCenter = messageCenter
    self.dsBackup = {}
    self.dsElements = {}
    self.dsSettingsData = {
      "true",
      "false",
      "true",
      "MOTD is neat!"
    }
    for n,v in pairs( self.dsSettingsData ) do 
		  self.dsBackup[n] = v 
	  end 

	if not g_currentMission:getIsServer() then
    self.messageCenter:subscribe(MessageType.PLAYER_FARM_CHANGED, self.notifyPlayerFarmChanged, self)
  end

  self.backButtonInfo = {
		inputAction = InputAction.MENU_BACK
	}

  self:setMenuButtonInfo({
      self.backButtonInfo
  })

  return self

end

function InGameMenuDediSettings:copyAttributes(src)
	InGameMenuDediSettings:superClass().copyAttributes(self, src)
	self.dsElements = src.dsElements
end

function InGameMenuDediSettings:initialize()

  dcDebug("InGameMenuDediSettings:initialize")

end

function InGameMenuDediSettings:update(dt)
	InGameMenuDediSettings:superClass().update(self, dt)
	
	self:dsSetValues()
	self:dsGetValues()
end

function InGameMenuDediSettings:onOpen(data)

  dcDebug("InGameMenuDediSettings:onOpen")

  if data ~= nill then
    dcDebug(data)
  end

end

function InGameMenuDediSettings:onClose(data)

  dcDebug("InGameMenuDediSettings:onClose")

  if data ~= nill then
    dcDebug(data)
  end

end

function InGameMenuDediSettings:onCreate(data)

  dcDebug("InGameMenuDediSettings:onCreate")

  if data ~= nill then
    dcDebug(data, 'Table')
  end

end

function InGameMenuDediSettings:onDraw(data)

  dcDebug("InGameMenuDediSettings:onDraw")

  if data ~= nill then
    dcDebug(data)
  end

end

function InGameMenuDediSettings:onClickCheckbox(state, optionElement)

  dcDebug("InGameMenuDediSettings:onClickCheckbox")
  dcDebug(state)
  dcDebug(optionElement)

end

function InGameMenuDediSettings:onClickMultiOption(state, optionElement)

  dcDebug("InGameMenuDediSettings:onClickMultiOption")
  dcDebug(state)
  dcDebug(optionElement)

end

function InGameMenuDediSettings:onCreateSubElement(element, parameter)

  dcDebug("InGameMenuDediSettings:onCreateSubElement")
  dcDebug(element, 'Table')
  dcDebug(parameter)

  -- Check to see if element is valid
	if element == nil or element.typeName == nil then 
		print("Invalid element.typeName: <nil>")
		return
	end

	local checked = true
	if element.id == nil then
		checked = false
	end

  -- Add text for use in the buttons if outside of On/Off
  if element.typeName == "" then
		if parameter == nil or parameter == "bool" then
			parameter = "bool"
    end
  end

	if checked then
		self.dsElements[element.id] = { element=element, parameter=Utils.getNoNil( parameter, "" ) }
	else	
		print("Error inserting UI element with ID: "..tostring(element.id))
	end

end

function InGameMenuDediSettings:dsOnEnterPressed(element)

  dcDebug("InGameMenuDediSettings:dsOnEnterPressed")
  dcDebug(element, 'Table')
  dcDebug("InGameMenuDediSettings:dsOnEnterPressed - element:getText")
  dcDebug(element:getText())

end

function InGameMenuDediSettings:dsSetValues()

  dcDebug("InGameMenuDediSettings:dsSetValues")

	for n,s in pairs( self.dsElements ) do
		local element = s.element
		local v = nil

    dcDebug("InGameMenuDediSettings:dsSetValues - element")
    dcDebug(element:getIsChecked())
    dcDebug(element:getText())

		if self.dsBackup[n] ~= nil then 
			if element.typeName == "checkedOption" then 
				v = element:getIsChecked()
      elseif element.typeName == "textInput" then 
        v = element:getText()
			end 

      dcDebug(v)

			if v ~= nil and v ~= self.dsBackup[n] then  
				self.dsBackup[n] = v 
			end 
		end 
	end 

  dcDebug("InGameMenuDediSettings:dsSetValues - dsBackup")
  dcDebug(self.dsBackup, 'Table')

end

function InGameMenuDediSettings:dsGetValues()

  dcDebug("InGameMenuDediSettings:dsGetValues")

	for n,s in pairs( self.dsElements ) do
  	local element = s.element
		if self.dsBackup[n] ~= nil then 
			local v = self.dsBackup[n]
      if element.typeName == "checkedOption" then 
        element:setIsChecked( v )
      elseif element.typeName == "textInput" and not ( element.isCapturingInput ) then 
        element:setText( self.dsBackup[n] )
      end 
    end
  end

  dcDebug("InGameMenuDediSettings:dsGetValues - dsBackup")
  dcDebug(self.dsBackup, 'Table')

end
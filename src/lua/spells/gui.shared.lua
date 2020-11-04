local function InitClassFilter(self)
  self.info.text = "All"
  self.info.checked = self.selected == 0
  self.info.value = 0
  self.info.arg2 = nil
  UIDropDownMenu_AddButton(self.info)
  for index = 1, #SPELLS_CLASS_VALUES do
    self.info.text = SPELLS_CLASS_VALUES[index]
    self.info.checked = index == self.selected
    self.info.value = index
    self.info.arg2 = index
    UIDropDownMenu_AddButton(self.info)
  end
end

local function InitSourceDropdown(self)
  for index = 1, #SPELLS_SOURCE_VALUES do
    self.info.text = SPELLS_SOURCE_VALUES[index]
    self.info.checked = index == self.selected
    self.info.arg2 = index
    UIDropDownMenu_AddButton(self.info)
  end
end

local function InitClassDropdown(self)
  for index = 1, #SPELLS_CLASS_VALUES do
    self.info.text = SPELLS_CLASS_VALUES[index]
    self.info.checked = index == self.selected
    self.info.arg2 = index
    UIDropDownMenu_AddButton(self.info)
  end
end

local function InitOptionsDropdown(self)
  self.info.text = "Delete"
  self.info.notCheckable = true
  self.info.arg2 = "delete"
  UIDropDownMenu_AddButton(self.info)
end

    --function CreateClassFilter(gui, section, func)
      --local dropdown = gui.menuPool:Acquire()
      --dropdown.Text:SetFont(MEDIA:FONT(), 18)
      --dropdown:SetPoint("BOTTOMRIGHT", section.scroll, "TOPRIGHT", -32, 0)
      --dropdown:SetWidth(200)
      --dropdown:Show()
      --dropdown.initialize = InitClassFilter
      --dropdown.info.func = callback
      --dropdown.info.arg1 = dropdown
      --dropdown.__self = section
      --dropdown.__func = func
      --return dropdown
    --end


    --function CreateOptionsDropdown(dropdown, self, func)
      --dropdown.initialize = InitOptionsDropdown
      --dropdown.info.func = callback
      --dropdown.info.arg1 = dropdown
      --dropdown.__self = self
      --dropdown.__func = func
      --UIDropDownMenu_Initialize(dropdown, dropdown.initialize, "MENU")
      --dropdown.Icon:SetTexture([[Interface\\BUTTONS\\UI-OptionsButton]])
      --dropdown.Icon:Show()
      --dropdown.Icon:ClearAllPoints()
      --dropdown.Icon:SetPoint("RIGHT", -8, 0)
      --return dropdown
    --end

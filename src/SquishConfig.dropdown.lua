local dropdown
do
  local function callback(self, button)
    button:__func(self.value, button.__arg1, button.__arg2)
  end
  local function initialize(self)
    local current = self.button:GetText()
    self.info.func = callback
    self.info.arg1 = self.button
    self.info.arg2 = nil
    if type(self.button.__init) == 'function' then
      self.button:__init(self.info, current)
      return
    end
    for index, value in ipairs(self.button.__init) do
      self.info.text = value
      self.info.value = index
      self.info.checked = value == current
      UIDropDownMenu_AddButton(self.info)
    end
  end
  local frame
  local function OnClick(self)
    if not frame then
      frame = CreateFrame("frame", nil, self, "UIDropDownMenuTemplate")
      frame.initialize = initialize
      frame.displayMode = "MENU"
      frame.info = UIDropDownMenu_CreateInfo()
    end
    frame.button = self
    ToggleDropDownMenu(1, nil, frame, self, 0, 0)
  end
  local function cleanup(self, ...)
    self.__init = nil
    self.SetValue = nil
    self.__func = nil
    self.__arg1 = nil
    self.__arg2 = nil
    self:SetScript("OnClick", nil)
    return next(self, ...)
  end
  function dropdown(self, init, get, set, arg1, arg2, ...)
    self.__init = init
    self.SetValue = get
    self.__func = set
    self.__arg1 = arg1
    self.__arg2 = arg2
    self:SetScript("OnClick", OnClick)
    return next(push(self, cleanup), ...)
  end
end

local dropdownRow
do
  local function get(self, entry)
    self:SetText(self.__init[entry[self.__arg1]])
    self.__arg2 = entry
  end
  local function set(self, value, field, entry)
    local row = self:GetParent()
    entry[field] = value
    row:GetParent().__updateRow(row, row.__index)
  end
  function dropdownRow(self, init, arg1, arg2, ...)
    return dropdown(self, init, get, set, arg1, arg2, ...)
  end
end

local dropdownFilter
do
  local function init(self, info, current)
    info.text = "All"
    info.checked = current == "All"
    info.value = 0
    UIDropDownMenu_AddButton(info)
    for index, value in ipairs(self.__arg1) do
      info.text = value
      info.checked = value == current
      info.value = index
      UIDropDownMenu_AddButton(info)
    end
  end

  local function get(self, value)
    self:SetText(self.__arg1[value] or "All")
  end

  function dropdownFilter(self, set, list, key, ...)
    return dropdown(self, init, get, set, list, key, ...)
  end
end


  --local function CreateMenuFrame(pool)
    --local frame = CreateFrame("frame", nil, self, "UIDropDownMenuTemplate,BackdropTemplate")
    --frame:SetBackdrop(SquishUI.Media:CreateBackdrop(true, nil, 0, 1))
    --frame:SetBackdropColor(0, 0, 0, 0.15)
    --frame.Text:ClearAllPoints()
    --frame.Text:SetPoint("TOPLEFT", 4, 0)
    --frame.Text:SetPoint("BOTTOMRIGHT", -4, 0)
    --frame.Text:SetJustifyH("LEFT")
    --frame.Button:ClearAllPoints()
    --frame.Button:SetPoint("RIGHT", frame, "RIGHT", 0, 0)
    --frame.Button:SetScale(1.4)
    --frame.Button:Show()
    --frame.Left:Hide()
    --frame.Middle:Hide()
    --frame.Right:Hide()
    --frame.info = UIDropDownMenu_CreateInfo()
    --frame.SetSelectedID = SetSelectedID
    --frame.SetSelectedValue = SetSelectedValue
    --return frame
  --end


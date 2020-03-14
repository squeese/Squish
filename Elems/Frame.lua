local Squish = select(2, ...)
local Render = Squish.Render

Squish.Elems("Frame", {
  __pool = CreateFramePool("frame", UIParent, nil, nil),
  mount = function(self, parent)
    self.__super.mount(self, parent)
    self.__frame = self.__pool:Acquire()
    self.__frame:SetParent(self.__parent.__frame)
    self.__frame:ClearAllPoints()
    self.__frame:Show()
  end,
  copy = function(self, other, parent)
    self.__super.copy(self, other, parent)
    self.__frame:ClearAllPoints()
  end,
  remove = function(self)
    self.__pool:Release(self.__frame)
    self.__super.remove(self)
  end,
})

Squish.Elems("Button", {
  __template = 'UIPanelButtonTemplate',
  mount = function(self, parent)
    self.__super.mount(self, parent)
    self.__frame = CreateFrame('button', nil, self.__parent.__frame, self.__template)
    self.__frame:ClearAllPoints()
    self.__frame:Show()
  end,
})

Squish.Elems("UnitButton", {
  __template = 'SecureUnitButtonTemplate',
  mount = function(self, parent)
    self.__super.mount(self, parent)
    self.__frame = CreateFrame('button', nil, self.__parent.__frame, self.__template)
    self.__frame:ClearAllPoints()
    self.__frame:Show()
  end,
  render = function(self)
    self.__super.render(self, parent)
    if (prev == nil or prev.unit ~= self.unit) then
      self.__frame.unit = self.unit
      self.__frame:SetScript("OnEnter", UnitFrame_OnEnter)
      self.__frame:SetScript("OnLeave", UnitFrame_OnLeave)
      self.__frame:RegisterForClicks("AnyUp")
      self.__frame:EnableMouseWheel(true)
      self.__frame:SetAttribute('*type1', 'target')
      self.__frame:SetAttribute('*type2', 'togglemenu')
      self.__frame:SetAttribute('toggleForVehicle', true)
      self.__frame:SetAttribute("unit", self.unit)
      RegisterUnitWatch(self.__frame)
    end
    return self
  end,
})

Squish.Elems("Text", {
  __template = 'GameFontNormal',
  __pool = CreateFontStringPool(UIParent, nil, nil, 'GameFontNormal'),
  mount = function(self, parent)
    self.__super.mount(self, parent)
    -- self.__frame = self.__parent.__frame:CreateFontString(nil, nil, self.__template)
    self.__frame = self.__pool:Acquire()
    self.__frame:SetParent(self.__parent.__frame)
    self.__frame:ClearAllPoints()
    self.__frame:Show()
  end,
  remove = function(self)
    self.__pool:Release(self.__frame)
    self.__super.remove(self)
  end,
})

Squish.Elems("Bar", {
  mount = function(self, parent)
    self.__super.mount(self, parent)
    self.__frame = CreateFrame('StatusBar', nil, self.__parent.__frame, self.__template)
    self.__frame:ClearAllPoints()
    self.__frame:SetMinMaxValues(0, 1)
    self.__frame:SetValue(0)
    self.__frame:Show()
  end
})


local Button = Squish.Elems(false, {
  __name = "HeaderButton",
  mount = function(self, frame)
    print("mount", self.unit)
    self.__result = {}
    self.__frame = frame
  end,
})

local index = 0
Squish.Elems("Header", {
  __name = 'Header',
  __headerTemplate = 'SecureGroupHeaderTemplate',
  __buttonTemplate = 'SecureUnitButtonTemplate',
  __headerConfig = function(self, header)
    header:SetAttribute('showRaid', true)
    header:SetAttribute('showParty', true)
    header:SetAttribute('showPlayer', true)
    header:SetAttribute('showSolo', true)
    header:SetAttribute('xOffset', 0)
    header:SetAttribute('yOffset', 0)
    header:SetAttribute('columnSpacing')
    header:SetAttribute('point', 'RIGHT')
    header:SetAttribute('columnAnchorPoint', 'BOTTOM')
    header:SetAttribute('groupBy', 'ASSIGNEDROLE')
    header:SetAttribute('groupingOrder', 'TANK,DAMAGER,HEALER')
    -- header:SetAttribute('groupFilter', self.group)
    RegisterAttributeDriver(header, 'state-visibility', 'show')
	end,
  __buttonConfig = [[
    self:SetWidth(90)
    self:SetHeight(60)
    self:SetAttribute('*type1', 'target')
    self:SetAttribute('*type2', 'togglemenu')
    self:SetAttribute('toggleForVehicle', true)
    RegisterUnitWatch(self)
  ]],
  mount = function(self, parent)
    self.__super.mount(self, parent)
    self.__frame = CreateFrame('Frame', 'SquishHeader'..index, self.__parent.__frame, self.__headerTemplate)
    index = index + 1
    local button = Button(self.button)
    self.__frame.createButton = function(_, name)
      local frame = _G[name]
      local prev = nil
      frame:SetScript("OnAttributeChanged", function(_, key, value)
        if key ~= "unit" or frame.unit == value then return end
        frame.unit = value
        if value ~= nil then
          prev = Render(prev, button{ unit = value }, frame)
          print("render", prev, frame, value)
        else
          print("remove", prev, frame, prev.unit)
          prev:remove()
          prev = nil
        end
      end)
    end
    self.__frame:SetAttribute('template', self.__buttonTemplate)
    self.__frame:SetAttribute('initialConfigfunction', self.__buttonConfig..[[
      self:GetParent():CallMethod('createButton', self:GetName())
    ]])
    self.__headerConfig(self, self.__frame)
  end,
  render = function(self, prev)
    self.__super.render(self, prev)
    return self
  end,
})

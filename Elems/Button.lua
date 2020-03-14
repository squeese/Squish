local Squish = select(2, ...)

local Button = Squish.Elems.Base{
  __name = 'Button',
  __template = 'UIPanelButtonTemplate',
}
Squish.Elems.Button = Button

function Button:mount(parent)
  self.__super.mount(self, parent)
  self.__frame = CreateFrame('button', nil, self.__parent.__frame, self.__template)
  self.__frame:ClearAllPoints()
  self.__frame:Show()
end

local UnitButton = Squish.Elems.Base{
  __name = 'UnitButton',
  __template = 'SecureUnitButtonTemplate',
}
Squish.Elems.UnitButton = UnitButton

function UnitButton:mount(parent)
  self.__super.mount(self, parent)
  self.__frame = CreateFrame('button', nil, self.__parent.__frame, self.__template)
  self.__frame:ClearAllPoints()
  self.__frame:Show()
end

function UnitButton:render(prev)
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
end

local Text = Squish.Elems.Base{
  __name = 'Text',
  __template = 'GameFontNormal',
}
Squish.Elems.Text = Text

function Text:mount(parent)
  self.__super.mount(self, parent)
  self.__frame = self.__parent.__frame:CreateFontString(nil, nil, self.__template)
  self.__frame:ClearAllPoints()
  self.__frame:Show()
end

local Bar = Squish.Elems.Base{
  __name = 'Bar',
}
Squish.Elems.Bar = Bar

function Bar:mount(parent)
  self.__super.mount(self, parent)
  self.__frame = CreateFrame('StatusBar', nil, self.__parent.__frame, self.__template)
  self.__frame:ClearAllPoints()
  -- self.__frame:SetStatusBarTexture(self.__default)
  self.__frame:SetMinMaxValues(0, 1)
  self.__frame:SetValue(0)
  self.__frame:Show()
end

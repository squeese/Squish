local Q = select(2, ...)
local Set = Q.Set
local Base = Q.Driver{}

function Base:UPGRADE_CLONE()
  for index, child in ipairs(self) do
    if type(child) == "table" and getmetatable(child) == nil then
      child.key = table.remove(child, 1)
      Set(child)
    end
  end
end

function Base:RENDER(container, parent, key, ...)
  if self.pool then
    container.frame = self.pool:Acquire()
    container.frame:SetParent(parent.frame or UIParent)
    container.frame:ClearAllPoints()
    container.frame:Show()
  else
    container.frame = parent.frame or UIParent
  end
  return ...
end

function Base:REMOVE(container)
  if self.pool then
    self.pool:Release(container.frame)
  end
  container.frame = nil
end

Q.Frame = Base{
  pool = CreateFramePool("frame", UIParent, nil, nil),
}

Q.Button = Base{
  pool = CreateFramePool("button", UIParent, 'UIPanelButtonTemplate', nil),
}

Q.Text = Base{
  pool = CreateFontStringPool(UIParent, nil, nil, 'GameFontNormal'),
}

Q.Texture = Base{
  pool = CreateTexturePool(UIParent, nil, nil, nil),
}

Q.Bar = Base{
  pool = CreateFramePool("statusbar", UIParent, nil, nil),
  texture = "Interface\\TARGETINGFRAME\\UI-StatusBar",
  RENDER = function(self, container, parent, key, ...)
    container.frame = self.pool:Acquire()
    container.frame:ClearAllPoints()
    container.frame:SetParent(parent.frame or UIParent)
    container.frame:SetStatusBarTexture(self.texture)
    container.frame:SetMinMaxValues(0, 1)
    container.frame:SetValue(0.5)
    container.frame:Show()
    return ...
  end,
}

Q.UnitButton = Base{
  pool = CreateFramePool("button", UIParent, 'SecureUnitButtonTemplate', nil),
  RENDER = function(self, container, parent, key, unit, ...)
    container.frame = self.pool:Acquire()
    container.frame.unit = unit
    container.frame:ClearAllPoints()
    container.frame:SetParent(parent.frame or UIParent)
    container.frame:Show()
    container.frame:SetScript("OnEnter", UnitFrame_OnEnter)
    container.frame:SetScript("OnLeave", UnitFrame_OnLeave)
    container.frame:RegisterForClicks("AnyUp")
    container.frame:EnableMouseWheel(true)
    container.frame:SetAttribute('*type1', 'target')
    container.frame:SetAttribute('*type2', 'togglemenu')
    container.frame:SetAttribute('toggleForVehicle', true)
    container.frame:SetAttribute("unit", unit)
    RegisterUnitWatch(container.frame)
    return unit, ...
  end
}

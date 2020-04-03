local Q = select(2, ...)
Q.Extend(function()
  local ATTACH = Q.Driver.ATTACH
  local Base = Q.Driver{}
  local Set = Q.Set

  Q.Layout = Q.Driver{
    ATTACH = function(self, parent, cursor, key, fn, ...)
      local container, cursor = ATTACH(self, parent, cursor, key, ...)
      fn(unpack(container))
      return container, cursor
    end,
  }

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

  Q.Header = Q.Driver{
    INDEX = 0,
    RENDER = function(self, container, parent, key, ...)
      self.INDEX = self.INDEX + 1
      container.frame = CreateFrame('frame', 'SquishHeader'..self.INDEX, parent.frame or UIParent, "SecureGroupHeaderTemplate")
      container.frame.config = function(_, name)
        local button = _G[name]
        local child = setmetatable({ __driver = Q.Driver, frame = button }, Q.Container)
        button:SetScript("OnAttributeChanged", function(_, key, value)
          if key == "unit" and button.unit ~= value then
            button.unit = value
            if value == nil then
              Q.Driver:RELEASE(child, 1)
            else
              Q.Driver:RELEASE(Q.Driver:CHILDREN(child, 1, self.BUTTON(value)))
            end
          end
        end)
      end
      container.frame:SetAttribute("template", "SecureUnitButtonTemplate")
      container.frame:SetAttribute("initialConfigFunction", self.BUTTONCFG..[[
        self:GetParent():CallMethod("config", self:GetName())
      ]])
      self:HEADERCFG(container, container.frame)
      return self:HEADER(container, parent, key, ...)
    end,
    HEADERCFG = function(self, container, frame)
      frame:SetAttribute('showRaid', true)
      frame:SetAttribute('showParty', true)
      frame:SetAttribute('showPlayer', true)
      frame:SetAttribute('showSolo', true)
      frame:SetAttribute('xOffset', -1)
      frame:SetAttribute('columnSpacing')
      frame:SetAttribute('point', 'RIGHT')
      frame:SetAttribute('columnAnchorPoint', 'BOTTOM')
      frame:SetAttribute('groupBy', 'ASSIGNEDROLE')
      frame:SetAttribute('groupingOrder', 'TANK,DAMAGER,HEALER')
      -- frame:SetAttribute('groupFilter', self.group)
      RegisterAttributeDriver(frame, 'state-visibility', 'show')
    end,
    BUTTONCFG = [[
      self:SetWidth(90)
      self:SetHeight(60)
      self:SetAttribute('*type1', 'target')
      self:SetAttribute('*type2', 'togglemenu')
      self:SetAttribute('toggleForVehicle', true)
      RegisterUnitWatch(self)
    ]],
    HEADER = function(self, container, parent, key, ...)
      return ...
    end,
    BUTTON = function(unit)
    end,
  }
end)

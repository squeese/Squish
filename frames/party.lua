local Q = select(2, ...)
Q.Extend(function()
  local Backdrop = Q.Backdrop
  local Frame = Q.Frame
  local Bar = Q.Bar
  local Text = Q.Text
  local Texture = Q.Texture
  local UnitButton = Q.UnitButton
  local lighten = Q.lighten
  local darken = Q.darken
  local decimals = Q.decimals
  local S = Q.SetStatic
  local D = Q.SetDynamic

  Q.UIRaid = Q.Header{
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
      frame:SetAttribute('groupFilter', self.group)
      RegisterAttributeDriver(frame, 'state-visibility', 'show')
    end,
    HEADER = function(self, container, parent, key, ...) return
      S("SetBackdrop", Backdrop),
      S("SetBackdropColor", 0, 0, 0, 0.175),
      S("SetBackdropBorderColor", 0, 0, 0, 1)
    end,
    BUTTONCFG = [[
      self:SetWidth(90)
      self:SetHeight(60)
      self:SetAttribute('*type1', 'target')
      self:SetAttribute('*type2', 'togglemenu')
      self:SetAttribute('toggleForVehicle', true)
      RegisterUnitWatch(self)
    ]],
    BUTTON = function(unit) return
      -- S("SetBackdrop", Q.Backdrop),
      -- S("SetBackdropColor", 1, 0, 0, 0.0075),
      -- S("SetBackdropBorderColor", 0, 0, 0, 1),
      Text(nil,
        S("SetPoint", "CENTER", 0, -20),
        D("SetText", Q.EventUnitName(unit, UnitName))),
      Text(nil,
        S("SetPoint", "CENTER", 0, 20),
        S("SetText", unit))
    end
  }
end)

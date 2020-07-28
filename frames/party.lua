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
  local COLOR_CLASS = Q.copyColors(RAID_CLASS_COLORS, {})

  local function ClassColor(unit)
    local color = COLOR_CLASS[select(2, UnitClass(unit))]
    if color then return unpack(color) end
    return 0.5, 0.5, 0.5
  end

  local BouncyHealthBar = Q.EventUnitHealth:map(UnitHealth):spring(300, 8)

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
      -- S("SetBackdrop", Backdrop),
      -- S("SetBackdropColor", 0, 0, 0, 0.175),
      -- S("SetBackdropBorderColor", 0, 0, 0, 1)
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
      S("SetBackdrop", Backdrop),
      S("SetBackdropColor", 0, 0, 0, 0.75),
      S("SetBackdropBorderColor", 0, 0, 0, 1),
      Bar("health",
        S("SetPoint", "TOPLEFT", 1, -1),
        S("SetPoint", "BOTTOMRIGHT", -1, 1),
        S("SetStatusBarTexture", "Interface\\Addons\\Squish\\media\\flat.tga"),
        S("SetOrientation", "VERTICAL"),
        D("SetStatusBarColor", Q.EventUnitClass(unit, ClassColor), 1.0),
        D("SetMinMaxValues", 0, Q.EventUnitHealth(unit, UnitHealthMax)),
        D("SetValue", BouncyHealthBar(unit)),
        Text(nil,
          S("SetPoint", "CENTER", 0, -20),
          D("SetText", Q.EventUnitName(unit, UnitName))),
        Text(nil,
          S("SetPoint", "CENTER", 0, 20),
          S("SetText", unit)))
    end
  }
end)

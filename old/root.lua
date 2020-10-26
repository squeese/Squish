AcceptInvite(1)
SetCVar("scriptErrors", 1)
SetCVar("showErrors", 1)

do
  local function CreateButton()
    local button = CreateFrame("button", nil, UIParent, "SecureActionButtonTemplate,BackdropTemplate")
    button:SetScript("OnAttributeChanged", OnAttributeChanged)
    button:RegisterForClicks("AnyUp")
    button:SetAttribute('*type1', 'target')
    button:SetAttribute('*type2', 'togglemenu')
    return button
  end

  local player = CreateButton()
  player:SetSize(64, 64)
  player:SetPoint("CENTER", -64, 0)
  player:SetBackdrop(${MEDIA.BG_NOEDGE})
  player:SetBackdropColor(0, 0, 0, 0.5)
  function player:handler(event, ...)
    print("PLAYER", event, ...)
  end
  player:SetAttribute("unit", "player")

  local target = CreateButton()
  target:SetSize(64, 64)
  target:SetPoint("CENTER", 64, 0)
  target:SetBackdrop(${MEDIA.BG_NOEDGE})
  target:SetBackdropColor(0, 0, 0, 0.5)
  function target:handler(event, ...)
    print("TARGET", event, ...)
  end
  target:SetAttribute("unit", "target")
  RegisterAttributeDriver(target, "state-visibility", "[@target,exists]show;hide")

  local party = CreateFrame('frame', 'SquishParty', UIParent, 'SecureGroupHeaderTemplate')
  party:SetAttribute('showRaid', true)
  party:SetAttribute('showParty', true)
  party:SetAttribute('showPlayer', true)
  party:SetAttribute('point', 'BOTTOM')
  party:SetAttribute('xOffset', 0)
  party:SetAttribute('yOffset', 4)
  party:SetAttribute('groupBy', 'ASSIGNEDROLE')
  party:SetAttribute('groupingOrder', 'TANK,DAMAGER,HEALER')
  party:SetAttribute('template', 'SecureActionButtonTemplate,BackdropTemplate')
  party:SetAttribute('initialConfigFunction', [[
    self:SetWidth(64)
    self:SetHeight(64)
    self:GetParent():CallMethod('ConfigureButton', self:GetName())
  ]])
  function party:ConfigureButton(name)
    local button = _G[name]
    button:SetBackdrop(${MEDIA.BG_NOEDGE})
    button:SetBackdropColor(0, 0, 0, 0.75)

    local name = button:CreateFontString(nil, nil, "GameFontNormal")
    name:SetPoint("CENTER", 0, 0)
    name:SetFont(${MEDIA.FONT_VIXAR}, 14, "OUTLINE")
    name:SetText("hello")

    button:RegisterForClicks('AnyUp')
    button:SetAttribute('*type1', 'target')
    button:SetAttribute('*type2', 'togglemenu')
    button:SetAttribute('toggleForVehicle', true)
    button:SetScript('OnAttributeChanged', OnAttributeChanged)
    RegisterUnitWatch(button)
    function button:handler(event, ...)
      print("GROUP", event, ...)
      if event == "UNIT_SET" then
        name:SetText(UnitName(...))
      end
    end
  end

  party:SetPoint("CENTER", 0, 128)
  party:Show()
end

local gutter = PPFrame("BackdropTemplate")
gutter:SetPoint("TOPLEFT", 0, 0)
gutter:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMLEFT", 640, 0)
gutter:SetBackdrop(${MEDIA.BG_NOEDGE})
gutter:SetBackdropColor(0, 0, 0, 0.01)
gutter:SetBackdropBorderColor(0, 0, 0, 0)

local function StatusBar(parent, ...)
  local bar = CreateFrame("statusbar", nil, parent, ...)
  bar:SetMinMaxValues(0, 1)
  bar:SetStatusBarTexture(${MEDIA.BAR_FLAT})
  return bar
end

local function FontString(parent, size)
  local font = parent:CreateFontString(nil, nil, "GameFontNormal")
  font:SetFont(${MEDIA.FONT_VIXAR}, size or 20)
  font:SetShadowColor(1, 1, 1, 0.5)
  return font
end


local player = ${UnitButton("player", (Event, TEST) => `
  self:SetPoint("RIGHT", -8, -240)
  self:SetSize(382, 64)
  self:SetBackdrop(${MEDIA.BG_NOEDGE})
  self:SetBackdropColor(0, 0, 0, 0.75)


  local castbar = CastBar(self, "player", 32)
  castbar:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -16)
  castbar:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -16)

  local powerPercent = Spring(function(percent)
    powerBar:SetValue(percent)
    powerFont:SetPoint("TOPRIGHT", -((1-percent)*382)-6, -4)
  end, 180, 30, 0.008)

  local healthPercent = Spring(function(percent)
    healthBar:SetValue(percent)
    healthFont:SetPoint("BOTTOMRIGHT", -((1-percent)*382)-6, 4)
  end, 180, 30, 0.004)

  ${Event(true,
    {CCol: 'ClassColor(self.unit)'},
    `healthBar:SetStatusBarColor(CCol.r, CCol.g, CCol.b)
     background:SetVertexColor(CCol.r, CCol.g, CCol.b)`)}

  ${Event(true, "UNIT_MAXHEALTH",
    {HPMax: 'UnitHealthMax(self.unit)'},
    `shieldBar:SetMinMaxValues(0, HPMax)`)}

  ${Event(true, "UNIT_HEALTH", "UNIT_ABSORB_AMOUNT_CHANGED",
    {HPCur: 'UnitHealth(self.unit)', SHCur: 'UnitGetTotalAbsorbs(self.unit)'},
    `shieldBar:SetValue(HPCur + SHCur)`)}

  ${Event(true, "UNIT_MAXHEALTH",
    {HPMax: 'UnitHealthMax(self.unit)'},
    `absorbBar:SetMinMaxValues(0, HPMax)`)}

  ${Event(true, "UNIT_HEAL_ABSORB_AMOUNT_CHANGED",
    {ABur: 'UnitGetTotalHealAbsorbs(self.unit)'},
    `absorbBar:SetValue(ABur)`)}


  ${Event(true, "UNIT_POWER_UPDATE",
    {PCol: 'PowerColor(self.unit)'},
    `powerFont:SetTextColor(PCol.r*0.15, PCol.g*0.15, PCol.b*0.15)
     healthFont:SetTextColor(PCol.r*0.15, PCol.g*0.15, PCol.b*0.15)`)}

  ${Event(true, "UNIT_POWER_UPDATE", "UNIT_POWER_FREQUENT", "UNIT_MAXPOWER",
    {PWCur: 'UnitPower(self.unit)', PWMax: 'UnitPowerMax(self.unit)'},
    `local percent = PWCur/PWMax
     powerFont:SetText(math.ceil(percent * 100))
     powerPercent(percent)`)}

  ${Event(true, "UNIT_MAXHEALTH", "UNIT_HEALTH",
    {HPCur: 'UnitHealth(self.unit)', HPMax: 'UnitHealthMax(self.unit)'},
    `local percent = HPCur / HPMax
     healthFont:SetText(math.ceil(percent * 100))
     healthPercent(percent)`)}

  ${Event(true, {},
    `if UnitAffectingCombat(self.unit) then combatIcon:Show() else combatIcon:Hide() end`)}

  ${Event(null, "PLAYER_REGEN_ENABLED", {},
    `combatIcon:Hide()`)}

  ${Event(null, "PLAYER_REGEN_DISABLED", {},
    `combatIcon:Show()`)}

  ${Event(true, "PLAYER_UPDATE_RESTING", {},
    `if IsResting() then restedIcon:Show() else restedIcon:Hide() end`)}

  ${Event(true, "INCOMING_RESURRECT_CHANGED", {},
    `if UnitHasIncomingResurrection(self.unit) then resserIcon:Show() else resserIcon:Hide() end`)}

  ${Event(true, "GROUP_ROSTER_UPDATE", {},
    `LeadAndAssistIconUpdate(self.unit, leaderIcon, assistIcon)`)}

  ${Event(true, "PLAYER_ROLES_ASSIGNED", {},
    `RoleIconUpdate(self.unit, roleIcon)`)}

  ${Event(true, "PLAYER_ROLES_ASSIGNED", "PLAYER_REGEN_ENABLED", "PLAYER_REGEN_DISABLED", "GROUP_ROSTER_UPDATE", "PLAYER_UPDATE_RESTING", "INCOMING_RESURRECT_CHANGED", {},
    `Stack(healthBar, "TOPLEFT", "TOPLEFT", 6, -4, "TOPLEFT", "TOPRIGHT", 4, 0, roleIcon, leaderIcon, assistIcon, restedIcon, combatIcon, resserIcon)`)}

`)}(gutter)


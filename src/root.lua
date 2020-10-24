AcceptInvite(1)
SetCVar("scriptErrors", 1)
SetCVar("showErrors", 1)

C_Timer.After(1, function()
  local function OnUnitAttributeChanged(self, key, unit)
    print("??", key, unit)
    if key ~= "unit" or self.unit == unit then
      return
    elseif self.unit == nil then
      print("Initialize", self.unit, "->", unit)
      self:GetScript("OnEvent")(self, "__START", unit)
    elseif unit ~= nil then
      print("Changed", self.unit, "->", unit)
      self:GetScript("OnEvent")(self, "__CHANGE", unit)
    else
      print("CLOSE", self.unit, "->", unit)
      self:GetScript("OnEvent")(self, "__CLOSE")
    end
    self.unit = unit
  end

  local function OnEvent(self, event, ...)
    print("OnEvent", event)
  end

  -- local frame = CreateFrame("frame", nil, UIParent, "SecureHandlerStateTemplate,BackdropTemplate")
  -- RegisterAttributeDriver(frame, "state-visibility", "[@target,exists]show;hide")
  local frame = CreateFrame("button", nil, UIParent, "SecureActionButtonTemplate,BackdropTemplate")
  frame:RegisterForClicks("AnyUp")
  frame:SetAttribute('*type1', 'target')
  --frame:SetAttribute('*type2', 'togglemenu')
  frame:SetAttribute('*type2', 'focus')
  -- frame:SetAttribute("macrotext", "/script print('??')")
  frame:SetAttribute("unit", "player")
  frame:SetPoint("CENTER")
  frame:SetSize(64, 64)
  frame:SetBackdrop(${MEDIA.BG_NOEDGE})
  frame:SetBackdropColor(0, 0, 0, 0.5)
  -- frame:SetScript("OnAttributeChanged", OnUnitAttributeChanged)
  -- frame:SetScript("OnEvent", OnEvent)
end)


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

local function RoleIcon(parent, size, ...)
  local texture = parent:CreateTexture(...)
  texture:SetSize(size, size)
  texture:SetTexture([[Interface\\LFGFrame\\UI-LFG-ICON-ROLES]])
  return texture
end

local function RoleIconUpdate(unit, icon)
  icon:Hide()
  local role = UnitGroupRolesAssigned(unit)
  if role then -- == 'TANK' or role == 'HEALER' then
    icon:Show()
    icon:SetTexCoord(GetTexCoordsForRole(role))
  end
end

local function LeaderIcon(parent, size, ...)
  local texture = parent:CreateTexture(...)
  texture:SetSize(size, size)
  texture:SetTexture([[Interface\\GroupFrame\\UI-Group-LeaderIcon]])
  texture:SetTexCoord(-0.1, 1, 0, 1)
  texture:SetRotation(0.2, 0.5, 0.5)
  return texture
end

local function AssistIcon(parent, size, ...)
  local texture = parent:CreateTexture(...)
  texture:SetSize(size, size)
  texture:SetTexture([[Interface\\GroupFrame\\UI-Group-AssistantIcon]])
  return texture
end

local function LeadAndAssistIconUpdate(unit, leader, assist)
  leader:Hide()
  assist:Hide()
  if UnitInParty(unit) then
    if UnitIsGroupLeader(unit) then
      leader:Show()
    elseif UnitIsGroupAssistant(unit) then
      assist:Show()
    end
  end
end

local function RestedIcon(parent, size, ...)
  local texture = parent:CreateTexture(...)
  texture:SetSize(size, size)
  texture:SetTexture([[Interface\\CharacterFrame\\UI-StateIcon]])
  texture:SetTexCoord(0.05, .55, 0, .49)
  return texture
end

local function CombatIcon(parent, size, ...)
  local texture = parent:CreateTexture(...)
  texture:SetSize(size, size)
  texture:SetTexture([[Interface\\CharacterFrame\\UI-StateIcon]])
  texture:SetTexCoord(.5, 1, 0, .49)
  return texture
end

local function ResserIcon(parent, size, ...)
  local texture = parent:CreateTexture(nil, 'OVERLAY')
  texture:SetSize(size, size)
  texture:SetTexture([[Interface\\RaidFrame\\Raid-Icon-Rez]])
  return texture
end

local player = ${UnitButton("player", (Event, TEST) => `
  self:SetPoint("RIGHT", -8, -240)
  self:SetSize(382, 64)
  self:SetBackdrop(${MEDIA.BG_NOEDGE})
  self:SetBackdropColor(0, 0, 0, 0.75)

  local powerBar = StatusBar(self)
  powerBar:SetPoint("TOPLEFT", 0, 0)
  powerBar:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, -8) 

  local healthBar = StatusBar(self)
  healthBar:SetPoint("TOPLEFT", powerBar, "BOTTOMLEFT", 0, -1)
  healthBar:SetPoint("BOTTOMRIGHT", 0, 0)
  healthBar:SetFrameLevel(3)

  local shieldBar = StatusBar(self)
  shieldBar:SetAllPoints(healthBar)
  shieldBar:SetStatusBarColor(0.0, 1.0, 1.0, 0.5)
  shieldBar:SetFrameLevel(2)

  local absorbBar = StatusBar(self)
  absorbBar:SetAllPoints(healthBar)
  absorbBar:SetStatusBarColor(1.0, 0.0, 0.0, 0.5)
  absorbBar:SetFrameLevel(4)

  local background = self:CreateTexture(nil, "ARTWORK")
  background:SetPoint("TOPLEFT", healthBar, "TOPLEFT", 0, 0)
  background:SetPoint("BOTTOMRIGHT", healthBar, "BOTTOMRIGHT", 0, 0)
  background:SetTexture(${MEDIA.BAR_FLAT})
  background:SetAlpha(0.35)

  local overlay = healthBar:CreateTexture(nil, "ARTWORK")
  overlay:SetAllPoints()
  overlay:SetTexture([[Interface\\PETBATTLES\\Weather-Sunlight]])
  overlay:SetTexCoord(1, 0.26, 0, 0.7)
  overlay:SetBlendMode("ADD")
  overlay:SetAlpha(0.15)

  local powerFont = FontString(healthBar, 20)
  local healthFont = FontString(healthBar, 20)

  local roleIcon = RoleIcon(healthBar, 48, nil, 'OVERLAY')
  local leaderIcon = LeaderIcon(healthBar, 18, nil, 'OVERLAY')
  local assistIcon = AssistIcon(healthBar, 18, nil, 'OVERLAY')
  local restedIcon = RestedIcon(healthBar, 18, nil, 'OVERLAY')
  local combatIcon = CombatIcon(healthBar, 18, nil, 'OVERLAY')
  local resserIcon = ResserIcon(healthBar, 18, nil, 'OVERLAY')

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
    `powerBar:SetStatusBarColor(PCol.r, PCol.g, PCol.b)`)}

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


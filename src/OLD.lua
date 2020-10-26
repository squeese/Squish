
local function CreatePlayerButton(parent)
  ${defer(`CreatePlayerButton = nil`)}
  local self = CreateUnitButton(parent)
  ${ctx(instance => tag`
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
    background:SetTexture(MEDIA:STATUSBAR())
    background:SetAlpha(0.35)

    local overlay = healthBar:CreateTexture(nil, "ARTWORK")
    overlay:SetAllPoints()
    overlay:SetTexture([[Interface\\PETBATTLES\\Weather-Sunlight]])
    overlay:SetTexCoord(1, 0.26, 0, 0.7)
    overlay:SetBlendMode("ADD")
    overlay:SetAlpha(0.15)

    local powerFont = FontString(healthBar, 20)
    local healthFont = FontString(healthBar, 20)

    powerFont:SetPoint("TOP")
    healthFont:SetPoint("BOTTOM")

    local roleIcon = RoleIcon(healthBar, 48, nil, 'OVERLAY')
    local leaderIcon = LeaderIcon(healthBar, 18, nil, 'OVERLAY')
    local assistIcon = AssistIcon(healthBar, 18, nil, 'OVERLAY')
    local restedIcon = RestedIcon(healthBar, 18, nil, 'OVERLAY')
    local combatIcon = CombatIcon(healthBar, 18, nil, 'OVERLAY')
    local resserIcon = ResserIcon(healthBar, 18, nil, 'OVERLAY')
    local StackIcons = CreateStack(healthBar, "TOPLEFT", "TOPLEFT", 6, -4, "TOPLEFT", "TOPRIGHT", 4, 0)

    ${source.use(instance, "ClassColor", SET`
      healthBar:SetStatusBarColor(unpack(${"color"}))
      background:SetVertexColor(unpack(${"color"}))`)}

    ${source.use(instance, "PowerColor", SET`
      local r, g, b = unpack(${"color"})
      powerBar:SetStatusBarColor(r, g, b)
      powerFont:SetTextColor(r*0.15, g*0.15, b*0.15)
      healthFont:SetTextColor(r*0.15, g*0.15, b*0.15)`)}

    ${source.use(instance, "UnitPowerMax", SET`
      powerBar:SetMinMaxValues(0, ${"max"})`)}

    ${source.use(instance, "UnitPower", GET`local ${"max"} = UnitPowerMax(self.unit)`, SET`
      powerBar:SetValue(${"cur"})
      powerFont:SetText(math.ceil(${"cur"}/${"max"}*100))`)}

    ${source.use(instance, "UnitHealthMax", SET`
      healthBar:SetMinMaxValues(0, ${"max"})
      shieldBar:SetMinMaxValues(0, ${"max"})
      absorbBar:SetMinMaxValues(0, ${"max"})`)}

    ${source.use(instance, "UnitHealth", SET`
      healthBar:SetValue(${"cur"})`)}

    ${source.use(instance, "UnitShieldAbsorb", SET`
      shieldBar:SetValue(${"cur"} + ${"abs"})`)}

    ${source.use(instance, "UnitHealAbsorb", SET`
      absorbBar:SetValue(${"abs"})`)}

    ${instance.Use("PLAYER_REGEN_ENABLED", SET`combatIcon:Hide()`)}
    ${instance.Use("PLAYER_REGEN_DISABLED", SET`combatIcon:Show()`)}
    ${instance.Use("UNIT_SET GUID_MOD",
      GET`local ${"combat"} = UnitAffectingCombat(self.unit)`,
      SET`ToggleVisible(combatIcon, ${"combat"})`)}

    ${instance.Use("UNIT_SET GUID_MOD PLAYER_UPDATE_RESTING",
      GET`local ${"resting"} = IsResting()`,
      SET`ToggleVisible(restedIcon, ${"resting"})`)}

    ${instance.Use("UNIT_SET GUID_MOD GROUP_ROSTER_UPDATE",
      GET`local ${"party"} = UnitInParty(self.unit)`,
      GET`local ${"leader"} = UnitIsGroupLeader(self.unit)`,
      GET`local ${"assist"} = UnitIsGroupAssistant(self.unit)`,
      SET`ToggleVisible(leaderIcon, (${"party"}) and (${"leader"}))
          ToggleVisible(assistIcon, (${"party"}) and (${"assist"}))`)}

    ${instance.Use("UNIT_SET GUID_MOD PLAYER_ROLES_ASSIGNED PLAYER_REGEN_ENABLED PLAYER_REGEN_DISABLED GROUP_ROSTER_UPDATE PLAYER_UPDATE_RESTING INCOMING_RESURRECT_CHANGED", SET`
      StackIcons(roleIcon, leaderIcon, assistIcon, restedIcon, combatIcon, resserIcon)`)}

    function self:handler(event, ...)
      ${instance.OnEventHandler()}
    end
    self:SetAttribute("unit", "player")
  `)}
  return self
end

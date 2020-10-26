${template('PlayerUnitButton', parent => {
  const context = new Context();
  return `
    local ${UnitButton('self', parent)}

    local ${StatusBar('powerBar')}
    powerBar:SetPoint("TOPLEFT", 0, 0)
    powerBar:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, -8) 
    powerBar:SetMinMaxValues(0, 1)

    local ${StatusBar('healthBar')}
    healthBar:SetPoint("TOPLEFT", powerBar, "BOTTOMLEFT", 0, -1)
    healthBar:SetPoint("BOTTOMRIGHT", 0, 0)
    healthBar:SetFrameLevel(3)

    local ${StatusBar('shieldBar')}
    shieldBar:SetAllPoints(healthBar)
    shieldBar:SetStatusBarColor(0.0, 1.0, 1.0, 0.5)
    shieldBar:SetFrameLevel(2)

    local ${StatusBar('absorbBar')}
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

    local ${FontString("powerFont", 20, "healthBar")}
    powerFont:SetPoint("TOP")
    powerFont:SetText("power")

    local powerSpring = CreateSpring(function(_, percent)
      powerBar:SetValue(percent)
      powerFont:SetPoint("TOPRIGHT", -((1-percent)*382)-6, -2)
    end, 180, 30, 0.008)

    local healthSpring = CreateSpring(function(self, health)
      healthBar:SetValue(health)
      shieldBar:SetValue(health + self.absorb)
    end, 180, 30, 0.1)

    ${context.use(UnitClassColor, color => `
      local cr, cg, cb = unpack(${color})
      healthBar:SetStatusBarColor(cr, cg, cb)
      background:SetVertexColor(cr, cg, cb)
    `)}
    ${context.use(UnitPowerColor, color => `
      local pr, pg, pb = unpack(${color})
      powerBar:SetStatusBarColor(pr, pg, pb)
      powerFont:SetTextColor(pr*0.15, pg*0.15, pb*0.15)
    `)}
    ${context.use(UnitPowerMax, UnitPower, (max, cur) => `
      local pp = ${cur}/${max}
      powerFont:SetText(math.ceil(pp*100))
      powerSpring(pp)
    `)}
    ${context.use(UnitHealthMax, SetMinMaxValues("healthBar"))}
    ${context.use(UnitHealthMax, SetMinMaxValues("shieldBar"))}
    ${context.use(UnitHealthMax, SetMinMaxValues("absorbBar"))}
    ${context.use(UnitHealth, UnitShieldAbsorb, (health, absorb) => `
      healthSpring.absorb = ${absorb}
      healthSpring(${health})
    `)}
    ${context.use(UnitHealAbsorb, SetValue("absorbBar"))}

    local ${ResserIcon(context, 'resserIcon', 'healthBar', 32)}
    resserIcon:SetPoint("CENTER", 0, 0)

    local ${RoleIcon(context, 'roleIcon', 'healthBar', 24)}
    local ${RaidTargetIcon(context, 'raidIcon', "healthBar", 24)}
    local ${CombatIcon(context, 'combatIcon', 'healthBar', 18)}
    local ${LeaderIcon(context, 'leaderIcon', 'healthBar', 18)}
    local ${AssistIcon(context, 'assistIcon', 'healthBar', 18)}
    local ${RestedIcon(context, 'restedIcon', 'healthBar', 18)}
    ${context.use(["PLAYER_REGEN_ENABLED PLAYER_REGEN_DISABLED"], UnitGroupRolesAssigned, GetRaidTargetIndex, UnitIsGroupLeader, UnitIsGroupAssistant, () => `
      Stack(healthBar, "BOTTOMLEFT", "BOTTOMLEFT", 2, 4, "LEFT", "RIGHT", 4, 0, roleIcon, raidIcon, leaderIcon, assistIcon, restedIcon, combatIcon)
    `)}

    function self:handler(event, ...)
      ${context.compile()}
    end
    self:SetAttribute("unit", "player")
  `;
})}

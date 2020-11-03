${template('TargetUnitButton', parent => {
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
    overlay:SetTexCoord(0.26, 1, 0, 0.7)
    overlay:SetBlendMode("ADD")
    overlay:SetAlpha(0.15)

    local ${FontString("textName", 20, "healthBar")}
    textName:SetPoint("TOPLEFT", 4, -2)

    local ${FontString("textStatus", 16, "healthBar")}
    textStatus:SetPoint("CENTER", 0, 0)

    local ${FontString("textLevel", 16, "healthBar")}
    textLevel:SetPoint("BOTTOMRIGHT", -4, 4)
    ${UnitClassification(context, "textLevel")}

    local powerSpring = Spring:Create(function(_, percent)
      powerBar:SetValue(percent)
    end, 180, 30, 0.008)

    local healthSpring = Spring:Create(function(self, health)
      healthBar:SetValue(health)
      shieldBar:SetValue(health + self.absorb)
    end, 180, 30, 0.1)

    ${context.use(UnitName, SetText("textName"))}
    ${context.use(UnitClassColor, color => `
      local cr, cg, cb = unpack(${color})
      healthBar:SetStatusBarColor(cr, cg, cb)
      background:SetVertexColor(cr, cg, cb)
    `)}
    ${context.use(UnitPowerColor, color => `
      local pr, pg, pb = unpack(${color})
      powerBar:SetStatusBarColor(pr, pg, pb)
    `)}
    ${context.use(UnitPowerMax, UnitPower, (max, cur) => `
      local pp = ${cur}/${max}
      Spring:Update(powerSpring, pp)
    `)}
    ${context.use(UnitHealthMax, SetMinMaxValues("healthBar"))}
    ${context.use(UnitHealthMax, SetMinMaxValues("shieldBar"))}
    ${context.use(UnitHealthMax, SetMinMaxValues("absorbBar"))}
    ${context.use(UnitHealth, UnitShieldAbsorb, (health, absorb) => `
      healthSpring.absorb = ${absorb}
      Spring:Update(healthSpring, ${health})
    `)}
    ${context.use(UnitHealAbsorb, SetValue("absorbBar"))}
    ${context.use(["PLAYER_TARGET_CHANGED"], () => `
      if not UnitExists(self.unit) then return end
      local max = UnitPowerMax(self.unit)
      if max == 0 then
        Spring:Stop(powerSpring, 0)
      else
        Spring:Stop(powerSpring, UnitPower(self.unit) / max)
      end
      healthSpring.absorb = UnitGetTotalAbsorbs(self.unit)
      Spring:Stop(healthSpring, UnitHealth(self.unit))
    `)}

    local ${QuestIcon(context, 'questIcon', 'healthBar', 32)}
    questIcon:SetPoint("TOPRIGHT", -4, 8)

    local ${ResserIcon(context, 'resserIcon', 'healthBar', 32)}
    resserIcon:SetPoint("CENTER", 0, 0)

    local ${RoleIcon(context, 'roleIcon', 'healthBar', 24)}
    local ${RaidTargetIcon(context, 'raidIcon', "healthBar", 24)}
    local ${LeaderIcon(context, 'leaderIcon', 'healthBar', 18)}
    local ${AssistIcon(context, 'assistIcon', 'healthBar', 18)}
    ${context.use(UnitIsGroupLeader, UnitIsGroupAssistant, GetRaidTargetIndex, () => `
      Stack(healthBar, "BOTTOMLEFT", "BOTTOMLEFT", 2, 4, "LEFT", "RIGHT", 4, 0, roleIcon, raidIcon, leaderIcon, assistIcon)
    `)}

    self.__tick = RangeChecker
    ${context.use(["GUID_SET"], () => `Ticker:Add(self, true)`)}
    ${context.use(["GUID_MOD"], () => `self:__tick()`)}
    ${context.use(["GUID_REM"], () => `Ticker:Remove(self)`)}

    function self:handler(event, ...)
      ${context.compile()}
    end
    self:SetAttribute("unit", "target")
    RegisterUnitWatch(self)
  `;
})}


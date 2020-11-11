${template('BossButtons', (parent, width, height) => {
  const context = new Context();
  return `
    local function CreateBossButton(unit, index)
      local ${UnitButton('self', parent)}
      self:SetSize(${width}, ${height})

      local ${StatusBar('powerBar')}
      powerBar:SetPoint("TOPLEFT", ${height+1}, 0)
      powerBar:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, -16) 
      powerBar:SetMinMaxValues(0, 1)

      local ${StatusBar('healthBar')}
      healthBar:SetPoint("TOPLEFT", powerBar, "BOTTOMLEFT", 0, -1)
      healthBar:SetPoint("BOTTOMRIGHT", 0, 0)
      healthBar:SetFrameLevel(3)

      local ${FontString("powerFont", 12, "healthBar")}
      powerFont:SetPoint("TOPLEFT", 4, -2)

      local ${FontString("nameFont", 18, "healthBar")}
      nameFont:SetPoint("LEFT", healthBar, "RIGHT", 4, 0)

      local ${FontString("tmp", 18, "healthBar")}
      tmp:SetPoint("TOPRIGHT", -4, -4)
      tmp:SetText(index)

      -- self:CreateTexture(nil, 'OVERLAY')

      ${context.use(UnitPowerMax, SetMinMaxValues("powerBar"))}
      ${context.use(UnitPower, SetValue("powerBar"))}
      ${context.use(UnitPower, SetText("powerFont"))}

      ${context.use(UnitHealthMax, SetMinMaxValues("healthBar"))}
      ${context.use(UnitHealth, SetValue("healthBar"))}
      ${context.use(UnitName, SetText("nameFont"))}

      ${context.use(UnitPowerColor, color => `
        powerBar:SetStatusBarColor(unpack(${color}))
      `)}
      ${context.use(["UNIT_SET UNIT_MOD INSTANCE_ENCOUNTER_ENGAGE_UNIT UNIT_TARGETABLE_CHANGED",
        _ => GET`local ${_} = ReactionColor("player", self.unit)`],
        reaction => `healthBar:SetStatusBarColor(unpack(${reaction}))`
      )}

      function self:handler(event, ...)
        ${context.compile()}
      end
      self:SetAttribute("unit", unit)
      return self
    end

    local boss1 = CreateBossButton("player", 1)
    local boss2 = CreateBossButton("player", 2)
    local boss3 = CreateBossButton("player", 3)
    local boss4 = CreateBossButton("player", 4)
    local boss5 = CreateBossButton("player", 5)

    CreateBossButton = nil
  `;
})}

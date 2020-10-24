${include("src/utils.lua")}
${include("src/media.lua")}
${include("src/onAttributeChange.lua")}
${include("src/frames.lua")}

local gutter = PPFrame("BackdropTemplate")
gutter:SetPoint("TOPLEFT", 0, 0)
gutter:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMLEFT", 640, 0)
gutter:SetBackdrop(MEDIA:BACKDROP())
gutter:SetBackdropColor(0, 0, 0, 0.1)
gutter:SetBackdropBorderColor(0, 0, 0, 0)

local player = ${block(`
  self = CreateUnitButton(gutter)
  self:SetSize(382, 64)
  self:SetPoint("RIGHT", -8, -240)

  ${ctx(instance => tag`
    local powerBar = StatusBar(self)
    powerBar:SetPoint("TOPLEFT", 0, 0)
    powerBar:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, -8) 

    local healthBar = StatusBar(self)
    healthBar:SetPoint("TOPLEFT", powerBar, "BOTTOMLEFT", 0, -1)
    healthBar:SetPoint("BOTTOMRIGHT", 0, 0)
    healthBar:SetFrameLevel(3)

    --local shieldBar = StatusBar(self)
    --shieldBar:SetAllPoints(healthBar)
    --shieldBar:SetStatusBarColor(0.0, 1.0, 1.0, 0.5)
    --shieldBar:SetFrameLevel(2)

    --local absorbBar = StatusBar(self)
    --absorbBar:SetAllPoints(healthBar)
    --absorbBar:SetStatusBarColor(1.0, 0.0, 0.0, 0.5)
    --absorbBar:SetFrameLevel(4)

    local background = self:CreateTexture(nil, "ARTWORK")
    background:SetPoint("TOPLEFT", healthBar, "TOPLEFT", 0, 0)
    background:SetPoint("BOTTOMRIGHT", healthBar, "BOTTOMRIGHT", 0, 0)
    background:SetTexture(MEDIA:STATUSBAR())
    background:SetAlpha(0.35)

    --local overlay = healthBar:CreateTexture(nil, "ARTWORK")
    --overlay:SetAllPoints()
    --overlay:SetTexture([[Interface\\PETBATTLES\\Weather-Sunlight]])
    --overlay:SetTexCoord(1, 0.26, 0, 0.7)
    --overlay:SetBlendMode("ADD")
    --overlay:SetAlpha(0.15)

    local powerFont = FontString(healthBar, 20)
    local healthFont = FontString(healthBar, 20)

    powerFont:SetPoint("TOP")
    healthFont:SetPoint("BOTTOM")

    --local roleIcon = RoleIcon(healthBar, 48, nil, 'OVERLAY')
    --local leaderIcon = LeaderIcon(healthBar, 18, nil, 'OVERLAY')
    --local assistIcon = AssistIcon(healthBar, 18, nil, 'OVERLAY')
    --local restedIcon = RestedIcon(healthBar, 18, nil, 'OVERLAY')
    --local combatIcon = CombatIcon(healthBar, 18, nil, 'OVERLAY')
    --local resserIcon = ResserIcon(healthBar, 18, nil, 'OVERLAY')

    ${source.use(instance, "ClassColor", SET`
      healthBar:SetStatusBarColor(unpack(${"color"}))
      background:SetVertexColor(unpack(${"color"}))
    `)}

    ${source.use(instance, "PowerColor", SET`
      local r, g, b = unpack(${"color"})
      powerBar:SetStatusBarColor(r, g, b)
      powerFont:SetTextColor(r*0.15, g*0.15, b*0.15)
      healthFont:SetTextColor(r*0.15, g*0.15, b*0.15)
    `)}

    ${instance.Use("GUID_SET GUID_MOD UNIT_POWER_FREQUENT UNIT_MAXPOWER UNIT_POWER_UPDATE",
      GET`local ${"val"} = UnitPower(self.unit)`,
      GET`local ${"max"} = UnitPowerMax(self.unit)`,
      SET`
          powerBar:SetMinMaxValues(0, ${"max"})
          powerBar:SetValue(${"val"})
          powerFont:SetText(math.ceil(${"val"}/${"max"}*100))`
    )}

    ${ignore(() => `
      ${source.use(instance, "UnitName",      SET`nameFont:SetText(${"name"})`)}
      ${source.use(instance, "UnitHealthMax", SET`healthBar:SetMinMaxValues(0, ${"max"})`)}
      ${source.use(instance, "UnitHealth",    SET`healthBar:SetValue(${"hp"})`)}
    `)}

    function self:handler(event, ...)
      ${instance.OnEventHandler()}
    end
    self:SetAttribute("unit", "player")
  `)}
`)}



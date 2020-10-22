AcceptInvite(1)
SetCVar("scriptErrors", 1)
SetCVar("showErrors", 1)

local gutter = PPFrame("BackdropTemplate")
gutter:SetPoint("TOPLEFT", 0, 0)
gutter:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMLEFT", 640, 0)
gutter:SetBackdrop(${MEDIA.BG_NOEDGE})
gutter:SetBackdropColor(0, 0, 0, 0.1)
gutter:SetBackdropBorderColor(0, 0, 0, 0)

local player = ${UnitButton("player", () => `
  self:SetPoint("RIGHT", -8, -240)
  self:SetSize(382, 64)

  -- HealthBar
  self.health = ${StatusBar(() => `
    bar:SetPoint("TOPLEFT", 0, 0)
    bar:SetPoint("BOTTOMRIGHT", 0, 9)
    bar:SetFrameLevel(3)
  `)}(self)
  ${Event("PLAYER_ENTERING_WORLD",                   {colHealth: 'ClassColor(self.unit)'},    `self.health:SetStatusBarColor(colHealth.r, colHealth.g, colHealth.b)`)}
  ${Event("PLAYER_ENTERING_WORLD", "UNIT_MAXHEALTH", {maxHealth: 'UnitHealthMax(self.unit)'}, `self.health:SetMinMaxValues(0, maxHealth)`)}
  ${Event("PLAYER_ENTERING_WORLD", "UNIT_HEALTH",    {curHealth: 'UnitHealth(self.unit)'},    `self.health:SetValue(curHealth)`)}

  -- ShieldBar, behind the healthbar
  self.shield = ${StatusBar(() => `
    bar:SetPoint("TOPLEFT", 0, 0)
    bar:SetPoint("BOTTOMRIGHT", 0, 9)
    bar:SetStatusBarColor(1.0, 0.7, 0.0)
    bar:SetFrameLevel(2)
    bar:SetMinMaxValues(0, 1)
    bar:SetValue(1)
  `)}(self)
  ${Event("PLAYER_ENTERING_WORLD", "UNIT_MAXHEALTH",             {maxHealth: 'UnitHealthMax(self.unit)'},                                           `self.shield:SetMinMaxValues(0, maxHealth)`)}
  ${Event("PLAYER_ENTERING_WORLD", "UNIT_ABSORB_AMOUNT_CHANGED", {curHealth: 'UnitHealth(self.unit)', curShield: 'UnitGetTotalAbsorbs(self.unit)'}, `self.shield:SetValue(curHealth + curShield)`)}

  -- ShieldAbsorb, above the healthbar
  self.absorb = ${StatusBar(() => `
    bar:SetPoint("TOPLEFT", 0, 0)
    bar:SetPoint("BOTTOMRIGHT", 0, 9)
    bar:SetStatusBarColor(1.0, 0.0, 0.0, 0.75)
    bar:SetFrameLevel(4)
  `)}(self)
  ${Event("PLAYER_ENTERING_WORLD", "UNIT_MAXHEALTH",             {maxHealth: 'UnitHealthMax(self.unit)'},           `self.absorb:SetMinMaxValues(0, maxHealth)`)}
  ${Event("PLAYER_ENTERING_WORLD", "UNIT_ABSORB_AMOUNT_CHANGED", {curAbsorb: 'UnitGetTotalHealAbsorbs(self.unit)'}, `self.absorb:SetValue(curAbsorb)`)}

  -- PowerBar
  self.power = ${StatusBar(() => `
    bar:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, 8)
    bar:SetPoint("BOTTOMRIGHT", 0, 0)
    bar:SetStatusBarColor(1.0, 0.5, 0.0)
    bar:SetMinMaxValues(0, 100)
    bar:SetValue(50)
  `)}(self)
  ${Event("PLAYER_ENTERING_WORLD", "UNIT_POWER_UPDATE",                        {colPower: 'PowerColor(self.unit)'},   `self.power:SetStatusBarColor(colPower.r, colPower.g, colPower.b)`)}
  ${Event("PLAYER_ENTERING_WORLD", "UNIT_POWER_UPDATE", "UNIT_MAXPOWER",       {maxPower: 'UnitPowerMax(self.unit)'}, `self.power:SetMinMaxValues(0, maxPower)`)}
  ${Event("PLAYER_ENTERING_WORLD", "UNIT_POWER_UPDATE", "UNIT_POWER_FREQUENT", {curPower: 'UnitPower(self.unit)'},    `self.power:SetValue(curPower)`)}

`)}(gutter)

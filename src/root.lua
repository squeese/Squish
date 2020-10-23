AcceptInvite(1)
SetCVar("scriptErrors", 1)
SetCVar("showErrors", 1)

local gutter = PPFrame("BackdropTemplate")
gutter:SetPoint("TOPLEFT", 0, 0)
gutter:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMLEFT", 640, 0)
gutter:SetBackdrop(${MEDIA.BG_NOEDGE})
gutter:SetBackdropColor(0, 0, 0, 0.1)
gutter:SetBackdropBorderColor(0, 0, 0, 0)

local player = ${UnitButton("player", Event => `
  self:SetPoint("RIGHT", -8, -240)
  self:SetSize(382, 64)
  self:SetBackdrop(${MEDIA.BG_NOEDGE})
  self:SetBackdropColor(0, 0, 0, 0.75)
  self:SetBackdropBorderColor(0, 0, 0, 1)

  self.health = CreateFrame("statusbar", nil, self)
  self.health:SetStatusBarTexture(${MEDIA.BAR_FLAT})
  self.health:SetPoint("TOPLEFT", 0, 0)
  self.health:SetPoint("BOTTOMRIGHT", 0, 9)
  self.health:SetFrameLevel(3)

  self.shield = CreateFrame("statusbar", nil, self)
  self.shield:SetStatusBarTexture(${MEDIA.BAR_FLAT})
  self.shield:SetPoint("TOPLEFT", 0, 0)
  self.shield:SetPoint("BOTTOMRIGHT", 0, 9)
  self.shield:SetStatusBarColor(1.0, 0.7, 0.0)
  self.shield:SetFrameLevel(2)

  self.absorb = CreateFrame("statusbar", nil, self)
  self.absorb:SetStatusBarTexture(${MEDIA.BAR_FLAT})
  self.absorb:SetPoint("TOPLEFT", 0, 0)
  self.absorb:SetPoint("BOTTOMRIGHT", 0, 9)
  self.absorb:SetStatusBarColor(1.0, 0.0, 0.0, 0.75)
  self.absorb:SetFrameLevel(4)

  self.power = CreateFrame("statusbar", nil, self)
  self.power:SetStatusBarTexture(${MEDIA.BAR_FLAT})
  self.power:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, 8)
  self.power:SetPoint("BOTTOMRIGHT", 0, 0)

  ${Event(true,                                              {colHealth: 'ClassColor(self.unit)'},              `self.health:SetStatusBarColor(colHealth.r, colHealth.g, colHealth.b)`)}
  ${Event(true, "UNIT_MAXHEALTH",                            {maxHealth: 'UnitHealthMax(self.unit)'},           `self.health:SetMinMaxValues(0, maxHealth)`)}
  ${Event(true, "UNIT_HEALTH",                               {curHealth: 'UnitHealth(self.unit)'},              `self.health:SetValue(curHealth)`)}
  ${Event(true, "UNIT_MAXHEALTH",                            {maxHealth: 'UnitHealthMax(self.unit)'},           `self.shield:SetMinMaxValues(0, maxHealth)`)}
  ${Event(true, "UNIT_HEALTH", "UNIT_ABSORB_AMOUNT_CHANGED", {curHealth: 'UnitHealth(self.unit)',
                                                              curShield: 'UnitGetTotalAbsorbs(self.unit)'},     `self.shield:SetValue(curHealth + curShield)`)}
  ${Event(true, "UNIT_MAXHEALTH",                            {maxHealth: 'UnitHealthMax(self.unit)'},           `self.absorb:SetMinMaxValues(0, maxHealth)`)}
  ${Event(true, "UNIT_HEAL_ABSORB_AMOUNT_CHANGED",           {curAbsorb: 'UnitGetTotalHealAbsorbs(self.unit)'}, `self.absorb:SetValue(curAbsorb)`)}
  ${Event(true, "UNIT_POWER_UPDATE",                         {colPower: 'PowerColor(self.unit)'},               `self.power:SetStatusBarColor(colPower.r, colPower.g, colPower.b)`)}
  ${Event(true, "UNIT_POWER_UPDATE", "UNIT_MAXPOWER",        {maxPower: 'UnitPowerMax(self.unit)'},             `self.power:SetMinMaxValues(0, maxPower)`)}
  ${Event(true, "UNIT_POWER_UPDATE", "UNIT_POWER_FREQUENT",  {curPower: 'UnitPower(self.unit)'},                `self.power:SetValue(curPower)`)}

  local castbar = CastBar(self, "player", 32)
  castbar:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -16)
  castbar:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -16)
`)}(gutter)

local target = ${UnitButton("target", (Event, Script) => `
  self:SetPoint("LEFT", player, "RIGHT", 16, 0)
  self:SetSize(320, 64)
  self:SetBackdrop(${MEDIA.BG_NOEDGE})
  self:SetBackdropColor(0, 0, 0, 0.75)
  self:SetBackdropBorderColor(0, 0, 0, 1)

  self.health = CreateFrame("statusbar", nil, self)
  self.health:SetStatusBarTexture(${MEDIA.BAR_FLAT})
  self.health:SetPoint("TOPLEFT", 0, 0)
  self.health:SetPoint("BOTTOMRIGHT", 0, 9)
  self.health:SetFrameLevel(3)

  self.shield = CreateFrame("statusbar", nil, self)
  self.shield:SetStatusBarTexture(${MEDIA.BAR_FLAT})
  self.shield:SetPoint("TOPLEFT", 0, 0)
  self.shield:SetPoint("BOTTOMRIGHT", 0, 9)
  self.shield:SetStatusBarColor(1.0, 0.7, 0.0)
  self.shield:SetFrameLevel(2)

  self.absorb = CreateFrame("statusbar", nil, self)
  self.absorb:SetStatusBarTexture(${MEDIA.BAR_FLAT})
  self.absorb:SetPoint("TOPLEFT", 0, 0)
  self.absorb:SetPoint("BOTTOMRIGHT", 0, 9)
  self.absorb:SetStatusBarColor(1.0, 0.0, 0.0, 0.75)
  self.absorb:SetFrameLevel(4)

  self.power = CreateFrame("statusbar", nil, self)
  self.power:SetStatusBarTexture(${MEDIA.BAR_FLAT})
  self.power:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, 8)
  self.power:SetPoint("BOTTOMRIGHT", 0, 0)

  self.nameString = self.health:CreateFontString(nil, nil, "GameFontNormal")
  self.nameString:SetPoint("TOPLEFT", 4, -6)
  self.nameString:SetFont(${MEDIA.FONT_VIXAR}, 16, "OUTLINE")

  self.healthString = self.health:CreateFontString(nil, nil, "GameFontNormal")
  self.healthString:SetPoint("BOTTOMLEFT", 4, 4)
  self.healthString:SetFont(${MEDIA.FONT_VIXAR}, 11, "OUTLINE")

  self.infoString = self.health:CreateFontString(nil, nil, "GameFontNormal")
  self.infoString:SetPoint("BOTTOMRIGHT", -4, 4)
  self.infoString:SetFont(${MEDIA.FONT_VIXAR}, 11, "OUTLINE")

  self.statusString = self.health:CreateFontString(nil, nil, "GameFontNormal")
  self.statusString:SetPoint("BOTTOM", 0, 4)
  self.statusString:SetFont(${MEDIA.FONT_VIXAR}, 11, "OUTLINE")
  self.statusString:SetText("Status")
  local function setStatus()
    if UnitIsDead(self.unit) then self.statusString:SetText("Dead")
    elseif UnitIsGhost(self.unit) then self.statusString:SetText("Ghost")
    elseif not UnitIsConnected(self.unit) then self.statusString:SetText("Offline")
    else self.statusString:SetText("")
    end
  end

  self.questIcon = self.health:CreateTexture(nil, 'OVERLAY')
  self.questIcon:SetSize(32, 32)
  self.questIcon:SetPoint("TOPRIGHT", -4, 8)
  self.questIcon:SetTexture([[Interface\\TargetingFrame\\PortraitQuestBadge]])

  ${Event(true,                                              {colHealth: 'ClassColor(self.unit)'},              `self.health:SetStatusBarColor(colHealth.r, colHealth.g, colHealth.b)`)}
  ${Event(true, "UNIT_MAXHEALTH",                            {maxHealth: 'UnitHealthMax(self.unit)'},           `self.health:SetMinMaxValues(0, maxHealth)`)}
  ${Event(true, "UNIT_HEALTH",                               {curHealth: 'UnitHealth(self.unit)'},              `self.health:SetValue(curHealth)`)}
  ${Event(true, "UNIT_MAXHEALTH",                            {maxHealth: 'UnitHealthMax(self.unit)'},           `self.shield:SetMinMaxValues(0, maxHealth)`)}
  ${Event(true, "UNIT_HEALTH", "UNIT_ABSORB_AMOUNT_CHANGED", {curHealth: 'UnitHealth(self.unit)',
                                                              curShield: 'UnitGetTotalAbsorbs(self.unit)'},     `self.shield:SetValue(curHealth + curShield)`)}
  ${Event(true, "UNIT_MAXHEALTH",                            {maxHealth: 'UnitHealthMax(self.unit)'},           `self.absorb:SetMinMaxValues(0, maxHealth)`)}
  ${Event(true, "UNIT_HEAL_ABSORB_AMOUNT_CHANGED",           {curAbsorb: 'UnitGetTotalHealAbsorbs(self.unit)'}, `self.absorb:SetValue(curAbsorb)`)}
  ${Event(true, "UNIT_POWER_UPDATE",                         {colPower: 'PowerColor(self.unit)'},               `self.power:SetStatusBarColor(colPower.r, colPower.g, colPower.b)`)}
  ${Event(true, "UNIT_POWER_UPDATE", "UNIT_MAXPOWER",        {maxPower: 'UnitPowerMax(self.unit)'},             `self.power:SetMinMaxValues(0, maxPower)`)}
  ${Event(true, "UNIT_POWER_UPDATE", "UNIT_POWER_FREQUENT",  {curPower: 'UnitPower(self.unit)'},                `self.power:SetValue(curPower)`)}
  ${Event(true, "UNIT_NAME_UPDATE",                          {name: 'UnitName(self.unit)'},                     `self.nameString:SetText(name)`)}
  ${Event(true, "UNIT_MAXHEALTH",                            {maxHealth: 'UnitHealthMax(self.unit)'},           `self.healthString:SetText(maxHealth)`)}
  ${Event(true, "UNIT_LEVEL", "UNIT_CLASSIFICATION_CHANGED", {level: 'UnitLevel(self.unit)',
                                                              status: 'UnitClassification(self.unit)'},         `self.infoString:SetText(level .. " " .. status)`)}
  ${Event(true, "UNIT_CLASSIFICATION_CHANGED",               {isBoss: 'UnitIsQuestBoss(self.unit)'},            `if isBoss then self.questIcon:Show() else self.questIcon:Hide() end`)}
  ${Event(true, "UNIT_HEALTH", "UNIT_CONNECTION",            {},                                                `setStatus()`)}
  ${Event(true,                                              {},                                                `RangeChecker:Update(self)`)}
  ${Script("OnShow", `RangeChecker:Register(self)`)}
  ${Script("OnHide", `RangeChecker:Unregister(self)`)}

  local castbar = CastBar(self, "target", 32)
  castbar:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -16)
  castbar:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -16)
`)}(gutter)

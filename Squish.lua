local addon, Q = ...
local Vixar = "interface\\addons\\squish\\media\\vixar.ttf"
local Backdrop = {
  bgFile = 'Interface\\Addons\\Squish\\media\\backdrop.tga',
  insets = { left = -1, right = -1, top = -1, bottom = -1 }
}

function copyColors(src, dst)
  for key, value in pairs(src) do
    if not dst[key] then
      dst[key] = { value.r, value.g, value.b }
    end
  end
  return dst
end
local COLOR_CLASS = copyColors(RAID_CLASS_COLORS, {})
local COLOR_POWER = copyColors(PowerBarColor, { MANA = { 0.31, 0.45, 0.63 }})
local function ClassColor(unit, ...)
  local color = COLOR_CLASS[select(2, UnitClass(unit))]
  if color then
    local r, g, b = unpack(color)
    return r, g, b, ...
  end
  return 0.5, 0.5, 0.5, ...
end
local function PowerColor(unit, ...)
  local color = COLOR_POWER[select(2, UnitPowerType(unit))]
  if color then
    local r, g, b = unpack(color)
    return r, g, b, ...
  end
  return 0.5, 0.5, 0.5, ...
end
local function Round(val, dec)
  local mult = 10 ^ dec
  return floor(val * mult + 0.5) / mult
end

local CastBar
do
  local OnUpdateCasting = function(self, elapsed)
    self.value = self.value + elapsed
    self.bar:SetValue(self.value)
  end

  local OnUpdateChannel = function (self, elapsed)
    self.value = self.value - elapsed
    self.bar:SetValue(self.value)
  end

  local OnUpdateFade = function (self, elapsed)
    self.alpha = self.alpha - (elapsed * 4)
    self:SetAlpha(self.alpha)
    if self.alpha <= 0 then
      self:SetScript("OnUpdate", nil)
    end
  end

  local update = function(self, casting, name, _, texture, sTime, eTime)
    if not name then return false end
    local curValue = GetTime() - (sTime / 1000)
    local maxValue = (eTime - sTime) / 1000
    self.bar:SetMinMaxValues(0, maxValue)
    self.bar:SetValue(casting and curValue or (maxValue - curValue))
    self.bar:SetStatusBarColor(1.0, 0.7, 0.0)
    self.icon:SetTexture(texture)
    self.text:SetText(name)
    self:SetAlpha(1.0)
    self.interupted = nil
    if casting then
      self.value = casting and curValue
      self:SetScript("OnUpdate", OnUpdateCasting)
    else
      self.value = maxValue - curValue
      self:SetScript("OnUpdate", OnUpdateChannel)
    end
    return true
  end

  CastBar = function(unit, height)
    local frame = CreateFrame("frame", nil, UIParent)
    frame:SetBackdrop(Backdrop)
    frame:SetBackdropColor(0, 0, 0, 0.75)
    frame:SetHeight(height)
    frame:Hide()
    frame:SetAlpha(0)

    local icon = frame:CreateTexture()
    icon:SetPoint("TOPLEFT", 0, 0)
    icon:SetPoint("BOTTOMRIGHT", frame, "BOTTOMLEFT", height, 0)
    icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    frame.icon = icon

    local bar = CreateFrame("statusbar", nil, frame)
    bar:SetPoint("TOPLEFT", height+1, 0)
    bar:SetPoint("BOTTOMRIGHT", 0, 0)
    bar:SetStatusBarTexture("Interface\\Addons\\Squish\\media\\flat.tga")
    frame.bar = bar

    local text = bar:CreateFontString(nil, nil, "GameFontNormal")
    text:SetPoint("CENTER", -(height/2), 0)
    text:SetFont(Vixar, 14, "OUTLINE")
    text:SetText("")
    frame.text = text

    if unit == "player" then
      frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    elseif unit == "target" then
      frame:RegisterEvent("PLAYER_TARGET_CHANGED")
    end
    frame:RegisterUnitEvent("UNIT_SPELLCAST_START", unit)
    frame:RegisterUnitEvent("UNIT_SPELLCAST_DELAYED", unit)
    frame:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", unit)
    frame:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", unit)
    frame:RegisterUnitEvent("UNIT_SPELLCAST_STOP", unit)
    frame:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", unit)
    -- frame:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", unit)
    frame:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", unit)
    -- frame:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTIBLE", unit)
    -- frame:RegisterUnitEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE", unit)

    frame:SetScript("OnEvent", function(self, event)
      if not UnitExists(unit) then
        self:Hide()
        self:SetAlpha(0)
        self:SetScript("OnUpdate", nil)
        return
      else
        self:Show()
      end

      if event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_DELAYED" then
        update(self, true, UnitCastingInfo(unit))

      elseif event == "UNIT_SPELLCAST_CHANNEL_START" or event == "UNIT_SPELLCAST_CHANNEL_UPDATE" then
        update(self, false, UnitChannelInfo(unit))

      elseif event == "PLAYER_TARGET_CHANGED" then
        -- try getting cast information
        if (update(self, true, UnitCastingInfo(unit))) then return end
        if (update(self, false, UnitChannelInfo(unit))) then return end
        self:SetAlpha(0)
        self:SetScript("OnUpdate", nil)

      elseif event == "UNIT_SPELLCAST_INTERRUPTED" then
        bar:SetMinMaxValues(0, 1)
        bar:SetValue(1)
        bar:SetStatusBarColor(1.0, 0.0, 0.0)
        text:SetText("Interrupted")
        self.interupted = true

      else
        bar:SetMinMaxValues(0, 1)
        bar:SetValue(1)
        self.alpha = self:GetAlpha() * (self.interupted and 4.0 or 1.0)
        self:SetScript("OnUpdate", OnUpdateFade)
      end

    end)
    return frame
  end
end

function HealthBar(unit, parent)
  local health = CreateFrame("statusbar", nil, parent)
  local shield = CreateFrame("statusbar", nil, parent)
  local absorb = CreateFrame("statusbar", nil, parent)

  local background = health:CreateTexture(nil, "BACKGROUND")
  background:SetAllPoints()
  background:SetTexture("Interface\\Addons\\Squish\\media\\flat.tga")

  health:SetStatusBarTexture("Interface\\Addons\\Squish\\media\\flat.tga")
  shield:SetStatusBarTexture("Interface\\Addons\\Squish\\media\\flat.tga")
  absorb:SetStatusBarTexture("Interface\\Addons\\Squish\\media\\flat.tga")

  if unit == "player" then
    health:RegisterEvent("PLAYER_ENTERING_WORLD")
  elseif unit == "target" then
    health:RegisterEvent("PLAYER_TARGET_CHANGED")
  end
  health:RegisterUnitEvent("UNIT_MAXHEALTH", unit)
  health:RegisterUnitEvent("UNIT_HEALTH_FREQUENT", unit)
  health:RegisterUnitEvent("UNIT_FACTION", unit)
  health:RegisterUnitEvent("UNIT_CONNECTION", unit)
  health:RegisterUnitEvent('UNIT_ABSORB_AMOUNT_CHANGED', unit)
  health:RegisterUnitEvent('UNIT_HEAL_ABSORB_AMOUNT_CHANGED', unit)

  health:SetScript("OnEvent", function(_, event, ...)
    if (event == "PLAYER_ENTERING_WORLD"
        or event == "PLAYER_TARGET_CHANGED"
        or event == "UNIT_MAXHEALTH"
        or event == "UNIT_FACTION"
        or event == "UNIT_CONNECTION") then
      local maxHealth = UnitHealthMax(unit)
      local curHealth = UnitHealth(unit)
      health:SetMinMaxValues(0, maxHealth)
      shield:SetMinMaxValues(0, maxHealth)
      absorb:SetMinMaxValues(0, maxHealth)
      health:SetValue(curHealth)
      shield:SetValue(curHealth + UnitGetTotalAbsorbs(unit))
      absorb:SetValue(UnitGetTotalHealAbsorbs(unit))
      local r, g, b = ClassColor(unit)
      health:SetStatusBarColor(r, g, b)
      background:SetVertexColor(r*0.2, g*0.2, b*0.2, 0.2)

    elseif event == "UNIT_HEALTH_FREQUENT" or event == "UNIT_ABSORB_AMOUNT_CHANGED" then
      local value = UnitHealth(unit)
      health:SetValue(value)
      shield:SetValue(value + UnitGetTotalAbsorbs(unit))

    elseif event == "UNIT_HEAL_ABSORB_AMOUNT_CHANGED" then
      absorb:SetValue(UnitGetTotalHealAbsorbs(unit))
    end
  end)

  return health, shield, absorb
end

function PowerBar(unit, parent)
  local frame = CreateFrame("statusbar", nil, parent)
  frame:SetStatusBarTexture("Interface\\Addons\\Squish\\media\\flat.tga")
  if unit == "player" then
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
  elseif unit == "target" then
    frame:RegisterEvent("PLAYER_TARGET_CHANGED")
  end
  frame:RegisterUnitEvent("UNIT_MAXPOWER", unit)
  frame:RegisterUnitEvent("UNIT_POWER_FREQUENT", unit)
  frame:RegisterUnitEvent("UNIT_POWER_UPDATE", unit)
  frame:RegisterUnitEvent("UNIT_FACTION", unit)
  frame:RegisterUnitEvent("UNIT_CONNECTION", unit)
  frame:SetScript("OnEvent", function(_, event, ...)
    if (event == "PLAYER_ENTERING_WORLD"
        or event == "PLAYER_TARGET_CHANGED"
        or event == "UNIT_POWER_UPDATE"
        or event == "UNIT_MAXPOWER"
        or event == "UNIT_FACTION"
        or event == "UNIT_CONNECTION") then
      frame:SetMinMaxValues(0, UnitPowerMax(unit))
      frame:SetValue(UnitPower(unit))
      frame:SetStatusBarColor(PowerColor(unit))

    elseif event == "UNIT_POWER_FREQUENT" then
      frame:SetValue(UnitPower(unit))
    end
  end)
  return frame
end

function Gutter(opacity)
  local frame = CreateFrame("frame", nil, UIParent)
  frame:SetPoint("TOPLEFT", 0, 0)
  frame:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMLEFT", 640, 0)
  frame:SetBackdrop(Backdrop)
  frame:SetBackdropColor(0, 0, 0, opacity)
  frame:RegisterEvent("PLAYER_ENTERING_WORLD")
  frame:SetScript("OnEvent", function(self)
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    self:SetScript("OnEvent", nil)
    self:SetScale(0.533333333 / UIParent:GetScale())
  end)
  return frame
end

function Player(gutter, width, height, ...)
  local frame = CreateFrame("button", nil, gutter, "SecureUnitButtonTemplate")

  frame.unit = "player"
  frame:SetScript("OnEnter", UnitFrame_OnEnter)
  frame:SetScript("OnLeave", UnitFrame_OnLeave)
  frame:RegisterForClicks("AnyUp")
  frame:EnableMouseWheel(true)
  frame:SetAttribute('*type1', 'target')
  frame:SetAttribute('*type2', 'togglemenu')
  frame:SetAttribute('toggleForVehicle', true)
  frame:SetAttribute("unit", frame.unit)
  RegisterUnitWatch(frame)
  frame:SetPoint(...)
  frame:SetSize(width, height)
  frame:SetBackdrop(Backdrop)
  frame:SetBackdropColor(0, 0, 0, 0.75)
  frame:SetBackdropBorderColor(0, 0, 0, 1)

  local health, shield, absorb = HealthBar("player", frame)
  shield:SetPoint("TOPLEFT", 0, 0)
  shield:SetPoint("BOTTOMRIGHT", 0, 9)
  shield:SetStatusBarColor(1.0, 0.7, 0.0)
  shield:SetFrameLevel(2)

  health:SetPoint("TOPLEFT", 0, 0)
  health:SetPoint("BOTTOMRIGHT", 0, 9)
  health:SetFrameLevel(3)

  absorb:SetPoint("TOPLEFT", 0, 0)
  absorb:SetPoint("BOTTOMRIGHT", 0, 9)
  absorb:SetStatusBarColor(1.0, 0.0, 0.0, 0.65)
  absorb:SetFrameLevel(4)

  local power = PowerBar("player", frame)
  power:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, 8)
  power:SetPoint("BOTTOMRIGHT", 0, 0)

  local castbar = CastBar("player", 32)
  castbar:SetParent(frame)
  castbar:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, -16)
  castbar:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT", 0, -16)

  return frame
end


function Target(gutter, player)
  local frame = CreateFrame("button", nil, gutter, "SecureUnitButtonTemplate")
  frame.unit = "target"
  frame:SetScript("OnEnter", UnitFrame_OnEnter)
  frame:SetScript("OnLeave", UnitFrame_OnLeave)
  frame:RegisterForClicks("AnyUp")
  frame:EnableMouseWheel(true)
  frame:SetAttribute('*type1', 'target')
  frame:SetAttribute('*type2', 'togglemenu')
  frame:SetAttribute('toggleForVehicle', true)
  frame:SetAttribute("unit", frame.unit)
  RegisterUnitWatch(frame)
  frame:SetPoint("LEFT", player, "RIGHT", 16, 0)
  frame:SetSize(320, 64)
  frame:SetBackdrop(Backdrop)
  frame:SetBackdropColor(0, 0, 0, 0.75)
  frame:SetBackdropBorderColor(0, 0, 0, 1)

  local health, shield, absorb = HealthBar("target", frame)
  shield:SetPoint("TOPLEFT", 0, 0)
  shield:SetPoint("BOTTOMRIGHT", 0, 9)
  shield:SetStatusBarColor(1.0, 0.7, 0.0)
  shield:SetFrameLevel(2)

  health:SetPoint("TOPLEFT", 0, 0)
  health:SetPoint("BOTTOMRIGHT", 0, 9)
  health:SetFrameLevel(3)

  absorb:SetPoint("TOPLEFT", 0, 0)
  absorb:SetPoint("BOTTOMRIGHT", 0, 9)
  absorb:SetStatusBarColor(1.0, 0.0, 0.0, 0.65)
  absorb:SetFrameLevel(4)

  local power = PowerBar("player", frame)
  power:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, 8)
  power:SetPoint("BOTTOMRIGHT", 0, 0)

  local txtName = health:CreateFontString(nil, nil, "GameFontNormal")
  txtName:SetPoint("TOPLEFT", 4, -6)
  txtName:SetFont(Vixar, 16, "OUTLINE")

  local txtHealth = health:CreateFontString(nil, nil, "GameFontNormal")
  txtHealth:SetPoint("BOTTOMLEFT", 4, 4)
  txtHealth:SetFont(Vixar, 11, "OUTLINE")

  frame:RegisterEvent("PLAYER_TARGET_CHANGED")
  frame:RegisterUnitEvent("UNIT_MAXHEALTH", "target")
  frame:SetScript("OnUpdate", function()
    if not UnitExists("target") then return end
    txtName:SetText(UnitName("target"))
    txtHealth:SetText((math.floor(UnitHealthMax("target") / 100) / 10) .. "k")
  end)

  local castbar = CastBar("target", 32)
  castbar:SetParent(frame)
  castbar:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, -16)
  castbar:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT", 0, -16)

  return frame
end

local Buffs
do
  local OnUpdate = function(self, elapsed)
    self.duration = self.duration - elapsed
    if self.duration < 60 then
      self.time:SetFormattedText("%ds", self.duration)
    elseif self.duration < 3600 then
      self.time:SetFormattedText("%dm", ceil(self.duration / 60))
    else
      self.time:SetText("alot")
    end
    -- print(SecondsToTime(self.duration, false, true))
    if self.duration <= 0 then
      self.time:SetText("0 s")
      self:SetScript("OnUpdate", nil)
    end
  end

  Buffs = function(parent, ...)
    local header = CreateFrame('frame', 'SquishBuffs', parent, 'SecureAuraHeaderTemplate')

    header:SetAttribute('template', 'SecureActionButtonTemplate')
    header:SetAttribute('initialConfigFunction', [[
      self:SetWidth(48)
      self:SetHeight(48)
      self:SetAttribute('type', 'cancelaura')
      self:GetParent():CallMethod('initialConfigFunction', self:GetName())
    ]])
    function header:initialConfigFunction(name)
      local button = _G[name]
      button:RegisterForClicks("RightButtonUp")
      button:SetBackdrop(Backdrop)
      button:SetBackdropColor(0, 0, 0, 0.75)

      local icon = button:CreateTexture()
      icon:SetAllPoints()
      icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

      local time = button:CreateFontString(nil, nil, "GameFontNormal")
      time:SetPoint("BOTTOM", 0, -20)
      time:SetFont(Vixar, 13, "OUTLINE")
      button.time = time

      local stack = button:CreateFontString(nil, nil, "GameFontNormal")
      stack:SetPoint("BOTTOMRIGHT", -2, 2)
      stack:SetFont(Vixar, 15, "OUTLINE")

      button:SetScript('OnAttributeChanged', function(_, key, value)
        if key == 'index' then -- and button.index ~= value then
          local name, texture, count, _, duration, expires = UnitAura("player", value)
          icon:SetTexture(texture)
          if duration > 0 then
            time:Show()
            button.duration = Round(expires - GetTime(), 3)
            button:SetScript("OnUpdate", OnUpdate)
          else
            time:Hide()
            button:SetScript("OnUpdate", nil)
          end
          if count and count > 0 then
            stack:Show()
            stack:SetText(count)
          else
            stack:Hide()
          end
          -- button.index = value
        end
      end)
    end

    header:SetAttribute('point', 'RIGHT')
    header:SetAttribute('unit', 'player')
    header:SetAttribute('filter', 'HELPFUL')
    header:SetAttribute('sortMethod', 'TIME')
    header:SetAttribute('sortDirection', '-')
    header:SetAttribute('minWidth', 48)
    header:SetAttribute('minHeight', 48)
    header:SetAttribute('xOffset', -52)
    -- header:SetAttribute('wrapYOffset', 0)
    -- header:SetAttribute('wrapAfter', 3)
    -- header:SetAttribute('maxWraps', 3)
    RegisterAttributeDriver(header, 'unit', '[vehicleui] vehicle; player')
    RegisterStateDriver(header, 'visibility', '[petbattle] hide; show')

    header:SetPoint(...)
    header:Show()
  end
end

local Party
do
  Party = function(parent, ...)
    local header = CreateFrame('frame', 'SquishParty', parent, 'SecureGroupHeaderTemplate')

    header:SetAttribute('template', 'SecureActionButtonTemplate')
    header:SetAttribute('initialConfigFunction', [[
      self:SetWidth(90)
      self:SetHeight(64)
      self:SetAttribute('*type1', 'target')
      self:SetAttribute('*type2', 'togglemenu')
      self:SetAttribute('toggleForVehicle', true)
      RegisterUnitWatch(self)
      self:GetParent():CallMethod('initialConfigFunction', self:GetName())
    ]])
    function header:initialConfigFunction(name)
      local button = _G[name]
      button:SetBackdrop(Backdrop)
      button:SetBackdropColor(0, 0, 0, 0.75)
      button:SetScript('OnEnter', UnitFrame_OnEnter)
      button:SetScript('OnLeave', UnitFrame_OnLeave)
      button:RegisterForClicks('AnyUp')

      local health, shield, absorb = HealthBar("player", button)
      shield:SetPoint("TOPLEFT", 0, 0)
      shield:SetPoint("BOTTOMRIGHT", 0, 9)
      shield:SetStatusBarColor(1.0, 0.7, 0.0)
      shield:SetFrameLevel(2)

      health:SetPoint("TOPLEFT", 0, 0)
      health:SetPoint("BOTTOMRIGHT", 0, 9)
      health:SetFrameLevel(3)

      absorb:SetPoint("TOPLEFT", 0, 0)
      absorb:SetPoint("BOTTOMRIGHT", 0, 9)
      absorb:SetStatusBarColor(1.0, 0.0, 0.0, 0.65)
      absorb:SetFrameLevel(4)

      button:SetScript('OnAttributeChanged', function(_, key, value)
        if key == 'unit' then
          button.unit = value
        end
      end)
    end

    header:SetAttribute('showRaid', true)
    header:SetAttribute('showParty', true)
    header:SetAttribute('showPlayer', true)
    header:SetAttribute('showSolo', true)
    header:SetAttribute('xOffset', 0)
    header:SetAttribute('yOffset', 4)
    -- header:SetAttribute('columnSpacing')
    header:SetAttribute('point', 'BOTTOM')
    header:SetAttribute('groupBy', 'ASSIGNEDROLE')
    header:SetAttribute('groupingOrder', 'TANK,DAMAGER,HEALER')
    RegisterAttributeDriver(header, 'state-visibility', '[raid] hide; show')

    header:SetPoint(...)
    header:Show()
  end
end

do
  Q.DisableBlizzard("player")
  Q.DisableBlizzard("target")
  CastingBarFrame:UnregisterAllEvents()
  CastingBarFrame:Hide()

  local gutter = Gutter(0.005)
  local buffs = Buffs(gutter, "TOPRIGHT", -8, -8)
  local party = Party(gutter, "RIGHT", -8, 0)
  local player = Player(gutter, 382, 64, "RIGHT", -8, -240)
  local target = Target(gutter, player)
end

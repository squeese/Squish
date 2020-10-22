local _, Q = ...

Q.FONT = "interface\\addons\\squish\\media\\vixar.ttf"
Q.BAR = "Interface\\Addons\\Squish\\media\\flat.tga"
Q.BACKDROP = {
  bgFile = 'Interface\\Addons\\Squish\\media\\backdrop.tga',
  -- edgeFile = 'Interface\\Addons\\ONodesUI\\media\\edgefile.tga',
  edgeSize = 1,
  insets = { left = -1, right = -1, top = -1, bottom = -1 },
}

do
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
  function Q.ClassColor(unit, ...)
    local color = COLOR_CLASS[select(2, UnitClass(unit))]
    if color then
      local r, g, b = unpack(color)
      return r, g, b, ...
    end
    return 0.5, 0.5, 0.5, ...
  end
  function Q.PowerColor(unit, ...)
    local color = COLOR_POWER[select(2, UnitPowerType(unit))]
    if color then
      local r, g, b = unpack(color)
      return r, g, b, ...
    end
    return 0.5, 0.5, 0.5, ...
  end
end


function Q.Round(val, dec)
  local mult = 10 ^ dec
  return floor(val * mult + 0.5) / mult
end

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

  function Q.CastBar(unit, height)
    local frame = CreateFrame("frame", nil, UIParent)
    frame:SetBackdrop(Q.BACKDROP)
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
    bar:SetStatusBarTexture(Q.BAR)
    frame.bar = bar

    local text = bar:CreateFontString(nil, nil, "GameFontNormal")
    text:SetPoint("CENTER", -(height/2), 0)
    text:SetFont(Q.FONT, 14, "OUTLINE")
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

function Q.HealthBar(unit, parent)
  local health = CreateFrame("statusbar", nil, parent)
  local shield = CreateFrame("statusbar", nil, parent)
  local absorb = CreateFrame("statusbar", nil, parent)

  local background = health:CreateTexture(nil, "BACKGROUND")
  background:SetAllPoints()
  background:SetTexture(Q.BAR)

  health:SetStatusBarTexture(Q.BAR)
  shield:SetStatusBarTexture(Q.BAR)
  absorb:SetStatusBarTexture(Q.BAR)

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
      local r, g, b = Q.ClassColor(unit)
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

function Q.PowerBar(unit, parent)
  local frame = CreateFrame("statusbar", nil, parent)
  frame:SetStatusBarTexture(Q.BAR)
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
      frame:SetStatusBarColor(Q.PowerColor(unit))

    elseif event == "UNIT_POWER_FREQUENT" then
      frame:SetValue(UnitPower(unit))
    end
  end)
  return frame
end

do
  local RANGE = {}
  RANGE.__frame = CreateFrame('frame', nil, UIParent)
  RANGE.__index = RANGE
  Q.Range = setmetatable(RANGE, RANGE)
  local insert = table.insert
  local remove = table.remove
  local elapsed = 0
  local function OnUpdate(_, e)
    elapsed = elapsed + e
    if elapsed > 0.15 then
      for index = 1, #RANGE do
        local button = RANGE[index]
        if UnitIsConnected(button.unit) then
          local close, checked UnitInRange(button.unit)
          if checked and not close then
            button:SetAlpha(0.25)
          else
            button:SetAlpha(1.0)
          end
        else
          button:SetAlpha(1.0)
        end
      end
      elapsed = 0
    end
  end
  function RANGE:Register(button)
    if #self == 0 then
      elapsed = 0
      self.__frame:SetScript("OnUpdate", OnUpdate)
    end
    table.insert(self, button)
  end
  function RANGE:Unregister(button)
    for index = 1, #self do
      if button == self[index] then
        remove(self, index)
        break
      end
    end
    if #self == 0 then
      self.__frame:SetScript("OnUpdate", nil)
    end
  end
end

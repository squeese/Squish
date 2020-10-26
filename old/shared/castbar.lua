local _, Q = ...

local function OnUpdateCasting(self, elapsed)
  self.value = self.value + elapsed
  self.bar:SetValue(self.value)
end

local function OnUpdateChannel(self, elapsed)
  self.value = self.value - elapsed
  self.bar:SetValue(self.value)
end

local function OnUpdateFade(self, elapsed)
  self.alpha = self.alpha - (elapsed * 4)
  self:SetAlpha(self.alpha)
  if self.alpha <= 0 then
    self:SetScript("OnUpdate", nil)
  end
end

local function Update(self, casting, name, _, texture, sTime, eTime)
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

local function OnEvent(self, event)
  if not UnitExists(self.unit) then
    self:Hide()
    self:SetAlpha(0)
    self:SetScript("OnUpdate", nil)
    return
  else
    self:Show()
  end

  if event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_DELAYED" then
    Update(self, true, UnitCastingInfo(self.unit))

  elseif event == "UNIT_SPELLCAST_CHANNEL_START" or event == "UNIT_SPELLCAST_CHANNEL_UPDATE" then
    Update(self, false, UnitChannelInfo(self.unit))

  elseif event == "PLAYER_TARGET_CHANGED" then
    if (Update(self, true, UnitCastingInfo(self.unit))) then return end
    if (Update(self, false, UnitChannelInfo(self.unit))) then return end
    self:SetAlpha(0)
    self:SetScript("OnUpdate", nil)

  elseif event == "UNIT_SPELLCAST_INTERRUPTED" then
    self.bar:SetMinMaxValues(0, 1)
    self.bar:SetValue(1)
    self.bar:SetStatusBarColor(1.0, 0.0, 0.0)
    self.text:SetText("Interrupted")
    self.interupted = true

  else
    self.bar:SetMinMaxValues(0, 1)
    self.bar:SetValue(1)
    self.alpha = self:GetAlpha() * (self.interupted and 4.0 or 1.0)
    self:SetScript("OnUpdate", OnUpdateFade)
  end
end

function Q.CastBar(unit, height)
  local frame = CreateFrame("frame", nil, UIParent, "BackdropTemplate")
  frame:SetBackdrop(Q.BACKDROP)
  frame:SetBackdropColor(0, 0, 0, 0.75)
  frame:SetHeight(height)
  frame:Hide()
  frame:SetAlpha(0)
  frame.unit = unit

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
  frame:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", unit)
  -- frame:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", unit)
  -- frame:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTIBLE", unit)
  -- frame:RegisterUnitEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE", unit)
  frame:SetScript("OnEvent", OnEvent)

  return frame
end

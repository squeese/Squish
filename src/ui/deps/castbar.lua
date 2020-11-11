${locals.use("math.min")}
local CreateCastBar
do
  local function OnUpdate_Casting(self, elapsed)
    self.elapsed = self.elapsed + elapsed
    self.bar:SetValue(self.elapsed)
  end

  local function OnUpdate_Channel(self, elapsed)
    self.elapsed = self.elapsed - elapsed
    self.bar:SetValue(self.elapsed)
  end

  local function OnUpdate_Fading(self, elapsed)
    self.delay = self.delay - elapsed
    local v = Math_Min(self.delay * 2, 1)
    self:SetAlpha(v * v)
    if self.delay <= 0 then
      self:SetScript("OnUpdate", nil)
    end
  end

  local function OnEvent(self, event, unit, castID, spellID)
    if not UnitExists(self.unit) then
      self:Hide()
      self.castID = nil
      self.spellID = nil
      self:SetAlpha(0)
      self:SetScript("OnUpdate", nil)
      self:UnregisterEvent("UNIT_SPELLCAST_START")
      self:UnregisterEvent("UNIT_SPELLCAST_DELAYED")
      self:UnregisterEvent("UNIT_SPELLCAST_STOP")
      self:UnregisterEvent("UNIT_SPELLCAST_INTERRUPTED")
      self:UnregisterEvent("UNIT_SPELLCAST_FAILED")
      self:UnregisterEvent("UNIT_SPELLCAST_INTERRUPTIBLE")
      self:UnregisterEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE")
      self:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_START")
      self:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE")
      self:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")

    elseif event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_DELAYED" then
      local name, _, texture, sTime, eTime, _, castID, shield, spellID = UnitCastingInfo(self.unit)
      if name then
        self.delay = 1
        self.castID = castID
        self.spellID = spellID
        self.duration = (eTime - sTime) / 1000
        self.elapsed = GetTime() - (sTime / 1000)
        self.bar:SetStatusBarColor(1.0, 0.7, 0.0)
        self.bar:SetMinMaxValues(0, self.duration)
        self.bar:SetValue(self.elapsed)
        self.icon:SetTexture(texture)
        self.text:SetText(name)
        if shield then
          self.shield:Show()
        else
          self.shield:Hide()
        end
        self:SetAlpha(1.0)
        self:SetScript("OnUpdate", OnUpdate_Casting)
        return true
      end

    elseif event == "UNIT_SPELLCAST_CHANNEL_START" or event == "UNIT_SPELLCAST_CHANNEL_UPDATE" then
      local name, _, texture, sTime, eTime, _, _, shield = UnitChannelInfo(self.unit)
      if name then
        self.delay = 1
        self.duration = (eTime - sTime) / 1000
        self.elapsed = self.duration - (GetTime() - (sTime / 1000))
        self.bar:SetStatusBarColor(1.0, 0.7, 0.0)
        self.bar:SetMinMaxValues(0, self.duration)
        self.bar:SetValue(self.elapsed)
        self.icon:SetTexture(texture)
        self.text:SetText(name)
        if shield then
          self.shield:Show()
        else
          self.shield:Hide()
        end
        self:SetAlpha(1.0)
        self:SetScript("OnUpdate", OnUpdate_Channel)
      end

    elseif event == "UNIT_SPELLCAST_INTERRUPTIBLE" then
      if self.castID == castID then
        self.shield:Hide()
      end

    elseif event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE" then
      if self.castID == castID then
        self.shield:Show()
      end

    elseif event == "UNIT_SPELLCAST_INTERRUPTED" then
      if self.castID == castID then
        self.bar:SetStatusBarColor(1.0, 0.0, 0.0)
        self.text:SetText("Interrupted")
        self.delay = 1.5
      end

    elseif event == "UNIT_SPELLCAST_FAILED" then
      if self.castID == castID then
        self.bar:SetStatusBarColor(1.0, 0.0, 0.0)
        self.text:SetText("Failed")
        self.delay = 1.5
      end

    elseif event == "UNIT_SPELLCAST_CHANNEL_STOP" then
      if self.castID == castID then
        self.castID = nil
        self.bar:SetValue(0)
        self:SetScript("OnUpdate", OnUpdate_Fading)
      end

    elseif event == "UNIT_SPELLCAST_STOP" then
      if self.castID == castID then
        self.castID = nil
        self.bar:SetValue(self.duration)
        self:SetScript("OnUpdate", OnUpdate_Fading)
      end

    else
      self:Show()
      self:RegisterUnitEvent("UNIT_SPELLCAST_START", self.unit)
      self:RegisterUnitEvent("UNIT_SPELLCAST_DELAYED", self.unit)
      self:RegisterUnitEvent("UNIT_SPELLCAST_STOP", self.unit)
      self:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTEd", self.unit)
      self:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", self.unit)
      self:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTIBLE", self.unit)
      self:RegisterUnitEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE", self.unit)
      self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", self.unit)
      self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", self.unit)
      self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", self.unit)
      if not OnEvent(self, "UNIT_SPELLCAST_START") then
        OnEvent(self, "UNIT_SPELLCAST_CHANNEL_START")
      end
    end
  end

  ${cleanup.add("CreateCastBar")}
  function CreateCastBar(parent, unit, height)
    local self = CreateFrame("frame", nil, parent, "BackdropTemplate")
    self:SetBackdrop(Media:CreateBackdrop(true, nil, 0, -1))
    self:SetBackdropColor(0, 0, 0, 0.75)
    self:SetHeight(height)
    self:SetAlpha(0)

    self.icon = self:CreateTexture()
    self.icon:SetPoint("TOPLEFT", 0, 0)
    self.icon:SetPoint("BOTTOMRIGHT", self, "BOTTOMLEFT", height, 0)
    self.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

    self.bar = CreateFrame("statusbar", nil, self)
    self.bar:SetPoint("TOPLEFT", height+1, 0)
    self.bar:SetPoint("BOTTOMRIGHT", 0, 0)
    self.bar:SetStatusBarTexture(Media.STATUSBAR_FLAT)

    self.shield = self.bar:CreateTexture(nil, "OVERLAY")
    self.shield:SetPoint("CENTER", self.icon, "CENTER", height*0.55, -height*0.05)
    self.shield:SetSize(height*3, height*3)
    self.shield:SetTexture([[Interface\\CastingBar\\UI-CastingBar-Arena-Shield]])

    self.text = self.bar:CreateFontString(nil, nil, "GameFontNormal")
    self.text:SetPoint("CENTER", -(height/2), 0)
    self.text:SetFont(Media.FONT_VIXAR, 14, "OUTLINE")

    self.unit = unit
    self:RegisterUnitEvent("UNIT_SPELLCAST_START", self.unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_DELAYED", self.unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_STOP", self.unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", self.unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", self.unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTIBLE", self.unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE", self.unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", self.unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", self.unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", self.unit)
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    if unit == "target" then
      self:RegisterEvent("PLAYER_TARGET_CHANGED")
    elseif unit:match('raid%d?$') or unit:match('party%d?$') then
      self:RegisterEvent("GROUP_ROSTER_UPDATE")
    elseif unit == "mouseover" then
      self:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
    elseif unit == "focus" then
      self:RegisterEvent("PLAYER_FOCUS_CHANGED")
    elseif unit:match('boss%d?$') then
      self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
      self:RegisterEvent("UNIT_TARGETABLE_CHANGED")
    elseif unit:match('arena%d?$') then
      self:RegisterEvent("ARENA_OPPONENT_UPDATE")
      self:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")
    end
    self:SetScript("OnEvent", OnEvent)
    return self
  end
end

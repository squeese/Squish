local CreateCastBar
do
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
    if self.alpha <= 0.25 then
      self:SetScript("OnUpdate", nil)
    end
  end
  local function Update(self, casting, name, _, texture, sTime, eTime, _, _, notInterruptible)
    if not name then return false end
    local curValue = GetTime() - (sTime / 1000)
    local maxValue = (eTime - sTime) / 1000
    self.bar:SetMinMaxValues(0, maxValue)
    self.bar:SetValue(casting and curValue or (maxValue - curValue))
    self.bar:SetStatusBarColor(1.0, 0.7, 0.0)
    self.icon:SetTexture(texture)
    self.text:SetText(name)
    --self:SetAlpha(1.0)
    self.interupted = nil
    if notInterruptible then
      self.shield:Show()
    else
      self.shield:Hide()
    end
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
    if event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_DELAYED" then
      Update(self, true, UnitCastingInfo(self.unit))

    elseif event == "UNIT_SPELLCAST_CHANNEL_START" or event == "UNIT_SPELLCAST_CHANNEL_UPDATE" then
      Update(self, false, UnitChannelInfo(self.unit))

    elseif event == "UNIT_SPELLCAST_INTERRUPTIBLE" or event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE" then
      if (Update(self, true, UnitCastingInfo(self.unit))) then return end
      if (Update(self, false, UnitChannelInfo(self.unit))) then return end
      --self:SetAlpha(0.25)
      self:SetScript("OnUpdate", nil)

    elseif event == "UNIT_SPELLCAST_INTERRUPTED" then
      print("2")
      self.bar:SetMinMaxValues(0, 1)
      self.bar:SetValue(1)
      self.bar:SetStatusBarColor(1.0, 0.0, 0.0)
      self.text:SetText("Interrupted")
      self.interupted = true

    elseif event == "UNIT_SPELLCAST_FAILED" then
      print("1")
      self.bar:SetMinMaxValues(0, 1)
      self.bar:SetValue(1)
      self.bar:SetStatusBarColor(1.0, 0.0, 0.0)
      self.text:SetText("Failed")
      self.interupted = true

    else
      -- self.bar:SetMinMaxValues(0, 1)
      -- self.bar:SetValue(1)
      -- self.alpha = self:GetAlpha() * (self.interupted and 4.0 or 1.0)
      -- self:SetScript("OnUpdate", OnUpdateFade)
    end
  end

  local function OnAttributeChanged(self, key, val)
    if key ~= 'statehidden' or val ~= self.hidden then
      -- print("changed", val)
      self.hidden = val
      if not self.hidden then
        print("show")
        UpdateCasting(self, UnitCastingInfo(self.unit))

      else
        print("hide")
        --self:SetAlpha(1)
        --self:SetScript("OnEvent", OnEvent)
        --if (Update(self, true, UnitCastingInfo(self.unit))) then return end
        --if (Update(self, false, UnitChannelInfo(self.unit))) then return end
        --self:SetAlpha(0.25)
        --self:SetScript("OnUpdate", nil)
      end
    end
  end

    --self:RegisterUnitEvent("UNIT_SPELLCAST_START", self.unit)
    --self:RegisterUnitEvent("UNIT_SPELLCAST_DELAYED", self.unit)
    --self:RegisterUnitEvent("UNIT_SPELLCAST_STOP", self.unit)
    --self:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", self.unit)
    --self:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", self.unit)
    --self:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTIBLE", self.unit)
    --self:RegisterUnitEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE", self.unit)
    --self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", self.unit)
    --self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", self.unit)
    --self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", self.unit)

  function CreateCastBar(parent, unit, height)
    local self = CreateFrame("frame", nil, parent, "SecureHandlerStateTemplate,BackdropTemplate")
    self:SetBackdrop(MEDIA:BACKDROP())
    self:SetBackdropColor(0, 0, 0, 0.75)
    self:SetHeight(height)
    --self:SetAlpha(0.25)
    self.icon = self:CreateTexture()
    self.icon:SetPoint("TOPLEFT", 0, 0)
    self.icon:SetPoint("BOTTOMRIGHT", self, "BOTTOMLEFT", height, 0)
    self.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    self.bar = CreateFrame("statusbar", nil, self)
    self.bar:SetPoint("TOPLEFT", height+1, 0)
    self.bar:SetPoint("BOTTOMRIGHT", 0, 0)
    self.bar:SetStatusBarTexture(MEDIA:STATUSBAR())
    self.shield = self.bar:CreateTexture(nil, "OVERLAY")
    self.shield:SetPoint("CENTER", self.icon, "CENTER", height*0.55, -height*0.05)
    self.shield:SetSize(height*3, height*3)
    self.shield:SetTexture([[Interface\\CastingBar\\UI-CastingBar-Arena-Shield]])
    self.text = self.bar:CreateFontString(nil, nil, "GameFontNormal")
    self.text:SetPoint("CENTER", -(height/2), 0)
    self.text:SetFont(MEDIA:FONT(), 14, "OUTLINE")
    self.text:SetText("")
    self.unit = "target"
    RegisterAttributeDriver(self, "state-visibility", "[@target,exists] show; hide")
    self:SetScript("OnAttributeChanged", OnAttributeChanged)
    return self
  end
end

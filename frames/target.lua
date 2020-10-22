local Q = select(2, ...)

local Range = Q.Range
local function OnEvent(self, event, ...)
  if UnitExists("target") then
    if not self.enabled then
      self.enabled = true
      Range:Register(self)
    end
    if event == "PLAYER_TARGET_CHANGED" then
      Range:Update(self)
    end
    self.nameString:SetText(UnitName("target"))
    self.healthString:SetText(UnitHealthMax("target")) -- (math.floor(UnitHealthMax("target") / 100) / 10) .. "k"
    self.infoString:SetText(UnitLevel("target") .." " .. UnitClassification("target"))
    if UnitIsQuestBoss("target") then
      self.questIcon:Show()
    else
      self.questIcon:Hide()
    end
  else
    self.enabled = nil
    Range:Unregister(self)
  end
end

function Target(gutter, player)
  local frame = CreateFrame("button", nil, gutter, "SecureUnitButtonTemplate,BackdropTemplate")
  frame.unit = "target"
  frame:SetScript("OnEnter", UnitFrame_OnEnter)
  frame:SetScript("OnLeave", UnitFrame_OnLeave)
  frame:RegisterForClicks("AnyUp")
  frame:EnableMouseWheel(true)
  frame:SetAttribute('*type1', 'target')
  frame:SetAttribute('*type2', 'togglemenu')
  frame:SetAttribute('toggleForVehicle', true)
  frame:SetAttribute("unit", frame.unit)
  frame:SetPoint("LEFT", player, "RIGHT", 16, 0)
  frame:SetSize(320, 64)
  frame:SetBackdrop(Q.BACKDROP)
  frame:SetBackdropColor(0, 0, 0, 0.75)
  frame:SetBackdropBorderColor(0, 0, 0, 1)
  RegisterUnitWatch(frame)

  local health, shield, absorb = Q.HealthBar("target", frame)
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

  local power = Q.PowerBar("player", frame)
  power:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, 8)
  power:SetPoint("BOTTOMRIGHT", 0, 0)

  local castbar = Q.CastBar("target", 32)
  castbar:SetParent(frame)
  castbar:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, -16)
  castbar:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT", 0, -16)

  frame.nameString = health:CreateFontString(nil, nil, "GameFontNormal")
  frame.nameString:SetPoint("TOPLEFT", 4, -6)
  frame.nameString:SetFont(Q.FONT, 16, "OUTLINE")

  frame.healthString = health:CreateFontString(nil, nil, "GameFontNormal")
  frame.healthString:SetPoint("BOTTOMLEFT", 4, 4)
  frame.healthString:SetFont(Q.FONT, 11, "OUTLINE")

  frame.infoString = health:CreateFontString(nil, nil, "GameFontNormal")
  frame.infoString:SetPoint("BOTTOMRIGHT", -4, 4)
  frame.infoString:SetFont(Q.FONT, 11, "OUTLINE")

  frame.questIcon = health:CreateTexture(nil, 'OVERLAY')
  frame.questIcon:SetSize(32, 32)
  frame.questIcon:SetPoint("TOPRIGHT", -4, 8)
  frame.questIcon:SetTexture([[Interface\TargetingFrame\PortraitQuestBadge]])

  frame:RegisterEvent("PLAYER_TARGET_CHANGED")
  frame:RegisterUnitEvent("UNIT_CLASSIFICATION_CHANGED", "target")
  frame:RegisterUnitEvent("UNIT_MAXHEALTH", "target")
  frame:RegisterUnitEvent("UNIT_LEVEL", "target")
  frame.enabled = nil
  frame:SetScript("OnEvent", OnEvent)

  return frame
end

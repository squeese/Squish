local Q = select(2, ...)

-- local quest = health:CreateTexture(nil, 'OVERLAY')
-- quest:SetSize(16, 16)
-- quest:SetPoint("BOTTOMLEFT", 52, 4)
-- quest:SetTexture([[Interface\TargetingFrame\PortraitQuestBadge]])

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

  local txtName = health:CreateFontString(nil, nil, "GameFontNormal")
  txtName:SetPoint("TOPLEFT", 4, -6)
  txtName:SetFont(Q.FONT, 16, "OUTLINE")

  local txtHealth = health:CreateFontString(nil, nil, "GameFontNormal")
  txtHealth:SetPoint("BOTTOMLEFT", 4, 4)
  txtHealth:SetFont(Q.FONT, 11, "OUTLINE")

  frame:RegisterEvent("PLAYER_TARGET_CHANGED")
  frame:RegisterUnitEvent("UNIT_MAXHEALTH", "target")

  local enabled = nil
  local Range = Q.Range
  frame:SetScript("OnUpdate", function()
    if UnitExists("target") then
      if not enabled then
        enabled = true
        Range:Register(frame)
      end
      txtName:SetText(UnitName("target"))
      txtHealth:SetText((math.floor(UnitHealthMax("target") / 100) / 10) .. "k")
    else
      enabled = nil
      Range:Unregister(frame)
    end
  end)

  local castbar = Q.CastBar("target", 32)
  castbar:SetParent(frame)
  castbar:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, -16)
  castbar:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT", 0, -16)

  return frame
end

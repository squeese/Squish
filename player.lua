local Q = select(2, ...)

function Q.Player(gutter, width, height, ...)
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
  frame:SetBackdrop(Q.BACKDROP)
  frame:SetBackdropColor(0, 0, 0, 0.75)
  frame:SetBackdropBorderColor(0, 0, 0, 1)

  local health, shield, absorb = Q.HealthBar("player", frame)
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

  local castbar = Q.CastBar("player", 32)
  castbar:SetParent(frame)
  castbar:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, -16)
  castbar:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT", 0, -16)

  return frame
end

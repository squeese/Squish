local UnitButton
do
  local OnEvent
  function UnitButton(parent, unit, config)
    local frame = CreateFrame("button", nil, parent, "SecureUnitButtonTemplate,BackdropTemplate")
    frame.unit = unit 
    frame:SetScript("OnEnter", UnitFrame_OnEnter)
    frame:SetScript("OnLeave", UnitFrame_OnLeave)
    frame:RegisterForClicks("AnyUp")
    frame:EnableMouseWheel(true)
    frame:SetAttribute('*type1', 'target')
    frame:SetAttribute('*type2', 'togglemenu')
    frame:SetAttribute('toggleForVehicle', true)
    frame:SetAttribute("unit", frame.unit)
    RegisterUnitWatch(frame)
    frame:SetBackdrop(${MEDIA.BG_NOEDGE})
    frame:SetBackdropColor(0, 0, 0, 0.75)
    frame:SetBackdropBorderColor(0, 0, 0, 1)

    --[[
    frame:SetScript("OnEvent", OnEvent)
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    function frame:EVENT(...)
      ${LOCAL.push()}
    end
    ]]
    return frame
  end
  function OnEvent(self, ...)
    print("ok", ...)
  end
end

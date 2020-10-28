local AcceptInvite
do
  local frame
  function AcceptInvite(delay)
    if frame == nil then
      frame = CreateFrame("frame", nil, UIParent)
    end
    frame:RegisterEvent("PARTY_INVITE_REQUEST")
    frame:SetScript("OnEvent", function(self)
      C_Timer.After(delay or 0.01, function()
        AcceptGroup()
        StaticPopup_Hide("PARTY_INVITE")
      end)
    end)
  end
end

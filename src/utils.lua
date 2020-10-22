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

local function PPFrame(...)
  local frame = CreateFrame("frame", nil, UIParent, ...)
  frame:SetPoint("TOPLEFT", 0, 0)
  frame:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMLEFT", 640, 0)
  frame:SetBackdrop(Q.BACKDROP)
  frame:SetBackdropColor(0, 0, 0, 0.1)
  frame:SetBackdropBorderColor(0, 0, 0, 0)
  frame:RegisterEvent("PLAYER_ENTERING_WORLD")
  frame:SetScript("OnEvent", function(self)
    self:SetScript("OnEvent", nil)
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    local scale = max(0.4, min(1.15, 768 / GetScreenHeight()))
    -- local scale = 0.533333333
    print("??", scale)
    self:SetScale(scale / UIParent:GetScale())
  end)
  return frame
end

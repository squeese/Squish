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
  frame:RegisterEvent("PLAYER_ENTERING_WORLD")
  frame:SetScript("OnEvent", function(self)
    self:SetScript("OnEvent", nil)
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    -- local scale = max(0.4, min(1.15, 768 / GetScreenHeight()))
    local scale = 0.533333333
    self:SetScale(scale / UIParent:GetScale())
  end)
  return frame
end

local ClassColor
local PowerColor
do
  function copyColors(src, dst)
    for key, value in pairs(src) do
      if not dst[key] then
        dst[key] = { r = value.r, g = value.g, b = value.b }
      end
    end
    return dst
  end
  local COLOR_POWER = copyColors(PowerBarColor, { MANA = { r = 0.31, g = 0.45, b = 0.63 }})
  ClassColor = function(unit)
    return RAID_CLASS_COLORS[select(2, UnitClass(unit))]
  end
  PowerColor = function(unit)
    return COLOR_POWER[select(2, UnitPowerType(unit))]
  end
end

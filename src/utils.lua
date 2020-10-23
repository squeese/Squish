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

local RangeChecker = {}
do
  RangeChecker.__frame = CreateFrame('frame', nil, UIParent)
  RangeChecker.__index = RangeChecker
  setmetatable(RangeChecker, RangeChecker)
  local insert = table.insert
  local remove = table.remove
  local elapsed = 0
  local function OnUpdate(_, e)
    elapsed = elapsed + e
    if elapsed > 0.15 then
      for index = 1, #RangeChecker do
        RangeChecker:Update(RangeChecker[index])
      end
      elapsed = 0
    end
  end
  function RangeChecker:Update(button)
    if UnitIsConnected(button.unit) then
      local close, checked = UnitInRange(button.unit)
      if checked and (not close) then
        button:SetAlpha(0.45)
      else
        button:SetAlpha(1.0)
      end
    else
      button:SetAlpha(1.0)
    end
  end
  function RangeChecker:Register(button)
    if #self == 0 then
      elapsed = 0
      self.__frame:SetScript("OnUpdate", OnUpdate)
    end
    table.insert(self, button)
  end
  function RangeChecker:Unregister(button)
    for index = 1, #self do
      if button == self[index] then
        remove(self, index)
        break
      end
    end
    if #self == 0 then
      self.__frame:SetScript("OnUpdate", nil)
    end
  end
end

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


local ClassColor
local PowerColor
do
  local COLOR_CLASS
  local COLOR_POWER
  do
    function copyColors(src, dst)
      for key, value in pairs(src) do
        if not dst[key] then
          dst[key] = { value.r, value.g, value.b }
        end
      end
      return dst
    end
    COLOR_POWER = copyColors(PowerBarColor, { MANA = { 0.31, 0.45, 0.63 }})
    COLOR_CLASS = copyColors(RAID_CLASS_COLORS, {})
  end
  local function ClassColor(unit)
    return COLOR_CLASS[select(2, UnitClass(unit))]
  end
  local function PowerColor(unit)
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

local function ToggleVisible(frame, condition)
  if condition then
    frame:Show()
  else
    frame:Hide()
  end
end

local function CreateStack(self, P, R, X, Y, p, r, x, y)
  return function(...)
    local anchor
    for i = 1, select("#", ...) do
      local icon = select(i, ...)
      if icon:IsShown() then
        if anchor == nil then
          icon:SetPoint(P, self, R, X, Y)
        else
          icon:SetPoint(p, anchor, r, x, y)
        end
        anchor = icon
      end
    end
  end
end

local Spring
do
  local FPS = 60
  local MPF = 1000/FPS
  local SPF = MPF/1000
  local function stepper(x, v, t, k, b)
    local fs = -k * (x - t)
    local fd = -b * v
    local a = fs + fd
    local V = v + a * SPF
    local X = x + V * SPF
    return X, V
  end
  local insert = table.insert
  local remove = table.remove
  local floor = math.floor
  local abs = math.abs
  local function update(s, elapsed)
    s.__update_e = s.__update_e + elapsed
    local delta = (s.__update_e - floor(s.__update_e / MPF) * MPF) / MPF
    local frames = floor(s.__update_e / MPF)
    for i = 0, frames-1 do
      s.__update_C, s.__update_V = stepper(s.__update_C, s.__update_V, s.__update_t, s.__update_k, s.__update_b)
    end
    local c, v = stepper(s.__update_C, s.__update_V, s.__update_t, s.__update_k, s.__update_b)
    s.__update_c = s.__update_C + (c - s.__update_C) * delta
    s.__update_v = s.__update_V + (v - s.__update_V) * delta
    s.__update_e = s.__update_e - frames * MPF
  end
  local function idle(s)
    if (abs(s.__update_v) < s.__update_p and abs(s.__update_c - s.__update_t) < s.__update_p) then
      s.__update_c = s.__update_t
      s.__update_C = s.__update_t
      s.__update_v = 0
      s.__update_V = 0
      s.__update_e = 0
      return true
    end
    return false
  end
  local frame = CreateFrame("frame", nil, UIParent)
  local active = {}
  local function OnUpdate(_, elapsed)
    local elapsedMS = elapsed * 1000
    local elapsedDT = elapsedMS / MPF
    for i = #active, 1, -1 do
      local s = active[i]
      if idle(s) then
        s.__active = nil
        remove(active, i)
        if #active == 0 then
          frame:SetScript("OnUpdate", nil)
        end
      else
        update(s, elapsedMS)
      end
      s.__update_F(s.__update_c)
    end
  end
  function Spring(FN, K, B, P)
    local spring
    return function(target)
      if not spring then
        spring = {}
        spring.__update_F = FN
        spring.__update_p = P or 0.01
        spring.__update_k = K or 170
        spring.__update_b = B or 26
        spring.__update_c = target
        spring.__update_C = target
        spring.__update_v = 0
        spring.__update_V = 0
        spring.__update_e = 0
      end
      spring.__update_t = target
      if not spring.__active then
        spring.__active = true
        if #active == 0 then
          frame:SetScript("OnUpdate", OnUpdate)
        end
        insert(active, spring)
      end
    end
  end
end

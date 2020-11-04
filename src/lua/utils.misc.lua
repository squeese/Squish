local function Misc_ToggleVisible(frame, condition)
  if condition then
    frame:Show()
  else
    frame:Hide()
  end
end

local function Misc_Stack(self, P, R, X, Y, p, r, x, y, ...)
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

local function Misc_RangeChecker(self)
  if UnitIsConnected(self.unit) then
    local close, checked = UnitInRange(self.unit)
    if checked and (not close) then
      self:SetAlpha(0.45)
    else
      self:SetAlpha(1.0)
    end
  else
    -- self:SetAlpha(0.45)
    self:SetAlpha(1.0)
  end
end

local function Misc_CountVisible(...)
  local n = 0
  for i = 1, select("#", ...) do
    if not select(i, ...):IsShown() then
      break
    end
    n = n + 1
  end
  return n
end

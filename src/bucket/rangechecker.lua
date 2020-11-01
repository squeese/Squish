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
        --button.__range(button, 0.45)
      else
        button:SetAlpha(1.0)
      end
    else
      button:SetAlpha(1.0)
    end
  end

  function RangeChecker:Register(button, doUpdate)
    if #self == 0 then
      elapsed = 0
      self.__frame:SetScript("OnUpdate", OnUpdate)
    end
    ${DEV && `for index = 1, #self do
      assert(#self[index] ~= button)
    end`}
    table.insert(self, button)
    if doUpdate then
      self:Update(button)
    end
  end

  function RangeChecker:Unregister(button)
    for index = 1, #self do
      if button == self[index] then
        remove(self, index)
        break
      end
    end
    ${DEV && `for index = 1, #self do
      assert(#self[index] ~= button)
    end`}
    button:SetAlpha(1)
    if #self == 0 then
      self.__frame:SetScript("OnUpdate", nil)
    end
  end
end

local Ticker = {}
do
  Ticker.__frame = CreateFrame('frame', nil, UIParent)
  Ticker.__index = Ticker

  local remove = table.remove
  local insert = table.insert
  local msWait = 1.0
  local cursor
  local elapsed

  local function OnUpdate_Ticker(self, e)
    elapsed = elapsed + e
    if elapsed < msWait then return end
    elapsed = 0
    local tbl = Ticker[cursor]
    cursor = cursor - 1
    tbl:__tick()
  end

  insert(Ticker, Ticker)

  function Ticker:__tick()
    cursor = #self
    msWait = 1.0 / cursor
  end

  function Ticker:Remove(tbl)
    for index = 1, #self do
      if tbl == self[index] then
        remove(self, index)
        break
      end
    end
    ${DEV && `for index = 1, #self do assert(#self[index] ~= tbl) end`}
    if #self == 1 then
      --self.__frame:SetScript("OnUpdate", nil)
    end
  end

  function Ticker:Add(tbl, doUpdate)
    ${DEV && `for index = 1, #self do assert(#self[index] ~= tbl) end`}
    if #self == 1 then
      elapsed = 0
      cursor = 2
      --self.__frame:SetScript("OnUpdate", OnUpdate_Ticker)
    end
    insert(self, tbl)
    print("added", elapsed, cursor, #self)
  end
end

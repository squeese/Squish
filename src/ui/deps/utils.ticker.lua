${locals.use("table.remove")}
${locals.use("table.insert")}
local Ticker = {}
do
  Ticker.__frame = CreateFrame('frame', nil, UIParent)
  Ticker.__index = Ticker
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

  Table_Insert(Ticker, Ticker)

  function Ticker:__tick()
    cursor = #self
    msWait = 1.0 / cursor
  end

  function Ticker:Remove(tbl)
    for index = 1, #self do
      if tbl == self[index] then
        Table_Remove(self, index)
        if cursor >= index then
          cursor = cursor - 1
        end
        break
      end
    end
    ${DEV && `for index = 1, #self do assert(self[index] ~= tbl) end`}
    if #self == 1 then
      self.__frame:SetScript("OnUpdate", nil)
    end
  end

  function Ticker:Add(tbl, doUpdate)
    ${DEV && `for index = 1, #self do assert(self[index] ~= tbl) end`}
    if #self == 1 then
      elapsed = 0
      cursor = 2
      self.__frame:SetScript("OnUpdate", OnUpdate_Ticker)
    end
    Table_Insert(self, tbl)
    if doUpdate then
      tbl:__tick()
    end
  end
end

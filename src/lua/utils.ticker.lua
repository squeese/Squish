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

local Queue = CreateFrame("frame", nil, UIParent)
do
  local function OnUpdate_Queue(self, elapsed)
    self[1].__delay = self[1].__delay - elapsed
    if self[1].__delay < 0 then
      if #self > 1 then
        self[2].__delay = self[2].__delay + self[1].__delay
      end
      local tbl = self[1]
      Table_Remove(self, 1)
      tbl:__tick()
      if #self == 0 then
        self:SetScript("OnUpdate", nil)
      end
    end
  end
  function Queue:Insert(tbl, delay)
    if #self == 0 then
      self:SetScript("OnUpdate", OnUpdate_Queue)
    end
    tbl.__delay = delay
    for i = 1, #self do
      if tbl.__delay < self[i].__delay then
        self[i].__delay = self[i].__delay - tbl.__delay
        Table_Insert(self, i, tbl)
        return
      else
        tbl.__delay = tbl.__delay - self[i].__delay
      end
    end
    Table_Insert(self, tbl)
  end
  function Queue:Remove(tbl)
    for i = 1, #self do
      if tbl == self[i] then
        if i < #self then
          self[i+1].__delay = self[i+1].__delay + tbl.__delay
        end
        Table_Remove(self, i)
        break
      end
    end
    if #self == 0 then
      self:SetScript("OnUpdate", nil)
    end
  end
end

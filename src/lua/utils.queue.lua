${locals.use("table.insert")}
${locals.use("table.remove")}
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

local Squish = select(2, ...)
local pool = CreateObjectPool(
  function(self) return {} end,
  function(self, tbl)
    for key in pairs(tbl) do
      tbl[key] = nil
    end
  end)

function Squish.getTableWith(...)
  local tbl = pool:Acquire()
  for i = 1, select('#', ...) do
    tbl[i] = select(i, ...)
  end
  return tbl
end

function Squish.getTable()
  return pool:Acquire()
end

function Squish.returnTable(tbl)
  pool:Release(tbl)
end

local Squish = select(2, ...)

function Squish.CreateWeakTable()
  local tbl = setmetatable({}, {
    __mode = 'v',
    __call = function(self, value)
      if value ~= nil then
        table.insert(self, value)
      else
        collectgarbage("collect")
        for key in pairs(self) do
          print("WeakMap:", key, self[key])
        end
        return #self
      end
    end,
  })
  getmetatable(tbl).__index = getmetatable(tbl)
  return tbl
end

do
  local function match(a, b)
    if a == b then
      return true
    end
    if type(a) ~= "table" or type(b) ~= "table" then
      return false
    end
    for key in pairs(a) do
      if not match(a[key], b[key]) then
        return false
      end
    end
    for key in pairs(b) do
      if not match(a[key], b[key]) then
        return false
      end
    end
    return true
  end
  Squish.matchTables = match
end

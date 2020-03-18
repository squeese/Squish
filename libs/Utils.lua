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

do
  local Stack = {}
  Stack.__index = Stack
  function Stack:push(node, ...)
    local index = #self+1
    local count = select("#", ...)
    self[index] = index + count + 1
    self[index+1] = node
    for i = 1, count do
      self[index+i+1] = select(i, ...)
    end
    return index
  end
  local function rewind(stack, from, to, ...)
    for i = from, to do
      stack[i] = nil
    end
    return ...
  end
  function Stack:pop(index)
    if not index then
      return index
    end
    return rewind(self, index, unpack(self, index, self[index]))
  end
  function Squish.Stack()
    return setmetatable({}, Stack)
  end
end

function Squish.Props()
  local dirty = false
  local props = {}
  local props_RO = setmetatable({}, {
    __index = props,
    __newindex = function(self, key, value)
    end,
  })
  return function(...)
    if dirty then
      for key in pairs(props) do
        props[key] = nil
      end
    end
    local offset = 1
    for i = 1, select("#", ...), 2 do
      local value = select(i, ...)
      if type(value) == "string" then
        dirty = true
        props[value] = select(i+1, ...)
        offset = i+2
      end
    end
    return props_RO, select(offset, ...)
  end
end

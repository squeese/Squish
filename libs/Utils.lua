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
  function Stack:push(...)
    local length = select("#", ...)
    local index = self.index + 1
    self[index] = index + length
    self.index = index + length
    for i = 1, length do
      self[index+i] = select(i, ...)
    end
    return index
  end
  local function rewind(stack, iBeg, iEnd, ...)
    for i = iBeg, iEnd do
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
    return setmetatable({ index = 0 }, Stack)
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

function Squish.Test(fn)
  local function section(name, fn)
    local status, result = pcall(fn)
    if not status then
      print("[x]", name)
      error(result, 3)
    end
    print("[v]", name)
  end

  local function equals(a, b, msg)
    if a ~= b then
      if msg then
        error(msg, 2)
      else
        print("a:", a)
        print("b:", b)
        error("equality error", 2)
      end
    end
  end

  local match = Squish.matchTables
  local function deepEquals(a, b)
    if not match(a, b) then
      error("equality error", 2)
    end
  end

  local function spy(fn)
    fn = fn or function(...) return ... end
    return setmetatable({ count = 0 }, {
      __call = function(self, ...)
        self.count = self.count + 1
        return fn(...)
      end,
    })
  end

  local status, result = pcall(fn, section, equals, spy, deepEquals)
  if not status then
    print(result)
    error(result)
  end
end

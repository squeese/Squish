local Squish = select(2, ...)

function Squish.Index(root, call)
  root.__call = call or function(self, next)
    next.__index = self
    next.__call = self.__call
    return setmetatable(next, next)
  end
  return setmetatable(root, root)
end

do
  local function create()
    return {}
  end
  local function reset(tbl)
    return tbl
  end
  function Squish.Pool()
    return CreateObjectPool(create, reset)
  end
end

do
  local function rewind(stack, iBeg, iEnd, _, ...)
    for i = iBeg, iEnd do
      stack[i] = nil
    end
    return ...
  end
  Squish.Stack = Squish.Index({
    index = 0,
    push = function(self, ...)
      local length = select("#", ...)
      local index = self.index + 1
      self[index] = index + length
      self.index = index + length
      for i = 1, length do
        self[index+i] = select(i, ...)
      end
      return index
    end,
    pop = function(self, index)
      if not index then
        return index
      end
      return rewind(self, index, unpack(self, index, self[index]))
    end,
  })
end

Squish.Nodes = Squish.Index({
  push = function(self, node)
    local sBeg = #self
    local sEnd = #self + #node
    local nEnd = 0
    for index, child in ipairs(node) do
      if child.key then
        node[child.key] = sBeg + index
      else
        nEnd = nEnd - 1
        node[nEnd] = sBeg + index
      end
      self[sBeg + index] = child
      node[index] = nil
    end
    node.__sBeg = sBeg
    node.__sEnd = sEnd
    node.__nBeg = -1
    node.__nEnd = nEnd
  end,

  next = function(self, node, key)
    if not key then
      key = node.__nBeg
      node.__nBeg = node.__nBeg - 1
    end
    local address = node[key]
    if address then
      node[key] = nil
      local node = self[address]
      self[address] = nil
      return node
    end
  end,

  _pop = function(self, node, fn)
    local sBeg = node.__sBeg
    local sEnd = node.__sEnd
    local sNum = node.__sNum
    for i = sBeg+1, sEnd do
      if self[i] ~= nil then
        if self[i].key then
          node[self[i].key] = nil
          fn(node, self[i])
        else
          node[sNum] = nil
          sNum = sNum + 1
          fn(node, self[i])
        end
        self[i] = nil
      end
    end
    node.__sBeg = nil
    node.__sEnd = nil
    node.__sNum = nil
  end,
})

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

local Squish = select(2, ...)
local Index = Squish.Index
local Pool = Squish.Pool
local Stack = Squish.Stack
local Nodes = Squish.Nodes
local Swap = Squish.Swap

local function Driver(self, next, ...)
  next = type(next) == "function" and { render = next } or next
  next.__index = self
  next.__call = self.__call
  return setmetatable(next, next)
end

local function Acquire(self, container, key, ...)
  return container, ...
end

function Squish.Create(pool, stack, nodes)
  local POOL = pool or Pool()
  local STACK = Stack(stack or {})
  local PASSIVE = { driver = Driver };
  local ACTIVE = {
    driver = function(self, ...)
      return STACK:push(self, ...)
    end,
    acquire = function(self, container, key)
    end,
    mount = function(self, container, node)
    end,
    render = function(self, node, ...)
      return node, ...
    end,
    release = function(self, node, ...)
    end,
  }
  local DRIVER = Index({
    __index = PASSIVE,
    __metatable = false,
  }, function(self, ...)
    return self:driver(...)
  end)

  local function acquire(i, node, key)
    if node[i] then
      if node[i].key == key then
        return node[i], i+1
      end
      for j = i+1, #node do
        node[i], node[j] = node[j], node[i]
        if node[i].key == key then
          return node[i], i+1
        end
      end
      node[#node+1] = node[i]
    end
    node[i] = POOL:Acquire()
    node[i].key = key
    return node[i], i+1
  end

  local function clean(node)
    for i = node.__beg, node.__end - 1 do
      print("remove", i)
    end
  end


  local render
  local function mount(index, node, driver, key, ...)
    assert(node ~= nil, "cant mount driver on empty node")
    local child = driver:acquire(index, node, key)

    if child ~= node then
      return render(b, e, node, ...)
    end
    b, e, child = acquire(b, e, node, key)
    if not child.driver then
      print(node, "mount", "new")
      child.driver = driver
      driver:mount(node, child)

    elseif child.driver ~= driver then
      print(node, "mount", "swap")
      driver:remove(node)
      node.driver = driver
      driver:mount(node, child)
    end

    render(1, #child+1, child, ...)

    return b, e
  end

  render = function(index, node, ...)
    for i = 1, select("#", ...) do
      local driver = select(i, ...)
      local kind = type(driver)
      if kind == "function" then
        index = render(index, node, driver())
      elseif kind == "number" then
        local index, driver = driver, STACK[driver+1]
        index = mount(index, node, driver, nil, STACK:pop(index))
      elseif kind == "table" then
        index = mount(index, node, driver, rawget(driver, 'key'), unpack(driver))
      end
    end
    return index
  end

  return DRIVER{}, function()
    local node = {}
    return function(...)
      DRIVER.__index = ACTIVE
      print(render(1, node, ...))
      DRIVER.__index = PASSIVE
      ViragDevTool_AddData(node, 'node')
    end,
    function()
    end
  end
end

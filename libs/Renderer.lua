local Q = select(2, ...)
local Stack = { index = 0 }
local Driver = {}
local CallClone
local CallStack
local CallMode
local Pool = CreateObjectPool(function()
  return {}
end, function(tbl)
  return tbl
end)

do
  CallClone = function(self, next)
    if type(next) == "function" then
      next = { render = next }
    end
    next.__index = self
    next.__call = self.__call
    setmetatable(next, next)
    next:upgrade()
    return next
  end

  CallStack = function(...)
    local length = select("#", ...)
    local index = Stack.index + 1
    Stack[index] = index + length
    Stack.index = index + length
    for i = 1, length do
      Stack[index+i] = select(i, ...)
    end
    return index
  end

  CallMode = CallClone
  Driver.__index = Driver
  Driver.__call = function(...)
    return CallMode(...)
  end
  setmetatable(Driver, Driver)

  function Driver:upgrade(next)
  end

  function Driver:opaque(parent, cursor, key)
    return parent, cursor
  end

  function Driver:acquire(parent, i, key)
    if parent[i] then
      if parent[i].key == key then
        return parent[i], i+1
      end
      for j = i+1, #parent do
        parent[i], parent[j] = parent[j], parent[i]
        if parent[i].key == key then
          return parent[i], i+1
        end
      end
      parent[#parent+1] = parent[i]
    end
    parent[i] = Pool:Acquire()
    parent[i].key = key
    return parent[i], i+1
  end

  function Driver:mount(container, parent)
  end

  function Driver:render(container, key, ...)
    return ...
  end

  function Driver:remove(container)
  end

  Q.Driver = Driver
end

do
  local mount
  local render
  local function release(container, offset)
    for index = offset, #container do
      local child = container[index]
      container[index] = nil
      release(child, 1)
      child.driver:remove(child)
      child.driver = nil
      child.key = nil
      for key in pairs(child) do
        assert(false, "key: "..key..", not nil")
      end
      Pool:Release(child)
    end
  end

  local function unwind(min, max, ...)
    for i = min, max do
      Stack[i] = nil
    end
    return ...
  end

  mount = function(container, cursor, driver, key, ...)
    local child, cursor = driver:acquire(container, cursor, key)
    if child == container then
      return render(container, cursor, driver:render(container, key, ...))
    elseif not child.driver then
      child.driver = driver
      driver:mount(child, container, key, ...)
    elseif child.driver ~= driver then
      child.driver:remove(child)
      child.driver = driver
      driver:mount(child, container, key, ...)
    end
    release(child, render(child, 1, driver:render(child, key, ...)))
    return cursor
  end

  render = function(container, cursor, ...)
    for i = 1, select("#", ...) do
      local driver = select(i, ...)
      if driver ~= nil then
        local kind = type(driver)
        if kind == "function" then
          cursor = render(container, cursor, driver())
        elseif kind == "number" then
          cursor = mount(container, cursor, unwind(driver, unpack(Stack, driver, Stack[driver])))
        elseif kind == "table" then
          cursor = mount(container, cursor, driver, rawget(driver, 'key'), unpack(driver))
        end
      end
    end
    return cursor
  end

  local Root = Driver{ acquire = Driver.opaque }

  local function Create()
    local root = { driver = Root }
    return function(...)
      CallMode = CallStack
      release(root, mount(root, 1, Root, nil, ...))
      CallMode = CallClone
    end
  end

  Q.Create = Create
end

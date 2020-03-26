local Q = select(2, ...)
local unwind = Q.unwind
local Stack = { index = 0 }
local Driver = {}
local CallClone
local CallStack
local CallMode
local RenderNode
local RenderChildren
local Pool = CreateObjectPool(function()
  return {}
end, function(tbl)
  return tbl
end)

local function next(parent, i, key)
  if parent[i] then
    if parent[i].key == key then
      return parent[i]
    end
    for j = i+1, #parent do
      parent[i], parent[j] = parent[j], parent[i]
      if parent[i].key == key then
        return parent[i]
      end
    end
    parent[#parent+1] = parent[i]
  end
  parent[i] = Pool:Acquire()
  parent[i].key = key
  return parent[i]
end

CallClone = function(self, next, update)
  if type(next) == "function" then
    next = { render = next, update = update }
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
--Driver.__index = Driver
Driver.__call = function(...)
  return CallMode(...)
end
setmetatable(Driver, Driver)
Q.Driver = Driver

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

function Driver:release(container, offset)
  for index = offset, #container do
    local child = container[index]
    child.__driver:release(child, 1)
    child.__driver:remove(child)
    child.__driver = nil
    child.key = nil
    Pool:Release(child)
    container[index] = nil
  end
end

function Driver:render(container, parent, key, ...)
  return ...
end

function Driver:update(container, ...)
  return ...
end

function Driver:remove(container)
end

function Driver:OPAQUE(parent, cursor, key, ...)
  return cursor, ...
end

function Driver:ATTACH(parent, cursor, key, ...)
  local container = next(parent, cursor, key)
  if container.__driver == driver then
    self:RELEASE(container, self:CHILDREN(container, 1, self:UPD(container, parent, key, ...)))
  else
    if container.__driver then
      container.__driver:REMOVE(container)
    end
    container.__driver = driver
    self:RELEASE(container, self:CHILDREN(container, 1, self:BEG(container, parent, key, ...)))
  end
  return cursor + 1
end

function Driver:CHILDREN(container, cursor, ...)
  for i = 1, select("#", ...) do
    local driver = select(i, ...)
    if driver ~= nil then
      local kind = type(driver)
      if kind == "function" then
        cursor = self:CHILDREN(container, cursor, driver())
      elseif kind == "number" then
        cursor = self:ATTACH(container, cursor, unwind(Stack, driver, unpack(Stack, driver, Stack[driver])))
      elseif kind == "table" then
        cursor = self:ATTACH(container, cursor, driver, rawget(driver, 'key'), unpack(driver))
      else
        print("skipped", kind, driver)
      end
    end
  end
  return cursor
end

function Driver:RELEASE(container, offset)
end

function Driver:REMOVE(container)
end

RenderNode = function(container, cursor, driver, key, ...)
  local child, cursor = driver:acquire(container, cursor, key)
  if child == container then
    return RenderChildren(container, cursor, driver:render(nil, container, key, ...))
  elseif not child.__driver then
    child.__driver = driver
    driver:release(child, RenderChildren(child, 1, driver:render(child, container, key, ...)))
  elseif child.__driver ~= driver then
    child.__driver:remove(child)
    child.__driver = driver
    driver:release(child, RenderChildren(child, 1, driver:render(child, container, key, ...)))
  else
    driver:release(child, RenderChildren(child, 1, driver:update(child, ...)))
  end
  return cursor
end

RenderChildren = function(container, cursor, ...)
  for i = 1, select("#", ...) do
    local driver = select(i, ...)
    if driver ~= nil then
      local kind = type(driver)
      if kind == "function" then
        cursor = RenderChildren(container, cursor, driver())
      elseif kind == "number" then
        cursor = RenderNode(container, cursor, unwind(Stack, driver, unpack(Stack, driver, Stack[driver])))
      elseif kind == "table" then
        cursor = RenderNode(container, cursor, driver, rawget(driver, 'key'), unpack(driver))
      else
        print("skipped", kind, driver)
      end
    end
  end
  return cursor
end

local function Create()
  local root = {}
  return function(...)
    CallMode = CallStack
    Driver:RELEASE(root, Driver:CHILDREN(root, 1, ...))
    CallMode = CallClone
  end
end


Q.Create = Create


do
  local Queue = {}
  Queue.__index = Queue
  local function dispatch(timer)
    local container = timer[1]
    local driver = container.__driver
    container.timer = nil
    CallMode = CallStack
    driver:release(container, RenderChildren(container, 1, driver:update(container, unpack(timer, 2))))
    CallMode = CallClone
  end
  function Queue:update(timer, ...)
    local length = select("#", ...)
    for i = 1, length do
      timer[i] = select(i, ...)
    end
    for i = length+1, #timer do
      timer[i] = nil
    end
  end
  function Queue:__call(container, ...)
    if not container.timer then
      container.timer = C_Timer.NewTimer(0, dispatch)
    end
    self:update(container.timer, container, ...)
  end
  setmetatable(Queue, Queue)
  function Driver:tmp(container, ...)
    Queue(container, ...)
  end
end

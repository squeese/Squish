local Q = select(2, ...)
local unwind = Q.unwind
local write = Q.write
local Stack = { index = 0 }
local Driver = {}
local Container = {}
local CallClone
local CallStack
local CallMode
local RenderNode
local RenderChildren

Container.__index = Container
Container.__pool = CreateObjectPool(function()
  return {}
end, function(self, tbl)
  tbl.key = nil
  setmetatable(tbl, nil)
  for key, value in pairs(tbl) do
    print("?????", key, value)
  end
  return tbl
end)

function Container:__call(i, key)
  if self[i] then
    if self[i].key == key then
      return self[i]
    end
    for j = i+1, #self do
      self[i], self[j] = self[j], self[i]
      if self[i].key == key then
        return self[i]
      end
    end
    self[#self+1] = self[i]
  end
  self[i] = setmetatable(self.__pool:Acquire(), Container)
  self[i].key = key
  return self[i]
end

CallClone = function(self, next)
  if type(next) == "function" then
    local oRENDER = self.RENDER
    local nRENDER = next
    next = {
      RENDER = function(self, container, parent, key, ...)
        return nRENDER(self, container, parent, key, oRENDER(self, container, parent, key, ...))
      end
    }
  end
  next.__index = self
  next.__call = next.__call or self.__call
  setmetatable(next, next)
  next:UPGRADE_CLONE()
  return next
end

local function stack(...)
  local length = select("#", ...)
  local index = Stack.index + 1
  Stack[index] = index + length
  Stack.index = index + length
  for i = 1, length do
    Stack[index+i] = select(i, ...)
  end
  return index
end

CallStack = function(self, ...)
  return stack(self, self:UPGRADE_STACK(stack, ...))
end

CallMode = CallClone
Driver.__call = function(...)
  return CallMode(...)
end
setmetatable(Driver, Driver)
Q.Driver = Driver

function Driver:STACK(...)
  return stack(...)
end

function Driver:UPGRADE_CLONE(driver)
end

function Driver:UPGRADE_STACK(fn, ...)
  return ...
end

function Driver:ATTACH(parent, cursor, key, ...)
  local container = parent(cursor, key)
  if container.__driver == self then
    self:RELEASE(self:CHILDREN(container, 1, self:UPDATE(container, ...)))
  else
    if container.__driver then
      container.__driver:REMOVE(container)
    end
    container.__driver = self
    self:RELEASE(self:CHILDREN(container, 1, self:RENDER(container, parent, key, ...)))
  end
  return container, cursor + 1
end

function Driver:CHILDREN(container, cursor, ...)
  for i = 1, select("#", ...) do
    local driver = select(i, ...)
    if driver ~= nil then
      local kind = type(driver)
      if kind == "function" then
        _, cursor = self:CHILDREN(container, cursor, driver())
      elseif kind == "number" then
        local a, b, driver = driver, Stack[driver], Stack[driver+1]
        _, cursor = self:CHILDREN(driver:ATTACH(container, cursor, unwind(Stack, a, b, unpack(Stack, a+2, b))))
      elseif kind == "table" then
        _, cursor = self:CHILDREN(driver:ATTACH(container, cursor, rawget(driver, 'key'), unpack(driver)))
      end
    end
  end
  return container, cursor
end

function Driver:RENDER(container, parent, key, ...)
  return ...
end

function Driver:UPDATE(container, ...)
  return ...
end

function Driver:RELEASE(container, offset)
  for index = offset or 1, #container do
    container[index].__driver:RELEASE(container[index], nil)
    container[index] = nil
  end
  if not offset then
    container.__driver:REMOVE(container)
    container.__driver = nil
    container.__pool:Release(container, nil)
  end
end

function Driver:REMOVE(container)
end

function Q.Create()
  local root = setmetatable({ __driver = Driver }, Container)
  return function(...)
    CallMode = CallStack
    Driver:RELEASE(Driver:CHILDREN(root, 1, ...))
    CallMode = CallClone
  end
end

do
  local function dispatch(timer)
    local driver, container, fn = unpack(timer, 1, 3)
    CallMode = CallStack
    driver:RELEASE(driver:CHILDREN(container, 1, fn(driver, container, unpack(timer, 4))))
    CallMode = CallClone
    container.timer = write(timer)
  end
  function Driver:QUEUE(container, ...)
    if not container.timer then
      container.timer = C_Timer.NewTimer(0, dispatch)
    end
    write(container.timer, self, container, ...)
  end
end

do
  local function dispatch(timer)
    local container = timer[1]
    local driver = container.__driver
    CallMode = CallStack
    driver:RELEASE(driver:CHILDREN(container, 1, unpack(container)))
    CallMode = CallClone
    container.timer = write(timer)
  end
  function Driver:FLASH(container)
    if not container.timer then
      container.timer = C_Timer.NewTimer(0, dispatch)
    end
    write(container.timer, container)
  end
end

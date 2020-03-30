local Q = select(2, ...)
local map = Q.map
local OFFSET = 32
local ATTACH = Q.Driver.ATTACH
local RELEASE = Q.Driver.RELEASE
local function write(t, o, ...)
  local l = select("#", ...)
  for i = 1, l do
    t[i+o] = select(i, ...)
  end
  return o+l
end

Q.Set = Q.Driver{
  name = "Set",
  UPGRADE_STACK = function(self, _, ...)
    return nil, ...
  end,
  ATTACH = function(self, parent, cursor, key, name, ...)
    parent.frame[name](parent.frame, ...)
    return parent, cursor
  end,
}

Q.SetStatic = Q.Set

Q.FValue = Q.Driver{
  RENDER = function(self, container, parent, _, value)
    container.__value = value
  end,
  WRITE = function(self, container, t, o)
    container.__next.__driver:WRITE(container.__next, t, write(t, o, container.__value))
  end,
  REMOVE = function(self, container)
    container.__value = nil
    container.__next = nil
  end,
}

Q.DValue = Q.Driver{
  ATTACH = function(self, parent, cursor, key, stream, ...)
    local container, cursor = ATTACH(self, parent, cursor, key, stream)
    container.__send(...)
    return container, cursor
  end,
  RENDER = function(self, container, parent, key, stream)
    container.__stream = stream
    container.__cleanup = stream:subscribe(self.STREAM, self, container)
  end,
  SUBSCRIBE = function(self, container, subscriber)
    container.__send = subscriber
    return Q.noop
  end,
  UPDATE = function(self, container, stream)
    if stream ~= container.__stream then
      container.__r = false
      container.__stream = stream
      container.__cleanup()
      container.__cleanup = stream:subscribe(self.STREAM, self, container)
    end
  end,
  STREAM = function(self, container, ...)
    local length = select("#", ...)
    for index = 1, length do
      container[index] = select(index, ...)
    end
    for index = length+1, #container do
      container[index] = nil
    end
    container.__r = true
    self:WRITE_NEXT(container)
  end,
  WRITE = function(self, container, t, o)
    container.__t = t
    container.__o = o
    self:WRITE_NEXT(container)
  end,
  WRITE_NEXT = function(self, container)
    if not container.__r then return end
    if not container.__t then return end
    local t = container.__t
    local o = container.__o
    container.__next.__driver:WRITE(container.__next, t, write(t, o, unpack(container)))
  end,
  RELEASE = function(self, container, offset)
    if not offset then
      for i = 1, #container do
        container[i] = nil
      end
      return RELEASE(self, container, nil)
    end
  end,
  REMOVE = function(self, container)
    container.__cleanup()
    container.__cleanup = nil
    container.__stream = nil
    container.__send = nil
    container.__next = nil
    container.__t = nil
    container.__o = nil
    container.__r = nil
  end
}

local FValue = Q.FValue
local function upgrade(index, value)
  if type(value) ~= "table" then
    return FValue(nil, value)
  end
  return value
end

local CALL = Q.Driver.__call
local args = {}
Q.SetDynamic = Q.Driver{
  __call = function(self, ...)
    local l = select("#", ...)
    for i = 1, l do
      local value = select(i, ...)
      if type(value) ~= "table" then
        args[i] = self:STACK(Q.FValue, nil, value)
      else
        args[i] = self:STACK(Q.DValue, nil, value, unpack(value))
      end
    end
    return CALL(self, nil, unpack(args, 1, l))
  end,
  ATTACH = function(self, ...)
    local container, cursor = ATTACH(self, ...)
    local next = container
    for i = #container, 1, -1 do
      container[i].__next = next
      next = container[i]
    end
    next.__driver:WRITE(next, container, OFFSET)
    return container, cursor
  end,
  RENDER = function(self, container, parent, key, ...)
    container.frame = parent.frame or UIParent
    -- return map(upgrade, ...)
    return ...
  end,
  UPDATE = function(self, container, ...)
    -- return map(upgrade, ...)
    return ...
  end,
  WRITE = function(self, container, t, o)
    -- print(unpack(container, OFFSET+1, o))
    container.frame[container[OFFSET+1]](container.frame, unpack(container, OFFSET+2, o))
    if container.__prev then
      for i = o+1, container.__prev do
        container[i] = nil
      end
    end
    container.__prev = o
  end,
  REMOVE = function(self, container)
    for i = OFFSET+1, container.__prev do
      container[i] = nil
    end
    container.frame = nil
    container.__prev = nil
  end,
}

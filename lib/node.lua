_, PS = ...
local node = {}

node.__call = function(self, dest)
  local constructor
  if type(dest) == 'function' then
    constructor = dest
    dest = {}
  else
    constructor = PS.Utils.identity
    dest = dest or {}
  end
  self:upgradeClone(dest)
  self:cloneProps(dest)
  self:cloneNodes(dest)
  dest.__index = node.__index
  dest.__call = node.__call
  return constructor(setmetatable(dest, self))
end

do
  local function indexFromParent(self, key)
    local parent = rawget(self, '__parent')
    return parent and parent[key] or nil
  end
  node.__index = function(self, key)
    return getmetatable(self)[key] or indexFromParent(self, key)
  end
end

-- When creating a new instance of a node, we get the oppertunity
-- to alter the default values, in some manner we choose
function node:upgradeClone(dest)
end

-- Copy over key values to the new instance
function node:cloneProps(dest)
  for key, value in pairs(self) do
    if type(value) == 'function' then
      -- dont copy functions, its pointless, they are called via 'inheritance'
    elseif PS.Utils.isProperty(key, value) and not dest[key] then
      dest[key] = value
    end
  end
end

-- Copy over all index values to the new instance
function node:cloneNodes(dest)
  for i = 1, #self do
    if type(self[i]) == 'table' and type(self[i].__call) == 'function' then
      table.insert(dest, i, self[i]{})
    else
      table.insert(dest, i, self[i])
    end
  end
end

do
  local Root = {}
  node.__kind = 'Node'
  Root.__frame = UIParent
  Root.__parent = Root
  Root.__propStream = PS.Stream.empty;
  function node:setParent(parent)
    return parent or Root
  end
end

function node:setFrame()
  return self.__frame or (self.__parent and self.__parent.__frame) or UIParent
end

function node:createPropStream()
  local streams = {} -- table pool
  for key, value in pairs(self) do
    if PS.Utils.isProperty(key, value) then
      if PS.Utils.isStream(value) then
        streams[key] = true
        table.insert(streams, value:map(function(...)
          return key, ...
        end))
      else
        streams[key] = true
        table.insert(streams, PS.Stream.of(key, value))
      end
    end
  end
  return PS.Stream.switch(
    self.__parent.__propStream:filter(function(key)
      return streams[key] ~= true
    end),
    unpack(streams));
end

function node:createStream()
  self.__propStream = self:createPropStream()
  return PS.Stream.switch(
    self.__propStream:map(self.propertyChanged, self),
    PS.Stream.switch(unpack(self)):map(self.childChanged, self))
end

function node:propertyChanged(...)
  return self, ...
end

function node:childChanged(...)
  return ...
end

function node:subscribe(send, done, parent)
  self.__parent = self:setParent(parent)
  self.__frame = self:setFrame()
  return self
    :createStream()
    :after(function(fn, ...)
      return self:remove(fn(...))
    end)
    :subscribe(send, done, self)
end

function node:remove(...)
  self.__frame = nil
  self.__parent = nil
  self.__propStream = nil
  return ...
end

do
  local Pool = {}
  Pool.__index = function(self, key)
    rawset(self, key, {})
    return rawget(self, key)
  end
  setmetatable(Pool, Pool)
  function node:getPool()
    return Pool[self:getPoolIdentifier()]
  end
end

function node:getPoolIdentifier()
  return (self.__pool or 'nodes') .. (self.__template or '')
end

-- create the first 'root' node
PS.Nodes = {
  Base = node.__call(node, {
    upgradeClone = function(self, dest)
      for i = 1, #dest do
        if type(dest[i]) == 'table' and getmetatable(dest[i]) == nil then
          dest[i] = PS.Nodes.Set(dest[i])
        end
      end
    end
  })
}
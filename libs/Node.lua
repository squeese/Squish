local Squish = select(2, ...)
local getTable = Squish.getTable
local freeTable = Squish.freeTable

local Node = {}
Node.__index = Node
Node.__name = 'Node'

function Node:mount(parent)
  self.__parent = parent
  self.__frame = parent.__frame
end

function Node:copy(prev, parent)
  self.__parent = parent
  prev.__parent = nil
  self.__frame = prev.__frame
  prev.__frame = nil
end

function Node:render(prev)
  return self
end

function Node:remove()
  self.__parent = nil
  self.__frame = nil
  freeTable(self)
end

function Node:upgrade(props)
end

function Node:children()
  return function(index)
    return self[index]
  end
end

function Node:context(key)
  local value = rawget(self, key)
  if value == nil and self.__parent ~= nil and self.__parent.context ~= nil then
    return self.__parent:context(key)
  end
  return value
end

function Node:extend(props, name)
  if type(props) == "function" then
    local render = props
    props = {}
    props.render = render
  end
  props.__name = name
  props.__index = self
  props.__call = props.__call or self.__call
  props.__super = self.__index.__index
  self:upgrade(props)
  return setmetatable(props, props)
end

function Node:__call(...)
end

function Squish.Extend(...)
  return Node:extend(...)
end

--[[
function Squish.E(fn, ...)
  local props = pool:Acquire()
  local i, m = 1, select("#", ...)
  while i <= m do
    local value = select(i, ...)
    if type(value) == "string" then
      props[value] = select(i+1, ...)
      i = i+2
    else
      table.insert(props, value)
      i = i+1
    end
  end
  return fn(props)
end

function Squish.S(fn, ...)
  local props = pool:Acquire()
  for i = 1, select("#", ...) do
    props[i] = select(i, ...)
  end
  return fn(props)
end
]]

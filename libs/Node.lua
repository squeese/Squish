local Squish = select(2, ...)
local node = Squish.node
node.__index = node
node.__name = 'node'

function node:mount(parent)
  self.__parent = parent
  self.__frame = parent.__frame
end

function node:copy(prev, parent)
  self.__parent = parent
  prev.__parent = nil
  self.__frame = prev.__frame
  prev.__frame = nil
end

function node:render()
  return self
end

function node:remove()
  self.__parent = nil
  self.__frame = nil
end

function node:upgrade(props)
  return props
end

function node:build(props, ...)
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
  return props
end

function node:children()
  return function(index)
    return self[index]
  end
end

function node:context(key)
  local value = rawget(self, key)
  if value == nil and self.__parent ~= nil and self.__parent.context ~= nil then
    return self.__parent:context(key)
  end
  return value
end

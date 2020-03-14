local Squish = select(2, ...)

local Node = {}
Node.__index = Node
Node.__name = 'Node'

function Node:mount(parent)
  -- print("Node:mount()", self.__name)
  self.__result = {}
  self.__parent = parent
  self.__frame = parent.__frame
end

function Node:copy(prev)
  -- print("Node:copy()", self.__name)
  self.__result = prev.__result
  self.__parent = prev.__parent
  self.__frame = prev.__frame
end

function Node:render(prev)
  -- print("Node:render()", self.__name)
  return self
end

function Node:remove()
  -- print("Node:remove()", self.__name)
  self.__parent = nil
  self.__frame = nil
end

function Node:upgrade(props)
end

function Node:children()
  return function(index)
    return self[index]
  end
end

function Node:__call(props, name)
  if type(props) == "function" then
    local render = props
    props = { __name = name }
    props.render = render
  end
  props.__index = self
  props.__call = self.__call
  props.__eq = self.__eq
  props.__super = self.__index.__index
  self:upgrade(props)
  return setmetatable(props, props)
end

Squish.Node = setmetatable({}, Node)
Squish.Elems = {}
Squish.Root = Squish.Node{
  __frame = UIParent,
  __parent = UIParent,
}
Squish.tooltipBackground = {
  bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
  edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
  tile = true, tileSize = 16, edgeSize = 16, 
  insets = { left = 4, right = 4, top = 4, bottom = 4 }
}

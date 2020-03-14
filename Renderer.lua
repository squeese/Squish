local Squish = select(2, ...)
local Set = Squish.Elems.Set

local update
local render
local INDEX = 1
local NODE
local STATES = {}
local REWIND = {}
local HOOKS = {}

do
  local function read(fn)
    local i = 0
    return function()
      i = i + 1
      return fn(i)
    end
  end
  update = function(node)
    assert(node ~= nil, "update, node cannot be nil")

    NODE = node
    local index = INDEX
    local result = node:render(prev)
    node.__hooks = INDEX - index
    -- ViragDevTool_AddData(node, 'node')

    -- component returned nothing
    if result == nil then
      for index, child in ipairs(node.__result) do
        render(child, nil)
        node.__result[index] = nil
      end
      assert(#node.__result == 0, "should always be 0")

    -- component returned itself, render the children inside the props
    elseif result == node then
      local j = 1
      for i = 1, #result do
        if type(result[i]) == "function" then
          for child in read(result[i]) do
            node.__result[j] = render(node.__result[j], child, node)
            j = j + 1
          end
        else
          node.__result[j] = render(node.__result[j], result[i], node)
          j = j + 1
        end
      end
      for i = j, #node.__result do
        node.__result[i] = nil
      end
      -- assert(#node.__result == #result, "should always match")

    -- component return another single component
    else
      node.__result[1] = render(node.__result[1], result, node)
      for index = 2, #node.__result do
        render(node.__result[index], nil)
        node.__result[index] = nil
      end
      assert(#node.__result == 1, "should always match")

    end
  end
end

render = function(prev, next, parent)
  if prev == nil then
    assert(next ~= nil, "next cannot be nil")
    next:mount(parent)
  elseif next == nil then
    assert(prev ~= nil, "prev cannot be nil")
    for _, child in ipairs(prev.__result) do
      render(child, nil, prev)
    end
    prev:remove()
    return nil
  elseif not rawequal(prev.__index, next.__index) then
    prev:remove()
    next:mount(parent)
  elseif prev ~= next then
    next:copy(prev)
  end
  update(next)
  return next
end

Squish.Render = render

local function useHook(fn, ...)
  local index = INDEX
  HOOKS[index] = HOOKS[index] or { fn = fn, ... }
  INDEX = INDEX + 1
  return index, HOOKS[index]
end

function Squish.useState(...)
  local node = NODE
  local index, hook = useHook(function() end, ...)
  return function(...)
    for i = 1, select("#", ...) do
      hook[i] = select(i, ...)
    end
    for i = select("#", ...) + 1, #hook do
      hook[i] = nil
    end
    INDEX = index
    update(node)
  end, unpack(hook)
end

local Squish = select(2, ...)
local update
local render
local INDEX = 1
local NODE

local NULL = {}
Squish.NULL = NULL



local MEM = setmetatable({}, {__mode = 'v'})
function Squish.POOL_REPORT()
  --collectgarbage("collect")
  --print("num:", pool.numActiveObjects)
  --print("   :", #pool.activeObjects)
  --print("   :", #pool.inactiveObjects)
  --print("   :", #MEM)
  --print(MEM[1])
  -- ViragDevTool_AddData(MEM[1], "App")
  -- ViragDevTool_AddData(Squish.Root, "root")
end

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

    INDEX = 1
    NODE = node
    local result = node:render()
    NODE = nil

    -- table.insert(MEM, result)
    -- table.insert(MEM, node.result)

    -- component returned nothing
    if result == nil then
      for index, child in ipairs(node.__result) do
        render(child, nil, node)
        node.__result[index] = nil
      end
      assert(#node.__result == 0, "should always be 0")
      if node.__parent == Squish.Root then
        render(node, nil, nil)
      end

    -- component returned the previous result, do nothing
    elseif result == node.result then

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
        render(node.__result[j], nil, node)
        node.__result[i] = nil
      end

    -- component return another single component
    else
      node.__result[1] = render(node.__result[1], result, node)
      for index = 2, #node.__result do
        render(node.__result[index], nil, node)
        node.__result[index] = nil
      end
      assert(#node.__result == 1, "should always match")

    end
  end
end


render = function(prev, next, parent)
  -- table.insert(MEM, next)
  -- table.insert(MEM, prev)
  if next == nil or next == NULL then
    if prev ~= nil and prev ~= NULL then 
      for index, child in ipairs(prev.__result) do
        render(child, nil, prev)
        prev.__result[index] = nil
      end
      pool:Release(prev.__result)
      prev.__result = nil
      if prev.__hooks then
        for _, hook in ipairs(prev.__hooks) do
          hook[1]()
          pool:Release(hook)
        end
        pool:Release(prev.__hooks)
        prev.__hooks = nil
      end
      prev:remove()
    end
    return next

  elseif prev == nil or prev == NULL then
    assert(next ~= nil and next ~= NULL, "next cannot be nil")
    next:mount(parent)
    next.__result = pool:Acquire()

  elseif not rawequal(prev.__index, next.__index) then
    for index, child in ipairs(prev.__result) do
      render(child, nil, prev)
      prev.__result[index] = nil
    end
    pool:Release(prev.__result)
    prev.__result = nil
    if prev.__hooks then
      for _, hook in ipairs(prev.__hooks) do
        hook[1](unpack(hook, 2))
        pool:Release(hook)
      end
      pool:Release(prev.__hooks)
      prev.__hooks = nil
    end
    prev:remove()
    next:mount(parent)
    next.__result = pool:Acquire()

  elseif prev ~= next then
    assert(parent ~= nil, "??")
    next:copy(prev, parent)
    next.__result = prev.__result
    next.__hooks = prev.__hooks
    prev.__hooks = nil
    prev.__result = nil
    for index in ipairs(prev) do
      prev[index] = nil
    end
    prev:remove()
  end

  update(next)
  return next
end
Squish.Render = render

local function useHook(fn, ...)
  if not NODE.__hooks then
    NODE.__hooks = pool:Acquire()
  end
  local index = INDEX 
  INDEX = INDEX + 1
  NODE.__hooks[index] = NODE.__hooks[index] or Acquire(fn, ...)
  return index, NODE.__hooks[index]
end

local function setHookValue(hook, ...)
  local changed = false
  for i = 1, select("#", ...) do
    local value = select(i, ...)
    changed = changed or vallue ~= hook[i+1]
    hook[i+1] = value
  end
  for i = 2 + select("#", ...), #hook do
    changed = true
    hook[i] = nil
  end
  return changed
end

function Squish.useState(...)
  local node = NODE
  local index, hook = useHook(Squish.ident, ...)
  return function(...)
    if setHookValue(hook, ...) then
      update(node)
      collectgarbage("collect")
      Squish.POOL_REPORT()
    end
  end, unpack(hook, 2)
end

function Squish.useStream(stream, ctx, ...)
  local node = NODE
  local index, hook = useHook(nil, ...)
  hook[1] = hook[1] or stream:subscribe(function(...)
    if setHookValue(hook, ...) then
      update(node)
      -- collectgarbage("collect")
      -- Squish.POOL_REPORT()
    end
  end, ctx)
  return unpack(hook, 2)
end




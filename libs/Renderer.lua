local Squish = select(2, ...)
local tableFill = Squish.tableFill
local childIterator = Squish.childIterator
local NIL = Squish.NIL
local root = Squish.root
local INDEX = 1
local NODE = nil
local update
local render
local pool = CreateObjectPool(
  function(self) return {} end,
  function(self, tbl)
    for key in pairs(tbl) do
      tbl[key] = nil
    end
  end)

local MEM = setmetatable({}, {__mode='v'})
function Squish.POOL_REPORT()
  collectgarbage("collect")
  print("active :", #pool.activeObjects)
  print("free    :", #pool.inactiveObjects)
  print("num    :", pool.numActiveObjects)
end

update = function(node)
  assert(node ~= nil, "update, node cannot be nil")

  if NODE == node then
    print("just break bro")
    return
  end
  assert(NODE == nil)

  INDEX = 1
  NODE = node
  local result = node:render()
  NODE = nil

  -- component returned nothing
  if result == nil then
    for index, child in ipairs(node.__result) do
      render(child, nil, node)
      node.__result[index] = nil
    end
    assert(#node.__result == 0, "should always be 0")
    if node.__parent == root then
      render(node, nil, nil)
    end

  -- component returned the previous result, do nothing
  elseif result == node.result then

  -- component returned itself, render the children inside the props
  elseif result == node then
    local j = 1
    for i = 1, #result do
      if type(result[i]) == "function" then
        for child in childIterator(result[i]) do
          node.__result[j] = render(node.__result[j], child, node)
          j = j + 1
        end
      elseif type(result[i]) == "table" and getmetatable(result[i]) == nil then
        for _, child in ipairs(result[i]) do
          node.__result[j] = render(node.__result[j], child, node)
          j = j + 1
        end
        pool:Release(result[i])
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

local function freeResult(prev)
  for index, child in ipairs(prev.__result) do
    render(child, nil, prev)
    prev.__result[index] = nil
  end
  pool:Release(prev.__result)
  prev.__result = nil
end

local function freeHooks(prev)
  if prev.__hooks then
    for index, hook in ipairs(prev.__hooks) do
      hook[1](unpack(hook, 2))
      pool:Release(hook)
      prev.__hooks[index] = nil
    end
    pool:Release(prev.__hooks)
    prev.__hooks = nil
  end
end

local function freeNode(prev)
  assert(prev.__transient == true or prev.__parent == root)
  prev:remove()
  assert(prev.__parent == nil)
  assert(prev.__frame == nil)
  assert(prev.__result == nil)
  assert(prev.__hooks == nil)
  if prev.__transient then
    pool:Release(prev)
  end
end

render = function(prev, next, parent)
  if next == nil or next == NIL then
    if prev ~= nil and prev ~= NIL then 
      freeResult(prev)
      freeHooks(prev)
      freeNode(prev)
    end
    return next

  elseif prev == nil or prev == NIL then
    assert(next ~= nil and next ~= NIL, "next cannot be nil")
    print("?", getmetatable(next))
    print("!", next)
    next:mount(parent)
    next.__result = pool:Acquire()

  elseif not rawequal(prev.__index, next.__index) then
    freeResult(prev)
    freeHooks(prev)
    freeNode(prev)
    next:mount(parent)
    next.__result = pool:Acquire()

  elseif prev ~= next then
    assert(parent ~= nil)
    next:copy(prev, parent)
    next.__result = prev.__result
    next.__hooks = prev.__hooks
    prev.__hooks = nil
    prev.__result = nil
    for index in ipairs(prev) do
      prev[index] = nil
    end
    freeNode(prev)
  end

  update(next)
  return next
end

function Squish.render(...)
  return render(...)
end

do
  local node = Squish.node
  function Squish.node:__call(arg, ...)
    if NODE ~= nil then
      assert(type(arg) ~= "table" or getmetatable(arg) ~= nil)
      local props = pool:Acquire()
      props.__index = self
      props.__transient = true
      return self:build(setmetatable(props, props), arg, ...)
    end
    local kind = type(arg)
    if kind == 'table' then
      assert(getmetatable(arg) == nil)
      arg.__name = arg.__name or select(1, ...)
      arg.__index = self
      arg.__call = node.__call
      arg.__super = node
      arg.__transient = false
      return self:upgrade(setmetatable(arg, arg))
    elseif kind == 'function' then
      local props = {}
      props.render = arg
      props.__name = select(1, ...)
      props.__index = self
      props.__call = node.__call
      props.__super = node
      props.__transient = false
      return self:upgrade(setmetatable(props, props))
    else
      assert(false)
    end
  end
end

local function useHook(fn, ...)
  if not NODE.__hooks then
    NODE.__hooks = pool:Acquire()
  end
  local index = INDEX 
  INDEX = INDEX + 1
  NODE.__hooks[index] = NODE.__hooks[index] or tableFill(pool:Acquire(), fn, ...)
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
      Squish.POOL_REPORT()
    end
  end, ctx)
  return unpack(hook, 2)
end

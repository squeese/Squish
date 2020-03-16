local Squish = select(2, ...)
Squish.square = {
  bgFile = 'Interface\\Addons\\Squish\\media\\backdrop.tga',
  edgeFile = 'Interface\\Addons\\Squish\\media\\edgefile.tga',
  insets   = { left = 1, right = 1, top = 1, bottom = 1 },
  edgeSize = 1
}

local function createMeta(tbl)
  tbl.__index = tbl
  return setmetatable({}, tbl)
end

local keys = createMeta({
  get = function(self, node)
    for i = -node.__children, -1 do
      self[node[i]] = true
    end
  end,
})

local dirty = false
local props = createMeta({
  reset = function(self)
    if not dirty then return end
    dirty = false
    for key in pairs(self) do
      rawset(self, key, nil)
    end
  end,
  __newindex = function(self, key, value)
    rawset(self, key, value)
    dirty = true
  end
})

local active = 0
local stack = createMeta({
  write = function(self, next, ...)
    active = active + 1
    local index = #self+1
    local count = select("#", ...)
    self[index] = next
    self[index+1] = index + count + 1
    for i = 1, count do
      self[index+i+1] = select(i, ...)
    end
    return index
  end,
  args = function(self, cursor)
    return unpack(self, cursor+2, self[cursor+1])
  end,
  unwind = function(self, cursor)
    active = active - 1
    for i = cursor, self[cursor+1] do
      self[i] = nil
    end
  end,
})

local Node = {}
Node.__index = Node
Node.__frame = UIParent

function Node:mount(parent)
  self.__parent = parent
end

function Node:remove()
  self.__parent = nil
end

function Node:render(...)
  return ...
end

function Node:props(...)
  props:reset()
  local offset = 1
  for i = 1, select("#", ...), 2 do
    local value = select(i, ...)
    if type(value) == "string" then
      props[value] = select(i+1, ...)
      offset = i+2
    end
  end
  return props, select(offset, ...)
end

function Node:extend(tbl)
  assert(active == 0)
  tbl.__index = self
  tbl.__call = Node.__call
  return setmetatable(tbl, tbl)
end

function Node:__call(...)
  assert(active > 0)
  return stack:write(self, ...)
end

-- REGION: Renderer
local render
local consolidate
local NIL = {}
local pool = {}
setmetatable(pool, pool)
function pool:__call()
  return #self > 0 and table.remove(self) or {}
end

function createNode(index)
  local node = pool()
  node.__index = index
  node.__children = 0
  return setmetatable(node, node)
end

function removeNode(node)
  for i = -1, -node.__children, -1 do
    render(node, node[node[i]], nil)
    node[i] = nil
    node[node[i]] = nil
  end
  node:remove()
  node.__index = nil
  node.__children = nil
end

function render(parent, node, cursor)
  assert(parent ~= nil)
  assert(type(cursor) == "number")
  assert(cursor <= #stack)

  local next = stack[cursor]
  if next == nil or next == NIL then
    if node ~= nil and node ~= NIL then 
      -- print("remove node")
      removeNode(node)
      setmetatable(node, nil)
      table.insert(pool, node)
    end
    return next

  elseif node == nil or node == NIL then
    -- print("create node")
    node = createNode(next)
    node:mount(parent)

  elseif getmetatable(node).__index ~= next then
    -- print("remove and swap node")
    removeNode(node)
    node.__index = next
    node:mount(parent)
  end

  -- print("call consolidate")
  consolidate(node, node:render(node:props(stack:args(cursor))))
  stack:unwind(cursor)

  if parent == Node then
    assert(#stack == 0)
  end

  return node
end

function consolidate(node, ...)
  keys:get(node)
  local offset = 0
  for index = 1, select("#", ...) do
    local cursor = select(index, ...)
    local key
    if props.key then
      key = props.key
      offset = offset - 1
    else
      key = index - offset
    end
    node[key] = render(node, node[key], cursor)
    keys[key] = nil
  end
  for key in pairs(keys) do
    -- print("remove", key)
  end
end

local Frame = Node:extend{
  __pool = CreateFramePool("frame", UIParent, nil, nil),
  mount = function(self, parent)
    print("frame: mount")
    Node.mount(self, parent)
    self.__frame = self.__pool:Acquire()
    self.__frame:SetParent(self.__parent.__frame)
    self.__frame:ClearAllPoints()
    self.__frame:Show()
  end,
  render = function(self, props, fn, ...)
    -- print("frame: render")
    return fn(self.__frame, ...)
  end,
  remove = function(self)
    -- print("frame: remove")
    mode.mount(self, parent)
    self.__pool:Release(self.__frame)
  end,
}

function tmp(frame, ...)
  -- print("tmp render")
  frame:SetPoint("CENTER", 0, 0)
  frame:SetSize(30, 30)
  frame:SetBackdrop(Squish.square)
  frame:SetBackdropColor(0, 0, 0, 0.6)
  frame:SetBackdropBorderColor(0, 0, 0, 1)
  return ...
end

local App = Node:extend{
  render = function(self, ...)
    -- print("app:render")
    return Frame(tmp)
  end
}

C_Timer.After(1, function()
  local app = nil
  for i = 1, 1000 do
    -- print("frame", i)
    app = render(Node, app, App)
  end
  collectgarbage("collect")
  -- ViragDevTool_AddData(stack, "stack")
end)

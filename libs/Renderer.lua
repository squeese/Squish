local Squish = select(2, ...)

function Squish.CreateRenderer()
  local RENDERING = false
  local DIRTY = false
  local PROPS = {}
  local STACK = {}
  local KEYS = {}
  local POOL = {}
  local NODE = {}
  NODE.__index = NODE
  NODE.__frame = UIParent
  local ROOT

  function NODE:mount(parent)
    self.__parent = parent
  end
  function NODE:remove()
    self.__parent = nil
  end
  function NODE:props(...)
    if DIRTY then
      for key in pairs(PROPS) do
        PROPS[key] = nil
      end
    end
    local offset = 1
    for i = 1, select("#", ...), 2 do
      local value = select(i, ...)
      if type(value) == "string" then
        PROPS[value] = select(i+1, ...)
        offset = i+2
      end
    end
    return PROPS, select(offset, ...)
  end
  function NODE:render(props, ...)
    return ...
  end
  function NODE:__call(...)
    if RENDERING then
      local index = #STACK+1
      local count = select("#", ...)
      STACK[index] = self
      STACK[index+1] = index + count + 1
      for i = 1, count do
        STACK[index+i+1] = select(i, ...)
      end
      return index
    else
      local next = select(1, ...)
      assert(type(next) == 'table')
      assert(select("#", ...) == 1)
      assert(getmetatable(next) == nil)
      assert(getmetatable(self) ~= nil or self == NODE)
      next.__index = self
      next.__call = NODE.__call
      return setmetatable(next, next)
    end
  end

  local remove
  local render
  function mount(parent, node, cursor)
    assert(parent ~= nil)
    assert(type(cursor) == "number")
    assert(cursor <= #STACK, cursor .. "<="..#STACK)

    local next = STACK[cursor]
    if next == nil then
      if node ~= nil then 
        remove(node)
        setmetatable(node, nil)
        table.insert(pool, node)
      end
      return next

    elseif node == nil then
      node = #POOL > 0 and table.remove(POOL) or {}
      node.__index = next
      node.__children = 0
      setmetatable(node, node)
      node:mount(parent)

    elseif getmetatable(node).__index ~= next then
      remove(node)
      node.__index = next
      node:mount(parent)
    end

    render(node, node:render(node:props(unpack(STACK, cursor+2, STACK[cursor+1]))))
    for i = cursor, STACK[cursor+1] do
      STACK[i] = nil
    end

    assert(parent ~= ROOT or #STACK == 0)
    return node
  end

  function remove(node)
    for i = -1, -node.__children, -1 do
      render(node, node[node[i]], nil)
      node[i] = nil
      node[node[i]] = nil
    end
    node:remove()
    node.__index = nil
    node.__children = nil
  end

  function render(node, ...)
    for i = -node.__children, -1 do
      KEYS[node[i]] = true
    end

    local offset = 0
    for index = 1, select("#", ...) do
      local cursor = select(index, ...)
      local key
      if PROPS.key then
        key = PROPS.key
        offset = offset - 1
      else
        key = index - offset
      end
      node[key] = mount(node, node[key], cursor)
      KEYS[key] = nil
    end
    for key in pairs(KEYS) do
      -- print("remove", key)
    end

    assert(#KEYS == 0)
  end

  ROOT = NODE:__call({})
  return ROOT, function(prev, next, ...)
    assert(type(next) == "table" or type(next) == "function")
    RENDERING = true
    local node = mount(ROOT, prev, next(...))
    RENDERING = false
    return node
  end
end



local Node, Render = Squish.CreateRenderer()

local Frame = Node {
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
    return fn(self.__frame, ...)
  end,
  remove = function(self)
    Node.mount(self, parent)
    self.__pool:Release(self.__frame)
  end,
}

function tmp(frame, ...)
  frame:SetPoint("CENTER", 0, 0)
  frame:SetSize(30, 30)
  frame:SetBackdrop(Squish.square)
  frame:SetBackdropColor(0, 0, 0, 0.6)
  frame:SetBackdropBorderColor(0, 0, 0, 1)
  return ...
end

local App = Node {
  render = function(self, props, ...)
    return Frame(tmp, ...)
  end
}

C_Timer.After(1, function()
  do
    local app = nil
    for i = 1, 1000 do
      -- print("frame", i)
      app = Render(app, function()
        return App()
      end)
    end
  end
  collectgarbage("collect")
end)

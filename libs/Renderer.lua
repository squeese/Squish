local Squish = select(2, ...)
local ROOT = {}
ROOT.__index = ROOT
function ROOT:construct(next, ...)
  next.__index = self
  next.__call = self.__call
  self.__root = self.__root or self
  next.__metatable = "Node"
  return setmetatable(next, next)
end
function ROOT:__call(...)
  return self:construct(...)
end

--[[

  sequence

    call to render with a basic function
      - swap root metadata
      - call basic function, NO PROPS
      - stack is populated with 'args'
        



--]]

Squish.Node = setmetatable({
  mount = function(self, parent)
    self.__parent = parent
  end,
  remove = function(self)
    self.__parent = nil
  end,
  render = function(self, props, ...)
    return ...
  end,
}, ROOT)

function Squish.CreateRenderer(pool)
  local RENDERING = false
  local DIRTY = false
  local PROPS = {}
  local PROPS_RO = setmetatable({}, {
    __index = PROPS,
    __newindex = function(self, key, value)
    end,
  })
  local STACK = {}
  local KEYS = {}
  local POOL = pool or {}
  local META = {}
  META.__index = META
  local readProps
  local render
  local mount
  local remove

  function META:construct(...)
    local index = #STACK+1
    local count = select("#", ...)
    STACK[index] = index + count + 1
    STACK[index+1] = self
    for i = 1, count do
      STACK[index+i+1] = select(i, ...)
    end
    return index
  end

  function META:props(...)
    return PROPS_RO, readProps(...)
  end

  local function rewindStack(s, e, ...)
    print(s, e, ...)
    for i = s, e do
      STACK[i] = nil
    end
    return ...
  end

  local function readStack(cursor)
    if cursor then
      return rewindStack(cursor, unpack(STACK, cursor, STACK[cursor]))
    end
    return nil
  end

  local function readProps(...)
    if DIRTY then
      for key in pairs(PROPS) do
        PROPS[key] = nil
      end
    end
    local offset = 1
    for i = 1, select("#", ...), 2 do
      local value = select(i, ...)
      if type(value) == "string" then
        DIRTY = true
        PROPS[value] = select(i+1, ...)
        offset = i+2
      end
    end
    return PROPS_RO, select(offset, ...)
  end


  render = function(parent, node, next, ...)
    print("mount", parent, node, next, "args", ...)

    if next == nil then
      if node ~= nil then 
        print("remove")
        remove(node)
        setmetatable(node, nil)
        table.insert(POOL, node)
      end
      return next

    elseif node == nil then
      print("new")
      node = #POOL > 0 and table.remove(POOL) or {}
      node.__index = next
      -- node.__children = 0
      setmetatable(node, node)
      node:mount(parent)

    elseif getmetatable(node).__index ~= next then
      print("switch", next)
      remove(node)
      node.__index = next
      -- node.__children = 0
      setmetatable(node, next)
      node:mount(parent)
    end

    return ...
  end

  --render = function(node, ...)
  --end





    --node:props(...)



    -- render(node, node:render(node:props(unpack(STACK, cursor+2, STACK[cursor+1]))))

    -- render(node, unpack(STACK, cursor+2, STACK[cursor+1]))



  --gay = function(node, ...)
    --local offset = 0
    --local index = 1

    --for index = 1, select("#", ...) do
      --local cursor = select(index, ...)

      --local key


      --if PROPS.key then
        --node.keys = node.keys or table.remove(pool) or {}

        --node.keys[key] = mount(node, node.keys[key], cursor)
        --offset = offset + 1
      --else
        --node[index - offset] = mount(node, node[key], cursor)
      --end
      --KEYS[key] = nil
      --node.__children = node.__children + 1
      --node[-node.__children] = key
    --end
    --for key in pairs(KEYS) do
      --print("REMOVE!!!", key)
    --end
  --end

  --remove = function(node)
    ----for i = -1, -node.__children, -1 do
      ------ print("!", i, node[i], node[node[i]], node.__children, unpack(node))
      ----mount(node, node[node[i]], nil)
      ----node[i] = nil
      ----node[node[i]] = nil
    ----end
    ----node:remove()
    ----node.__index = nil
    ----node.__children = nil
  --end


  return function(parent)
    local prev
    return function(next, ...)
      RENDERING = true
      META.__metatable = true
      setmetatable(Squish.Node, META)

      prev = render(parent, prev, readStack(next and next(readProps(...))))

      META.__metatable = nil
      setmetatable(Squish.Node, ROOT)
      RENDERING = false
    end
  end
end

local R = Squish.CreateRenderer()
local U = R(nil)
local N = Squish.Node{}
U(function()
  return N("key", "root",
    N("key", "root:1"),
    N("key", "root:2")
  )
end)

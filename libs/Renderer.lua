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
  local PROPS = Squish.Props()
  local STACK = Squish.Stack()
  local POOL = pool or {}
  local META = {}
  META.__index = META
  local render

  function META:construct(...)
    return STACK:push(self, ...)
  end

  function META:props(...)
    return PROPS(...)
  end

  local function props(node, ...)
    if not node then
      return nil
    end
    return node, node:props(...)
  end

  local _print = _G['print']
  local function print(depth, ...)
    local str = ""
    for i = 1, depth do
      str = str .. "  "
    end
    return _print(str, ...)
  end

  local function remove(instance)
  end

  local function child(depth, instance, index, prototype, props, ...)
    print(depth, "child", getmetatable(prototype), "index", index)
    if props.key then
      instance[props.key] = render(depth + 1, instance, instance[props.key], prototype, props, ...)
      return true
    end
    instance[index] = render(depth + 1, instance, instance[index], prototype, props, ...)
  end

  local function children(depth, instance, ...)
    print(depth, "children", getmetatable(instance.__index))
    local offset = 0
    local length = select("#", ...)
    for index = 1, length do
      if child(depth, instance, index - offset, props(STACK:pop(select(index, ...)))) then
        offset = offset + 1
      end
    end
    for index = length - offset + 1, #instance do
      print(depth, "children.remove", index)
      instance[index] = render(depth + 1, instance, instance[index], nil)
    end
  end

  render = function(depth, parent, instance, prototype, props, ...)
    print(depth, "render", getmetatable(prototype))
    if prototype == nil then
      if instance ~= nil then 
        print(depth, "render.remove", getmetatable(instance.__index))
        remove(instance)
        setmetatable(instance, nil)
        table.insert(POOL, instance)
      end
      return nil
    elseif instance == nil then
      instance = #POOL > 0 and table.remove(POOL) or {}
      instance.__index = prototype
      setmetatable(instance, instance)
      instance:mount(parent, props, ...)
    elseif instance.__index ~= prototype then
      remove(instance)
      instance.__index = prototype
      setmetatable(instance, prototype)
      instance:mount(parent, props, ...)
    else
      print(depth, "render.same", getmetatable(instance.__index))
    end
    children(depth, instance, instance:render(props, ...))
    return instance
  end

  return function(parent)
    local prev = nil
    return function(next, ...)
      META.__metatable = true
      setmetatable(Squish.Node, META)
      prev = render(0, parent, prev, props(STACK:pop(next and next())))
      META.__metatable = nil
      setmetatable(Squish.Node, ROOT)
      ViragDevTool_AddData(prev, "prev")
    end
  end
end

C_Timer.After(1, function()
  local R = Squish.CreateRenderer()
  local U = R(nil)
  local N = Squish.Node{}
  U(function()
    return N("_key", "root",
      N("_key", "root:1"),
      N("_key", "root:2"),
      N("_key", "root:3")
    )
  end)
  print(" ")
  U(function()
    return N("_key", "root",
      N("_key", "root:1"),
      --N("_key", "root:2"),
      N("_key", "root:3")
    )
  end)
end)

      --print("STEP: 1 - call function, write to stack, get index")
      --print("- index:", index)
      --print("- stack:", unpack(STACK))
      --print(" ")

      --print("STEP: 2 - read from stack, get node prototype, and args")
      --tmp(function(node, ...)
        --print("- node:", node)
        --print("- args:", ...)
        --print(" ")

        --print("STEP: 3 - get props and 'children' from the args")
        --tmp(function(props, ...)
          --print(" props: ", dump(props))
          --print(" children:", ...)
          --print(" ")

          ----print("STEP: 4 - call render with: parent, prev, node, props, ... (children)")
          --prev = render(parent, prev, node, props, ...)

        --end, node:props(...))
      --end, STACK:pop(index))

--[[

  sequence

    call to render with a basic function
      [x] swap root metadata

      [x] call basic function, NO PROPS
        function()
          return N("key", "root",
            N("key", "root:1"),
            N("key", "root:2")
          )
        end
        returns an index to the stack, ie: 9

      [x] stack is populated with 'args'
        STACK = { 4, node, "key", "root1", 8, node, "key", "root:2", 14, "key", "root", 1, 5 }

      [x] read from stack with cursor to get current node and its args
      [x] build props with node and args

      status:
        - node prototype
        - props
        - res

      [ ] get previous instance for this node
        - first one is supplied from initial render call, it's always the same
]]

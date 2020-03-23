local Index, Pool, Stack = select(2, ...)
local Index = Squish.Index
local Pool = Squish.Pool
local Stack = Squish.Stack

local function clone(self, next)
  next.__index = self
  next.__call = self.__call
  return setmetatable(next, next)
end
local function stack(self, ...)
  print("stack", ...)
end
local Call = clone
local Node = {}
Node.__index = Node
Node.__call = function(...)
  return Call(...)
end
setmetatable(Node, Node)










--local Meta = {}
--function Meta:__index(key)
  --local super = rawget(self, '__super')
  --if self == Meta then
    --return nil
  --end
  --return self.__super[key]
--end
--function Meta:get(key)
  --local value = rawget(self.__super, key)
  --if value then
    --return value, self.__super
  --end
  --return self.__super:get(key)
--end






--register(Meta, "Meta")
--register(Root, "Root")
--register(Node, "Node")
--register(Next, "Next")

--setmetatable(Root, Meta)
--Root(Node)
--Node(Next)

---- Node.value = 'value'
--print(Next.value)

-- print(Next:test(1, 2, 3))


--local Meta
--local Node = {}
--local Next = {}
--local Bleh = {}

--local function log(tbl, ...)
  --if tbl == Meta then return print(tbl, "Meta", ...) end
  --if tbl == Node then return print(tbl, "Node", ...) end
  --if tbl == Next then return print(tbl, "Next", ...) end
  --if tbl == Bleh then return print(tbl, "Bleh", ...) end
  --print(tbl, "????")
--end

--local Clone = {}
--function Clone:driver(next, ...)
  --print("Clone:driver()", ...)
  --next.__super = self
  --next.__index = self.__index or getmetatable(self).__index
  --next.__call = self.__call or getmetatable(self).__call
  --return setmetatable(next, next)
--end

--Meta = {
  --__call = function(self, next, ...)
  --end,
--}

--setmetatable(Meta, Meta)

--Meta(Node)
--Node(Next)
--Next(Bleh)

--function Node:test(...)
  --print("Node.test", ...)
  --log(self, "SELF")
  --log(self.__index, "INDEX")
  --log(self.__super, "SUPER")
--end

----function Next:test(...)
  ----print("Next.test", ...)
  ----log(self, "SELF")
  ----log(self.__index, "INDEX")
  ----log(self.__super, "SUPER")
  ----self.__super:test(...)
----end

----function Bleh:test(...)
  ----print("Bleh.test", ...)
  ----log(self, "SELF")
  ----log(self.__index, "INDEX")
  ----log(self.__super, "SUPER")
  ----self.__super:test(...)
----end

---- log(Bleh, "Bleh")
---- log(Bleh.__inde)

--Bleh:test(1, 2, 3)

----function Node:test(...)
  ----print("Node:test", ...)
----end

----function Next:test(...)
  ----print("Next:test", ...)
  ----print(self, "SELF")
  ----print(self.__index, "INDEX")
----end

---- Next(Bleh)
---- Bleh:test(1, 2, 3)




---- print(next, 'next')
---- print(getmetatable(next), 'meta')
---- print(getmetatable(next).__call, 'meta')
---- Next(Bleh)





----function Driver:test(...)
  ----print("Driver:test", ...)
----end


----local Node1 = Driver{}
----function Node1:val()
  ----print(self, "self")
----end

----function Node1:test(...)
  ----print("Node1:test", ...)
  ------ self.__index:test(...)
----end

----local Node2 = Node1{}

----Node2:test("node", 1, 2, 3)

----00 print(Node1, "Node1")
------ print(Node2, "Node2")
------ print(Node2.__index, "index")













----local function Driver(self, next, ...)
----end

----local function Acquire(self, container, key, ...)
  ----return container, ...
----end

----function Squish.Create(pool, stack, nodes)
  ----local POOL = pool or Pool()
  ----local STACK = Stack(stack or {})
  ----local PASSIVE = { driver = Driver };
  ----local ACTIVE = {
    ----driver = function(self, ...)
      ----return STACK:push(self, ...)
    ----end,
    ----acquire = function(self, container, key)
    ----end,
    ----mount = function(self, container, node)
    ----end,
    ----render = function(self, node, ...)
      ----return node, ...
    ----end,
    ----release = function(self, node, ...)
    ----end,
  ----}
  ----local DRIVER = Index({
    ----__index = PASSIVE,
    ----__metatable = false,
  ----}, function(self, ...)
    ----return self:driver(...)
  ----end)

  ----local function acquire(i, node, key)
    ----if node[i] then
      ----if node[i].key == key then
        ----return node[i], i+1
      ----end
      ----for j = i+1, #node do
        ----node[i], node[j] = node[j], node[i]
        ----if node[i].key == key then
          ----return node[i], i+1
        ----end
      ----end
      ----node[#node+1] = node[i]
    ----end
    ----node[i] = POOL:Acquire()
    ----node[i].key = key
    ----return node[i], i+1
  ----end

  ----local function clean(node)
    ----for i = node.__beg, node.__end - 1 do
      ----print("remove", i)
    ----end
  ----end


  ----local render
  ----local function mount(index, node, driver, key, ...)
    ----assert(node ~= nil, "cant mount driver on empty node")
    ----local child = driver:acquire(index, node, key)

    ----if child ~= node then
      ----return render(b, e, node, ...)
    ----end
    ----b, e, child = acquire(b, e, node, key)
    ----if not child.driver then
      ----print(node, "mount", "new")
      ----child.driver = driver
      ----driver:mount(node, child)

    ----elseif child.driver ~= driver then
      ----print(node, "mount", "swap")
      ----driver:remove(node)
      ----node.driver = driver
      ----driver:mount(node, child)
    ----end

    ----render(1, #child+1, child, ...)

    ----return b, e
  ----end

  ----render = function(index, node, ...)
    ----for i = 1, select("#", ...) do
      ----local driver = select(i, ...)
      ----local kind = type(driver)
      ----if kind == "function" then
        ----index = render(index, node, driver())
      ----elseif kind == "number" then
        ----local index, driver = driver, STACK[driver+1]
        ----index = mount(index, node, driver, nil, STACK:pop(index))
      ----elseif kind == "table" then
        ----index = mount(index, node, driver, rawget(driver, 'key'), unpack(driver))
      ----end
    ----end
    ----return index
  ----end

  ----return DRIVER{}, function()
    ----local node = {}
    ----return function(...)
      ----DRIVER.__index = ACTIVE
      ----print(render(1, node, ...))
      ----DRIVER.__index = PASSIVE
      ----ViragDevTool_AddData(node, 'node')
    ----end,
    ----function()
    ----end
  ----end
----end

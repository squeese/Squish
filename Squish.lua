local Squish = select(2, ...)

local tests = {}
function test(description, fn)
  table.insert(tests, {description, function()
    local status, result = pcall(fn)
    if not status then
      print("  ", result)
      return false
    end
    return not result
  end})
end

local function check(a, b)
  if a ~= b then error("equality error", 2) end
end

local function createSpy(fn)
  fn = fn or function(...) return ... end
  return setmetatable({ count = 0 }, {
    __call = function(self, ...)
      self.count = self.count + 1
      return fn(...)
    end,
  })
end

local function subtest(message, fn)
  local status, result = pcall(fn)
  if not status then
    print("fail:", message)
    error(result, 2)
  else
    print("ok:", message)
  end
end

test("adding children", function()
  local Render = Squish.CreateRenderer()
  local match = Squish.matchTables
  local node = Squish.Node{}
  function node:mount(parent)
    print("mount")
    self.__parent = parent
    self.__frame = {}
    table.insert(parent.__frame, self.__frame)
  end
  function node:render(props, ...)
    print("render")
    for key in pairs(self.__frame) do
      if type(key) == "string" then
        self.__frame[key] = nil
      end
    end
    for key, value in pairs(props) do
      self.__frame[key] = value
    end
    return ...
  end
  function node:remove()
    print("remove")
    for index, frame in ipairs(self.__parent.__frame) do
      if frame == self.__frame then
        table.remove(self.__parent.__frame, index)
        break
      end
    end
  end
  local root = {}
  local update = Render({ __frame = root })

  subtest("initial render", function()
    update(function()
      return
        node("name", "root",
          node("name", "middle_a"),
          node("name", "middle_b"),
          node("name", "middle_c"))
    end)
    check(true, match(root, {
      { name = "root",
        { name = "middle_a" },
        { name = "middle_b" },
        { name = "middle_c" },
      }
    }))
  end)

  --[[


      node(                 mount 
                            props ...
                            render
                            consodigate
        node("key", "a",       mount
                               props
                            
          node(),
          node(),
          node()),

        node("key", "b",       mount
          node(),
          node(),
          node()))

                    >      
    node(key, val, child, child)
      :props()

      :render()


    
  --]]

  subtest("same re-render", function()
    print(" ")
    print(" ")
    print(" ")
    update(function()
      return
        node("name", "root",
          node("name", "middle_a"),
          node("name", "middle_b"),
          node("name", "middle_c"))
    end)
    check(true, match(root, {
      { name = "root",
        { name = "middle_a" },
        { name = "middle_b" },
        { name = "middle_c" },
      }
    }))
  end)

  --subtest("changing props without changing keys", function()
    --update(function()
      --return
        --node("name", "ROOT",
          --node("name", "MIDDLE_A"),
          --node("name", "MIDDLE_B"),
          --node("name", "MIDDLE_C"))
    --end)
    --ViragDevTool_AddData(root, "root")
    --check(true, match(root, {
      --{ name = "ROOT",
        --{ name = "MIDDLE_A" },
        --{ name = "MIDDLE_B" },
        --{ name = "MIDDLE_C" },
      --}
    --}))
  --end)

  --subtest("removing a node", function()
    --update(function()
      --return
        --node("name", "ROOT",
          --node("name", "MIDDLE_A"),
          --node("name", "MIDDLE_C"))
    --end)
    --check(true, match(root, {
      --{ name = "ROOT",
        --{ name = "MIDDLE_A" },
        --{ name = "MIDDLE_C" },
      --}
    --}))
  --end)

  return true
end)

test("basic node inheritance", function()
  local R = Squish.Node

  local A_ARG = {}
  local A = R(A_ARG, "A_ARG", A_ARG)
  check(A_ARG, A)
  check(A.__index, R)

  local B_ARG = {}
  local B = A(B_ARG, "B_ARG", B_ARG)
  check(B_ARG, B)
  check(B.__index, A)

  local C_ARG = {}
  local C = B(C_ARG, "C_ARG", C_ARG)
  check(C_ARG, C)
  check(C.__index, B)

  local r_spy = createSpy()
  local a_spy = createSpy()
  local b_spy = createSpy()

  R.render = r_spy
  A.render = nil
  B.render = nil
  C:render()
  check(r_spy.count, 1)
  check(a_spy.count, 0)
  check(b_spy.count, 0)

  R.render = r_spy
  A.render = a_spy
  B.render = nil
  C:render()
  check(r_spy.count, 1)
  check(a_spy.count, 1)
  check(b_spy.count, 0)

  R.render = r_spy
  A.render = a_spy
  B.render = b_spy
  C:render()
  check(r_spy.count, 1)
  check(a_spy.count, 1)
  check(b_spy.count, 1)

  do
    local spy = createSpy(function(self, a, b, c)
      check(self, C)
      check(a, 1)
      check(b, 2)
      check(c, 3)
      return self, a, b, c
    end)
    local M = {}
    local P = getmetatable(R)
    M.__index = M
    M.construct = spy
    setmetatable(R, M)
    C(1, 2, 3)
    setmetatable(R, P)
  end
end)


test("order of lifecycle calls", function()
  local order = { "remove", "render", "props", "mount" }
  local Test = Squish.Node {
    mount = function(self, ...)
      check(table.remove(order), "mount")
      return self.__root.mount(self, ...)
    end,
    props = function(self, ...)
      check(table.remove(order), "props")
      return self.__root.props(self, ...)
    end,
    render = function(self, ...)
      check(table.remove(order), "render")
      return self.__root.render(self, ...)
    end,
    remove = function(self, ...)
      check(table.remove(order), "remove")
      return self.__root.remove(self, ...)
    end,
  }
  local Render = Squish.CreateRenderer()
  local update = Render()
  update(Test)
  update(nil)
  check(#order, 0)
end)

test("pool retains node, and it's properly cleaned", function()
  local order = { "remove", "render", "props", "mount" }
  -- local pool = setmetatable({}, {__mode='v'})
  local pool = {}
  local node = nil
  local Test = Squish.Node{
    mount = function(self, ...)
      node = self
      return self.__root.mount(self, ...)
    end,
  }
  local Render = Squish.CreateRenderer(pool)
  local update = Render()
  update(Test)
  check(#pool, 0)
  update(nil)
  check(#pool, 1)
  check(pool[1], node)
  check(getmetatable(node), nil)
  for key in pairs(node) do
    error("key: " .. key .. " set")
  end
end)

test("references are destroyed", function()
  local pool = setmetatable({}, {__mode='v'})
  do
    local Test = Squish.Node{}
    local Render = Squish.CreateRenderer(pool)
    local update = Render()
    update(Test)
    check(#pool, 0)
    update(nil)
    collectgarbage("collect")
    check(#pool, 0)
    table.insert(pool, Render)
    table.insert(pool, update)
  end
  collectgarbage("collect")
  check(#pool, 0)
end)

--C_Timer.After(1, function()
  --for _, test in ipairs(tests) do
    --local message, fn = unpack(test)
    --if fn() then
      --print("[x]", message)
    --else
      --print("[_]", message)
      --break
    --end
  --end
--end)

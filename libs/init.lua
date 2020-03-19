local Squish = select(2, ...)

local App = Q("App", "Base", function()
  local setBlue, blue = useState(true)
  local setRed, red = useState(true)
  local setNum, num = useState(0)
  local setOpen, open = useState(true)
  return Q.Frame("player",
    Q.Set("SetPoint", "CENTER", 0, 0),
    Q.Set("SetSize", 500, 100),
    Q.Set("SetBackdrop", Squish.square),
    Q.Set("SetBackdropColor", 0, 0, 0, 0.6),
    Q.Set("SetBackdropBorderColor", 0, 0, 0, 1),
    Q.Button(
      Q.Set("SetPoint", "TOPLEFT", 0, 0),
      Q.Set("SetSize", 50, 25),
      Q.Set("SetText", "Blue"),
      Q.Set("SetScript", "OnClick", function()
          setBlue(not blue)
      end)),
    Q.Button(
      Q.Set("SetPoint", "TOP", 0, 30),
      Q.Set("SetSize", 50, 25),
      Q.Set("SetText", "X"),
      Q.Set("SetScript", "OnClick", function()
          setOpen(false)
      end)),
    Q.Button(
      Q.Set("SetPoint", "TOP", -60, 0),
      Q.Set("SetSize", 50, 25),
      Q.Set("SetText", "-"),
      Q.Set("SetScript", "OnClick", function()
          setNum(math.max(0, num-1))
      end)),
    Q.Text(
      Q.Set("SetPoint", "TOP", 0, 0),
      Q.Set("SetText", tostring(num))),
    Q.Button(
      Q.Set("SetPoint", "TOP", 60, 0),
      Q.Set("SetSize", 50, 25),
      Q.Set("SetText", "+"),
      Q.Set("SetScript", "OnClick", function()
          setNum(math.min(6, num+1))
      end)),
    Q.Range(num, function(i)
      return
        Q.Frame("key", i,
          Q.Set("SetPoint", "CENTER", (i-1) * 30 - (num-1)*30/2, 0),
          Q.Set("SetSize", 30, 30),
          Q.Set("SetBackdrop", Squish.square),
          Q.Set("SetBackdropColor", 0, 0, 0, 0.6),
          Q.Set("SetBackdropBorderColor", 0, 0, 0, 1))
    end),
    Q.Button(
      Q.Set("SetPoint", "TOPRIGHT", 0, 0),
      Q.Set("SetSize", 50, 25),
      Q.Set("SetText", "Red"),
      Q.Set("SetScript", "OnClick", function()
          setRed(not red)
      end)),
    not blue and NIL or Q.Square("b", 1, "side", "LEFT"),
    not red and NIL or Q.Square("r", 1, "side", "RIGHT"),
    Q.Text(
      Q.Set("SetPoint", "BOTTOMLEFT", 0, 0),
      Q.Set("SetText", tostring(blue))),
    Q.Text(
      Q.Set("SetPoint", "BOTTOMRIGHT", 0, 0),
      Q.Set("SetText", tostring(red))))
end)




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

  return true
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

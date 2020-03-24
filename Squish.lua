local Create = select(2, ...).Create
local Driver = select(2, ...).Driver
local Stream = select(2, ...).Stream

local Render = Create()

local SetStatic = Driver{
  acquire = Driver.opaque,
  render = function(self, container, name, ...)
    container.frame[name](container.frame, ...)
  end,
}

local function init(size)
  return bit.lshift(1, size) - 1
end

local function open(gate, index)
  return bit.bxor(gate, bit.lshift(1, index-1))
end

local function update(container)
  if container.gate ~= 0 then return end
  local frame = container.frame
  local name = container[3]
  frame[name](frame, unpack(container, 4, container.length+2))
end

local Set = Driver{
  mount = function(self, container, parent, ...)
    container.frame = parent.frame
    local length = select("#", ...)
    container.gate = init(length)
    container.length = length
    for index = 1, length do
      local value = select(index, ...)
      if type(value) == "table" and getmetatable(value) == Stream then
        container[-index] = value:subscribe(function(value)
          container[index+2] = value
          container.gate = open(container.gate, index)
          update(container)
        end)
      else
        container.gate = open(container.gate, index)
        container[index+2] = value
      end
    end
    update(container)
  end,
  render = function(self, container, key, ...)
  end,
  remove = function(self, container)
    container.frame = nil
    container.gate = nil
    for i = -1, -container.length, -1 do
      local value = container[i]
      if value then
        value()
      end
      container[i] = nil
    end
    for i = 3, container.length+2 do
      container[i] = nil
    end
    container.length = nil
  end,
}

--Set.__call = function(driver, key, ...)
  --return Driver.__call(Static, key, key, ...)
--end

local function upgrade(self)
  for index, child in ipairs(self) do
    if type(child) == "table" and getmetatable(child) == nil then
      child.key = table.remove(child, 1)
      Set(child)
    end
  end
end

local function mount(self, container, parent)
  container.state = parent.state
  container.frame = self.pool:Acquire()
  container.frame:SetParent(parent.frame or UIParent)
  container.frame:ClearAllPoints()
  container.frame:Show()
end

local function remove(self, container)
  self.pool:Release(container.frame)
  container.frame = nil
  container.state = nil
end

local Context = Driver{
  mount = function(self, container, parent)
    container.state = container
  end,
  remove = function(self, container)
    container.state = nil
  end
}

local backdrop = {
  bgFile = 'Interface\\Addons\\Squish\\media\\backdrop.tga',
  edgeFile = 'Interface\\Addons\\Squish\\media\\edgefile.tga',
  insets   = { left = 1, right = 1, top = 1, bottom = 1 },
  edgeSize = 1
}

local Frame = Driver{
  pool = CreateFramePool("frame", UIParent, nil, nil),
  name = "Frame",
  mount = mount,
  remove = remove,
  upgrade = upgrade,
}

local Button = Driver{
  pool = CreateFramePool("button", UIParent, 'UIPanelButtonTemplate', nil),
  name = "Button",
  mount = mount,
  remove = remove,
  upgrade = upgrade,
}

local Text = Driver{
  pool = CreateFontStringPool(UIParent, nil, nil, 'GameFontNormal'),
  name = "Text",
  mount = mount,
  remove = remove,
  upgrade = upgrade,
}

local Texture = Driver{
  pool = CreateTexturePool(UIParent, nil, nil, nil),
  name = "Texture",
  mount = mount,
  remove = remove,
  upgrade = upgrade,
}

local Iterator
local Range
do
  local tmp = {}
  Iterator = Driver{
    acquire = Driver.opaque,
    render = function(self, container, fn)
      local i = 0
      repeat
        i = i + 1
        tmp[i] = fn(i)
      until not tmp[i]
      return unpack(tmp, 1, i-1)
    end
  }
  Range = Driver{
    acquire = Driver.opaque,
    render = function(self, container, b, e, fn)
      for i = 1, 100 do
        tmp[i] = nil
      end
      for i = b, e do
        tmp[i] = fn(i)
      end
      return unpack(tmp, b, e)
    end
  }
end

local X = Stream.create(function(_, send)
  local timer = C_Timer.NewTicker(0.1, function()
    local value = (math.random() - 0.5) * 100
    send(value)
  end)
  return function()
    timer:Cancel()
  end
end)

local function testAppClean()
  local App = Context{
    unit = "player",
    Frame{
      {"SetPoint", "CENTER", X, 0},
      {"SetSize", 100, 310},
      {"SetBackdrop", backdrop},
      {"SetBackdropColor", 0, 0, 0, 0.5},
      {"SetBackdropBorderColor", 0, 0, 0, 0.8},
    }
  }
  local open = false
  C_Timer.NewTicker(2, function()
    if open then
      Render()
      collectgarbage("collect")
    else
      Render(App)
    end
    open = not open
  end)
end
-- testAppClean()




local function testApp()
  local app
  local count = 0
  local function report(fn)
    collectgarbage("collect")
    local before = collectgarbage("count")
    fn()
    local change = collectgarbage("count") - before
    collectgarbage("collect")
    local after = collectgarbage("count")
    -- print("Before", before, "After", after, "Change", change)
  end
  local function dec()
    report(function()
      repeat
        count = math.max(0, count - 1)
        Render(app)
      until count == 0
    end)
  end
  local function inc()
    report(function()
      repeat
        count = math.min(count + 1, 6)
        Render(app)
      until count == 6
    end)
  end

  local Butt = Button(function(self)
    return
      Set("SetPoint", self.point, 0, 0),
      Set("SetText", self.text),
      Set("SetScript", "OnClick", self.onClick)
  end)

  local TApp = Frame{
    {"SetPoint", "CENTER", 0, 100},
    {"SetSize", 100, 100},
    {"SetBackdrop", backdrop},
    {"SetBackdropColor", 0, 0, 0, 0.5},
    {"SetBackdropBorderColor", 0, 0, 0, 0.8},
    Butt{ point="TOPLEFT", text="-", onClick=dec },
    Butt{ point="TOPRIGHT", text="+", onClick=inc },
    --Button{
      --{"SetPoint", "TOPLEFT", 0, 0},
      --{"SetText", "-"},
      --{"SetScript", "OnClick", dec},
    --},
    --Button{
      --{"SetPoint", "TOPRIGHT", 0, 0},
      --{"SetText", "+"},
      --{"SetScript", "OnClick", inc},
    --},
    Iterator{function(i)
      if i <= count then
        return Text(nil
          , Set("SetPoint", "TOP", 0, -i*10)
          , Set("SetText", i))
      end
    end},
  }

  local FApp = Driver(function(self, container, ...)
    return Frame(nil
      , Set("SetPoint", "CENTER", 0, 100)
      , Set("SetSize", 100, 100)
      , Set("SetBackdrop", backdrop)
      , Set("SetBackdropColor", 0, 0, 0, 0.5)
      , Set("SetBackdropBorderColor", 0, 0, 0, 0.8)
      , Button(nil
        , Set("SetPoint", "TOPLEFT", 0, 0)
        , Set("SetText", "-")
        , Set("SetScript", "OnClick", dec))
      , Button(nil
        , Set("SetPoint", "TOPRIGHT", 0, 0)
        , Set("SetText", "+")
        , Set("SetScript", "OnClick", inc))
      , Range(nil, 1, count, function(i)
        return Text(nil
          , Set("SetPoint", "TOP", 0, -i*10)
          , Set("SetText", i))
        end))

  end)

  app = FApp
  Render(app)
end

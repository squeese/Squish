local Squish = select(2, ...)
Squish.NIL = {}
Squish.node = {}
Squish.ident = function(...) return ... end
Squish.Stream = {}
Squish.Elems = setmetatable({}, {
  __call = function(self, name, source, props)
    if type(source) == "string" then
      self[name] = self[source](props, name)
    elseif source == nil then
      self[name] = Squish.node:__call(props, name)
    else
      self[name] = source(props)
    end
    return self[name]
  end,
})
Squish.root = {
  __frame = UIParent,
  __parent = UIParent,
}
Squish.mini = 'Interface\\Addons\\Squish\\media\\minimalist.tga'
Squish.flat = 'Interface\\Addons\\Squish\\media\\flat.tga'
Squish.vixar = 'Interface\\Addons\\Squish\\media\\vixar.ttf'
Squish.defbar = 'Interface\\TARGETINGFRAME\\UI-StatusBar'
Squish.square = {
  bgFile = 'Interface\\Addons\\Squish\\media\\backdrop.tga',
  edgeFile = 'Interface\\Addons\\Squish\\media\\edgefile.tga',
  insets   = { left = 1, right = 1, top = 1, bottom = 1 },
  edgeSize = 1
}

C_Timer.After(1, function()
  local Q = Squish.Elems
  local NIL = Squish.NIL
  local useState = Squish.useState
  local render = Squish.render

  Q("Square", "Base", function(props)
    local setValue, value = useState(math.random())
    return
      Q.Frame(
        Q.Set("SetPoint", props.side, 0, 0),
        Q.Set("SetSize", 32, 32),
        Q.Set("SetBackdrop", Squish.square),
        Q.Set("SetBackdropColor", props.r or 0, 0, props.b or 0, 0.6),
        Q.Set("SetScript", "OnMouseDown", function()
            setValue(value + math.random())
        end),
        Q.Text(
          Q.Set("SetPoint", "CENTER", 0, 0),
          Q.Set("SetText", tostring(value))))
  end)

  Q("Range", nil, {
    build = function(self, props, num, cb)
      for i = 1, num do
        props[i] = cb(i)
      end
      return setmetatable(props, nil)
    end,
  })

  local App = Q("App", "Base", function(props)
    local setBlue, blue = useState(true)
    local setRed, red = useState(true)
    local setNum, num = useState(0)
    local setOpen, open = useState(true)
    if not open then return nil end
    return Q.Frame(
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

  local App2 = Q.Frame{
    {"SetPoint", "CENTER", 0, 0},
    {"SetSize", 500, 100},
    {"SetBackdrop", Squish.square},
    {"SetBackdropColor", 0, 0, 0, 0.6},
    {"SetBackdropBorderColor", 0, 0, 0, 1},
  }

  print(#App2{})

  local open = false
  local app = nil
  function TOGGLE_BUTTONS()
    if not open then
      app = render(nil, App2{}, Squish.root)
    else
      render(app, nil, Squish.root)
    end
    open = not open
    Squish.POOL_REPORT()
  end
  TOGGLE_BUTTONS()
end)
local Squish = select(2, ...)
local node = Squish.node
node.__index = node
node.__name = 'node'

function node:mount(parent)
  self.__parent = parent
  self.__frame = parent.__frame
end

function node:copy(prev, parent)
  self.__parent = parent
  prev.__parent = nil
  self.__frame = prev.__frame
  prev.__frame = nil
end

function node:render()
  return self
end

function node:remove()
  self.__parent = nil
  self.__frame = nil
end

function node:upgrade(props)
  return props
end

function node:build(props, ...)
  local i, m = 1, select("#", ...)
  while i <= m do
    local value = select(i, ...)
    if type(value) == "string" then
      props[value] = select(i+1, ...)
      i = i+2
    else
      table.insert(props, value)
      i = i+1
    end
  end
  return props
end

function node:children()
  return function(index)
    return self[index]
  end
end

function node:context(key)
  local value = rawget(self, key)
  if value == nil and self.__parent ~= nil and self.__parent.context ~= nil then
    return self.__parent:context(key)
  end
  return value
end

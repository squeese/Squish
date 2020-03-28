local Q = select(2, ...)

function Q.Stream.unit(streams, map)
  return Q.Stream.create(function(self, send, ctx, ...)
    local current = nil
    local cleanData = Q.noop
    local cleanUnit = ctx.unit:subscribe(function(unit)
      --if current == nil then
        --send(unit)
      --end
      if current ~= unit then
        cleanData()
        cleanData = streams[unit]:subscribe(map(unit, send))
        current = unit
      end
    end)
    return function()
      cleanData()
      cleanUnit()
    end
  end)
end

local Power = Q.Stream.unit({
  player = Q.Stream.switch(
    Q.Stream.event("UNIT_MAXPOWER"),
    Q.Stream.event("UNIT_POWER_FREQUENT"),
    Q.Stream.event("PLAYER_ENTERING_WORLD")),
  target = Q.Stream.switch(
    Q.Stream.event("UNIT_MAXPOWER"),
    Q.Stream.event("UNIT_POWER_FREQUENT"),
    Q.Stream.event("PLAYER_TARGET_CHANGED")),
}, function(unit, send)
  return function(eName, eUnit)
    if not eUnit or eUnit == unit then
      send(UnitPower(unit), UnitPowerMax(unit), UnitPowerType(unit))
    end
  end
end)

local UnitAuraIt = Q.Stream.unit({
  player = Q.Stream.switch(
    Q.Stream.event("UNIT_AURA"),
    Q.Stream.event("PLAYER_ENTERING_WORLD")),
  target = Q.Stream.switch(
    Q.Stream.event("UNIT_AURA"),
    Q.Stream.event("PLAYER_TARGET_CHANGED")),
}, function(unit, send)
  return function(eName, eUnit)
    if not eUnit or eUnit == unit then
      send(function(i, ...)
        return UnitAura(unit, i, ...)
      end)
    end
  end
end)

-- name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal,
-- spellId, canApplyAura, isBossDebuff, castByPlayer

local Fixed = Q.Driver{
  ATTACH = function(self, parent, cursor, _, value)
    local container = parent[cursor]
    if container and type(container) == "table" and container.__driver then
      container.__driver:RELEASE(container, nil)
    end
    parent[cursor] = value
    return cursor + 1
  end,
}

local Dynamic = Q.Driver{
  ATTACH = function(self, parent, cursor, _, value)
    local container = parent[cursor]
    if not container or type(container) ~= "table" then
      container = parent(#parent+1)
      container.__driver = self
      container.__unsub = value:subscribe(function(...)
        self:QUEUE(container, self.SEND, ...)
      end)
      -- self:RELEASE(self:CHILDREN(container, 1, self:RENDER(container, parent, value)))
    else
      -- self:RELEASE(self:CHILDREN(container, 1, self:UPDATE(container, value)))
    end
    return cursor + 1
  end,

  SEND = function(self, container, ...)
    print("SEND", ...)
  end,

  --RENDER = function(self, container, parent, value)
    --print("Dynamic render", value)
  --end,

  --UPDATE = function(self, container, value)
    --print("Dynamic update", value)
  --end,

  REMOVE = function(self, container)
    container.__unsub()
    container.__unsub = nil
  end
}

local map = Q.map
local tmp = function(index, value)
  local kind = type(value)
  if kind == "table" and getmetatable(value) == Q.Stream then
    return Dynamic(nil, value)
  else
    return Fixed(nil, value)
  end
end

local Test = Q.Driver{
  RENDER = function(self, container, parent, key, ...)
    return map(tmp, ...)
  end,
  UPDATE = function(self, container, ...)
    return map(tmp, ...)
  end,
  RELEASE = function(self, container, offset)
    for index = offset or 1, #container do
      if type(container[index]) == "table" then
        container[index].__driver:RELEASE(container[index], nil)
      end
      container[index] = nil
    end
    if not offset then
      container.__driver:REMOVE(container)
      container.__driver = nil
      container.__pool:Release(container)
    end
  end
}

local S = Q.Stream.create(function(_, send)
  local timer = C_Timer.NewTicker(0.5, function()
    send(math.random())
  end)
  return function()
    timer:Cancel()
  end
end)

local Aura = function(index, name, icon, count, kind, duration, expires) return
  Q.Frame(name
    ,Q.Set("SetSize", 64, 64)
    ,Q.Set("SetPoint", "TOP", 0, (index-1) * -64)
    ,Q.Set("SetBackdrop", Q.Backdrop)
    ,Q.Set("SetBackdropColor", 0, 0, 0, 0.5)
    ,Q.Set("SetBackdropBorderColor", 0, 0, 0, 0.8)
    -- ,Input(S, "hello")
    ,Test(nil, 1, S, 3)
    ,Q.Texture("icon"
      ,Q.Set("SetAllPoints")
      ,Q.Set("SetTexture", icon)
      ,Q.Set("SetTexCoord", 0.1, 0.9, 0.1, 0.9)
      ,Q.Set("SetDrawLayer", "BACKGROUND", -1))
    ,Q.Text("name"
      ,Q.Set("SetPoint", "TOP", 0, 0)
      ,Q.Set("SetText", duration))
    ,Q.Text("name"
      ,Q.Set("SetPoint", "BOTTOM", 0, 0)
      ,Q.Set("SetText", expires)))
end

local App = Q.Context{
  unit = Q.Stream.of("player"),
  Q.Box{
    width = 256,
    height = 128,
    Q.Tmp{UnitAuraIt, Aura},
  },
}

--local App = Q.Frame{
  --Q.Set{"SetPoint", "CENTER", 0, 0},
  --Q.Set{"SetSize", 128, 32},
  --Q.Set{"SetBackdrop", Q.Backdrop},
  --Q.Set{"SetBackdropColor", 0, 0, 0, 0.5},
  --Q.Set{"SetBackdropBorderColor", 0, 0, 0, 0.8},
--}

--App = Q.Box{}

local Render = Q.Create()
Render(App)


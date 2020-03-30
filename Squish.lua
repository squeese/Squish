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

local stream = Q.Stream.create(function(_, send, driver, container)
  driver:SUBSCRIBE(container, function(...)
    local args = {...}
    C_Timer.After(1, function()
      send(driver, container, "one", unpack(args))
    end)
    C_Timer.After(2, function()
      send(driver, container, "two", "three", unpack(args))
    end)
    C_Timer.After(3, function()
      send(driver, container, unpack(args))
    end)
  end)
end)

Q.Stream.something = Q.Stream.create(function(self, send, driver, container)
  return driver:SUBSCRIBE(container, function(...)
    send(driver, container, ...)
  end)
end)

local TimeLeft = Q.Stream.something
  :ticker(0.2)
  :map(function(driver, container, expires) 
    local value = (expires > 0) and (expires-GetTime()) or 0
    return driver, container, math.floor(value * 100) / 100
  end)

local Position = Q.Stream.something:spring()

local Aura = function(index, name, icon, count, kind, duration, expires) return
  Q.Frame(name
    ,Q.SetStatic("SetSize", 64, 64)
    -- ,Q.SetStatic("SetPoint", "TOP", 0, (index-1) * -64)
    ,Q.SetDynamic("SetPoint", "TOP", 0, Position((index-1) * 64))
    ,Q.SetStatic("SetBackdrop", Q.Backdrop)
    ,Q.SetStatic("SetBackdropColor", 0, 0, 0, 0.5)
    ,Q.SetStatic("SetBackdropBorderColor", 0, 0, 0, 0.8)
    ,Q.Texture("icon"
      ,Q.SetStatic("SetAllPoints")
      ,Q.SetStatic("SetTexture", icon)
      ,Q.SetStatic("SetTexCoord", 0.1, 0.9, 0.1, 0.9)
      ,Q.SetStatic("SetDrawLayer", "BACKGROUND", -1)
    )
    ,Q.Text("name"
      ,Q.SetStatic("SetPoint", "CENTER", 0, 0)
      ,Q.SetDynamic("SetText", TimeLeft(expires))
      --,Q.SetDynamic("SetText", Position(index))
    )
  )
end

local App = Q.Context{
  unit = Q.Stream.of("player"),
  Q.Box{
    width = 256,
    height = 128,
    Q.Tmp{UnitAuraIt, Aura},
  },
}

local Render = Q.Create()
Render(App)

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

local Aura = function(index, name, icon, count, kind, duration, expires) return
  Q.Frame(name
    ,Q.Set("SetSize", 64, 64)
    ,Q.Set("SetPoint", "TOP", 0, (index-1) * -64)
    ,Q.Set("SetBackdrop", Q.Backdrop)
    ,Q.Set("SetBackdropColor", 0, 0, 0, 0.5)
    ,Q.Set("SetBackdropBorderColor", 0, 0, 0, 0.8)
    ,Q.Texture("icon"
      ,Q.Set("SetAllPoints")
      ,Q.Set("SetTexture", icon)
      ,Q.Set("SetTexCoord", 0.1, 0.9, 0.1, 0.9)
      ,Q.Set("SetDrawLayer", "BACKGROUND", -1))
    ,Q.Text("name"
      ,Q.Set("SetPoint", "TOP", 0, 0)
      ,Q.Set("SetText", duration)
      ,Q.Sex(nil
        ,Q.Val("SetText")
        ,Q.Val("1")
        ,Q.Val("2")
        ,Q.Val("3")
        ,Q.Val(0)))
    ,Q.Text("name"
      ,Q.Set("SetPoint", "BOTTOM", 0, 0)
      ,Q.Set("SetText", expires))
  )
end

local App = Q.Context{
  unit = Q.Stream.of("player"),
  Q.Box{
    width = 256,
    height = 128,
    -- Q.Tmp{UnitAuraIt, Aura},
  },
}

local Render = Q.Create()
Render(App)


local Squish = select(2, ...)
local Stream = Squish.Stream
Squish.Data = {}
local Data = Squish.Data
local event = Stream.event
local events = Stream.events
local switch = Stream.switch
local empty = Stream.empty
local unitContext = Stream.unitContext

local ticker = Stream.create(function(next, send, unit)
  local prevGUID = nil
  local timer = Squish.setTimeout(0.5, true, function()
    local currGUID = UnitGUID(unit)
    if currGUID ~= prevGUID then
      prevGUID = currGUID
      send('TICKER')
    end
  end)
  return function()
    Squish.clearTimeout(timer)
  end
end)

function unitContext(streams)
  for key, val in pairs(streams) do
    streams[key] = Stream.create(function(_, send, ctx)
      send(ctx)
      return val:subscribe(send, ctx)
    end)
  end
  return Stream.create(function(_, send, ctx)
    if ctx == "player" then
      return streams.player:subscribe(send, ctx)
    elseif ctx == "target" then
      return streams.target:subscribe(send, ctx)
    elseif ctx == "focus" then
      return streams.focus:subscribe(send, ctx)
    elseif string.match(ctx, "%w+target") then
      return streams.subtarget:subscribe(send, ctx)
    elseif string.match(ctx, "party%d$") or string.match(ctx.unit, "raid%d+$") then
      return streams.friends:subscribe(send, ctx)
    else
      return streams.other:subscribe(send, ctx)
    end
  end)
end

local function UnitFilter(ctx, _, unit)
  return unit == nil or ctx == unit
end


--[[
PLAYER_ENTERING_WORLD     isLogn   isReloading
PLAYER_TARGET_CHANGED     nil
UNIT_NAME_UPDATE          unit
GROUP_ROSTER_UPDATE       nil
]]


--Data.UnitName = unitContext({
  --player    = event("PLAYER_ENTERING_WORLD"),
  --target    = events("UNIT_NAME_UPDATE", "PLAYER_TARGET_CHANGED"),
  --focus     = events("UNIT_NAME_UPDATE", "PLAYER_FOCUS_CHANGED"),
  --friends   = events("UNIT_NAME_UPDATE", "GROUP_ROSTER_UPDATE"),
  --subtarget = switch(event("UNIT_NAME_UPDATE"), ticker),
  --other     = empty
--})
  --:


--:filter(UnitFilter)
  --:filter(UnitExists)
  --:map(function(self, next, send, ...)
    --return self:subscribe(function(...)

    --end, ...)
--end)
-- :map(UnitName) -- name, realm
--



Data.UnitPower = unitContext({
  player    = events("UNIT_POWER_FREQUENT", "UNIT_MAXPOWER", "PLAYER_ENTERING_WORLD"),
  target    = events("UNIT_POWER_FREQUENT", "UNIT_MAXPOWER", "PLAYER_TARGET_CHANGED"),
  focus     = empty,
  friends   = empty,
  subtarget = empty,
  other     = empty
})
:filter(UnitFilter)
:filter(UnitExists)
:map(function(unit)
  return UnitPower(unit), UnitPowerMax(unit), UnitPowerType(unit)
end)


--:map(function(self, next, send, ctx, ...)
  --return self:subscribe(function(event, unit, ...)
    --if unit == nil or ctx.unit == unit then
      --print("TRUE", event, unit, ...)
      --print(UnitPower(ctx.unit))
      --print(UnitPowerMax(ctx.unit))
      --print(UnitPowerType(ctx.unit))
      --send(UnitPower())
    --else
      --print("FALSE", event, unit, ...)
    --end
  --end, ctx, ...)
--end)

-- Data.UnitPower:subscribe(print, { unit = "target" })

--:filter(UnitFilter)
  --:filter(UnitExists)

--Data.UnitAura = unitContext({
  --player    = events("PLAYER_ENTERING_WORLD", "UNIT_AURA"),
  --target    = empty,
  --focus     = empty,
  --friends   = empty,
  --subtarget = empty,
  --other     = empty
--})
  --:filter(UnitFilter)
  --:filter(UnitExists)

-- Data.UnitAura:subscribe(print, 'player')
-- Data.UnitName:subscribe(print, 'player')
-- Data.UnitName:subscribe(print, 'target')
-- Data.UnitName:subscribe(print, 'targettarget')

--[[
local UNIT_POWER_PLAYER = Stream.events(
  "PLAYER_ENTERING_WORLD",
  "UNIT_POWER_FREQUENT",
  "UNIT_MAXPOWER",
  "UNIT_DISPLAYPOWER"
)
local UNIT_POWER_TARGET = Stream.events(
  "PLAYER_TARGET_CHANGED",
  "UNIT_POWER_FREQUENT",
  "UNIT_MAXPOWER",
  "UNIT_DISPLAYPOWER"
)
local UNIT_POWER_FOCUS = Stream.events(
  "PLAYER_FOCUS_CHANGED",
  "UNIT_POWER_FREQUENT",
  "UNIT_MAXPOWER",
  "UNIT_DISPLAYPOWER"
)

Data.UnitPower = Stream.ctx()
  :map(function(unit)
    if unit == "player" then
      return UNIT_POWER_PLAYER
    elseif unit == "target" then
      return UNIT_POWER_TARGET
    elseif unit == "focus" then
      return UNIT_POWER_FOCUS
    end

  end)
  .events('UNIT_POWER_FREQUENT', 'UNIT_MAXPOWER', 'UNIT_DISPLAYPOWER')
  :tap(print)
  :map(function(ctx, e, unit)
    return ctx, unit
  end, true)
  :filter(rawequal)
  :onCreate(function(ctx, send)
    send(ctx)
  end)
  :map(function(unit)
    return UnitPower(unit), UnitPowerMax(unit)
  end)
]]

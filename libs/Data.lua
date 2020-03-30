local Q = select(2, ...)
local switch = Q.Stream.switch
local event = Q.Stream.event
local empty = Q.Stream.empty
local noop = Q.noop
local ident = Q.ident
local create = Q.Stream.create
local UnitSelector = {}
local map = Q.map
local function events(...)
  return switch(map(function(_, stream)
    return type(stream) == "string" and event(stream) or stream
  end, ...))
end

function UnitSelector:__call(unit)
  if unit == "player" then
    return self.player or empty
  elseif unit == "target" then
    return self.target or empty
  elseif unit == "focus" then
    return self.focus or empty
  elseif string.match(unit, "%w+target") then
    return self.subtarget or empty
  elseif string.match(unit, "party%d$") or string.match(ctx.unit, "raid%d+$") then
    return self.friends or empty
  end
  return empty
end

local function GenericFilter(unit, eventName, eventUnit)
  return (not eventUnit or unit == eventUnit) and UnitExists(unit)
end

local function UnitStream(streams, filter, map)
  streams.player = events("PLAYER_ENTERING_WORLD", unpack(streams))
  streams.target = events("PLAYER_TARGET_CHANGED", unpack(streams))
  streams.subtarget = events("PLAYER_TARGET_CHANGED", Q.Stream.tocker, unpack(streams))
  streams.friends = events("PLAYER_ENTERING_WORLD", "GROUP_ROSTER_UPDATE", unpack(streams))
  filter = filter or GenericFilter
  setmetatable(streams, UnitSelector)
  return create(function(self, send, driver, container)
    local unit = nil
    local unsubStream = noop
    local unsubDriver = driver:SUBSCRIBE(container, function(next)
      if next == unit then return end
      unit = next
      unsubStream()
      print("unit", unit)
      if not unit then return end
      unsubStream = streams(unit):subscribe(function(...)
        if filter(unit, ...) then
          if map then
            send(driver, container, map(unit, ...))
          else
            send(driver, container, unit)
          end
        end
      end)
    end)
    return function()
      unsubStream()
      unsubDriver()
    end
  end)
end


Q.EventUnitHealth     = UnitStream({"UNIT_MAXHEALTH", "UNIT_HEALTH_FREQUENT"})
Q.EventUnitPower      = UnitStream({"UNIT_MAXPOWER", "UNIT_POWER_FREQUENT"})
Q.EventUnitName       = UnitStream({"UNIT_NAME_UPDATE"})
Q.EventUnitClass      = UnitStream({"UNIT_FACTION", "UNIT_CONNECTION"})
Q.EventUnitPowerType  = UnitStream({"UNIT_POWER_UPDATE", "UNIT_DISPLAYPOWER"})
Q.EventUnitRole       = UnitStream({"PLAYER_ROLES_ASSIGNED"})

Q.DataUnitRole        = Q.EventUnitRole:map(UnitGroupRolesAssigned)
Q.DataUnitRoleIcon    = Q.DataUnitRole:map(function(role)
  if role == 'NONE' then return 1, 1, 1, 1 end
  return GetTexCoordsForRoleSmallCircle(role)
end)







Q.EventUnitCasting    = UnitStream({
  "UNIT_SPELLCAST_START",
  "UNIT_SPELLCAST_CHANNEL_START",
  "UNIT_SPELLCAST_CHANNEL_UPDATE",
  "UNIT_SPELLCAST_DELAYED",
  "UNIT_SPELLCAST_STOP",
  "UNIT_SPELLCAST_FAILED",
  "UNIT_SPELLCAST_CHANNEL_STOP",
  -- "PLAYER_ENTERING_WORLD"
  -- "UNIT_SPELLCAST_INTERRUPTED",
  -- "UNIT_SPELLCAST_INTERRUPTIBLE",
  -- "UNIT_SPELLCAST_NOT_INTERRUPTIBLE",
}, nil, ident):map(function(unit, event)
  if event == "UNIT_SPELLCAST_START" then
    return true, UnitCastingInfo(unit)
  end
  return false, UnitChannelInfo(unit)
end)

Q.EventUnitCastingName = Q.EventUnitCasting:select(2):sticky()
Q.EventUnitCastingIcon = Q.EventUnitCasting:select(4):sticky()

Q.EventUnitCastingDuration = Q.EventUnitCasting:map(function(_, _, _, _, sTime, eTime)
  if not sTime then return nil end
  return (eTime - sTime) / 1000
end):sticky(1)

Q.EventUnitCastingDurationLeft = Q.EventUnitCasting:map(function(_, _, _, _, _, eTime)
  if not eTime then return 0, 0 end
  return eTime / 1000 - GetTime(), 0
end):update(0, 0)

Q.EventUnitCastingFadeIn = Q.EventUnitCasting:map(function(_, name)
  if name then return 1, 200, 15 end
  return 0, 20, 30
end):spring()

Q.EventUnitCastingElapsed = Q.EventUnitCasting:map(function(isCasting, _, _, _, nbeg, nend)
  if not nbeg then return nil, nil end
  local elapsed = GetTime() - nbeg / 1000
  local duration = (nend - nbeg) / 1000
  return elapsed, duration
end):update(1, 1)




--local function CLEUStream(stream)
  --return create(function(self, send, driver, container)
    --local unit = nil
    --local unsubDriver = driver:SUBSCRIBE(container, function(value)
      --unit = value
    --end)
    --local unsubStream = stream:subscribe(function(...)
      --if not unit then return end
      --send(driver, container, unit, ...)
    --end)
    --return function()
      --unsubStream()
      --unsubDriver()
    --end
  --end)
--end



--Q.TMP = CLEUStream(switch(
  --event("CLEU_SWING_DAMAGE"),
  --event("CLEU_RANGE_DAMAGE"),
  --event("CLEU_SPELL_DAMAGE"),
  --event("CLEU_SPELL_PERIODIC_DAMAGE"),
  --event("CLEU_SPELL_BUILDING_DAMAGE"),
  --event("CLEU_ENVIRONMENTAL_DAMAGE")))
  --:filter(function(unit, ...)
    --return UnitGUID(unit) == select(10, ...)
  --end)
  --:extend(function()
    --local sum = 
    --return function(unit, ...)
      --local tstamp = select(3, ...)
      --local damage = select(15, ...)
      --print(...)
      --print(unit, tstamp, damage)
      --return UnitName(unit)
    --end
  --end)

--tmp:subscribe(function(...)
  --local event = select(4, ...)
  --local destGUID = select(10, ...)
  --local amount = select(15, ...)
  --print(event, destGUID, UnitGUID("player"), amount)
--end)


  --return GetTime() - sTime / 1000, (eTime - sTime) / 1000
  --local CastTime = Q.EventUnitCasting:map(function()
        --D("SetText", CastTimeUpdate(unit, FormatSeconds))))

--local tmp = {}
--tmp.__index = tmp
--function tmp:SUBSCRIBE(container, subscriber)
  --subscriber("player")
--end
--setmetatable(tmp, tmp)

--Q.EventUnitChannel:subscribe(noop, tmp)

-- event('UNIT_SPELLCAST_START'):subscribe(print)
-- event('UNIT_SPELLCAST_CHANNEL_START'):subscribe(print)
-- event('UNIT_SPELLCAST_STOP'):subscribe(print)    -- when cast finished, or player stopped casting
-- event('UNIT_SPELLCAST_FAILED'):subscribe(print)  -- cannot trigger manually
-- event('UNIT_SPELLCAST_INTERRUPTED'):subscribe(print) -- triggered when player stops casting
-- event('UNIT_SPELLCAST_INTERRUPTIBLE'):subscribe(print)
-- event('UNIT_SPELLCAST_NOT_INTERRUPTIBLE'):subscribe(print)
--event('UNIT_SPELLCAST_CHANNEL_UPDATE'):subscribe(print)
--event('UNIT_SPELLCAST_CHANNEL_STOP'):subscribe(print)
--event('UNIT_SPELLCAST_DELAYED'):subscribe(print)


-- https://wowwiki.fandom.com/wiki/Events/Unit_Info
-- https://wow.gamepedia.com/Events

event("UNIT_NAME_UPDATE"):subscribe(print)
event('UNIT_POWER_UPDATE'):subscribe(print)
event('UNIT_POWER_BAR_SHOW'):subscribe(print)
event('UNIT_POWER_BAR_HIDE'):subscribe(print)

-- Fired when the unit's mana stype is changed.
-- Occurs when a druid shapeshifts as well as in certain other cases.
event('UNIT_DISPLAYPOWER'):subscribe(print)

event('UNIT_MAXPOWER'):subscribe(print)

-- 
event('UNIT_FACTION'):subscribe(print)

-- afk/dnd?
event('UNIT_FLAGS'):subscribe(print)

-- fired if a unit comes back online after a disconnect.
-- UnitIsConnected()
event('UNIT_CONNECTION'):subscribe(print)

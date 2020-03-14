local Squish = select(2, ...)
local Stream = Squish.Stream
local Node = Squish.Node
local media = Squish.media
local Q = Squish.Elems
--// always copy result table?
--// reuse tables in prev/next

-- Stream.of(1, 2, 3):init(nil, 5, 6):subscribe(print)
-- REPORT()

local Data = {}

-- Stream.events("UNIT_NAME_UPDATE", "PLAYER_TARGET_CHANGED"):subscribe(print)

Data.UnitHealth = Stream
  .events('UNIT_HEALTH_FREQUENT', 'UNIT_MAXHEALTH')
  :tap(print)
  :map(function(ctx, _, unit)
    return ctx, unit
  end, true)
  :filter(rawequal)
  :onCreate(function(ctx, send)
    send(ctx)
  end)
  :map(function(unit)
    return UnitHealth(unit), UnitHealthMax(unit)
  end)

Data.UnitPower = Stream
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

Stream
  .create(function(_, send, ctx)
    send(ctx)
  end)
  :map(function(unit)
    print("inside map")
    if unit == "target" then
      return Stream.switch(
        Stream.event("PLAYER_TARGET_CHANGED"),
        Stream.event("UNIT_NAME_UPDATE"))
    end
  end)
  :flatten()
  :tap(print)
  :subscribe(print, "target")

-- Data.UnitName = Stream.events('UNIT_NAME_UPDATE')

-- Data.UnitHealth:subscribe(print, 'target')
-- Data.UnitPower:subscribe(print, 'target')
-- Data.UnitName:subscribe(print, 'target')

-- UNIT_PORTRAIT_UPDATE
-- UNIT_MODEL_CHANGED


local Tile = Q.Base {}
function Tile:render(prev)
  local offset = 0
  local height = self.__frame:GetHeight()
  local weights = 0
  for _, child in ipairs(self) do
    weights = weights + (child.weight or 1)
  end
  for index, child in ipairs(self) do
    local chunk = ((child.weight or 1) / weights) * height
    table.insert(child, Q.Set{'ClearAllPoints'})
    table.insert(child, Q.Set{'SetPoint', 'TOPLEFT', 0, -offset})
    table.insert(child, Q.Set{'SetPoint', 'BOTTOMRIGHT', self.__frame, 'TOPRIGHT', 0, -offset + -chunk})
    offset = offset + chunk
  end
  return self
end

local UnitFrame = Q.Base(function(props)
  return Q.UnitButton {
    unit = props.unit,
    {"SetSize", 200, 64},
    {"SetBackdrop", media.square},
    {"SetBackdropColor", 0, 0, 0, 0.6},
    {"SetBackdropBorderColor", 0, 0, 0, 1},
    props:children(),
    Tile {
      Q.Bar {
        {'SetStatusBarTexture', media.flat},
        {'SetStatusBarColor', 0.3, 0.05, 0.6, 0.75},
        {'SetMinMaxValues', 0, Data.UnitHealth:use(props.unit):select(2) },
        {'SetValue', Data.UnitHealth:use(props.unit)},
        Q.Text {
          {"SetPoint", "CENTER", 0, 0},
          {"SetText", UnitName(props.unit)},
        },
      },
      Q.Bar {
        weight = 0.2,
        {'SetStatusBarTexture', media.flat},
        {'SetStatusBarColor', 0.8, 0.05, 0.6, 0.75},
        {'SetMinMaxValues', 0, Data.UnitPower:use(props.unit):select(2) },
        {'SetValue', Data.UnitPower:use(props.unit)},
        Q.Text {
          {"SetPoint", "CENTER", 0, 0},
          {"SetText", Data.UnitPower:use(props.unit)},
        },
      }
    }
  }
end)

local UI = Node {
  UnitFrame {
    unit = 'player',
    {"SetPoint", "CENTER", -105, 0},
  },
  UnitFrame {
    unit = 'target',
    {"SetPoint", "CENTER", 105, 0},
  },
}

--[[
Stream.events("SPELLS_CHANGED"):once():subscribe(function(...)
  print("initial render")
  -- Squish.Render(nil, UI, Squish.Root)
end)
]]

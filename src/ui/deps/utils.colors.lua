local ClassColor
local PowerColor
local DebuffColor
local ReactionColor
do
  local COLOR_CLASS
  local COLOR_POWER
  local COLOR_DEBUFF
  local COLOR_REACTION
  local default = { 0.5, 0.5, 0.5 }
  do
    function copyColors(src, dst)
      for key, value in pairs(src) do
        if not dst[key] then
          dst[key] = { value.r, value.g, value.b }
        end
      end
      return dst
    end
    COLOR_POWER = copyColors(PowerBarColor, { MANA = { 0.31, 0.45, 0.63 }})
    COLOR_CLASS = copyColors(RAID_CLASS_COLORS, {})
    COLOR_DEBUFF = copyColors(DebuffTypeColor, {})
    COLOR_REACTION = copyColors(FACTION_BAR_COLORS, {})
  end
  function ClassColor(unit)
    local color = COLOR_CLASS[select(2, UnitClass(unit))]
    if not color then
      return default
    end
    return color
  end
  function PowerColor(unit)
    local color = COLOR_POWER[select(2, UnitPowerType(unit))]
    if not color then
      return default
    end
    return color
  end
  function DebuffColor(kind)
    local color = COLOR_DEBUFF[kind]
    if not color then
      return default
    end
    return color
  end
  function ReactionColor(unita, unitb)
    local color = COLOR_REACTION[UnitReaction(unita, unitb)]
    if not color then
      return default
    end
    return color
  end
end

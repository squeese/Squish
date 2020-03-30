local Q = select(2, ...)
Q.Extend(function()
  local Backdrop = Q.Backdrop
  local Frame = Q.Frame
  local Bar = Q.Bar
  local Text = Q.Text
  local Texture = Q.Texture
  local UnitButton = Q.UnitButton
  local lighten = Q.lighten
  local darken = Q.darken
  local decimals = Q.decimals
  local S = Q.SetStatic
  local D = Q.SetDynamic
  local COLOR_CLASS = Q.copyColors(RAID_CLASS_COLORS, {})
  local COLOR_POWER = Q.copyColors(PowerBarColor, {
    MANA = { 0.31, 0.45, 0.63 },
  })
  local Vixar = "Interface\\Addons\\Squish\\media\\vixar.ttf"
  local BarBackdrop = {
    bgFile = 'Interface\\Addons\\Squish\\media\\backdrop.tga',
    insets   = { left = -1, right = -1, top = -1, bottom = -1 }, 
  }

  local function FormatHealth(unit)
    return (math.floor(UnitHealth(unit) / 100) / 10) .. "k"
  end

  local function ClassColor(unit)
    local color = COLOR_CLASS[select(2, UnitClass(unit))]
    if color then return unpack(color) end
    return 0.5, 0.5, 0.5
  end

  local function PowerColor(fn, s, unit)
    local color = COLOR_POWER[select(2, UnitPowerType(unit))]
    if color then return fn(s, unpack(color)) end
    return 0.5, 0.5, 0.5
  end

  local BouncyHealthBar = Q.EventUnitHealth:map(UnitHealth):spring(300, 8)

  Q.UIPlayerFrame = Q.UnitButton(function(s, c, p, k, unit) return
    S("SetSize", 452, 64),
    S("SetBackdrop", Backdrop),
    S("SetBackdropColor", 0, 0, 0, 0.75),
    S("SetBackdropBorderColor", 0, 0, 0, 1),
    --Q.Subscription("key", Q.EventUnitPower(unit, UnitPower), function(value)
    --end),
    Bar("health",
      S("SetPoint", "TOPLEFT", 1, -1),
      S("SetPoint", "BOTTOMRIGHT", -1, 1),
      S("SetStatusBarTexture", "Interface\\Addons\\Squish\\media\\flat.tga"),
      D("SetStatusBarColor", Q.EventUnitClass(unit, ClassColor), 1.0),
      D("SetMinMaxValues", 0, Q.EventUnitHealth(unit, UnitHealthMax)),
      D("SetValue", BouncyHealthBar(unit)),
      Text(nil,
        S("SetFont", Vixar, 18, "OUTLINE"),
        S("SetTextColor", 1, 1, 1, 0.9),
        S("SetPoint", "BOTTOMLEFT", 3, 3),
        D("SetText", Q.EventUnitHealth(unit, FormatHealth))),
      Texture("role",
        S("SetDrawLayer", "OVERLAY"),
        S("SetSize", 16, 16),
        S("SetPoint", "TOPLEFT", 8, -16),
        S("SetTexture", "Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES"),
        D("SetTexCoord", Q.DataUnitRoleIcon(unit)))),
    Bar("power",
      S("SetFrameLevel", 3),
      S("SetPoint", "TOPLEFT", 1, 4),
      S("SetSize", 196, 16),
      S("SetStatusBarTexture", "Interface\\Addons\\Squish\\media\\flat.tga"),
      S("SetBackdrop", BarBackdrop),
      D("SetBackdropColor", Q.EventUnitPowerType(unit, PowerColor, darken, 0.75), 1.0),
      D("SetStatusBarColor", Q.EventUnitPowerType(unit, PowerColor, lighten, 0), 1.0),
      D("SetMinMaxValues", 0, Q.EventUnitPower(unit, UnitPowerMax)),
      D("SetValue", Q.EventUnitPower(unit, UnitPower)))
  end)

  Q.UIPlayerCastbar = Q.Frame(function(s, c, p, k, unit) return
    S("SetSize", 452, 32),
    S("SetBackdrop", Backdrop),
    S("SetBackdropColor", 0, 0, 0, 0.75),
    S("SetBackdropBorderColor", 0, 0, 0, 1),
    D("SetAlpha", Q.EventUnitCastingFadeIn(unit)),
    Texture(nil,
      S("SetPoint", "TOPLEFT", 1, -1),
      S("SetSize", 30, 30),
      S("SetTexCoord", 0.1, 0.9, 0.1, 0.9),
      D("SetTexture", Q.EventUnitCastingIcon(unit))),
    Bar(nil,
      S("SetPoint", "TOPLEFT", 32, -1),
      S("SetPoint", "BOTTOMRIGHT", -1, 1),
      S("SetStatusBarTexture", "Interface\\Addons\\Squish\\media\\flat.tga"),
      -- D("SetBackdropColor", Q.EventUnitPowerType(unit, PowerColor, darken, 0.75), 1.0),
      -- D("SetStatusBarColor", Q.EventUnitPowerType(unit, PowerColor, lighten, 0), 1.0),
      -- D("SetMinMaxValues", 0, CastTime(unit, select, 2)),
      D("SetMinMaxValues", 0, Q.EventUnitCastingDuration(unit)),
      D("SetValue", Q.EventUnitCastingElapsed(unit)),
      Text(nil,
        S("SetFont", Vixar, 14, "OUTLINE"),
        S("SetTextColor", 1, 1, 1, 0.9),
        S("SetPoint", "LEFT", 4, 0),
        D("SetText", Q.EventUnitCastingName(unit))),
      Text(nil,
        S("SetFont", Vixar, 11, "OUTLINE"),
        S("SetTextColor", 1, 1, 1, 0.9),
        S("SetPoint", "RIGHT", -4, 0),
        D("SetText", Q.EventUnitCastingDurationLeft(unit, decimals, 1))))
  end)

  Q.UITargetFrame = Q.UnitButton(function(s, c, p, k, unit) return
    S("SetSize", 452, 64),
    S("SetBackdrop", Backdrop),
    S("SetBackdropColor", 0, 0, 0, 0.75),
    S("SetBackdropBorderColor", 0, 0, 0, 1),
    Bar("health",
      S("SetPoint", "TOPLEFT", 1, -1),
      S("SetPoint", "BOTTOMRIGHT", -1, 1),
      S("SetStatusBarTexture", "Interface\\Addons\\Squish\\media\\flat.tga"),
      D("SetStatusBarColor", Q.EventUnitClass(unit, ClassColor), 1.0),
      D("SetMinMaxValues", 0, Q.EventUnitHealth(unit, UnitHealthMax)),
      D("SetValue", Q.EventUnitHealth(unit, UnitHealth)),
      Text(nil,
        S("SetFont", Vixar, 18, "OUTLINE"),
        S("SetShadowColor", 0, 0, 0, 1),
        S("SetTextColor", 1, 1, 1, 0.9),
        S("SetPoint", "BOTTOMLEFT", 3, 3),
        D("SetText", Q.EventUnitName(unit, UnitName))),
      Text(nil,
        S("SetFont", Vixar, 18, "OUTLINE"),
        S("SetShadowColor", 0, 0, 0, 1),
        S("SetTextColor", 1, 1, 1, 0.9),
        S("SetPoint", "BOTTOMRIGHT", -3, 3),
        D("SetText", Q.EventUnitHealth(unit, FormatHealth)))),
    Bar("power",
      S("SetFrameLevel", 3),
      S("SetPoint", "TOPLEFT", 1, 4),
      S("SetSize", 196, 16),
      S("SetStatusBarTexture", "Interface\\Addons\\Squish\\media\\flat.tga"),
      S("SetBackdrop", BarBackdrop),
      D("SetBackdropColor", Q.EventUnitPowerType(unit, PowerColor, darken, 0.75), 1.0),
      D("SetStatusBarColor", Q.EventUnitPowerType(unit, PowerColor, lighten, 0), 1.0),
      D("SetMinMaxValues", 0, Q.EventUnitPower(unit, UnitPowerMax)),
      D("SetValue", Q.EventUnitPower(unit, UnitPower)))
  end)

  Q.UITTargetFrame = Q.UnitButton(function(s, c, p, k, unit) return
    S("SetSize", 128, 27),
    S("SetBackdrop", Backdrop),
    S("SetBackdropColor", 0, 0, 0, 0.5),
    S("SetBackdropBorderColor", 0, 0, 0, 0.8),
    Bar("health",
      S("SetPoint", "TOPLEFT", 1, -1),
      S("SetPoint", "BOTTOMRIGHT", -1, 1),
      S("SetStatusBarTexture", "Interface\\Addons\\Squish\\media\\flat.tga"),
      D("SetStatusBarColor", Q.EventUnitClass(unit, ClassColor), 1.0),
      D("SetMinMaxValues", 0, Q.EventUnitHealth(unit, UnitHealthMax)),
      D("SetValue", Q.EventUnitHealth(unit, UnitHealth)),
      Text(nil,
        S("SetFont", Vixar, 11, "OUTLINE"),
        S("SetShadowColor", 0, 0, 0, 1),
        S("SetTextColor", 1, 1, 1, 0.9),
        S("SetPoint", "BOTTOMLEFT", 3, 3),
        D("SetText", Q.EventUnitName(unit, UnitName))))
  end)
end)

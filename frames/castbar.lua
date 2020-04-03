local Q = select(2, ...)
q.extend(function()
  local Backdrop = q.Backdrop
  local Frame = Q.Frame
  local Bar = Q.Bar
  local Text = Q.Text
  local Texture = Q.Texture
  local decimals = q.Decimals
  local S = Q.SetStatic
  local D = Q.SetDynamic
  local Vixar = "interface\\addons\\squish\\media\\vixar.ttf"

  Q.UIPlayerCastbar = Frame(function(s, c, p, k, unit) return
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
end)

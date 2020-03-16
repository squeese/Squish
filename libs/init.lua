local Squish = select(2, ...)

local App = Q("App", "Base", function()
  local setBlue, blue = useState(true)
  local setRed, red = useState(true)
  local setNum, num = useState(0)
  local setOpen, open = useState(true)
  return Q.Frame("player",
    Q.Set("SetPoint", "CENTER", 0, 0),
    Q.Set("SetSize", 500, 100),
    Q.Set("SetBackdrop", Squish.square),
    Q.Set("SetBackdropColor", 0, 0, 0, 0.6),
    Q.Set("SetBackdropBorderColor", 0, 0, 0, 1),
    Q.Button(
      Q.Set("SetPoint", "TOPLEFT", 0, 0),
      Q.Set("SetSize", 50, 25),
      Q.Set("SetText", "Blue"),
      Q.Set("SetScript", "OnClick", function()
          setBlue(not blue)
      end)),
    Q.Button(
      Q.Set("SetPoint", "TOP", 0, 30),
      Q.Set("SetSize", 50, 25),
      Q.Set("SetText", "X"),
      Q.Set("SetScript", "OnClick", function()
          setOpen(false)
      end)),
    Q.Button(
      Q.Set("SetPoint", "TOP", -60, 0),
      Q.Set("SetSize", 50, 25),
      Q.Set("SetText", "-"),
      Q.Set("SetScript", "OnClick", function()
          setNum(math.max(0, num-1))
      end)),
    Q.Text(
      Q.Set("SetPoint", "TOP", 0, 0),
      Q.Set("SetText", tostring(num))),
    Q.Button(
      Q.Set("SetPoint", "TOP", 60, 0),
      Q.Set("SetSize", 50, 25),
      Q.Set("SetText", "+"),
      Q.Set("SetScript", "OnClick", function()
          setNum(math.min(6, num+1))
      end)),
    Q.Range(num, function(i)
      return
        Q.Frame("key", i,
          Q.Set("SetPoint", "CENTER", (i-1) * 30 - (num-1)*30/2, 0),
          Q.Set("SetSize", 30, 30),
          Q.Set("SetBackdrop", Squish.square),
          Q.Set("SetBackdropColor", 0, 0, 0, 0.6),
          Q.Set("SetBackdropBorderColor", 0, 0, 0, 1))
    end),
    Q.Button(
      Q.Set("SetPoint", "TOPRIGHT", 0, 0),
      Q.Set("SetSize", 50, 25),
      Q.Set("SetText", "Red"),
      Q.Set("SetScript", "OnClick", function()
          setRed(not red)
      end)),
    not blue and NIL or Q.Square("b", 1, "side", "LEFT"),
    not red and NIL or Q.Square("r", 1, "side", "RIGHT"),
    Q.Text(
      Q.Set("SetPoint", "BOTTOMLEFT", 0, 0),
      Q.Set("SetText", tostring(blue))),
    Q.Text(
      Q.Set("SetPoint", "BOTTOMRIGHT", 0, 0),
      Q.Set("SetText", tostring(red))))
end)

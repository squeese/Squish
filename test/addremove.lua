local Q = select(2, ...)

--local function testApp()
  --local app
  --local count = 0
  --local function report(fn)
    --collectgarbage("collect")
    --local before = collectgarbage("count")
    --fn()
    --local change = collectgarbage("count") - before
    --collectgarbage("collect")
    --local after = collectgarbage("count")
    ---- print("Before", before, "After", after, "Change", change)
  --end
  --local function dec()
    --report(function()
      --repeat
        --count = math.max(0, count - 1)
        --Render(app)
      --until count == 0
    --end)
  --end
  --local function inc()
    --report(function()
      --repeat
        --count = math.min(count + 1, 6)
        --Render(app)
      --until count == 6
    --end)
  --end

  --local Butt = Button(function(self)
    --return
      --Set("SetPoint", self.point, 0, 0),
      --Set("SetText", self.text),
      --Set("SetScript", "OnClick", self.onClick)
  --end)

  --local TApp = Frame{
    --{"SetPoint", "CENTER", 0, 100},
    --{"SetSize", 100, 100},
    --{"SetBackdrop", backdrop},
    --{"SetBackdropColor", 0, 0, 0, 0.5},
    --{"SetBackdropBorderColor", 0, 0, 0, 0.8},
    --Butt{ point="TOPLEFT", text="-", onClick=dec },
    --Butt{ point="TOPRIGHT", text="+", onClick=inc },
    ----Button{
      ----{"SetPoint", "TOPLEFT", 0, 0},
      ----{"SetText", "-"},
      ----{"SetScript", "OnClick", dec},
    ----},
    ----Button{
      ----{"SetPoint", "TOPRIGHT", 0, 0},
      ----{"SetText", "+"},
      ----{"SetScript", "OnClick", inc},
    ----},
    --Iterator{function(i)
      --if i <= count then
        --return Text(nil
          --, Set("SetPoint", "TOP", 0, -i*10)
          --, Set("SetText", i))
      --end
    --end},
  --}

  --local FApp = Driver(function(self, container, ...)
    --return Frame(nil
      --, Set("SetPoint", "CENTER", 0, 100)
      --, Set("SetSize", 100, 100)
      --, Set("SetBackdrop", backdrop)
      --, Set("SetBackdropColor", 0, 0, 0, 0.5)
      --, Set("SetBackdropBorderColor", 0, 0, 0, 0.8)
      --, Button(nil
        --, Set("SetPoint", "TOPLEFT", 0, 0)
        --, Set("SetText", "-")
        --, Set("SetScript", "OnClick", dec))
      --, Button(nil
        --, Set("SetPoint", "TOPRIGHT", 0, 0)
        --, Set("SetText", "+")
        --, Set("SetScript", "OnClick", inc))
      --, Range(nil, 1, count, function(i)
        --return Text(nil
          --, Set("SetPoint", "TOP", 0, -i*10)
          --, Set("SetText", i))
        --end))

  --end)

  --app = FApp
  --Render(app)
--end
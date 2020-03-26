local Q = select(2, ...)

local function stuff()
  C_Timer.After(1, function()
    local frame = CreateFrame("frame", nil, UIParent)
    local backdrop = Q.Backdrop
    local function reset()
      frame:SetSize(100, 100)
      frame:SetPoint("CENTER", 0, 0)
      frame:SetBackdrop(backdrop)
      frame:SetBackdropColor(0, 0, 0, 0.5)
      frame:SetBackdropBorderColor(0, 0, 0, 0.5)
      frame:Show()
    end
    reset()

    local iterations = 100
    local values = {}
    for i = 1, iterations do
      table.insert(values, {
        100 * math.random(),
        100 * math.random(),
        50 - 100 * math.random(),
        50 - 100 * math.random(),
        math.random(),
        math.random(),
        math.random(),
        math.random(),
      })
    end
    local function test(fn, variations)
      reset()
      local time = 0
      for i = 1, iterations do
        if variations then
          time = time + fn(unpack(values[i]))
        else
          time = time + fn(unpack(values[1]))
        end
      end
      return time
    end

    print("same values, no change check", test(function(w, h, x, y, r, g, b, a)
      local start = debugprofilestop()
      frame:SetSize(w, h)
      frame:SetPoint("CENTER", x, y)
      frame:SetBackdropColor(r, g, b, a)
      frame:SetBackdropBorderColor(r, g, b, a)
      return debugprofilestop() - start
    end, false))

    print("different values, no change check", test(function(w, h, x, y, r, g, b, a)
      local start = debugprofilestop()
      frame:SetSize(w, h)
      frame:SetPoint("CENTER", x, y)
      frame:SetBackdropColor(r, g, b, a)
      frame:SetBackdropBorderColor(r, g, b, a)
      return debugprofilestop() - start
    end, true))

    local function change(variations)
      local pw, ph, px, py, pr, pg, pb = 100, 100, 0, 0, 0, 0, 0, 0.5
      print("change check", test(function(w, h, x, y, r, g, b, a)
        local start = debugprofilestop()
        if w ~= pw or h ~= ph then
          frame:SetSize(w, h)
          pw, ph = w, h
        end
        if x ~= px or y ~= py then
          frame:SetPoint("CENTER", x, y)
          px, py = x, y
        end
        if r ~= pr or g ~= pg or b ~= pg or a ~= pa then
          frame:SetBackdropColor(r, g, b, a)
          frame:SetBackdropBorderColor(r, g, b, a)
          pr, pg, pb, pa = r, g, b, a
        end
        return debugprofilestop() - start
      end, variations))
    end

    change(false)
    change(true)
  end)
end

--debugprofilestop
--debugprofilestart
--debuglocals
--debugstack

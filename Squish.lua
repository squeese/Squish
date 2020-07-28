local addon, Q = ...
local Render = Q.Create()
--Render(Q.Extend(function() return
  --Q.Layout{
    --function(playerButton, targetButton, ttargetButton, ...)
      --playerButton.frame:SetPoint("LEFT", 224, -320)
      --targetButton.frame:SetPoint("LEFT", playerButton.frame, "RIGHT", 6, 0)
      --ttargetButton.frame:SetPoint("BOTTOMRIGHT", targetButton.frame, "TOPRIGHT", 0, 5)
      ---- playerCastbar.frame:SetPoint("TOP", playerButton.frame, "BOTTOM", 0, -6)
      --for i = 1, select("#", ...) do
        --local raid = select(i, ...)
        --if i == 1 then
          --raid.frame:SetPoint("BOTTOMRIGHT", playerButton.frame, "TOPRIGHT", 0, 32)
        --else
          --raid.frame:SetPoint("BOTTOMRIGHT", select(i-1, ...).frame, "TOPRIGHT", 0, 1)
        --end
      --end
    --end,
    --Q.UIPlayerFrame{"player"},
    --Q.UITargetFrame{"target"},
    --Q.UITTargetFrame{"targettarget"},
    ---- Q.UIPlayerCastbar{"player"},
    --Q.UIRaid{ group = 1 },
    --Q.UIRaid{ group = 2 },
    --Q.UIRaid{ group = 3 },
    --Q.UIRaid{ group = 4 },
    --Q.UIRaid{ group = 5 },
    --Q.UIRaid{ group = 6 },
    --Q.UIRaid{ group = 7 },
    --Q.UIRaid{ group = 8 },
  --}
--end))
--
Render(Q.Extend(function() return
  Q.UIRaid{
    group = 1,
    HEADER = function() return
      Q.Set("SetPoint", "CENTER", 0, 0),
      Q.Set("SetBackdrop", Q.Backdrop),
      Q.Set("SetBackdropColor", 0, 0, 0, 0.175),
      Q.Set("SetBackdropBorderColor", 0, 0, 0, 1)
    end,
    BUTTON = function(unit)
      print("BUTTON??", unit)
      return
      Q.Set("SetBackdrop", Backdrop),
      Q.Set("SetBackdropColor", 0, 0, 0, 0.75),
      Q.Set("SetBackdropBorderColor", 0, 0, 0, 1),
      Q.Bar("health",
        Q.Set("SetPoint", "TOPLEFT", 1, -1),
        Q.Set("SetPoint", "BOTTOMRIGHT", -1, 1),
        Q.Set("SetStatusBarTexture", "Interface\\Addons\\Squish\\media\\flat.tga"),
        Q.Set("SetOrientation", "VERTICAL"),
        Q.SetDynamic("SetValue", Q.EventUnitHealth(unit, UnitHealth)),
        Q.SetDynamic("SetMinMaxValues", 0, Q.EventUnitHealth(unit, UnitHealthMax)))
    end,
  }
end))

--local function Test()
  --local frame = CreateFrame("frame", nil, UIParent)
  --local child = setmetatable({ __driver = Q.Driver, frame = frame }, Q.Container)
  --local function BUTTON(unit) return
    --Q.Set("SetPoint", "CENTER", 0, 0),
    --Q.Set("SetSize", 100, 100),
    --Q.Set("SetBackdrop", Q.Backdrop),
    --Q.Set("SetBackdropColor", 0, 0, 0, 0.75),
    --Q.Set("SetBackdropBorderColor", 0, 0, 0, 1),
    --Q.Text(nil,
      --Q.Set("SetPoint", "CENTER", 0, 0),
      --Q.SetDynamic("SetText", Q.EventUnitName(unit, UnitName)))
  --end
  --return {
    --render = function(...)
      --Q.Driver:RELEASE(Q.Driver:CHILDREN(child, 1, BUTTON(...)))
    --end,
    --close = function()
      --print("close")
      --Q.Driver:RELEASE(child, 1)
    --end
  --}
--end

--local test = Test()
--C_Timer.After(1, function()
  --test.render("player")
--end)
--C_Timer.After(3, function()
  --test.render("target")
--end)
--C_Timer.After(5, function()
  --test.render("raid1")
--end)
--C_Timer.After(7, function()
  --test.render("party1")
--end)




-- background groups
-- layout groups
-- remove lots of files
-- sidebar
-- auras bottom/top



-- reload
-- addon_loaded
-- variables_loaded

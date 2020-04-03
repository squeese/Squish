local addon, Q = ...
local Render = Q.Create()
Render(Q.Extend(function() return
  Q.Layout{
    function(playerButton, targetButton, ttargetButton, ...)
      playerButton.frame:SetPoint("LEFT", 224, -320)
      targetButton.frame:SetPoint("LEFT", playerButton.frame, "RIGHT", 6, 0)
      ttargetButton.frame:SetPoint("BOTTOMRIGHT", targetButton.frame, "TOPRIGHT", 0, 5)
      -- playerCastbar.frame:SetPoint("TOP", playerButton.frame, "BOTTOM", 0, -6)


      for i = 1, select("#", ...) do
        local raid = select(i, ...)
        if i == 1 then
          raid.frame:SetPoint("BOTTOMRIGHT", playerButton.frame, "TOPRIGHT", 0, 32)
        else
          raid.frame:SetPoint("BOTTOMRIGHT", select(i-1, ...).frame, "TOPRIGHT", 0, 0)
        end
      end
    end,
    Q.UIPlayerFrame{"player"},
    Q.UITargetFrame{"target"},
    Q.UITTargetFrame{"targettarget"},
    -- Q.UIPlayerCastbar{"player"},
    Q.UIRaid{ group = 1 },
    Q.UIRaid{ group = 2 },
    Q.UIRaid{ group = 3 },
    Q.UIRaid{ group = 4 },
    Q.UIRaid{ group = 5 },
    Q.UIRaid{ group = 6 },
    Q.UIRaid{ group = 7 },
    Q.UIRaid{ group = 8 },
  }
end))



-- background groups
-- layout groups
-- remove lots of files
-- sidebar
-- auras bottom/top



-- reload
-- addon_loaded
-- variables_loaded

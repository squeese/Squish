local addon, Q = ...
local Render = Q.Create()
Render(Q.Extend(function() return
  Q.Layout{
    function(playerButton, targetButton, ttargetButton, playerCastbar)
      playerButton.frame:SetPoint("LEFT", 224, -320)
      targetButton.frame:SetPoint("LEFT", playerButton.frame, "RIGHT", 6, 0)
      ttargetButton.frame:SetPoint("BOTTOMRIGHT", targetButton.frame, "TOPRIGHT", 0, 5)

      -- playerCastbar.frame:SetPoint("TOP", playerButton.frame, "BOTTOM", 0, -6)
    end,
    Q.UIPlayerFrame{"player"},
    Q.UITargetFrame{"target"},
    Q.UITTargetFrame{"targettarget"},
    -- Q.UIPlayerCastbar{"player"},
    -- Q.UIRaid{ group = 1 },
    -- Q.UIRaid{ group = 1 },
    -- Q.UIRaid{ group = 1 },
    -- Q.UIRaid{ group = 1 },
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

local addon, Q = ...
local Render = Q.Create()
Render(Q.Extend(function() return
  Q.Layout{
    function(playerButton, playerCastbar, targetButton, ttargetButton)
      playerButton.frame:SetPoint("LEFT", 256, -320)
      playerCastbar.frame:SetPoint("TOP", playerButton.frame, "BOTTOM", 0, -6)
      targetButton.frame:SetPoint("LEFT", playerButton.frame, "RIGHT", 8, 0)
      ttargetButton.frame:SetPoint("TOPRIGHT", targetButton.frame, "BOTTOMRIGHT", 0, -6)
    end,
    Q.UIPlayerFrame{"player"},
    Q.UIPlayerCastbar{"player"},
    Q.UITargetFrame{"target"},
    Q.UITTargetFrame{"targettarget"},
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

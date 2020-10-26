${include("src/lua/utils.lua")}
${include("src/lua/onAttributeChange.lua")}
${include("src/lua/templates.lua")}
${include("src/playerButton.lua")}

local UI = CreateFrame("frame", nil, UIParent, "BackdropTemplate")
UI:RegisterEvent("PLAYER_LOGIN")
UI:SetScript("OnEvent", function(self)
  self:SetScript("OnEvent", nil)
  self:UnregisterAllEvents()
  self:SetPoint("TOPLEFT", 0, 0)
  self:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMLEFT", 640, 0)
  self:SetBackdrop(MEDIA:BACKDROP())
  self:SetBackdropColor(0, 0, 0, 0.1)
  self:SetBackdropBorderColor(0, 0, 0, 0)
  self:SetScale(0.533333333 / UIParent:GetScale())

  local playerButton = (function()
    ${template.PlayerUnitButton('playerButton', 'self')}
    self:SetSize(382, 64)
    self:SetPoint("RIGHT", -8, -240)
    return self
  end)()

  -- local playerCastbar = CreateCastBar(playerButton, "player", 32)
  -- playerCastbar:SetPoint("TOPLEFT", playerButton, "BOTTOMLEFT", 0, -16)
  -- playerCastbar:SetPoint("TOPRIGHT", playerButton, "BOTTOMRIGHT", 0, -16)
end)

    ${instance.Use("UNIT_SET GUID_MOD GROUP_ROSTER_UPDATE",
      GET`local ${"party"} = UnitInParty(self.unit)`,
      GET`local ${"leader"} = UnitIsGroupLeader(self.unit)`,
      GET`local ${"assist"} = UnitIsGroupAssistant(self.unit)`,
      SET`ToggleVisible(leaderIcon, (${"party"}) and (${"leader"}))
          ToggleVisible(assistIcon, (${"party"}) and (${"assist"}))`)}

    ${instance.Use("UNIT_SET GUID_MOD PLAYER_ROLES_ASSIGNED PLAYER_REGEN_ENABLED PLAYER_REGEN_DISABLED GROUP_ROSTER_UPDATE PLAYER_UPDATE_RESTING INCOMING_RESURRECT_CHANGED", SET`
      StackIcons(roleIcon, leaderIcon, assistIcon, restedIcon, combatIcon, resserIcon)`)}

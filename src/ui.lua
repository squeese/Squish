${template('DEV', process.env.NODE_ENV === 'DEV')}

${include("src/lua/utils.lua")}
${include("src/lua/utils.spring.lua")}
${include("src/lua/utils.blizzard.lua")}
${include("src/lua/utils.auratable.lua")}
${include("src/lua/utils.ticker.lua")}
${include("src/lua/utils.queue.lua")}
${include("src/lua/utils.candispel.lua")}
${include("src/lua/onAttributeChange.lua")}
${include("src/lua/castbar.lua")}
${include("src/lua/templates.lua")}
${include("src/lua/spells/data.lua")}
${include("src/lua/spells/gui.lua")}
${include("src/lua/cooldowns.lua")}
${include("src/buffsHeader.lua")}
${include("src/playerButton.lua")}
${include("src/targetButton.lua")}
${include("src/partyHeader.lua")}

local UI = CreateFrame("frame", nil, UIParent)
UI:RegisterEvent("PLAYER_LOGIN")
UI:SetScript("OnEvent", function(self, event)
  self:UnregisterAllEvents()
  self:SetPoint("TOPLEFT", 0, 0)
  self:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMLEFT", 640, 0)
  self:SetScale(0.533333333 / UIParent:GetScale())

  HookSpellBookTooltips()

  BuffFrame:SetScript("OnUpdate", nil) BuffFrame:SetScript("OnEvent", nil)
  BuffFrame:UnregisterAllEvents()
  BuffFrame:Hide()
  CreatePlayerBuffs(UI, 48, "player", "HELPFUL", true, "PlayerBuffs"):SetPoint("TOPRIGHT", -4, -4)
  CreatePlayerBuffs(UI, 64, "player", "HARMFUL", false, "PlayerDebuffs"):SetPoint("TOPRIGHT", -4, -100)

  ${template('WIDTH', 376)}

  local playerButton = (function()
    ${PlayerUnitButton('UI', WIDTH, 64)}
    self:SetPoint("RIGHT", -8, -240)
    DisableBlizzard("player")
    CastingBarFrame:SetScript('OnUpdate', nil)
    CastingBarFrame:SetScript('OnEvent', nil)
    CastingBarFrame:UnregisterAllEvents()
    CastingBarFrame:Hide()
    local castbar = CreateCastBar(self, "player", 32)
    castbar:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -16)
    castbar:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -16)
    return self
  end)()

  local cdRot = CreateCooldowns(UI, 48, SPELLS.Rotation)
  cdRot:SetPoint("BOTTOMRIGHT", playerButton, "TOPRIGHT", 0, 16)

  local cdSit = CreateCooldowns(UI, 48, SPELLS.Situational)
  cdSit:SetPoint("TOPRIGHT", playerButton, "BOTTOMRIGHT", 0, -64)

  -- local cdOth = CreateCooldowns(UI, 32, SPELLS.Other)
  -- cdOth:SetPoint("TOPRIGHT", cdSit, "BOTTOMRIGHT", 0, -4)

  do
    ${TargetUnitButton('UI')}
    self:SetSize(${WIDTH}, 64)
    self:SetPoint("LEFT", playerButton, "RIGHT", 16, 0)
    DisableBlizzard("target")
    local castbar = CreateCastBar(UI, "target", 32)
    castbar:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -16)
    castbar:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -16)
  end

  do
    ${PartyHeader('UI', WIDTH, 128)}
    self:SetPoint("BOTTOMRIGHT", playerButton, "TOPRIGHT", 1, 100)
    self:Show()
  end

  ${cleanup}
end)

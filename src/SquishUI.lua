${template('DEV', process.env.NODE_ENV === 'DEV')}

local name, SquishUI = ...
_G[name] = SquishUI

BINDING_HEADER_SQUISHUI = 'SquishUI'
BINDING_NAME_TOGGLE_CONFIG = 'Toggle Config Panel'
function SquishUI:ToggleConfigUI()
  print("toggle!")
end

${locals}
${include("src/lua/utils.media.lua")}
${include("src/lua/utils.spring.lua")}
${include("src/lua/utils.queue.lua")}
${include("src/lua/utils.ticker.lua")}
${include("src/lua/utils.colors.lua")}
${include("src/lua/utils.misc.lua")}
${include("src/lua/utils.blizzard.lua")}
${include("src/lua/utils.auratable.lua")}
${include("src/lua/initialData.lua")}
${include("src/lua/onAttributeChange.lua")}
${include("src/lua/templates.lua")}
${include("src/lua/castbar.lua")}
${include("src/lua/cooldowns.lua")}
${include("src/SquishUI.AuraHeader.lua")}
${include("src/SquishUI.PlayerButton.lua")}
${include("src/SquishUI.TargetButton.lua")}
${include("src/SquishUI.PartyHeader.lua")}

local UI = CreateFrame("frame", nil, UIParent)
UI:RegisterEvent("VARIABLES_LOADED")
UI:RegisterEvent("PLAYER_LOGIN")
UI:SetScript("OnEvent", function(self, event)
  if event == "VARIABLES_LOADED" then
    if type(_G.SquishUIData) ~= "table" then
      _G.SquishUIData = CreateInitialData()
    end
    CreateInitialData = nil

  elseif event == "PLAYER_LOGIN" then
    local SquishUIData = _G.SquishUIData
    self:UnregisterAllEvents()
    self:SetPoint("TOPLEFT", 0, 0)
    self:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMLEFT", 640, 0)
    self:SetScale(0.533333333 / UIParent:GetScale())

    BuffFrame:SetScript("OnUpdate", nil) BuffFrame:SetScript("OnEvent", nil)
    BuffFrame:UnregisterAllEvents()
    BuffFrame:Hide()
    CreateAuraHeader(UI, 48, "player", "HELPFUL", true, "PlayerBuffs"):SetPoint("TOPRIGHT", -4, -4)
    CreateAuraHeader(UI, 64, "player", "HARMFUL", false, "PlayerDebuffs"):SetPoint("TOPRIGHT", -4, -100)

    local playerButton = (function()
      ${PlayerUnitButton('UI', 376, 64)}
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

    local CooldownRotation = CreateCooldowns(UI, 48, SquishUIData.CooldownRotation)
    CooldownRotation:SetPoint("BOTTOMRIGHT", playerButton, "TOPRIGHT", 0, 16)

    local CooldownSituational = CreateCooldowns(UI, 48, SquishUIData.CooldownSituational)
    CooldownSituational:SetPoint("TOPRIGHT", playerButton, "BOTTOMRIGHT", 0, -64)

    do
      ${TargetUnitButton('UI')}
      self:SetSize(playerButton:GetWidth(), 64)
      self:SetPoint("LEFT", playerButton, "RIGHT", 16, 0)
      DisableBlizzard("target")
      local castbar = CreateCastBar(UI, "target", 32)
      castbar:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -16)
      castbar:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -16)
    end

    do
      ${PartyHeader('UI', 128)}
      self:SetPoint("BOTTOMRIGHT", playerButton, "TOPRIGHT", 1, 100)
      self:Show()
    end

    SquishUI.Media = Media
    local loaded, reason = LoadAddOn("SquishConfig")
    print("SquishUI loaded", loaded, reason)

    ${cleanup}
  end
end)

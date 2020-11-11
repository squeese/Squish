${template('DEV', process.env.NODE_ENV === 'DEV')}

local name, SquishUI = ...
_G[name] = SquishUI

${locals}
${include("src/ui/deps/utils.media.lua")}
${include("src/ui/deps/utils.spring.lua")}
${include("src/ui/deps/utils.queue.lua")}
${include("src/ui/deps/utils.ticker.lua")}
${include("src/ui/deps/utils.colors.lua")}
${include("src/ui/deps/utils.misc.lua")}
${include("src/ui/deps/utils.blizzard.lua")}
${include("src/ui/deps/utils.auratable.lua")}
${include("src/ui/deps/utils.candispel.lua")}
${include("src/SquishUI.Spells.lua")}
${include("src/ui/deps/onAttributeChange.lua")}
${include("src/ui/deps/templates.lua")}
${include("src/ui/deps/castbar.lua")}
${include("src/ui/deps/cooldowns.lua")}
${include("src/ui/AuraHeader.lua")}
${include("src/ui/PlayerButton.lua")}
${include("src/ui/TargetButton.lua")}
${include("src/ui/PartyHeader.lua")}
${include("src/ui/BossButtons.lua")}

local UI = CreateFrame("frame", nil, UIParent)
UI:RegisterEvent("VARIABLES_LOADED")
UI:RegisterEvent("PLAYER_LOGIN")
UI:SetScript("OnEvent", function(self, event)
  if event == "VARIABLES_LOADED" then
  _G.SquishUIData = CreateInitialData()
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

    do
      ${BossButtons('UI', 100, 48)}
      Misc_Stack(playerButton, "BOTTOMLEFT", "TOPRIGHT", 16, 101, "BOTTOM", "TOP", 0, 8, boss1, boss2, boss3, boss4, boss5)
    end

    local Config = {}
    Config.__addon = nil
    Config.__index = function(self, key)
      if rawget(self, '__addon') == nil then
        SquishUI.Media = Media
        local loaded, reason = LoadAddOn("SquishConfig")
        if not loaded then
          print("SquishUI, failed to load SquishConfig")
          return
        end
        rawset(self, '__addon', _G.SquishConfig)
      end
      return rawget(self, '__addon')[key]
    end
    setmetatable(Config, Config)
    BINDING_HEADER_SQUISHUI = 'SquishUI'
    BINDING_NAME_TOGGLE_CONFIG = 'Toggle Config Panel'
    function SquishUI:ToggleConfigUI()
      SquishUIData.ConfigGUIOpen = not SquishUIData.ConfigGUIOpen
      if SquishUIData.ConfigGUIOpen then
        Config:OpenGUI()
      else
        Config:CloseGUI()
      end
    end
    if SquishUIData.ConfigGUIOpen then
      Config:OpenGUI()
    end

    ${cleanup}
  end
end)

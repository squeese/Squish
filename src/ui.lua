${template('DEV', process.env.NODE_ENV === 'DEV')}

${include("src/lua/utils.lua")}
${include("src/lua/rangechecker.lua")}
${include("src/lua/ticker.lua")}
${include("src/lua/onAttributeChange.lua")}
${include("src/lua/templates.lua")}
${include("src/lua/castbar.lua")}
${include("src/lua/auras.lua")}
${include("src/lua/bossTarget.lua")}
${include("src/playerButton.lua")}
${include("src/targetButton.lua")}
${include("src/buffsHeader.lua")}
${include("src/partyHeader.lua")}
${include("src/lua/spellsgui.lua")}

local UI = CreateFrame("frame", nil, UIParent, "BackdropTemplate")
UI:RegisterEvent("PLAYER_LOGIN")
UI:SetScript("OnEvent", function(self, event)
  self:SetScript("OnEvent", nil)
  self:UnregisterAllEvents()
  self:SetPoint("TOPLEFT", 0, 0)
  self:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMLEFT", 640, 0)
  self:SetBackdrop(MEDIA:BACKDROP(true, nil, 0, -1))
  self:SetBackdropColor(0, 0, 0, 0)
  self:SetBackdropBorderColor(0, 0, 0, 0)
  self:SetScale(0.533333333 / UIParent:GetScale())
  --self:SetScale(max(0.4, min(1.15, 768 / GetScreenHeight())) / UIParent:GetScale())

  local function tick(self)
    local now = GetTime()
    local elapsed = now - self.time
    print("tick", self.name, elapsed)
    self.time = now
  end

  --local test1 = { name = '1', __tick = tick, time = GetTime() }
  --Ticker:Add(test1)

  ${template('WIDTH', 382)}

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

  do
    ${TargetUnitButton('UI')}
    self:SetSize(${WIDTH}, 64)
    self:SetPoint("LEFT", playerButton, "RIGHT", 16, 0)
    DisableBlizzard("target")
    local castbar = CreateCastBar(UI, "target", 32)
    castbar:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -16)
    castbar:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -16)
  end

  BuffFrame:SetScript("OnUpdate", nil)
  BuffFrame:SetScript("OnEvent", nil)
  BuffFrame:UnregisterAllEvents()
  BuffFrame:Hide()
  do
    ${PlayerBuffsHeader('UI', 48, "player", "HELPFUL", true, "PlayerBuffs")}
    self:SetPoint("TOPRIGHT", -4, -4)
  end
  do
    ${PlayerBuffsHeader('UI', 64, "player", "HARMFUL", false, "PlayerDebuffs")}
    self:SetPoint("TOPRIGHT", -4, -100)
  end

  do
    ${PartyHeader('UI', WIDTH, 128)}
    self:SetPoint("BOTTOMRIGHT", playerButton, "TOPRIGHT", 1, 100)
    self:Show()
  end
end)

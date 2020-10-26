${include("src/lua/utils.lua")}
${include("src/lua/onAttributeChange.lua")}
${include("src/lua/templates.lua")}
${include("src/lua/castbar.lua")}
${include("src/playerButton.lua")}
${include("src/targetButton.lua")}
${include("src/buffsHeader.lua")}

local UI = CreateFrame("frame", nil, UIParent, "BackdropTemplate")
UI:RegisterEvent("PLAYER_LOGIN")
UI:SetScript("OnEvent", function(self)
  self:SetScript("OnEvent", nil)
  self:UnregisterAllEvents()
  self:SetPoint("TOPLEFT", 0, 0)
  self:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMLEFT", 640, 0)
  self:SetBackdrop(MEDIA:BACKDROP(true, nil, 0, -1))
  self:SetBackdropColor(0, 0, 0, 0.2)
  self:SetBackdropBorderColor(0, 0, 0, 0)
  self:SetScale(0.533333333 / UIParent:GetScale())

  local playerButton = (function()
    ${PlayerUnitButton('UI')}
    self:SetSize(382, 64)
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

  local targetButton = (function()
    ${TargetUnitButton('UI')}
    self:SetSize(382, 64)
    self:SetPoint("LEFT", playerButton, "RIGHT", 16, 0)
    DisableBlizzard("target")
    local castbar = CreateCastBar(UI, "target", 32)
    castbar:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -16)
    castbar:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -16)
    return self
  end)()

  --BuffFrame:SetScript("OnUpdate", nil)
  --BuffFrame:SetScript("OnEvent", nil)
  --BuffFrame:UnregisterAllEvents()
  --BuffFrame:Hide()
  do
    ${PlayerBuffsHeader('UI', 48, "player", "HELPFUL", true, "PlayerBuffs")}
    self:SetPoint("TOPRIGHT", -4, -4)
  end
  do
    ${PlayerBuffsHeader('UI', 64, "player", "HARMFUL", false, "PlayerDebuffs")}
    self:SetPoint("TOPRIGHT", -4, -100)
  end

-- Q.DisableBlizzard("party")
  --[[
  local buttons = {}
  local test = CreateFrame("frame", nil, UIParent, "BackdropTemplate")
  test:SetPoint("CENTER", 0, 0)
  test:SetBackdrop(MEDIA:BACKDROP(true, nil, 0, 0))
  test:SetBackdropColor(0, 0, 0, 1)
  test:SetSize(200, 200)
  test:RegisterEvent("PLAYER_ENTERING_WORLD")
  test:RegisterUnitEvent("UNIT_AURA", "player")
  test:SetScript("OnEvent", function(self)
    for index = 1, 10 do
      local _, texture = UnitAura("player", index, "HELPFUL")
      if not texture then break end
      if not buttons[index] then
        buttons[index] = CreateFrame("button", nil, test)
        buttons[index]:SetSize(32, 32)
        buttons[index].icon = buttons[index]:CreateTexture()
        buttons[index].icon:SetAllPoints()
        buttons[index]:RegisterForClicks("RightButtonUp")
        buttons[index]:SetScript("OnClick", function(self)
          print("cancelbuff", self.index)
          CancelUnitBuff("player", self.index, "HELPFUL")
        end)
      end
      local button = buttons[index]
      button.index = index
      button.icon:SetTexture(texture)
      button:SetPoint("CENTER", (index-1)*32, 0)
      button:Show()
    end
  end)
  ]]--


  -- local playerCastbar = CreateCastBar(playerButton, "player", 32)
  -- playerCastbar:SetPoint("TOPLEFT", playerButton, "BOTTOMLEFT", 0, -16)
  -- playerCastbar:SetPoint("TOPRIGHT", playerButton, "BOTTOMRIGHT", 0, -16)
end)



    --do -- boss target
      --local target = CreateFrame('frame', nil, self, "BackdropTemplate")
      --target:SetSize(${buttonWidth}, 32)
      --target:SetPoint("BOTTOMRIGHT", 0, 0)
      --target:SetBackdrop(MEDIA:BACKDROP(true, false, 0, 0))
      --target:SetBackdropColor(0, 0, 0, 0.75)
      --target:SetFrameLevel(4)
      --target.playerTargetPosition = CreateSpring(function(_, index)
        --target:SetPoint("BOTTOMRIGHT", (index-1) * -${offsetWidth}, 128)
      --end, 230, 24, 0.001)
      --target.playerTargetAlpha = CreateSpring(function(_, value)
        --target:SetAlpha(value)
      --end, 300, 20, 0.1)
      --target.playerTargetAlpha(0)
      --target:RegisterEvent("PLAYER_TARGET_CHANGED")
      --target.header = self
      --target:SetScript("OnEvent", OnEvent_PlayerTarget)
    --end

  self:UnregisterAllEvents()
  self:SetPoint("TOPLEFT", 0, 0)
  self:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMLEFT", 640, 0)
  self:SetBackdrop(MEDIA:BACKDROP(true, nil, 0, -1))
  self:SetBackdropColor(0, 0, 0, 0)
  self:SetBackdropBorderColor(0, 0, 0, 0)
  self:SetScale(0.533333333 / UIParent:GetScale())

  local CooldownsRotation = CreateCooldowns(UI, Spells.Rotation)

  local CanDispelUpdate = CanDispel:RegisterEvents(self)
  -- local CooldownsUpdate = CooldownsRegisterEvents(self)
  self:SetScript("OnEvent", function(self, event, ...)
    CanDispelUpdate(self, event, ...)
    -- CooldownsUpdate(self, event, ...)
  end)

  BuffFrame:SetScript("OnUpdate", nil) BuffFrame:SetScript("OnEvent", nil)
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

  ${cleanup()}

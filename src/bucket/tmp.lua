

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


  local CooldownsRotation = CreateCooldowns(UI, Spells.Rotation)

  local CanDispelUpdate = CanDispel:RegisterEvents(self)
  -- local CooldownsUpdate = CooldownsRegisterEvents(self)
  self:SetScript("OnEvent", function(self, event, ...)
    CanDispelUpdate(self, event, ...)
    -- CooldownsUpdate(self, event, ...)
  end)








  ${cleanup()}

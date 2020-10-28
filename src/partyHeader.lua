${template('PartyHeader', (parent, width, height) => {
  const gap = 2;
  const buttonWidth = Math.ceil((width - 4*gap) / 5);
  const offsetWidth = Math.ceil(width / 5);
  const context = new Context();
  return `
    local self = CreateFrame('frame', 'SquishPartyHeader', ${parent}, 'SecureGroupHeaderTemplate')
    self:SetAttribute('showRaid', true)
    self:SetAttribute('showParty', true)
    self:SetAttribute('showPlayer', true)
    self:SetAttribute('showSolo', true)
    self:SetAttribute('point', 'RIGHT')
    self:SetAttribute('columnAnchorPoint', 'BOTTOM')
    self:SetAttribute('xOffset', -${gap})
    self:SetAttribute('yOffset', 0)
    ---self:SetAttribute('groupBy', 'ASSIGNEDROLE')
    self:SetAttribute('groupBy', 'GROUP')
    ---self:SetAttribute('groupingOrder', 'TANK,DAMAGER,HEALER')
    self:SetAttribute('groupingOrder', '1,2,3,4,5,6,7,8')
    self:SetAttribute('template', 'SecureActionButtonTemplate,BackdropTemplate')
    self:SetAttribute('initialConfigFunction', [[
      print("initialConfigFunction")
      self:SetWidth(${buttonWidth})
      self:SetHeight(${height})
      self:GetParent():CallMethod('ConfigureButton', self:GetName())
    ]])

    do -- boss target
      local target = CreateFrame('frame', nil, self, "BackdropTemplate")
      target:SetSize(${buttonWidth}, 32)
      target:SetPoint("BOTTOMRIGHT", 0, 0)
      target:SetBackdrop(MEDIA:BACKDROP(true, false, 0, 0))
      target:SetBackdropColor(0, 0, 0, 0.75)
      target:SetFrameLevel(4)
      target.playerTargetPosition = CreateSpring(function(_, index)
        target:SetPoint("BOTTOMRIGHT", (index-1) * -${offsetWidth}, 128)
      end, 230, 24, 0.001)
      target.playerTargetAlpha = CreateSpring(function(_, value)
        target:SetAlpha(value)
      end, 300, 20, 0.1)
      target.playerTargetAlpha(0)
      target:RegisterEvent("PLAYER_TARGET_CHANGED")
      target.header = self
      target:SetScript("OnEvent", OnEvent_PlayerTarget)
    end

    local OnEvent
    function self:ConfigureButton(name)
      local self = _G[name]
      self:RegisterForClicks('AnyUp')
      self:SetAttribute('*type1', 'target')
      self:SetAttribute('*type2', 'togglemenu')
      self:SetAttribute('toggleForVehicle', true)
      self:SetScript('OnAttributeChanged', OnAttributeChanged)
      self:SetBackdrop(MEDIA:BACKDROP(true, false, 0, 0))
      self:SetBackdropColor(0, 0, 0, 0.75)
      RegisterUnitWatch(self)
      self.handler = OnEvent

      ${StatusBar('self.healthBar', 'self')}
      self.healthBar:SetPoint("TOPLEFT", 1, -1)
      self.healthBar:SetPoint("BOTTOMRIGHT", -1, 1)
      self.healthBar:SetOrientation("VERTICAL")
      self.healthBar:SetFrameLevel(3)

      ${StatusBar('self.shieldBar', 'self')}
      self.shieldBar:SetAllPoints(self.healthBar)
      self.shieldBar:SetStatusBarColor(0.0, 1.0, 1.0, 0.5)
      self.shieldBar:SetOrientation("VERTICAL")
      self.shieldBar:SetFrameLevel(2)

      ${StatusBar('self.absorbBar', 'self')}
      self.absorbBar:SetAllPoints(self.healthBar)
      self.absorbBar:SetStatusBarColor(1.0, 0.0, 0.0, 0.5)
      self.absorbBar:SetOrientation("VERTICAL")
      self.absorbBar:SetFrameLevel(4)

      self.textName = self.healthBar:CreateFontString(nil, nil, "GameFontNormal")
      self.textName:SetPoint("CENTER", 0, 0)
      self.textName:SetFont(MEDIA:FONT(), 14, "OUTLINE")

      self.textStatus = self.healthBar:CreateFontString(nil, nil, "GameFontNormal")
      self.textStatus:SetFont(MEDIA:FONT(), 12)
      self.textStatus:SetPoint("TOP", self.textName, "BOTTOM", 0, -8)
      ${UnitStatus(context, "self.textStatus")}

      self.healthSpring = CreateSpring(function(spring, health)
        self.healthBar:SetValue(health)
        self.shieldBar:SetValue(health + spring.absorb)
      end, 180, 30, 0.1)

      ${AuraIndicator('self.auraAttonement', 24, 'self')}
      self.auraAttonement:SetPoint("TOPRIGHT", -2, -2)
      self.auraAttonement:SetBackdrop(MEDIA:BACKDROP(true, nil, 0, 0))
      self.auraAttonement:SetBackdropColor(1, 1, 0)
      self.auraAttonement.spellID = 194384

      -- 2 auras top
      -- 3 auras bottom


      --self.healthBar:Hide()
      --self.absorbBar:Hide()
      --self.shieldBar:Hide()


      do
        local icon = CreateFrame("frame", nil, self, "BackdropTemplate")
        icon:SetSize(${buttonWidth}, ${buttonWidth})
        icon:SetPoint("BOTTOM", self, "TOP", 0, 3)
        icon:SetBackdrop(MEDIA:BACKDROP(true, false, 0, 0))
        icon:SetBackdropColor(0, 0, 0, 0.75)
        icon.texture = icon:CreateTexture()
        icon.texture:SetPoint("TOPLEFT", 1, -1)
        icon.texture:SetPoint("BOTTOMRIGHT", -1, 1)
        icon.texture:SetTexture(MEDIA:STATUSBAR())
        icon.texture:SetVertexColor(0, 0.5, 1, 0.5)
      end
      self.buffs = {}
      self.buffs.cursor = 0

      ${context.use(['GUID_SET GUID_MOD UNIT_AURA'], () => `
        self.auraAttonement:Hide()
        for index = 1, 40 do
          local name, icon, count, kind, duration, expiration, source, stealable, _, id = UnitAura(self.unit, index, "HELPFUL")
          if not name then break end
          AuraList_Push(self.buffs, name, icon, id)
          if id == 194384 then
            self.auraAttonement:Show()
            self.auraAttonement.cd:SetCooldown(expiration - duration, duration)
          end
        end


      `)}

      ${context.use(['GUID_SET GUID_MOD UNIT_AURA'], () => `
        self.auraAttonement:Hide()
        self.buffs.cursor = 0
      `)}

      ${context.use(UnitName, name => `self.textName:SetText(${name}:sub(1, 5))`)}
      ${context.use(UnitClassColor, color => `
        local cr, cg, cb = unpack(${color})
        self.healthBar:SetStatusBarColor(cr, cg, cb)
      `)}
      ${context.use(UnitHealthMax, SetMinMaxValues("self.healthBar"))}
      ${context.use(UnitHealthMax, SetMinMaxValues("self.shieldBar"))}
      ${context.use(UnitHealthMax, SetMinMaxValues("self.absorbBar"))}

      ${context.use(["GUID_SET UNIT_HEALTH UNIT_ABSORB_AMOUNT_CHANGED",
        _ => GET`local ${_} = UnitHealth(self.unit)`,
        _ => GET`local ${_} = UnitGetTotalAbsorbs(self.unit)`],
        (health, absorb) => `
          self.healthSpring.absorb = ${absorb}
          self.healthSpring(${health})
      `)}
      ${context.use(["GUID_MOD",
        _ => GET`local ${_} = UnitHealth(self.unit)`,
        _ => GET`local ${_} = UnitGetTotalAbsorbs(self.unit)`],
        (health, absorb) => `
          self.healthSpring.absorb = ${absorb}
          self.healthSpring:stop(${health})
      `)}

      ${context.use(["CUST_BOSS_TARGET", _ => GET`local ${_} = ...`], guid => `
        --print("boss target", ${guid}, self.guid)
      `)}

      ${context.use(UnitHealAbsorb, SetValue("self.absorbBar"))}

      ${RoleIcon(context, 'self.roleIcon', 'self.healthBar', 22)}
      ${RaidTargetIcon(context, 'self.raidIcon', "self.healthBar", 22)}
      ${LeaderIcon(context, 'self.leaderIcon', 'self.healthBar', 18)}
      ${AssistIcon(context, 'self.assistIcon', 'self.healthBar', 18)}
      ${context.use(UnitIsGroupLeader, UnitIsGroupAssistant, GetRaidTargetIndex, () => `
        Stack(self.healthBar, "BOTTOMLEFT", "BOTTOMLEFT", -3, -6, "BOTTOM", "TOP", 0, 0, self.roleIcon, self.raidIcon, self.leaderIcon, self.assistIcon)
      `)}

      ${ResserIcon(context, 'self.resserIcon', 'self.healthBar', 32)}
      self.resserIcon:SetPoint("CENTER", 0, 0)

      ${context.use(["GUID_SET"], () => `RangeChecker:Register(self, true)`)}
      ${context.use(["GUID_MOD"], () => `RangeChecker:Update(self)`)}
      ${context.use(["GUID_REM"], () => `RangeChecker:Unregister(self)`)}
    end
    function OnEvent(self, event, ...)
      ${context.compile()}
    end
  `;
})}

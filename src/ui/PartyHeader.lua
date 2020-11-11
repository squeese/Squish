${template('PartyHeader', (parent, height) => {
  const buttonWidth = 74
  const context = new Context();
  return `
    local self = CreateFrame('frame', 'SquishPartyHeader', ${parent}, 'SecureGroupHeaderTemplate')
    self:SetAttribute('showRaid', true)
    self:SetAttribute('showParty', true)
    self:SetAttribute('showPlayer', true)
    self:SetAttribute('showSolo', true)
    self:SetAttribute('point', 'RIGHT')
    self:SetAttribute('columnAnchorPoint', 'BOTTOM')
    self:SetAttribute('xOffset', -2)
    self:SetAttribute('yOffset', 0)
    self:SetAttribute('groupBy', 'GROUP')
    self:SetAttribute('groupingOrder', '1,2,3,4,5,6,7,8')
    self:SetAttribute('template', 'SecureActionButtonTemplate,BackdropTemplate')
    self:SetAttribute('initialConfigFunction', [[
      self:SetWidth(${buttonWidth})
      self:SetHeight(${height})
      self:GetParent():CallMethod('ConfigureButton', self:GetName())
    ]])

    local UNIT_AURA_HELPFUL = {}
    local UNIT_AURA_HARMFUL = {}
    local positive = {}
    local negative = {}
    --for id, spell in pairs(SPELLS.Positive) do
      --if spell[SPELL_SOURCE] == "UNIT_AURA_HELPFUL" then
        --UNIT_AURA_HELPFUL[id] = {}
        --UNIT_AURA_HELPFUL[id].priority = spell[SPELL_PRIORITY]
        --UNIT_AURA_HELPFUL[id].collection = positive
      --elseif spell[SPELL_SOURCE] == "UNIT_AURA_HARMFUL" then
        --UNIT_AURA_HARMFUL[id] = {}
        --UNIT_AURA_HARMFUL[id].priority = spell[SPELL_PRIORITY]
        --UNIT_AURA_HARMFUL[id].collection = positive
      --end
    --end
    --for id, spell in pairs(SPELLS.Negative) do
      --if spell[SPELL_SOURCE] == "UNIT_AURA_HARMFUL" then
        --UNIT_AURA_HARMFUL[id] = {}
        --UNIT_AURA_HARMFUL[id].priority = spell[SPELL_PRIORITY]
        --UNIT_AURA_HARMFUL[id].collection = negative
      --elseif spell[SPELL_SOURCE] == "UNIT_AURA_HELPFUL" then
        --UNIT_AURA_HELPFUL[id] = {}
        --UNIT_AURA_HELPFUL[id].priority = spell[SPELL_PRIORITY]
        --UNIT_AURA_HELPFUL[id].collection = negative
      --end
    --end

    local function UpdateUnitAuras(button)
      button.auraAttonement:Hide()
      AuraTable_Clear(positive)
      AuraTable_Clear(negative)
      for index = 1, 40 do
        local _, icon, stack, kind, duration, expiration, _, _, _, id = UnitAura(button.unit, index, "HELPFUL")
        if not id then break end
        local entry = UNIT_AURA_HELPFUL[id]
        if entry then
          AuraTable_Insert(entry.collection, entry.priority, index, icon, duration, expiration, nil, stack)
        end
        if id == button.auraAttonement.spellID then
          button.auraAttonement:Show()
          button.auraAttonement.cd:SetCooldown(expiration - duration, duration)
        end
      end
      for index = 1, 40 do
        local _, icon, count, kind, duration, expiration, _, _, _, id, _, boss = UnitAura(button.unit, index, "HARMFUL")
        if not id then break end
        local entry = UNIT_AURA_HARMFUL[id]
        if entry then
          local priority = entry.priority + (boss and 1 or 0) + (CanDispel[kind] and 1 or 0)
          AuraTable_Insert(entry.collection, priority, index, icon, duration, expiration, kind, count)
        else
          local priority = (boss and 1 or 0) + (CanDispel[kind] and 1 or 0)
          AuraTable_Insert(negative, priority, index, icon, duration, expiration, kind, count)
        end
      end
      AuraTable_Write(positive, button.unit, "HELPFUL", button[1], button[2], button[3])
      AuraTable_Write(negative, button.unit, "HARMFUL", button[4], button[5], button[6], button[7])
      button[2]:SetPoint("TOP", button, "BOTTOM", Misc_CountVisible(button[3]) * -13, -1)
      button[5]:SetPoint("BOTTOM", button, "TOP", Misc_CountVisible(button[6], button[7]) * -12.5, 1)
    end

    local OnEvent
    function self:ConfigureButton(name)
      local self = _G[name]
      self:RegisterForClicks('AnyUp')
      self:SetAttribute('*type1', 'target')
      self:SetAttribute('*type2', 'togglemenu')
      self:SetAttribute('toggleForVehicle', true)
      self:SetScript('OnAttributeChanged', OnAttributeChanged)
      self:SetBackdrop(Media:CreateBackdrop(true, nil, 1, 0))
      self:SetBackdropColor(0, 0, 0, 0.75)
      --self:SetBackdropBorderColor(0, 0, 0, 0.75)
      RegisterUnitWatch(self)
      self.handler = OnEvent

      self.background = self:CreateTexture(nil, 'BACKGROUND', nil, -7)
      self.background:SetTexture(Media.STATUSBAR_FLAT)
      self.background:SetVertexColor(1, 1, 1, 0.75)
      self.background:SetPoint("TOPLEFT", -2, 2)
      self.background:SetPoint("BOTTOMRIGHT", 2, -2)
      self.background:Hide()

      ${StatusBar('self.healthBar', 'self')}
      self.healthBar:SetPoint("TOPLEFT", 1, -1)
      self.healthBar:SetPoint("BOTTOMRIGHT", -1, 1)
      self.healthBar:SetOrientation("VERTICAL")
      self.healthBar:SetFrameLevel(3)

      ${StatusBar('self.shieldBar', 'self')}
      self.shieldBar:SetAllPoints(self.healthBar)
      self.shieldBar:SetStatusBarColor(0.0, 1.0, 1.0, 0.75)
      self.shieldBar:SetOrientation("VERTICAL")
      self.shieldBar:SetFrameLevel(2)

      ${StatusBar('self.absorbBar', 'self')}
      self.absorbBar:SetAllPoints(self.healthBar)
      self.absorbBar:SetStatusBarColor(1.0, 0.0, 0.0, 0.5)
      self.absorbBar:SetOrientation("VERTICAL")
      self.absorbBar:SetFrameLevel(4)

      ${context.use(UnitClassColor, color => `
        local cr, cg, cb = unpack(${color})
        self.healthBar:SetStatusBarColor(cr, cg, cb)
      `)}
      ${context.use(UnitHealthMax, SetMinMaxValues("self.healthBar"))}
      ${context.use(UnitHealthMax, SetMinMaxValues("self.shieldBar"))}
      ${context.use(UnitHealthMax, SetMinMaxValues("self.absorbBar"))}
      ${context.use(UnitHealAbsorb, SetValue("self.absorbBar"))}
      self.healthSpring = Spring:Create(function(spring, health)
        self.healthBar:SetValue(health)
        self.shieldBar:SetValue(health + spring.absorb)
      end, 280, 30, 0.1)
      ${context.use(["GUID_SET UNIT_HEALTH UNIT_ABSORB_AMOUNT_CHANGED",
        _ => GET`local ${_} = UnitHealth(self.unit)`,
        _ => GET`local ${_} = UnitGetTotalAbsorbs(self.unit)`],
        (health, absorb) => `
          self.healthSpring.absorb = ${absorb}
          Spring:Update(self.healthSpring, ${health})
      `)}
      ${context.use(["GUID_MOD",
        _ => GET`local ${_} = UnitHealth(self.unit)`,
        _ => GET`local ${_} = UnitGetTotalAbsorbs(self.unit)`],
        (health, absorb) => `
          self.healthSpring.absorb = ${absorb}
          Spring:Stop(self.healthSpring, ${health})
      `)}

      self.textName = self.healthBar:CreateFontString(nil, nil, "GameFontNormal")
      self.textName:SetPoint("CENTER", 0, 0)
      self.textName:SetFont(Media.FONT_VIXAR, 14, "OUTLINE")
      ${context.use(UnitName, name => `self.textName:SetText(${name}:sub(1, 5))`)}

      self.textStatus = self.healthBar:CreateFontString(nil, nil, "GameFontNormal")
      self.textStatus:SetFont(Media.FONT_VIXAR, 12)
      self.textStatus:SetPoint("BOTTOM", self, "BOTTOM", 0, 24)
      ${UnitStatus(context, "self.textStatus")}

      ${AuraIndicator('self.auraAttonement', 20, 'self')}
      self.auraAttonement:SetPoint("TOPRIGHT", -2, -2)
      self.auraAttonement:SetBackdrop(Media:CreateBackdrop(true, nil, 0, 0))
      self.auraAttonement:SetBackdropColor(1, 1, 0)
      self.auraAttonement.spellID = 194384

      ${ResserIcon(context, 'self.resserIcon', 'self.healthBar', 32)}
      self.resserIcon:SetPoint("CENTER", 0, 0)

      ${RoleIcon(context, 'self.roleIcon', 'self.healthBar', 20)}
      ${RaidTargetIcon(context, 'self.raidIcon', "self.healthBar", 22)}
      ${LeaderIcon(context, 'self.leaderIcon', 'self.healthBar', 18)}
      ${AssistIcon(context, 'self.assistIcon', 'self.healthBar', 18)}
      ${context.use(UnitIsGroupLeader, UnitIsGroupAssistant, GetRaidTargetIndex, () => `
        Misc_Stack(self.healthBar, "BOTTOMLEFT", "BOTTOMLEFT", -3, -6, "BOTTOM", "TOP", 0, 0, self.roleIcon, self.raidIcon, self.leaderIcon, self.assistIcon)
      `)}

      self.__tick = Misc_RangeChecker
      ${context.use(["GUID_SET"], () => `Ticker:Add(self, true)`)}
      ${context.use(["GUID_MOD"], () => `self:__tick()`)}
      ${context.use(["GUID_REM"], () => `Ticker:Remove(self)`)}

      -- large buff icon
      table.insert(self, CreateAuraIcon_Bar(self, 37, 16))
      self[1]:SetPoint("BOTTOM", self, "BOTTOM", 0, 4)

      -- smaller buff icons
      table.insert(self, CreateAuraIcon_Bar(self, 25))
      table.insert(self, CreateAuraIcon_Bar(self, 25))
      Misc_Stack(self, "TOP", "BOTTOM", 0, -1, "LEFT", "RIGHT", 1, 0, self[2], self[3])

      -- large debuff icons
      table.insert(self, CreateAuraIcon_Bar(self, ${buttonWidth-2}, 28, 28))
      self[4]:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 1, 26)
      self[4].priority = 5

      -- small debuff icons
      table.insert(self, CreateAuraIcon_Bar(self, 24))
      table.insert(self, CreateAuraIcon_Bar(self, 24))
      table.insert(self, CreateAuraIcon_Bar(self, 24))
      Misc_Stack(self, "BOTTOM", "TOP", -25, 1, "LEFT", "RIGHT", 1, 0, self[5], self[6], self[7])
      for i = 5, 7 do
        self[i].priority = 1
      end

      ${context.use(['GUID_SET GUID_MOD UNIT_AURA'], () => `UpdateUnitAuras(self)`)}
      ${context.use(['GUID_SET GUID_MOD PLAYER_TARGET_CHANGED'], () => `
        if UnitIsUnit(self.unit, "playertarget") then
          self.background:Show()
        else
          self.background:Hide()
        end
      `)}
    end
    function OnEvent(self, event, ...)
      ${context.compile()}
    end
  `;
})}

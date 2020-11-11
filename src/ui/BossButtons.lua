${template('BossButtons', (parent, width, height) => {
  const context = new Context();
  return `

    local auras = {}
    local function UpdateUnitAuras(self, icon, castbar)
      AuraTable_Clear(auras)
      for index = 1, 40 do
        local _, icon, count, kind, duration, expiration, source = UnitAura(self.unit, index, "HELPFUL")
        if not icon then break end
        if source:sub(1, 4) == "boss" then
          AuraTable_Insert(auras, 1, index, icon, duration, expiration, kind, count)
          break
        end
      end
      AuraTable_Write(auras, self.unit, "HELPFUL", icon)
      if icon:IsShown() then
        castbar:SetPoint("BOTTOMLEFT", icon, "BOTTOMRIGHT", 2, 0)
      else
        castbar:SetPoint("BOTTOMLEFT", self, "BOTTOMRIGHT", 2, 0)
      end
    end


    local function CreateBossButton(unit)
      local ${UnitButton('self', parent)}
      self:SetSize(${width}, ${height})

      local portrait = CreateFrame('PlayerModel', nil, self)
      portrait:SetPoint("TOPLEFT", 1, -1)
      portrait:SetPoint("BOTTOMRIGHT", self, "BOTTOMLEFT", ${height}, 1)
      ${SetPortrait(context, "portrait")}

      local ${RaidTargetIcon(context, 'raidIcon', "portrait", 32)}
      raidIcon:SetPoint("CENTER", portrait, "LEFT", 0, 0)

      local ${StatusBar('powerBar')}
      powerBar:SetPoint("TOPLEFT", ${height+1}, 0)
      powerBar:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, -16) 
      powerBar:SetMinMaxValues(0, 1)
      ${context.use(UnitPowerMax, SetMinMaxValues("powerBar"))}
      ${context.use(UnitPower, SetValue("powerBar"))}
      ${context.use(UnitPowerColor, color => `powerBar:SetStatusBarColor(unpack(${color}))`)}

      local powerFont = powerBar:CreateFontString(nil, nil, "GameFontNormal")
      powerFont:SetPoint("CENTER")
      ${context.use(UnitPowerMax, UnitPower, (max, val) => `powerFont:SetText((${max} and ${max} > 0) and Math_Ceil(${val}/${max}*100) or "")`)}

      local ${StatusBar('healthBar')}
      healthBar:SetPoint("TOPLEFT", powerBar, "BOTTOMLEFT", 0, -1)
      healthBar:SetPoint("BOTTOMRIGHT", 0, 0)
      ${context.use(UnitHealthMax, SetMinMaxValues("healthBar"))}
      ${context.use(UnitHealth, SetValue("healthBar"))}
      ${context.use(
        ["GUID_SET GUID_MOD", _ => GET`local ${_} = ReactionColor("player", self.unit)`],
        reaction => `healthBar:SetStatusBarColor(unpack(${reaction}))`
      )}

      local healthFont = healthBar:CreateFontString(nil, nil, "GameFontNormal")
      healthFont:SetPoint("TOP", 0, -2)
      ${context.use(UnitHealthMax, UnitHealth, (max, val) => `healthFont:SetText(Math_Ceil(${val}/${max}*100))`)}

      local nameFont = healthBar:CreateFontString(nil, nil, "GameFontNormal")
      nameFont:SetPoint("BOTTOM")
      ${context.use(UnitName, SetText("nameFont"))}

      local castbar = CreateCastBar(${parent}, unit, 36)
      castbar:SetSize(300, 36)

      local buffIcon = CreateAuraIcon_Bar(self, 36, 16)
      buffIcon:SetPoint("BOTTOMLEFT", self, "BOTTOMRIGHT", 2, 0)
      local _, _, icon = GetSpellInfo(17)
      buffIcon.texture:SetTexture(icon)
      ${context.use(['GUID_SET GUID_MOD UNIT_AURA'], () => `UpdateUnitAuras(self, buffIcon, castbar)`)}

      function self:handler(event, ...)
        ${context.compile()}
      end
      self:SetAttribute("unit", unit)
      return self
    end

    local function CreateBossFrames(...)
      local tbl = {...}
      for i = 1, 5 do
        local unit = i <= 5 and "boss"..i or "player"
        local button = CreateBossButton(unit)
        --local castbar = CreateCastBar(${parent}, unit, 32)
        --castbar:SetPoint("TOPLEFT", button, "TOPRIGHT", 8, -16)
        --castbar:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 300, 0)
        table.insert(tbl, button)
      end
      Misc_Stack(unpack(tbl))
      for i = 4, 0, -1 do
        RegisterUnitWatch(tbl[#tbl-i])
      end
      CreateBossButton = nil
      CreateBossFrames = nil
    end
  `;
})}

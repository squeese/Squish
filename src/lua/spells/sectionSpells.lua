local Section_Spells = { title = "Spells", icon = 237542 }
do


  local function OnEnter_Row(self)
    if self.spellID then
      local r, g, b = self:GetBackdropColor()
      self:SetBackdropColor(r, g, b, 0.35)
      GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMLEFT')
      GameTooltip:SetSpellByID(self.spellID)
      GameTooltip:Show()
    end
  end

  local function OnLeave_Row(self)
    local r, g, b = self:GetBackdropColor()
    self:SetBackdropColor(r, g, b, 0.25)
    GameTooltip:Hide()
  end

  local function OnClick_CheckButton(button)
    local row = button:GetParent()
    SquishData.SpellsData[row.spellID][button.field] = not SquishData.SpellsData[row.spellID][button.field]
    Section_Spells.UpdateRow(row:GetParent(), row, row.spellID)
  end

  local info = UIDropDownMenu_CreateInfo()
  local function InitializeDropdown(self, level)
    if level == 1 then
      info.isTitle = true
      info.notCheckable = true
      info.hasArrow = false
      info.text = self.title
      UIDropDownMenu_AddButton(info)
      info.isTitle = false
      info.disabled = false
      info.text = "Source"
      info.hasArrow = true
      UIDropDownMenu_AddButton(info, 1)
    elseif level == 2 then
      info.isTitle = false
      info.hasArrow = false
      info.notCheckable = false
      info.checked = false
      info.text = "UNIT_AURA, HELPFUL"
      UIDropDownMenu_AddButton(info, 2)
      info.checked = true
      info.text = "UNIT_AURA, HARMFUL"
      UIDropDownMenu_AddButton(info, 2)
    end
  end

  local dropdown
  local function OnClick_Row(self, button)
    if button == "RightButton" then
      dropdown.title = GetSpellInfo(self.spellID)
      ToggleDropDownMenu(1, nil, dropdown, "cursor", 0, 0)
    end
  end

  function Section_Spells:SetupRows()
    dropdown = CreateFrame("frame", nil, self, "UIDropDownMenuTemplate")
    UIDropDownMenu_Initialize(dropdown, InitializeDropdown, "MENU")

    local height = self[1]:GetHeight()
    self.name = self.fontPool:Acquire()
    self.name:SetFont(MEDIA:FONT(), 18)
    self.name:SetPoint("TOPLEFT", self, "TOPLEFT", 8+height, -12)
    self.name:SetText("Spellname")
    self.name:Show()

    self.spell = self.fontPool:Acquire()
    self.spell:SetFont(MEDIA:FONT(), 18)
    self.spell:SetPoint("TOPLEFT", self, "TOPLEFT", 200, -12)
    self.spell:SetText("SpellID")
    self.spell:Show()

    self.personal = self.fontPool:Acquire()
    self.personal:SetFont(MEDIA:FONT(), 18)
    self.personal:SetPoint("TOPLEFT", self, "TOPRIGHT", -128, -12)
    self.personal:SetText("Personal")
    self.personal:Show()

    for index, row in ipairs(self) do
      row.icon = self.texturePool:Acquire()
      row.icon:SetPoint("TOPLEFT", row, "TOPLEFT", 0, 0)
      row.icon:SetPoint("BOTTOMRIGHT", row, "TOPLEFT", row:GetHeight(), -row:GetHeight())
      row.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
      row.icon:SetParent(row)
      row.icon:Show()

      -- Something(row, "Icon", )

      row.personal = self.checkPool:Acquire()
      row.personal:SetHitRectInsets(0, 0, 0, 0)
      row.personal:SetPoint("RIGHT", row, "RIGHT", -4-row:GetHeight(), 0)
      row.personal:SetSize(row:GetHeight(), row:GetHeight())
      row.personal:SetScript("OnClick", OnClick_CheckButton)
      row.personal.field = "personal"
      row.personal:Show()
      row.personal:SetParent(row)

      row.spell = self.fontPool:Acquire()
      row.spell:SetFont(MEDIA:FONT(), 14)
      row.spell:SetPoint("LEFT", row.icon, "RIGHT", 8, 0)
      row.spell:SetParent(row)
      row.spell:Show()

      row.name = self.fontPool:Acquire()
      row.name:SetFont(MEDIA:FONT(), 14)
      row.name:SetPoint("LEFT", row.icon, "LEFT", 200, 0)
      row.name:SetParent(row)
      row.name:Show()

      row:SetScript("OnEnter", OnEnter_Row)
      row:SetScript("OnLeave", OnLeave_Row)
      --row:RegisterForClicks("anyup")
      row:SetScript("OnMouseUp", OnClick_Row)
      row:Show()
    end
  end

  local function comparator(a, b)
    return SquishData.SpellsData[a].class < SquishData.SpellsData[b].class
  end
  function Section_Spells:PopulateData(DATA)
    for spell, _ in pairs(SquishData.SpellsData) do
      table.insert(DATA, spell)
    end
    table.sort(DATA, comparator)
  end

  local fallbackColor = { r=0, g=0, b=0 }
  function Section_Spells:UpdateRow(row, spell)
    if spell then
      local name, _, icon = GetSpellInfo(spell)
      local class = SquishData.SpellsData[spell].class
      local personal = SquishData.SpellsData[spell].personal
      local color = RAID_CLASS_COLORS[class] or fallbackColor 
      row.spellID = spell
      row.icon:SetTexture(icon)
      row.spell:SetText(spell)
      row.name:SetText(name)
      row.personal:SetChecked(personal)
      row:SetBackdropColor(color.r, color.g, color.b, 0.25)
      --row.personal:SetChecked(SquishData.spells[spell][FIELD_PERSONAL])
      row:Show()
    else
      row.spellID = nil
      row:Hide()
    end
  end

  function Section_Spells:CleanupRows()
    self.fontPool:Release(self.name)
    self.fontPool:Release(self.spell)
    self.fontPool:Release(self.personal)
    self.name = nil
    self.spell = nil
    self.personal = nil
    for index, row in ipairs(self) do
      self.texturePool:Release(row.icon)
      self.checkPool:Release(row.personal)
      self.fontPool:Release(row.spell)
      self.fontPool:Release(row.name)
      row.personal = nil
      row.icon = nil
      row.spell = nil
      row.name = nil
      row.spellID = nil
      row:SetScript("OnEnter", nil)
      row:SetScript("OnLeave", nil)
      row:Hide()
    end
  end
end

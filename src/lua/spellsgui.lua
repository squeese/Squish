do
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
      --for i = 1, NUMROWS do
        --if self[i] == row then
          --updateData(row, CURSOR+i-1)
          --return
        --end
      --end
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






  local frame = CreateFrame("frame", nil, UIParent, "BackdropTemplate")
  frame:RegisterEvent("VARIABLES_LOADED")
  frame:SetScript("OnEvent", function(self)
    if not SquishData then
      SquishData = {}
    end
    if not SquishData.SpellsData then
      SquishData.SpellsData = {}
    end
    self:UnregisterAllEvents()
    -- self:RegisterEvent("UNIT_AURA")
    -- self:RegisterEvent("UNIT_SPELLCAST_START")
    -- self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    self:SetScript("OnEvent", OnEvent_SpellCollector)

    local WIDTH = 1024
    local HEIGHT = 1025
    local NUMROWS = 32
    local ROWHEIGHT = HEIGHT/NUMROWS
    local CURSOR = 1
    local CURSOR_MAX = 1
    local DATA = {}
    local SECTION = 1
    local SECTIONS = {
      Section_Spells,
      --{"Spells", 237542, PrepareRows_Spells, UpdateRows_Spells},
      -- {"Scanned", 134952},
    }
    self:SetSize(WIDTH, HEIGHT+8+ROWHEIGHT)
    self:SetPoint("CENTER", 0, 0)
    self:SetBackdrop(MEDIA:BACKDROP(true, false, 1, 0))
    self:SetBackdropColor(0, 0, 0, 0.7)
    self:SetBackdropBorderColor(0, 0, 0, 1)
    self:SetFrameStrata("HIGH")
    self:EnableMouseWheel(true)
    self:SetScale(0.533333333 / UIParent:GetScale())
    self:Hide()
    self.buttonPool = CreateFramePool("button", self, "UIPanelButtonTemplate")
    self.checkPool = CreateFramePool("checkbutton", self, "OptionsCheckButtonTemplate")
    self.texturePool = CreateTexturePool(self)
    self.fontPool = CreateFontStringPool(self, nil, nil, 'GameFontNormal')

    for rowIndex = 1, NUMROWS do
      local row = CreateFrame("frame", nil, frame, "BackdropTemplate")
      row:SetSize(WIDTH-32, ROWHEIGHT-1)
      row:SetBackdrop(MEDIA:BACKDROP(true, true, 1, 0))
      row.color = rowIndex % 2 == 0 and 0.46 or 0.54
      row:SetBackdropColor(0, 0, 0, row.color)
      row:SetBackdropBorderColor(0, 0, 0, 0)
      if rowIndex == 1 then
        row:SetPoint("TOPLEFT", 4, -4-ROWHEIGHT)
      else
        row:SetPoint("TOPLEFT", self[rowIndex-1], "BOTTOMLEFT", 0, -1)
      end
      table.insert(self, row)
      row:Hide()
    end

    local OnMouseWheel
    local updateScroll
    local OnClick_CloseGUI

    do
      local close = CreateFrame("button", nil, self, "UIPanelButtonTemplate")
      close:SetSize(32, 32)
      close:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 2, 1)
      close:SetText("X")
      function OnClick_CloseGUI()
        SquishData.SpellsGUIOpen = false
        SECTIONS[SECTION].CleanupRows(self)
        self:Hide()
      end
      close:SetScript("OnClick", OnClick_CloseGUI)
    end

    do
      local scrollbar = CreateFrame("frame", nil, frame, "BackdropTemplate")
      scrollbar:SetBackdrop(MEDIA:BACKDROP(true, nil, 0, 0))
      scrollbar:SetBackdropColor(0.5, 0.4, 0.8, 0.3)
      scrollbar:EnableMouse(true)
      scrollbar:SetWidth(20)
      function updateScroll()
        scrollbar:SetPoint("TOPRIGHT", -4, -4-ROWHEIGHT-(CURSOR-1)*HEIGHT/#DATA)
        scrollbar:SetHeight(math.min(1, NUMROWS/#DATA) * HEIGHT)
      end
      scrollbar:SetScript("OnEnter", function(self)
        self:SetBackdropColor(0.5, 0.4, 0.8, 0.7)
      end)
      local function OnLeave(self)
        self:SetBackdropColor(0.5, 0.5, 0.8, 0.3)
      end
      local function OnMouseUp(self)
        self:SetScript("OnUpdate", nil)
        self:SetScript("OnMouseUp", nil)
        self:SetScript("OnLeave", OnLeave)
        OnLeave(self)
      end
      local function OnUpdate(self)
        local position = select(2, GetCursorPosition())
        local offset = position - self.start
        local delta
        if offset < 0 then
          delta = math.ceil(offset / self.height)
        else
          delta = math.floor(offset / self.height)
        end
        if delta ~= 0 then
          self.start = self.start + delta * self.height
          local sign = delta < 0 and -1 or 1
          for i = delta, sign, sign*-1 do
            OnMouseWheel(frame, sign)
          end
        end
      end
      local function OnMouseDown(self)
        self.height = (HEIGHT/#DATA) * UIParent:GetScale()
        self.start = select(2, GetCursorPosition())
        self:SetScript("OnUpdate", OnUpdate)
        self:SetScript("OnMouseUp", OnMouseUp)
        self:SetScript("OnLeave", nil)
      end
      scrollbar:SetScript("OnLeave", OnLeave)
      scrollbar:SetScript("OnMouseDown", OnMouseDown)
    end

    do
      local buttons = {}
      local function OnClick(button)
        buttons[SECTION]:SetAlpha(0.5)
        buttons[SECTION]:SetHeight(20)
        buttons[SECTION].icon:SetTexCoord(0.1, 0.9, 0.1, 0.6)
        SECTION = button.index
        SquishData.SpellsGUISection = button.index
        button:SetAlpha(1)
        button:SetHeight(32)
        button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        for i = #DATA, 1, -1 do DATA[i] = nil end
        SECTIONS[SECTION].SetupRows(self)
        SECTIONS[SECTION].PopulateData(self, DATA)
        CURSOR = 1
        CURSOR_MAX = math.max(1, #DATA-NUMROWS+1)
        for i = 1, NUMROWS do
          SECTIONS[SECTION].UpdateRow(self, self[i], DATA[i])
        end
        updateScroll()
      end
      local function OnEnter(self)
        self:SetAlpha(1)
      end
      local function OnLeave(self)
        if self.index == SECTION then return end
        self:SetAlpha(0.5)
      end
      for index = 1, #SECTIONS do
        local button = CreateFrame("button", nil, self, "BackdropTemplate")
        button:SetSize(32, 32)
        button:SetBackdrop(MEDIA:BACKDROP(true, nil, 0, -1))
        button:SetBackdropColor(0, 0, 0, 0.75)
        button:SetAlpha(0.5)
        button:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 1+(index-1)*32, 1)
        button:SetHeight(20)
        button.icon = button:CreateTexture()
        button.icon:SetAllPoints()
        button.icon:SetTexture(SECTIONS[index].icon)
        button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.6)
        button.index = index
        button:RegisterForClicks("anyup")
        --button:SetScript("OnClick", OnClick)
        --button:SetScript("OnEnter", OnEnter)
        --button:SetScript("OnLeave", OnLeave)
        table.insert(buttons, button)
      end
      if SquishData.SpellsGUIOpen then
        self:Show()
        OnClick(buttons[SECTION])
      end
      _G[name] = {}
      _G[name].ToggleSpellsGUI = function()
        SquishData.SpellsGUIOpen = not SquishData.SpellsGUIOpen
        if SquishData.SpellsGUIOpen then
          self:Show()
          OnClick(buttons[SECTION])
        else
          OnClick_CloseGUI()
        end
      end
    end

    function OnMouseWheel(self, delta)
      if delta < 0 then -- up
        if (CURSOR - delta) > CURSOR_MAX then return end
        self[2]:SetPoint("TOPLEFT", self, "TOPLEFT", 4, -4-ROWHEIGHT)
        self[1]:SetPoint("TOPLEFT", self[NUMROWS], "BOTTOMLEFT", 0, -1)
        SECTIONS[SECTION].UpdateRow(self, self[1], DATA[CURSOR+NUMROWS])
        --updateData(frame[1], CURSOR+NUMROWS)
        table.insert(self, self[1])
        table.remove(self, 1)
        CURSOR = CURSOR - delta
      else
        if (CURSOR - delta) < 1 then return end
        CURSOR = CURSOR - delta
        self[NUMROWS]:SetPoint("TOPLEFT", self, "TOPLEFT", 4, -4-ROWHEIGHT)
        self[1]:SetPoint("TOPLEFT", self[NUMROWS], "BOTTOMLEFT", 0, -1)
        SECTIONS[SECTION].UpdateRow(self, self[NUMROWS], DATA[CURSOR])
        --updateData(self[NUMROWS], CURSOR)
        table.insert(self, 1, self[NUMROWS])
        table.remove(self)
      end
      updateScroll()
    end
    self:SetScript('OnMouseWheel', OnMouseWheel)
  end)
end
      --[[
      row.personal = CreateFrame("checkbutton", nil, row, "OptionsCheckButtonTemplate")
      row.personal:SetHitRectInsets(0, 0, 0, 0)
      row.personal:SetScript("OnClick", OnClick)
      row.personal.field = FIELD_PERSONAL
      --row.casting = CreateFrame("checkbutton", nil, row, "OptionsCheckButtonTemplate")
      --row.casting:SetHitRectInsets(0, 0, 0, 0)
      --row.casting:SetScript("OnClick", OnClick)
      --row.warning = CreateFrame("checkbutton", nil, row, "OptionsCheckButtonTemplate")
      --row.warning:SetHitRectInsets(0, 0, 0, 0)
      --row.warning:SetScript("OnClick", OnClick)
      Stack(row, "RIGHT", "RIGHT", -32, 0, "RIGHT", "LEFT", -32, 0, row.personal)
      ]]

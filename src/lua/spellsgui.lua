do
  local WIDTH = 1024
  local HEIGHT = 768
  local NUMROWS = 24
  local ROWHEIGHT = HEIGHT/NUMROWS
  local SECTION = 1
  local CURSOR = 1
  local CURSOR_MAX = 1
  local DATA = {}
  local FIELD_SECTION = 1
  local FIELD_PERSONAL = 2
  local SECTIONS = {
    {"Battle Res", 237542},
    {"Tank", 134952},
    {"Damage", 136224},
    {"Dispel", 135894},
    {"HardCC", 136071},
    {"RaidCD", 2565244},
    {"SoftCC", 132310},
    {"Healing", 135907},
    {"Utility", 134062},
    {"External", 135966},
    {"Immunity", 524354},
    {"Personal", 132336},
    {"STHardCC", 134400},
    {"STSoftCC", 134400},
    {"Interrupt", 135856},
  }

  local frame = CreateFrame("frame", nil, UIParent, "BackdropTemplate")
  frame:RegisterEvent("VARIABLES_LOADED")
  frame:SetScript("OnEvent", function(self)
    self:UnregisterAllEvents()
    self:SetScript("OnEvent", nil)
    self:SetSize(WIDTH, HEIGHT+8)
    self:SetPoint("CENTER", 0, 0)
    self:SetBackdrop(MEDIA:BACKDROP(true, true, 1, 0))
    self:SetBackdropColor(0, 0, 0, 0.7)
    self:SetBackdropBorderColor(0, 0, 0, 1)
    self:SetFrameStrata("HIGH")
    self:EnableMouseWheel(true)
    self:Hide()
    SECTION = SquishData.SpellsGUISection or 1

    local close = CreateFrame("button", nil, self, "UIPanelButtonTemplate")
    close:SetSize(32, 32)
    close:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 2, 1)
    close:SetText("X")
    close:SetScript("OnClick", function(self)
      SquishData.SpellsGUIOpen = false
      frame:Hide()
    end)

    local function updateData(row, index)
      local spell = DATA[index]
      if spell then
        local name, _, icon = GetSpellInfo(spell)
        row.spell = spell
        row.icon:SetTexture(icon)
        row.name:SetText(name)
        row.personal:SetChecked(SquishData.spells[spell][FIELD_PERSONAL])
        row:Show()
      else
        row:Hide()
      end
    end

    local function OnMouseWheel(self, delta)
      if delta < 0 then -- up
        if (CURSOR - delta) > CURSOR_MAX then return end
        frame[2]:SetPoint("TOPLEFT", frame, "TOPLEFT", 4, -4)
        frame[1]:SetPoint("TOPLEFT", frame[NUMROWS], "BOTTOMLEFT", 0, 0)
        updateData(frame[1], CURSOR+NUMROWS)
        table.insert(frame, frame[1])
        table.remove(frame, 1)
        CURSOR = CURSOR - delta
      else
        if (CURSOR - delta) < 1 then return end
        CURSOR = CURSOR - delta
        frame[NUMROWS]:SetPoint("TOPLEFT", frame, "TOPLEFT", 4, -4)
        frame[1]:SetPoint("TOPLEFT", frame[NUMROWS], "BOTTOMLEFT", 0, 0)
        updateData(frame[NUMROWS], CURSOR)
        table.insert(frame, 1, frame[NUMROWS])
        table.remove(frame)
      end
      updateScroll()
    end
    frame:SetScript('OnMouseWheel', OnMouseWheel)

    do
      local function OnEnter(self)
        self:SetBackdropColor(0, 0, 0, 0.6)
        if not self.spell then return end
        GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMLEFT')
        GameTooltip:SetSpellByID(self.spell)
        GameTooltip:Show()
      end
      local function OnLeave(self)
        self:SetBackdropColor(0, 0, 0, self.color)
        GameTooltip:Hide()
      end
      local function OnClick(button)
        local row = button:GetParent()
        if SquishData.spells[row.spell][button.field] then
          SquishData.spells[row.spell][button.field] = nil
        else
          SquishData.spells[row.spell][button.field] = true
        end
        for i = 1, NUMROWS do
          if self[i] == row then
            updateData(row, CURSOR+i-1)
            return
          end
        end
      end
      for rowIndex = 1, NUMROWS do
        local row = CreateFrame("frame", nil, frame, "BackdropTemplate")
        row:SetSize(WIDTH-32, ROWHEIGHT)
        row:SetBackdrop(MEDIA:BACKDROP(true, false, 1, 1))
        row.color = rowIndex % 2 == 0 and 0.46 or 0.54
        row:SetBackdropColor(0, 0, 0, row.color)
        row:SetBackdropBorderColor(0, 0, 0, 0)
        if rowIndex == 1 then
          row:SetPoint("TOPLEFT", 4, -4)
        else
          row:SetPoint("TOPLEFT", self[rowIndex-1], "BOTTOMLEFT", 0, 0)
        end
        row.icon = row:CreateTexture()
        row.icon:SetPoint("TOPLEFT", 1, -1)
        row.icon:SetPoint("BOTTOMRIGHT", row, "TOPLEFT", ROWHEIGHT-2, -ROWHEIGHT+2)
        row.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        -- NAME
        row.name = row:CreateFontString(nil, nil, "GameFontNormal")
        row.name:SetFont(MEDIA:FONT(), 10)
        row.name:SetPoint("LEFT", row.icon, "RIGHT", 8, 0)

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
        row:SetScript("OnEnter", OnEnter)
        row:SetScript("OnLeave", OnLeave)
        table.insert(self, row)
        row:Hide()
      end
    end

    do
      local scrollbar = CreateFrame("frame", nil, frame, "BackdropTemplate")
      scrollbar:SetBackdrop(MEDIA:BACKDROP(true, nil, 0, 0))
      scrollbar:SetBackdropColor(0, 0, 0, 0.5)
      scrollbar:EnableMouse(true)
      scrollbar:SetWidth(20)
      function updateScroll()
        scrollbar:SetPoint("TOPRIGHT", -4, -4-(CURSOR-1)*HEIGHT/#DATA)
        scrollbar:SetHeight(math.min(1, NUMROWS/#DATA) * HEIGHT)
      end
      scrollbar:SetScript("OnEnter", function(self)
        self:SetBackdropColor(0.5, 0.5, 0.5, 0.5)
      end)
      local function OnLeave(self)
        self:SetBackdropColor(0, 0, 0, 0.5)
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
        for i = #DATA, 1, -1 do
          DATA[i] = nil
        end
        for spell, data in pairs(SquishData.spells) do
          if data[FIELD_SECTION] == SECTION then
            table.insert(DATA, spell)
          end
        end
        CURSOR = 1
        CURSOR_MAX = math.max(1, #DATA-NUMROWS+1)
        for i = 1, NUMROWS do
          updateData(self[i], i)
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
        button.icon:SetTexture(SECTIONS[index][2])
        button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.6)
        button.index = index
        button:RegisterForClicks("anyup")
        button:SetScript("OnClick", OnClick)
        button:SetScript("OnEnter", OnEnter)
        button:SetScript("OnLeave", OnLeave)
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
          frame:Show()
          OnClick(buttons[SECTION])
        else
          frame:Hide()
        end
      end
    end
  end)
end

local Section_Positive = { title = "Positive", icon = 134468 }
do
  local data = nil
  local UpdateRow
  local lastEdited = nil

  local function OnClick_IncrementPriority(button)
    local row = button:GetParent()
    local index = row:GetIndex()
    local priority = SPELLS.StatusPositive[data[index]][SPELLS_STATUS_POSITIVE_FIELD_PRIORITY]
    SPELLS.StatusPositive[data[index]][SPELLS_STATUS_POSITIVE_FIELD_PRIORITY] = priority + 1
    UpdateRow(nil, row, index)
  end

  local function OnClick_DecrementPriority(button)
    local row = button:GetParent()
    local index = row:GetIndex()
    local priority = SPELLS.StatusPositive[data[index]][SPELLS_STATUS_POSITIVE_FIELD_PRIORITY]
    SPELLS.StatusPositive[data[index]][SPELLS_STATUS_POSITIVE_FIELD_PRIORITY] = Math_Max(1, priority - 1)
    UpdateRow(nil, row, index)
  end

  local function SetClassFilter(self, index)
    SquishData.GUISectionPositive.filterClass = index
    self.classFilter:SetSelectedValue(index or 0)
    self:UpdateData()
  end

  local function SetSource(row, source)
    local index = row:GetIndex()
    SPELLS.StatusPositive[data[index]][SPELLS_STATUS_POSITIVE_FIELD_SOURCE] = source
    UpdateRow(nil, row, index)
  end

  local function SetClass(row, class)
    local index = row:GetIndex()
    SPELLS.StatusPositive[data[index]][SPELLS_STATUS_POSITIVE_FIELD_CLASS] = class
    UpdateRow(nil, row, index)
  end

  local function SetOption(row, value)
    local index = row:GetIndex()
    SPELLS.StatusPositive[data[index]] = nil
    Section_Positive:UpdateData()
  end

  local function SetNotes(input)
    local row = input:GetParent()
    local index = row:GetIndex()
    local value = input:GetText()
    input:ClearFocus()
    input:SetText(input.__initial)
    SPELLS.StatusPositive[data[index]][SPELLS_STATUS_POSITIVE_FIELD_NOTES] = value
    UpdateRow(nil, row, index)
  end

  local function CreateRow(scroll, row, rowIndex)
    Table_Insert(row, row:AcquireIcon())
    Table_Insert(row, row:AcquireFontString(nil, 3))
    Table_Insert(row, row:AcquireFontString(nil, 1, "RIGHT"))
    Table_Insert(row, row:AcquireButton(row:GetHeight(), nil, OnClick_IncrementPriority))
    Table_Insert(row, row:AcquireButton(row:GetHeight(), nil, OnClick_DecrementPriority))
    Table_Insert(row, row:AcquireInput(nil, 3, SetNotes))
    Table_Insert(row, row:AcquireDropdown(250, nil, InitSourceDropdown, row, SetSource))
    Table_Insert(row, row:AcquireFontString(128))
    Table_Insert(row, row:AcquireDropdown(200, nil, InitClassDropdown, row, SetClass))
    Table_Insert(row, row:AcquireDropdown(row:GetHeight(), nil, InitOptionsDropdown, row, SetOption))
    row:StackElements(4, unpack(row))
  end

  function UpdateRow(scroll, row, index)
    local name, _, icon = GetSpellInfo(data[index])
    local source = SPELLS.StatusPositive[data[index]][SPELLS_STATUS_POSITIVE_FIELD_SOURCE]
    local prio   = SPELLS.StatusPositive[data[index]][SPELLS_STATUS_POSITIVE_FIELD_PRIORITY]
    local class  = SPELLS.StatusPositive[data[index]][SPELLS_STATUS_POSITIVE_FIELD_CLASS]
    local notes  = SPELLS.StatusPositive[data[index]][SPELLS_STATUS_POSITIVE_FIELD_NOTES]
    local edited = data[index] == lastEdited
    local ICON, NAME, PRIOVAL, PRIOUP, PRIODN, NOTES, SOURCE, SPELLID, CLASS, _ = unpack(row)
    ICON:SetTexture(icon)
    NAME:SetText(name)
    PRIOVAL:SetText(prio)
    PRIOUP.icon:SetTexture([[Interface\\BUTTONS\\Arrow-Up-Down]])
    PRIODN.icon:SetTexture([[Interface\\BUTTONS\\Arrow-Down-Down]])
    NOTES:SetText(notes or "")
    SOURCE:SetSelectedID(source)
    SPELLID:SetText(data[index])
    CLASS:SetSelectedID(class)
    if class then
      local color = RAID_CLASS_COLORS[SPELLS_CLASS_VALUES[class]]
      local alpha = edited and 0.6 or 0.3
      row:SetBackdropColor(color.r, color.g, color.b, alpha)
    end
  end

  local function ReleaseRow(scroll, row)
    while #row > 0 do
      row:ReleaseElement(Table_Remove(row))
    end
  end

  local function SortData(a, b)
    local classA = SPELLS.StatusPositive[a][SPELLS_STATUS_POSITIVE_FIELD_CLASS]
    local classB = SPELLS.StatusPositive[b][SPELLS_STATUS_POSITIVE_FIELD_CLASS]
    if classA == classB then
      local priorityA = SPELLS.StatusPositive[a][SPELLS_STATUS_POSITIVE_FIELD_PRIORITY]
      local priorityB = SPELLS.StatusPositive[b][SPELLS_STATUS_POSITIVE_FIELD_PRIORITY]
      if priorityA == priorityB then
        return a < b
      end
      return priorityA > priorityB
    end
    return classA < classB
  end

  function Section_Positive:UpdateData()
    for k in pairs(data) do data[k] = nil end
    local filterClass = SquishData.GUISectionPositive.filterClass
    for id, spell in pairs(SPELLS.StatusPositive) do
      if not filterClass or filterClass == spell[SPELLS_STATUS_POSITIVE_FIELD_CLASS] then
        Table_Insert(data, id)
      end
    end
    Table_Sort(data, SortData)
    self.scroll:Init(32, #data, 32)
  end

  local function Footer_Update(header)
    local INPUT, NAME, SOURCE, CLASS, ADD, RESET = unpack(header)
    NAME:SetText(header.__spellName)
    SOURCE:SetSelectedID(header.__source)
    CLASS:SetSelectedID(header.__class)
    ADD:SetText("Add")
    RESET:SetText("Reset")
    if header.__valid then
      ADD:Enable()
      RESET:Enable()
    else
      ADD:Disable()
      RESET:Disable()
    end
  end
  local function Footer_SetSpell(input)
    local value = input:GetText()
    local name, _, _, _, _, _, spellId = GetSpellInfo(value)
    local footer = input:GetParent()
    footer.__spellId = spellId
    footer.__spellName = name
    footer.__valid = name ~= nil
    Footer_Update(footer)
  end
  local function Footer_SetSource(footer, value)
    footer.__source = value
    Footer_Update(footer)
  end
  local function Footer_SetClass(footer, value)
    footer.__class = value
    Footer_Update(footer)
  end
  local function Footer_OnClickReset(button)
    local footer = button:GetParent()
    footer[1]:SetText("")
    footer.__spellName = ""
    footer.__spellId = nil
    footer.__source = 1
    footer.__class = #SPELLS_CLASS_VALUES
    footer.__valid = false
    Footer_Update(footer)
  end
  local function Footer_OnClickAdd(button)
    local footer = button:GetParent()
    local entry = {}
    entry[SPELLS_STATUS_POSITIVE_FIELD_SOURCE] = footer.__source
    entry[SPELLS_STATUS_POSITIVE_FIELD_PRIORITY] = 1
    entry[SPELLS_STATUS_POSITIVE_FIELD_CLASS] = footer.__class
    entry[SPELLS_STATUS_POSITIVE_FIELD_NOTES] = ""
    SPELLS.StatusPositive[footer.__spellId] = entry
    Footer_OnClickReset(button)
    Section_Positive:UpdateData()
  end


  function Section_Positive:Load(gui)
    if not SquishData.GUISectionPositive then
      SquishData.GUISectionPositive = {}
    end

    gui.header:SetText("Status Positive Spells")

    self.scroll = gui.scrollPool:Acquire()
    self.scroll:SetPoint("LEFT", 8, 0)
    self.scroll:SetPoint("RIGHT", -8, 0)
    self.scroll:SetPoint("CENTER", 0, 0)
    self.scroll.CreateRow = CreateRow
    self.scroll.UpdateRow = UpdateRow
    self.scroll.ReleaseRow = ReleaseRow
    self.scroll.cursor = 1

    -- self.classFilter = CreateClassFilter(gui, self, SetClassFilter)
    -- self.classFilter:SetSelectedValue(SquishData.GUISectionPositive.filterClass or 0)

    data = gui.tablePool:Acquire()
    self:UpdateData()
    self.scroll:Show()

    self.footer = self.scroll.rowPool:Acquire()
    self.footer:SetBackdrop(MEDIA:BACKDROP(true, false, 0, -4, -36, -4, -8))
    self.footer:SetBackdropColor(0, 0, 0, 0.75)
    self.footer:SetSize(self.scroll:GetWidth()-32, 32)
    self.footer:SetPoint("TOPLEFT", self.scroll, "BOTTOMLEFT", 0, -8)
    self.footer:Show()
    self.footer.__spellName = ""
    self.footer.__spellId = nil
    self.footer.__source = 1
    self.footer.__class = #SPELLS_CLASS_VALUES
    self.footer.__valid = false

    Table_Insert(self.footer, self.footer:AcquireInput(nil, 1, Footer_SetSpell))
    Table_Insert(self.footer, self.footer:AcquireFontString(nil, 1))
    Table_Insert(self.footer, self.footer:AcquireDropdown(200, nil, InitSourceDropdown, self.footer, Footer_SetSource))
    Table_Insert(self.footer, self.footer:AcquireDropdown(200, nil, InitClassDropdown, self.footer, Footer_SetClass))
    Table_Insert(self.footer, self.footer:AcquireButton(64, nil, Footer_OnClickAdd))
    Table_Insert(self.footer, self.footer:AcquireButton(64, nil, Footer_OnClickReset))
    self.footer:StackElements(4, unpack(self.footer))

    Footer_Update(self.footer)
  end

  function Section_Positive:Unload(gui)
    data = gui.tablePool:Release(data)
    gui.header:SetText("")

    self.scroll:ReleaseRow(self.footer)
    self.scroll.rowPool:Release(self.footer)
    self.footer = nil

    gui.menuPool:Release(self.classFilter)
    self.classFilter = nil

    gui.scrollPool:Release(self.scroll)
    self.scroll = nil
  end
end

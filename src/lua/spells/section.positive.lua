local Section_Positive = { title = "Positive", icon = 134468 }
do
  local data = nil

  local function CreateRow(scroll, row, rowIndex)
    Table_Insert(row, row:AcquireIcon())
    Table_Insert(row, row:AcquireFontString())
    Table_Insert(row, row:AcquireFontString())
    Table_Insert(row, row:AcquireButton(row:GetHeight()))
    Table_Insert(row, row:AcquireFontString(256))
    Table_Insert(row, row:AcquireFontString(128))
    Table_Insert(row, row:AcquireFontString(128))
    row:StackElements(4, unpack(row))
  end

  local function UpdateRow(scroll, row, index)
    local name, _, icon = GetSpellInfo(data[index])
    local prio   = SPELLS.Positive[data[index]][SPELL_PRIORITY]
    local source = SPELLS.Positive[data[index]][SPELL_SOURCE]
    local class  = SPELLS.Positive[data[index]][SPELL_CLASS]
    row[1]:SetTexture(icon)
    row[2]:SetText(name)
    row[3]:SetText(prio)
    row[4]:SetText("+")
    row[5]:SetText(source)
    row[6]:SetText(data[index])
    row[7]:SetText(CLASS_SORT_ORDER[class])
    if class then
      local color = RAID_CLASS_COLORS[CLASS_SORT_ORDER[class]]
      row:SetBackdropColor(color.r, color.g, color.b, 0.3)
    end
  end

  local function ReleaseRow(scroll, row, rowIndex)
    while #row > 0 do
      row:ReleaseElement(Table_Remove(row))
    end
  end

  local function SortByClass(a, b)
    local A = SPELLS.Positive[a][SPELL_CLASS]
    local B = SPELLS.Positive[b][SPELL_CLASS]
    return A < B
  end

  function Section_Positive:UpdateData()
    for k in pairs(data) do data[k] = nil end
    local filterClass = SquishData.SectionPositive.filterClass
    for id, spell in pairs(SPELLS.Positive) do
      if not filterClass or filterClass == spell[SPELL_CLASS] then
        Table_Insert(data, id)
      end
    end
    Table_Sort(data, SortByClass)
    self.scroll:Init(32, #data, 32)
  end

  local function InitClassFilter(self)
    self.info.text = "All"
    self.info.checked = self.selected == 1
    self.info.arg2 = nil
    UIDropDownMenu_AddButton(self.info)
    for index = 1, #CLASS_SORT_ORDER do
      self.info.text = CLASS_SORT_ORDER[index]
      self.info.checked = (index + 1) == self.selected
      self.info.arg2 = index
      UIDropDownMenu_AddButton(self.info)
    end
  end

  local function SetClassFilter(_, self, index)
    SquishData.SectionPositive.filterClass = index
    if index then
      self.class:Select(index + 1)
    else
      self.class:Select(1)
    end
    self:UpdateData()
  end

  function Section_Positive:Load(gui)
    if not SquishData.SectionPositive then
      SquishData.SectionPositive = {}
    end

    gui.header:SetText("Positive spells")
    self.scroll = gui.scrollPool:Acquire()
    self.scroll:SetPoint("TOPLEFT", 8, -64)
    self.scroll:SetPoint("TOPRIGHT", -8, -64)
    self.scroll.CreateRow = CreateRow
    self.scroll.UpdateRow = UpdateRow
    self.scroll.ReleaseRow = ReleaseRow
    self.scroll.cursor = 1

    SquishData.SectionPositive.filterClass = nil
    self.class = gui.menuPool:Acquire()
    self.class:SetPoint("TOPRIGHT", gui, "TOPRIGHT", -150, -22)
    self.class:SetScale(1.2)
    self.class:Show()
    self.class.initialize = InitClassFilter
    self.class.info.func = SetClassFilter
    self.class.info.arg1 = self
    if SquishData.SectionPositive.filterClass then
      self.class:Select(SquishData.SectionPositive.filterClass + 1)
    else
      self.class:Select(1)
    end

    data = gui.tablePool:Acquire()
    self:UpdateData()
    self.scroll:Show()

    self.input = CreateFrame("editbox", nil, gui, "InputBoxTemplate")
    self.input:SetSize(256, 64)
    self.input:SetAutoFocus(false)
    self.input:SetPoint("BOTTOM", 0, 128)
    self.input:SetFontObject("ChatFontNormal")
    self.input:SetScript("OnEscapePressed", function(self)
      self:ClearFocus()
    end)
    self.input:SetScript("OnEnterPressed", function(self)
      local text = self:GetText()
      print(text, GetSpellInfo(text))
    end)
    self.input:Show()
  end

  function Section_Positive:Unload(gui)
    gui.header:SetText("")
    gui.scrollPool:Release(self.scroll)
    gui.menuPool:Release(self.class)
    data = gui.tablePool:Release(data)
  end
end

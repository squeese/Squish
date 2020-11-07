do
  local SectionPositive = { title = "Positive", icon = 134468 }
  local data

  --local function SortData(a, b)
    --local classA = SPELLS.StatusPositive[a][SPELLS_STATUS_POSITIVE_FIELD_CLASS]
    --local classB = SPELLS.StatusPositive[b][SPELLS_STATUS_POSITIVE_FIELD_CLASS]
    --if classA == classB then
      --local priorityA = SPELLS.StatusPositive[a][SPELLS_STATUS_POSITIVE_FIELD_PRIORITY]
      --local priorityB = SPELLS.StatusPositive[b][SPELLS_STATUS_POSITIVE_FIELD_PRIORITY]
      --if priorityA == priorityB then
        --return a < b
      --end
      --return priorityA > priorityB
    --end
    --return classA < classB
  --end

  local function updateData()
    for k in ipairs(data) do data[k] = nil end
    for id, entry in pairs(SquishUIData.StatusPositive) do
      if not data.class or data.class == entry[SquishUI.FIELD_CLASS_POSITIVE] then
        table.insert(data, id)
      end
    end
    --table.sort(data, sortData)
    return #data
  end

  local function increment(self)
    local row = self:GetParent()
    local id = data[row.__index]
    SquishUIData.StatusPositive[id][SquishUI.FIELD_PRIORITY_POSITIVE] = SquishUIData.StatusPositive[id][SquishUI.FIELD_PRIORITY_POSITIVE] + 1
    row:GetParent().__updateRow(row, row.__index)
  end

  local function decrement(self)
    local row = self:GetParent()
    local id = data[row.__index]
    SquishUIData.StatusPositive[id][SquishUI.FIELD_PRIORITY_POSITIVE] = math.max(1, SquishUIData.StatusPositive[id][SquishUI.FIELD_PRIORITY_POSITIVE] - 1)
    row:GetParent().__updateRow(row, row.__index)
  end

  local function TEST(self)
    local row = self:GetParent()
    local value = self:GetText()
    local id = data[row.__index]
    self:ClearFocus()
    self:SetText(self.__initial)
    SquishUIData.StatusPositive[id][SquishUI.FIELD_NOTES_POSITIVE] = value
    row:GetParent().__updateRow(row, row.__index)
  end

  local function createRow(row)
    row:SetBackdrop(SquishUI.Media:CreateBackdrop(true, nil, 0, 0))
    row:set("icon",   AcquireIcon('OVERLAY', 0, setParentAndShow, row))
    row:set("spell",  AcquireFontString(setParentAndShow, row))
    row:set("name",   AcquireFontString(setParentAndShow, row))
    row:set("prio",   AcquireFontString(setParentAndShow, row))
    row:set("pinc",   AcquireButton(increment, setParentAndShow, row))
    row:set("pdec",   AcquireButton(decrement, setParentAndShow, row))
    row:set("note",   AcquireInput(TEST, setParentAndShow, row))
    row:set("source", AcquireButton(nil, setParentAndShow, row, dropdownRow, SquishUI.FIELD_SOURCE_VALUES, SquishUI.FIELD_SOURCE_POSITIVE, nil))
    row:set("class",  AcquireButton(nil, setParentAndShow, row, dropdownRow, SquishUI.FIELD_CLASS_VALUES, SquishUI.FIELD_CLASS_POSITIVE, nil))
    stack(row, 4
      ,row.icon,   row:GetHeight(), 0
      ,row.spell,  0,   1
      ,row.name,   0,   3
      ,row.prio,   32,  0
      ,row.pinc,   32,  0
      ,row.pdec,   32,  0
      ,row.note,   300, 0
      ,row.source, 200, 0
      ,row.class,  150, 0
    )
  end

  local function updateRow(row, index)
    local spell = data[index]
    local entry = SquishUIData.StatusPositive[spell]
    local name, _, icon = GetSpellInfo(data[index])
    local color = RAID_CLASS_COLORS[SquishUI.FIELD_CLASS_VALUES[entry[SquishUI.FIELD_CLASS_POSITIVE]]]
    row.icon:SetTexture(icon)
    row.spell:SetText(data[index])
    row.name:SetText(name)
    row.prio:SetText(entry[SquishUI.FIELD_PRIORITY_POSITIVE])
    row.pinc:SetText("+")
    row.pdec:SetText("-")
    row.note:SetText(entry[SquishUI.FIELD_NOTES_POSITIVE] or "")
    row.source:SetValue(entry)
    row.class:SetValue(entry)
    row:SetBackdropColor(color.r, color.g, color.b, 0.2)
  end


  local scroll
  local function cleanup(self, ...)
    data = nil
    scroll = nil
    return next(self, ...)
  end

  local function updateFilter(self, value, _, key)
    data[key] = value ~= 0 and value or nil
    self:SetValue(value)
    scroll:update(updateData())
  end

  function SectionPositive.init(section)
    data = { class = nil }

    local header = AcquireFontString(setParentAndShow, self)
    header:SetPoint("TOP", 10, -64)
    header:SetText(section.title)

    scroll = AcquireScroll(self, 16, 32, createRow, updateRow)
    scroll:SetPoint("LEFT", 8, 0)
    scroll:SetPoint("RIGHT", -8, 0)
    scroll:SetPoint("CENTER", 0, 0)

    local filter = AcquireButton(setParentAndShow, self, dropdownFilter, updateFilter, SquishUI.FIELD_CLASS_VALUES, "class")
    filter:SetSize(150, 32)
    filter:SetPoint("BOTTOMRIGHT", scroll, "TOPRIGHT", -28, 4)
    filter:SetValue(data.class)

    scroll:update(updateData())

    return rpush(section, header, scroll, filter, cleanup, iclean)
  end

  table.insert(Sections, SectionPositive)
end

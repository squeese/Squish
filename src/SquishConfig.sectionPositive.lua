do
  local SectionPositive = { title = "Positive", icon = 134468 }
  local data

  local function updateData()
    for k in ipairs(data) do data[k] = nil end
    for id, entry in pairs(SquishUIData.StatusPositive) do
      if not data.class or data.class == entry[SquishUI.FIELD_CLASS_POSITIVE] then
        table.insert(data, id)
      end
    end
    return #data
  end

  local function createRow(row)
    row:SetBackdrop(SquishUI.Media:CreateBackdrop(true, nil, 0, 0))
    row:set("icon",   AcquireTexture('OVERLAY', 0, setParentAndShow, row))
    row:set("name",   AcquireFontString(setParentAndShow, row))
    row:set("prio",   AcquireFontString(setParentAndShow, row))
    row:set("spell",  AcquireFontString(setParentAndShow, row))
    row:set("source", AcquireButton(setParentAndShow, row, dropdownRow, SquishUI.FIELD_SOURCE_VALUES, SquishUI.FIELD_SOURCE_POSITIVE, nil))
    row:set("class",  AcquireButton(setParentAndShow, row, dropdownRow, SquishUI.FIELD_CLASS_VALUES, SquishUI.FIELD_CLASS_POSITIVE, nil))
    stack(row, 4
      ,row.icon,   row:GetHeight(), 0
      ,row.name,   0,   1
      ,row.prio,   32,  0
      ,row.spell,  0,   1
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
    row.name:SetText(name)
    row.prio:SetText(entry[SquishUI.FIELD_PRIORITY_POSITIVE])
    row.spell:SetText(data[index])
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

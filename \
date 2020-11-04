do
  local SectionPositive = { title = "Positive", icon = 134468 }
  local data = {}

  local function UpdateData()
    for k in pairs(data) do data[k] = nil end
    -- local filterClass = SquishData.GUISectionPositive.filterClass
    for id, spell in pairs(SquishUIData.StatusPositive) do
      table.insert(data, id)
      --if not filterClass or filterClass == spell[SPELLS_STATUS_POSITIVE_FIELD_CLASS] then
        --Table_Insert(data, id)
      --end
    end
    -- Table_Sort(data, SortData)
    return #data
  end

  local function Set(self, key, value)
    self[key] = value
    return self
  end

  local function CreateRow(scroll, row, index)
    table.insert(row, row:AcquireTexture(row.frame, SetupIcon, nil))
    table.insert(row, row:AcquireFontString(row.frame, Set, "weight", 2))
    table.insert(row, row:AcquireFontString(row.frame, Set, "weight", 1))
    row:Stack(4, unpack(row))
  end

  local function UpdateRow(scroll, row, index)
    row[2]:SetText("one")
    row[3]:SetText("two")
  end

  local function ReleaseRow(scroll, row)
    while #row > 0 do
      table.remove(row):Release(Set, "weight", nil)
    end
    row:Release()
  end

  local HEADER = 1
  local SCROLL = 2
  function SectionPositive:Init()
    self[HEADER] = self:AcquireFontString(self:root())
    self[HEADER]:SetPoint("TOP", self:root(), "TOP", 0, -64)
    self[HEADER]:SetText(self.title)

    self[SCROLL] = self:AcquireScroll(self:root())
    self[SCROLL].frame:SetPoint("LEFT", 8, 0)
    self[SCROLL].frame:SetPoint("RIGHT", -8, 0)
    self[SCROLL].frame:SetPoint("CENTER", 0, 0)
    self[SCROLL].CreateRow = CreateRow
    self[SCROLL].UpdateRow = UpdateRow 
    self[SCROLL].ReleaseRow = ReleaseRow
    self[SCROLL]:Update(4, UpdateData(), 64)
  end

  table.insert(Sections, SectionPositive)
end

do
  local SectionNegative = { title = "Negative", icon = 134466 }

  function SectionNegative:Init()
  end

  table.insert(Sections, SectionNegative)
end

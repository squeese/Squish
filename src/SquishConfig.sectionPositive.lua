do
  --local order
  --local data

  --local function XXX(tbl)
    --local function sort(a, b)
      --local A, B
      --for i = 1, #tbl do
        --A, B = tbl[i].__sort(a, b)
        --if A ~= B then
          --break
        --end
      --end
      --return A < B
    --end
    --tbl.__call = function(self, data)
      --if #self > 0 then
        --table.sort(data, sort)
      --end
    --end
    --setmetatable(tbl, tbl)
  --end



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

  --local function updateData()


    --for k in ipairs(data) do data[k] = nil end
    --for id, entry in pairs(SquishUIData.StatusPositive) do
      --if not data.class or data.class == entry[SquishUI.FIELD_CLASS_POSITIVE] then
        --table.insert(data, id)
      --end
    --end
    --order(data)
    ---- table.sort(data, sortData)
    --return #data
  --end

  --local function increment(self)
    --local row = self:GetParent()
    --local id = data[row.__index]
    --SquishUIData.StatusPositive[id][SquishUI.FIELD_PRIORITY_POSITIVE] = SquishUIData.StatusPositive[id][SquishUI.FIELD_PRIORITY_POSITIVE] + 1
    --row:GetParent().__updateRow(row, row.__index)
  --end

  --local function decrement(self)
    --local row = self:GetParent()
    --local id = data[row.__index]
    --SquishUIData.StatusPositive[id][SquishUI.FIELD_PRIORITY_POSITIVE] = math.max(1, SquishUIData.StatusPositive[id][SquishUI.FIELD_PRIORITY_POSITIVE] - 1)
    --row:GetParent().__updateRow(row, row.__index)
  --end

  --local function TEST(self)
    --local row = self:GetParent()
    --local value = self:GetText()
    --local id = data[row.__index]
    --self:ClearFocus()
    --self:SetText(self.__initial)
    --SquishUIData.StatusPositive[id][SquishUI.FIELD_NOTES_POSITIVE] = value
    --row:GetParent().__updateRow(row, row.__index)
  --end

  --local function createRow(row)
    --row:SetBackdrop(SquishUI.Media:CreateBackdrop(true, nil, 0, 0))
    --row:set("icon",   AcquireIcon(row, 'OVERLAY', 0))
    --row:set("name",   AcquireFontString(row, "LEFT", 16))
    --row:set("prio",   AcquireFontString(row, "CENTER", 18))
    --row:set("pinc",   AcquireButton(row, increment))
    --row:set("pdec",   AcquireButton(row, decrement))
    --row:set("note",   AcquireInput(row, TEST))
    --row:set("source", AcquireButton(row, nil, dropdownRow, SquishUI.FIELD_SOURCE_VALUES, SquishUI.FIELD_SOURCE_POSITIVE, nil))
    --row:set("class",  AcquireButton(row, nil, dropdownRow, SquishUI.FIELD_CLASS_VALUES, SquishUI.FIELD_CLASS_POSITIVE, nil))
    --stack(row, 4
      --,row.icon,   row:GetHeight(), 0
      --,row.name,   0,   3
      --,row.note,   304, 0
      --,row.prio,   32,  0
      --,row.pinc,   32,  0
      --,row.pdec,   32,  0
      --,row.source, 200, 0
      --,row.class,  150, 0
    --)
  --end

  --local function updateRow(row, index)
    --local spell = data[index]
    --local entry = SquishUIData.StatusPositive[spell]
    --local name, _, icon = GetSpellInfo(data[index])
    --local color = RAID_CLASS_COLORS[SquishUI.FIELD_CLASS_VALUES[entry[SquishUI.FIELD_CLASS_POSITIVE]]]
    --row.icon:SetTexture(icon)
    --row.name:SetText(name)
    --row.prio:SetText(entry[SquishUI.FIELD_PRIORITY_POSITIVE])
    --row.pinc:SetText("+")
    --row.pdec:SetText("-")
    --row.note:SetText(entry[SquishUI.FIELD_NOTES_POSITIVE] or "")
    --row.source:SetValue(entry)
    --row.class:SetValue(entry)
    --row:SetBackdropColor(color.r, color.g, color.b, 0.2)
  --end


  --local scroll
  --local function cleanup(self, ...)
    --data = nil
    --order = nil
    --scroll = nil
    --return next(self, ...)
  --end

  --local function updateFilter(self, value, _, key)
    --data[key] = value ~= 0 and value or nil
    --self:SetValue(value)
    --scroll:update(updateData())
  --end

  --local function updateOrder(self, key)


    --local value
    --if not data[key] then
      --value = 1
    --elseif data[key] > 0 then
      --value = -1
    --end
    --data[key] = value
    --self:SetValue(value)
  --end

  local function init(self, root, subscribe, dispatch, ...)
    data = {}
    order = {}
    push(section, cleanup, iclean)

    XXX(order)

    scroll = AcquireScroll(self, 16, 32, createRow, updateRow)
    scroll:SetPoint("LEFT", 8, 0)
    scroll:SetPoint("RIGHT", -8, 0)
    scroll:SetPoint("CENTER", 0, 0)
    push(section, scroll)

    local filter = AcquireButton(self, nil, dropdownFilter, updateFilter, SquishUI.FIELD_CLASS_VALUES, "class")
    filter:SetSize(150, 32)
    filter:SetPoint("BOTTOMRIGHT", scroll, "TOPRIGHT", -28, 40)
    filter:SetValue(data.class)
    push(section, filter)

    local header = AcquireFrame(self)
    header:SetPoint("BOTTOMLEFT", scroll, "TOPLEFT", -4, 4)
    header:SetPoint("TOPRIGHT", scroll, "TOPRIGHT", -30, 36)
    push(section, header)

    local function TMP()
      scroll:update(updateData())
    end

    local function test(name, field)
      local btn = AcquireSortButton(self, order, TMP, SquishUIData.StatusPositive, field)
      btn:SetText(name)
      push(section, btn)
      return btn
    end

    stack(header, 4
      ,test("Name", SquishUI.FIELD_CLASS_POSITIVE),                                    0, 1
      ,test("Prioriy", SquishUI.FIELD_PRIORITY_POSITIVE),                            410, 0
      ,test("Source", SquishUI.FIELD_SOURCE_POSITIVE),                               200, 0
      ,test("Class", SquishUI.FIELD_CLASS_POSITIVE),                                 150, 0
    )

    --scroll:update(updateData())
    return next(push(self, header), ...)
  end

  table.insert(Sections, { title = "Positive", icon = 134468, init })
end

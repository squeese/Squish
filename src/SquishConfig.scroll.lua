do
  local scrollPool = {}

  local function Setup(frame)
    frame:SetBackdrop(SquishUI.Media:CreateBackdrop(true, nil, -4))
    frame:SetBackdropColor(0, 0, 0, 0.75)
    frame:EnableMouseWheel(true)
    frame:Show()
    return frame
  end

  local function Cleanup(self)
    while #self > 0 do
      self:ReleaseRow(table.remove(self)) 
    end
    self.frame:SetBackdrop(nil)
    self.frame:EnableMouseWheel(false)
    self.frame:Release()
    self.frame = nil
    return self
  end

  local function Release(...)
    table.insert(scrollPool, Cleanup(Modify(...)))
  end

  local function Update(self, rows, length, height, cursor)
    self.length = length
    self.rowCount = rows
    self.rowHeight = height
    self.cursor = cursor or 1
    self.rowMax = math.max(1, length - rows + 1)
    self.totHeight = self.rowHeight * rows
    self.cursor = math.max(1, math.min(self.rowMax, self.cursor))
    self.frame:SetHeight(rows * height)
    for rowIndex = 1, rows do
      local dataIndex = self.cursor + rowIndex - 1
      if dataIndex > self.length then
        while #self >= rowIndex do
          self:ReleaseRow(table.remove(self)) 
        end
        break
      end
      local row = self[rowIndex]
      if rowIndex > #self then
        row = self:AcquireRow(self.frame)
        row.frame:SetPoint("LEFT", 0, 0)
        row.frame:SetPoint("RIGHT", -32, 0)
        row.frame:SetHeight(self.rowHeight-1)
        if rowIndex == 1 then
          row.frame:SetPoint("TOP", 0, -1)
        else
          row.frame:SetPoint("TOP", self[rowIndex-1].frame, "BOTTOM", 0, -1)
        end
        self:CreateRow(row, rowIndex)
        row.frame:Show()
        table.insert(self, row)
      end
      self:UpdateRow(row, dataIndex)
    end
  end

  local function ReleaseRow(self, row)
    row:Release()
  end

  function self:AcquireScroll(parent, ...)
    if #scrollPool > 0 then
      local scroll = table.remove(scrollPool)
      scroll.frame = self:AcquireFrame(parent, Setup)
      return Modify(scroll, ...)
    end
    return Modify(setmetatable({
      Update = Update,
      Release = Release,
      ReleaseRow = ReleaseRow,
      frame = self:AcquireFrame(parent, Setup),
    }, self:root()), ...)
  end
end

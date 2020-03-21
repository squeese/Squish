local Squish = select(2, ...)

local Tray = CreateFrame("frame", nil, UIParent, nil)
Tray:SetPoint("TOP", 0, 0)
Tray:SetPoint("LEFT", 0, 0)
Tray:SetPoint("BOTTOM", 0, 0)
Tray:SetWidth(300)
Tray:SetFrameStrata("BACKGROUND")

local Debug = Squish.Scroller.create({
  columns = { 64, 512 },
  lines = UIParent:GetHeight() / 20,
  scroll = 4,
  base = function(self, frame)
    frame:SetParent(Tray)
    frame:SetAllPoints(Tray)
  end,
  row = function(self, frame, row, rowIndex, prev)
    row:SetSize(frame:GetWidth(), 20)
    if not prev then
      row:SetPoint("TOPLEFT", 0, 0)
    else
      row:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, 0)
    end
  end,
  cell = function(self, frame, row, rowIndex, cell, colIndex, prev)
    cell.text:SetFont("Interface\\Addons\\Squish\\media\\vixar.ttf", 12)
    cell:SetWidth(self.columns[colIndex])
    cell:SetPoint("TOP", 0, 0)
    cell:SetPoint("BOTTOM", 0, 0)
    if not prev then
      cell:SetPoint("LEFT", 0, -10)
    else
      cell:SetPoint("LEFT", prev, "RIGHT", 0, 0)
    end
  end,
  UpdateRow = function(self, row, entry, rowIndex, entryIndex, _, prevEntry)
    row:Show()
    row:SetText(1, entryIndex)
    row:SetText(2, entry)
  end,
})

--for i = 1, 100 do
  --table.insert(Debug, "Line: " ..i)
--end
--Debug:Update()

do
  local Driver, Render = Squish.Create()
  local Update = Render()
  -- print(Test, "Test")
  Update(Driver{
    Driver{},
    Driver{},
  })
  -- Update(function() return Driver, Driver() end)
end

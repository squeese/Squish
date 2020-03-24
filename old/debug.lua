local Squish = select(2, ...)
local Scroller = {}
Scroller.__index = Scroller
Squish.Scroller = Scroller

local function createCell(scroller, row, rowIndex, colIndex, prev)
  local cell = CreateFrame('frame', nil, row)
  cell:SetBackdrop({
    bgFile = 'Interface\\Addons\\Squish\\media\\backdrop.tga',
    edgeFile = 'Interface\\Addons\\Squish\\media\\edgefile.tga',
    insets   = { left = 1, right = 1, top = 1, bottom = 1 },
    edgeSize = 1
  })
  cell:SetBackdropColor(0, 0, 0, 0)
  cell:SetBackdropBorderColor(0, 0, 0, 0)
  cell:SetScript('OnEnter', function(self)
    scroller:CellEnter(row, cell, rowIndex, colIndex)
  end)
  cell:SetScript('OnLeave', function(self)
    scroller:CellLeave(row, cell, rowIndex, colIndex)
  end)
  cell:SetScript('OnMouseUp', function(self)
    scroller:CellClicked(row, cell, rowIndex, colIndex)
    scroller:RowClicked(row, rowIndex)
  end)
  cell.text = cell:CreateFontString(nil, nil, 'GameFontNormal')
  cell.text:SetPoint('LEFT', 0, 0)
  cell.text:SetPoint('TOP', 0, 0)
  cell.text:SetPoint('RIGHT', 0, 0)
  cell.text:SetPoint('BOTTOM', 0, 0)
  cell.text:SetJustifyH(justify or 'LEFT')
  cell.text:SetTextColor(1, 1, 1, 1)
  cell.text:SetText('')
  scroller:cell(scroller.frame, row, rowIndex, cell, colIndex, prev)
  function cell:SetText(...)
    cell.text:SetText(...)
  end
  return cell
end

local function createRow(scroller, rowIndex, prev)
  local row = CreateFrame('frame', nil, scroller.frame)
  row:SetPoint('LEFT', 0, 0)
  row:SetPoint('RIGHT', 0, 0)
  row:SetBackdrop({
    bgFile = 'Interface\\Addons\\Squish\\media\\backdrop.tga',
    edgeFile = 'Interface\\Addons\\Squish\\media\\edgefile.tga',
    insets   = { left = 1, right = 1, top = 1, bottom = 1 },
    edgeSize = 1
  })
  row:SetBackdropColor(1, 1, 1, 0)
  row:SetBackdropBorderColor(1, 1, 1, 0)
  scroller:row(scroller.frame, row, rowIndex, prev)
  row:SetScript('OnMouseUp', function(self)
    scroller:RowClicked(row, rowIndex)
  end)
  row.cells = {}
  local cell
  for colIndex = 1, #scroller.columns do
    cell = createCell(scroller, row, rowIndex, colIndex, cell)
    table.insert(row.cells, cell)
  end
  function row:SetText(i, ...)
    self.cells[i].text:SetText(...)
  end
  function row:SetTextColor(i, ...)
    self.cells[i].text:SetTextColor(...)
  end
  return row
end

local function sum(...)
  local val = 0
  for i = 1, select('#', ...) do
    val = val + select(i, ...)
  end
  return val
end

local function createBase(scroller)
  local frame = CreateFrame("frame", nil, UIParent) 
  frame.texture = frame:CreateTexture() 
  frame.texture:SetAllPoints() 
  frame.texture:SetColorTexture(0,0,0,0.8)
  frame:EnableMouseWheel(true)
  frame:SetScript('OnMouseWheel', function(self, delta)
    return IsShiftKeyDown()
      and scroller:MoveIndex(delta*scroller.lines)
      or  scroller:MoveIndex(delta*scroller.scroll)
  end)
  scroller:base(frame)
  scroller.frame = frame
  scroller.rows = {}
  local row
  for i = 1, scroller.lines do
    row = createRow(scroller, i, row)
    table.insert(scroller.rows, row)
  end
  scroller.base = nil
  scroller.row = nil
  scroller.cell = nil
end

function Scroller.create(scroller)
  setmetatable(scroller, Scroller)
  scroller.index = scroller.index or 1
  scroller.lines = scroller.lines or 60
  scroller.columns = scroller.columns or {100}
  scroller.scroll = scroller.scroll or 1
  scroller.base = scroller.base or function(self, frame)
    frame:SetSize(sum(unpack(scroller.columns)), UIParent:GetHeight()) 
    frame:SetPoint('TOPLEFT', 0, 0)
  end
  scroller.row = scroller.row or function(self, frame, row, rowIndex, prev)
    row:SetHeight(frame:GetHeight()/scroller.lines)
    if not prev then
      row:SetPoint('TOPLEFT', 0, 0)
    else
      row:SetPoint('TOPLEFT', prev, 'BOTTOMLEFT', 0, 0)
    end
  end
  scroller.cell = scroller.cell or function(self, frame, row, rowIndex, cell, colIndex, prev)
    cell.text:SetFont('Interface\\Addons\\ONodesUI\\media\\vixar.ttf', 13)
    cell:SetWidth(self.columns[colIndex])
    cell:SetPoint('TOP', 0, 0)
    cell:SetPoint('BOTTOM', 0, 0)
    if not prev then
      cell:SetPoint('LEFT', 0, 0)
    else
      cell:SetPoint('LEFT', prev, 'RIGHT', 0, 0)
    end
  end
  createBase(scroller)
  return scroller
end

function Scroller:MoveIndex(n)
  local sign = n > 0 and 1 or -1
  while n ~= 0 do
    local skip = 0
    repeat
      skip = skip-sign
      if self.index+skip <= 0 or self.index+skip > #self then
        self:Update()
        return
      end
    until self:Filter(self.index+skip, self[self.index+skip])
    self.index = self.index+skip
    n = n-sign
  end
  self.index = math.min(math.max(self.index-n, 1), math.max(#self-self.lines+1, 1))
  self:Update()
end

function Scroller:Clear()
  self.index = 1
  for i = 1, #self do
    self[i] = nil
  end
  self:Update()
end

function Scroller:RowClicked(row, rowIndex) end
function Scroller:CellClicked(row, cell, rowIndex, cellIndex) end
function Scroller:CellEnter(row, cell, rowIndex, cellIndex) end
function Scroller:CellLeave(row, cell, rowIndex, cellIndex) end

function Scroller:Filter(entryIndex, entry)
  return true
end

function Scroller:Entries()
  local rowIndex, entryIndex = 0, self.index-1
  return function()
    rowIndex = rowIndex + 1
    entryIndex = entryIndex + 1
    if rowIndex <= self.lines then
      while entryIndex <= #self and not self:Filter(entryIndex, self[entryIndex]) do
        entryIndex = entryIndex + 1
      end
      if entryIndex <= #self then
        return rowIndex, entryIndex, self[entryIndex]
      else
        return rowIndex, nil, nil
      end
    end
  end
end

function Scroller:UpdateRow(row, entry, rowIndex, entryIndex)
  row:Show()
end

function Scroller:Update()
  local prevIndex, prevEntry
  for rowIndex, entryIndex, entry in self:Entries() do
    if entryIndex then
      self:UpdateRow(self.rows[rowIndex], self[entryIndex], rowIndex, entryIndex, prevIndex, prevEntry)
      prevIndex = entryIndex
      prevEntry = self[entryIndex]
    else
      self.rows[rowIndex]:Hide()
    end
  end
end

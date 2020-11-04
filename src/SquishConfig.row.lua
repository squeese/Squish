do
  local rowPool = {}

  local function Setup(frame)
    frame:SetBackdrop(SquishUI.Media:CreateBackdrop(true, nil, 0, 0))
    frame:SetBackdropColor(1, 0.5, 0, 0.15)
    return frame
  end

  local function Cleanup(self)
    while #self > 0 do
      table.remove(self):Release()
    end
    self.frame:SetBackdrop(nil)
    self.frame:Release()
    self.frame = nil
    return self
  end

  local function Release(...)
    table.insert(rowPool, Cleanup(Modify(...)))
  end

  local function Stack(self, gap, ...)
    local length = select("#", ...)
    local width = self.frame:GetWidth() - gap * (length - 1)
    local sum = 0
    for i = 1, length do
      local element = select(i, ...)
      if element.weight then
        sum = sum + element.weight
      else
        width = width - element:GetWidth()
      end
    end
    for i = 1, length do
      local element = select(i, ...)
      if i == 1 then
        element:SetPoint("LEFT", self.frame, "LEFT", 0, 0)
      else
        local prev = select(i-1, ...)
        element:SetPoint("LEFT", prev, "RIGHT", gap, 0)
      end
      if element.weight then
        element:SetWidth(width * (element.weight / sum))
      end
    end
  end

  function self:AcquireRow(parent, ...)
    if #rowPool > 0 then
      local row = table.remove(rowPool)
      row.frame = self:AcquireFrame(parent, Setup)
      return Modify(row, ...)
    end
    return Modify(setmetatable({
      Update = Update,
      Release = Release,
      Stack = Stack,
      frame = self:AcquireFrame(parent, Setup),
    }, self:root()), ...)
  end
end

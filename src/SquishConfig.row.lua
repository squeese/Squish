do
  local rowPool = {}

  local function Setup(self, parent)
    self.frame = self:AcquireFrame(parent)
    self.frame:SetBackdrop(SquishUI.Media:CreateBackdrop(true, nil, 0, 0))
    self.frame:SetBackdropColor(1, 0.5, 0, 0.15)
    self.frame.row = self
    return self
  end

  local function Cleanup(self)
    while #self > 0 do
      table.remove(self):Release()
    end
    self.frame:SetBackdrop(nil)
    self.frame:Release()
    self.frame.row = nil
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
      return Modify(Setup(table.remove(rowPool), parent), ...)
    end
    return Modify(Setup(setmetatable({
      Update = Update,
      Release = Release,
      Stack = Stack,
    }, self:root()), parent), ...)
  end
end

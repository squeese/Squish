local function Modify(self, func, ...)
  if func and type(func) == "function" then
    return func(self, ...)
  end
  return self
end

local function SetParentAndShow(self, parent)
  if parent then
    self:SetParent(parent)
  end
  self:Show()
  return self
end

local function ClearAndHide(self)
  self:ClearAllPoints()
  self:Hide()
  return self
end

local function SetupIcon(self, icon)
  self:SetPoint("LEFT", 7, 0)
  self:SetSize(16, 16)
  self:SetTexture(icon)
  return self
end

do
  local framePool = {}
  local function Release(...)
    table.insert(framePool, ClearAndHide(Modify(...)))
  end
  function self:AcquireFrame(parent, ...)
    if #framePool > 0 then
      return Modify(SetParentAndShow(table.remove(framePool), parent), ...)
    end
    local frame = CreateFrame("frame", nil, self:root(), "BackdropTemplate")
    frame.Release = Release
    return Modify(SetParentAndShow(frame, parent), ...)
  end
end

do
  local fontStringPool = {}
  local function Release(...)
    table.insert(fontStringPool, ClearAndHide(Modify(...)))
  end
  function self:AcquireFontString(parent, ...)
    if #fontStringPool > 0 then
      return Modify(SetParentAndShow(table.remove(fontStringPool), parent), ...)
    end
    local font = self:root():CreateFontString(nil, nil, "GameFontNormal")
    font:SetFont(SquishUI.Media.FONT_VIXAR, 16)
    font.Release = Release
    return Modify(SetParentAndShow(font, parent), ...)
  end
end

do
  local texturePool = {}
  local function Release(...)
    table.insert(texturePool, ClearAndHide(Modify(...)))
  end
  function self:AcquireTexture(parent, ...)
    if #texturePool > 0 then
      return Modify(SetParentAndShow(table.remove(texturePool), parent), ...)
    end
    local texture = self:roote():CreateTexture(nil, 'OVERLAY')
    texture.Release = Release
    return Modify(SetParentAndShow(texture, parent), ...)
  end
end












--local function StackElements(row, gap, ...)
  --local length = select("#", ...)
  --local width = row:GetWidth() - gap * (length - 1)
  --local sum = 0
  --for i = 1, length do
    --local element = select(i, ...)
    --if element.weight then
      --sum = sum + element.weight
    --else
      --width = width - element:GetWidth()
    --end
  --end
  --for i = 1, length do
    --local element = select(i, ...)
    --if i == 1 then
      --element:SetPoint("LEFT", row, "LEFT", 0, 0)
    --else
      --local prev = select(i-1, ...)
      --element:SetPoint("LEFT", prev, "RIGHT", gap, 0)
    --end
    --if element.weight then
      --element:SetWidth(width * (element.weight / sum))
    --end
  --end
--end



--do
  --local pool = {}
  --local function Release(self)
    --while #self > 0 do
      --table.remove(self):Release()
    --end
    --print("release row", self)
    --table.insert(pool, self)
  --end
  --local function Init(self)
    --self[1] = self:AcquireFontString()
    --self[2] = self:AcquireFontString()
  --end
  --function self:AcquireRow()
    --if #pool > 0 then
      --local row = table.remove(pool)
      --print("reuse row", row)
      --return row
    --end
    --local row = { Release = Release, Init = Init }
    --print("create row", row)
    --return setmetatable(row, getmetatable(self).__index)
  --end
--end


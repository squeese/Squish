local function next(self, arg, ...)
  if arg then
    local kind = type(arg)
    if kind == "function" then
      return arg(self, ...)
    elseif kind == "table" then
      next(arg, unpack(arg))
      return next(self, ...)
    end
  end
  return self
end

local function ident(self)
  return self
end



local function push(self, ...)
  for i = 1, select("#", ...) do
    local arg = select(i, ...)
    table.insert(self, i, arg)
  end
  return self
end

local function rpush(self, ...)
  for i = 1, select("#", ...) do
    local arg = select(i, ...)
    table.insert(self, arg)
  end
  return self
end

local function unwind(self)
  return next(self, unpack(self))
end

local function iclean(self, ...)
  for i in ipairs(self) do
    self[i] = nil
  end
  return next(self, ...)
end

local function clearAndHide(self, ...)
  --print("clearAndHide", self)
  self:ClearAllPoints()
  self:Hide()
  return next(self, ...)
end

local function setParentAndShow(self, parent, ...)
  --print("setParentAndShow", self, parent)
  self:SetParent(parent)
  self:Show()
  return next(push(self, clearAndHide), ...)
end

local function setScript(self, name, func, ...)
  self:SetScript(name, func)
  return next(self, ...)
end

local CreatePool
do
  local counts = {}
  local pools = {}
  local timer
  local function report()
    timer = nil
    local sum = 0
    for _, pool in ipairs(pools) do
      sum = sum + #pool
    end
    print("SUM", sum)
  end
  local function trigger()
    if timer then
      timer:Cancel()
    end
    timer = C_Timer.NewTicker(1, report, 1)
  end
  local function log(self, name, action, count)
    local key = tostring(self):sub(8)
    counts[key] = (counts[key] or 0) + count
    --print("LOG", action, name, key, counts[key])
    trigger()
  end
  local function generic(frame, release, ...)
    return next(push(frame, release), ...)
  end
  function CreatePool(name, fn, a, b, c, d, compose)
    -- compose = compose or generic
    local pool = { name = name }
    table.insert(pools, pool)
    local function acquire()
      local frame
      if #pool == 0 then
        frame = fn(a, b, c, d)
        log(frame, name, "create", 1)
      else
        frame = table.remove(pool)
        log(frame, name, "reuse", 1)
      end
      return frame
    end
    local function release(self, ...)
      assert(select("#", ...) == 0)
      for i in ipairs(self) do
        self[i] = nil
      end
      log(self, name, "release", -1)
      table.insert(pool, self)
    end
    return compose and compose(acquire, release) or function(...)
      return next(push(acquire(), release), ...)
    end
  end
end

local AcquireFrame = CreatePool("FRAME", CreateFrame, "frame", nil, self, "BackdropTemplate")

local AcquireFontString = CreatePool("FONT", self.CreateFontString, self, nil, nil, "GameFontNormal")

local AcquireTexture = CreatePool("TEXTURE", self.CreateTexture, self, nil, 'ARTWORK', 0, function(acquire, release)
  local function setup(self, layer, level, ...)
    self:SetDrawLayer(layer or 'ARTWORK', sublevel or 0)
    self:SetTexture(nil)
    return next(self, ...)
  end
  return function(...)
    return next(push(acquire(), release), setup, ...)
  end
end)

local AcquireIcon = next(nil, function()
  local function setup(self, ...)
    self:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    return next(self, ...)
  end
  local function cleanup(self, ...)
    self:SetTexCoord(0, 1, 0, 1)
    return next(self, ...)
  end
  return function(layer, level, ...)
    return next(push(AcquireTexture(layer or 'OVERLAY', level), cleanup), setup, ...)
  end
end)

local AcquireButton = CreatePool("BUTTON", CreateFrame, "button", nil, self, "UIPanelButtonTemplate", function(acquire, release)
  local function setup(self, fn, ...)
    self:SetScript("OnClick", fn)
    return next(self, ...)
  end
  return function(...)
    return next(push(acquire(), setup, nil, release), setup, ...)
  end
end)

local AcquireInput = CreatePool("INPUT", CreateFrame, "editbox", nil, self, "LargeInputBoxTemplate,BackdropTemplate", function(acquire, release)
  local function OnEscapePressed(self)
    self:SetText(self.__initial)
    self:ClearFocus()
  end
  local function OnTextSet(self)
    self.__initial = self:GetText()
  end
  local function OnTextChanged(self)
    local dirty = self.__initial ~= self:GetText()
    if dirty then
      self:SetAlpha(1)
    else
      self:SetAlpha(0.5)
    end
  end
  local function setup(self, fn, ...)
    self.__initial = ""
    self:SetScript("OnEscapePressed", OnEscapePressed)
    self:SetScript("OnEnterPressed", fn)
    self:SetScript("OnTextChanged", OnTextChanged)
    self:SetScript("OnTextSet", OnTextSet)
    self:SetAutoFocus(false)
    return next(self, ...)
  end
  local function clean(self, ...)
    self.__initial = nil
    self:SetScript("OnEscapePressed", nil)
    self:SetScript("OnEnterPressed", nil)
    self:SetScript("OnTextChanged", nil)
    self:SetScript("OnTextSet", nil)
    return next(self, ...)
  end
  return function(...)
    return next(push(acquire(), cleanup, release), setup, ...)
  end
end)

--local AcquireFrame
--do
  --local pool = {}
  --function AcquireFrame(...)
    --if #pool > 0 then
      --return next(push(table.remove(pool), release, pool), reportReuse, "frame", ...)
    --end
    --return next(push(CreateFrame("frame", nil, self, "BackdropTemplate"), release, pool), reportCreate, "frame", ...)
  --end
--end

--local AcquireButton
--do
  --local pool = {}
  --local function clean(self, ...)
    --self:SetScript("OnClick", nil)
    --return next(self, ...)
  --end
  --function AcquireButton(...)
    --if #pool > 0 then
      --return next(push(table.remove(pool), release, pool), reportReuse, "button", ...)
    --end
    --return next(push(CreateFrame("button", nil, self, "UIPanelButtonTemplate"), clean, release, pool), reportCreate, "button", ...)
  --end
--end

--local AcquireFontString
--do
  --local pool = {}
  --function AcquireFontString(...)
    --if #pool > 0 then
      --return next(push(table.remove(pool), release, pool), reportReuse, "font", ...)
    --end
    --return next(push(self:CreateFontString(nil, nil, "GameFontNormal"), release, pool), reportCreate, "font", ...)
  --end
--end

--local AcquireInput
--do
  --local pool = {}
  --local function OnEscapePressed(self)
    --self:SetText(self.__initial)
    --self:ClearFocus()
  --end
  --local function OnTextSet(self)
    --self.__initial = self:GetText()
  --end
  --local function OnTextChanged(self)
    --local dirty = self.__initial ~= self:GetText()
    --if dirty then
      --self:SetAlpha(1)
    --else
      --self:SetAlpha(0.5)
    --end
  --end
  --local function setup(self, ...)
    --self.__initial = ""
    --self:SetScript("OnEscapePressed", OnEscapePressed)
    --self:SetScript("OnTextChanged", OnTextChanged)
    --self:SetScript("OnTextSet", OnTextSet)
    --self:SetAutoFocus(false)
    --return next(self, ...)
  --end
  --local function clean(self, ...)
    --self.__initial = nil
    --self:SetScript("OnEscapePressed", nil)
    --self:SetScript("OnTextChanged", nil)
    --self:SetScript("OnTextSet", nil)
    --self:SetScript("OnEnterPressed", nil)
    --return next(self, ...)
  --end
  --function AcquireInput(...)
    --if #pool > 0 then
      --return next(push(table.remove(pool), release, pool), setup, reportReuse, "button", ...)
    --end
    --return next(push(CreateFrame("editbox", nil, self, "LargeInputBoxTemplate,BackdropTemplate"), clean, release, pool), setup, reportCreate, "button", ...)
  --end
--end


--local AcquireTexture
--do
  --local pool = {}
  --local function init(self, layer, sublevel)
    --self:SetDrawLayer(layer or 'ARTWORK', sublevel or 0)
    --self:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    --return self
  --end
  --function AcquireTexture(layer, sublevel, ...)
    --local texture
    --local fn
    --if #pool > 0 then
      --texture = table.remove(pool)
      --fn = reportReuse
    --else
      --texture = self:CreateTexture()
      --fn = reportCreate
    --end
    --return next(push(init(texture, layer, sublevel), release, pool), fn, "texture", ...)
  --end
--end

local useSet
do
  local function cleanup(self, key, doUnwind, ...)
    if doUnwind then
      unwind(self[key])
    end
    self[key] = nil
    return next(self, ...)
  end
  local function set(self, key, value, ...)
    self[key] = value
    return push(self, cleanup, key, true)
  end
  function useSet(self, ...)
    self.set = set
    return next(push(self, cleanup, "set", false), ...)
  end
end

local function stack(parent, gap, ...)
  local length = select("#", ...)
  local WIDTH = parent:GetWidth() - gap*((length/3)-1)
  local WEIGHT = 0
  for i = 1, length, 3 do
    local elem, width, weight = select(i, ...)
    if weight > 0 then
      WEIGHT = WEIGHT + weight
    elseif width > 0 then
      elem:SetWidth(width)
      WIDTH = WIDTH - width
    else
      WIDTH = WIDTH - elem:GetWidth()
    end
  end
  local height = parent:GetHeight()
  for i = 1, length, 3 do
    local elem, _, weight = select(i, ...)
    elem:SetHeight(height)
    if i == 1 then
      elem:SetPoint("LEFT", parent, "LEFT", 0, 0)
    else
      elem:SetPoint("LEFT", select(i-3, ...), "RIGHT", gap, 0)
    end
    if weight > 0 then
      elem:SetWidth(WIDTH * (weight / WEIGHT))
    end
  end
end

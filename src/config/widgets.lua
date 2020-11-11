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

local function call(self, key, value, ...)
  self[key](self, value)
  return next(self, ...)
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

local function setScript(self, name, func, ...)
  self:SetScript(name, func)
  return next(self, ...)
end

local CreatePool
do
  local counts = {}
  local pools = {}
  local timer
  local created = 0
  local reused = 0
  local released = 0
  local function report()
    timer = nil
    local sum = 0
    for _, pool in ipairs(pools) do
      sum = sum + #pool
    end
    print("SUM", sum)
    print("CREATED", created)
    print("REUSED", reused)
    print("RELEASE", released)
    created = 0
    reused = 0
    released = 0
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
    if action == "create" then
      created = created + 1
    elseif action == "reuse" then
      reused = reused + 1
    elseif action == "release" then
      released = released + 1
    else
      print("WTF")
    end
    trigger()
  end
  local function generic(frame, release, ...)
    return next(push(frame, release), ...)
  end
  function CreatePool(name, fn, a, b, c, d, compose)
    -- compose = compose or generic
    local pool = { name = name }
    table.insert(pools, pool)
    local function acquire(parent)
      local frame
      if #pool == 0 then
        frame = fn(a, b, c, d)
        log(frame, name, "create", 1)
      else
        frame = table.remove(pool)
        log(frame, name, "reuse", 1)
      end
      frame:SetParent(parent)
      frame:Show()
      return frame
    end
    local function release(self, ...)
      self:ClearAllPoints()
      self:Hide()
      assert(select("#", ...) == 0)
      for i in ipairs(self) do
        self[i] = nil
      end
      log(self, name, "release", -1)
      table.insert(pool, self)
    end
    return compose and compose(acquire, release) or function(parent, ...)
      return next(push(acquire(parent), release), ...)
    end
  end
end

local AcquireFrame = CreatePool("FRAME", CreateFrame, "frame", nil, UIParent, "BackdropTemplate")

local AcquireFontString = CreatePool("FONT", UIParent.CreateFontString, UIParent, nil, nil, "GameFontNormal", function(acquire, release)
  local function setup(self, justify, size, text, ...)
    self:SetJustifyH(justify or "CENTER")
    self:SetFont(SquishUI.Media.FONT_VIXAR, size or 14)
    self:SetText(text or "")
    return next(self, ...)
  end
  return function(parent, ...)
    return next(push(acquire(parent), release), setup, ...)
  end
end)

local AcquireTexture = CreatePool("TEXTURE", UIParent.CreateTexture, UIParent, nil, 'ARTWORK', 0, function(acquire, release)
  local function setup(self, layer, level, ...)
    self:SetDrawLayer(layer or 'ARTWORK', sublevel or 0)
    self:SetTexture(nil)
    return next(self, ...)
  end
  return function(parent, ...)
    return next(push(acquire(parent), release), setup, ...)
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
  return function(parent, layer, level, ...)
    return next(push(AcquireTexture(parent, layer or 'OVERLAY', level), cleanup), setup, ...)
  end
end)

local AcquireButton = CreatePool("BUTTON", CreateFrame, "button", nil, UIParent, "UIPanelButtonTemplate", function(acquire, release)
  local function setup(self, fn, ...)
    self:SetScript("OnClick", fn)
    return next(self, ...)
  end
  local function cleanup(self, ...)
    self:SetScript("OnClick", nil)
    self:ClearAllPoints()
    return next(self, ...)
  end
  return function(parent, ...)
    return next(push(acquire(parent), cleanup, release), setup, ...)
  end
end)

local AcquireInput = CreatePool("INPUT", CreateFrame, "editbox", nil, UIParent, "LargeInputBoxTemplate,BackdropTemplate", function(acquire, release)
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
    self.Left:Hide()
    self.Right:Hide()
    self.Middle:Hide()
    self:SetAutoFocus(false)
    return next(self, ...)
  end
  local function cleanup(self, ...)
    self.__initial = nil
    self:SetScript("OnEscapePressed", nil)
    self:SetScript("OnEnterPressed", nil)
    self:SetScript("OnTextChanged", nil)
    self:SetScript("OnTextSet", nil)
    return next(self, ...)
  end
  return function(parent, ...)
    return next(push(acquire(parent), cleanup, release), setup, ...)
  end
end)

local AcquireSortButton = next(nil, function()
  local function setup(self, ...)
    self.__tbl = tbl
    self.__val = 0
    self.__update = updateFN
    self.__func = SetValue
    self.__sort = function(a, b)
      if self.__val > 0 then
        return SRC[a][FIELD], SRC[b][FIELD]
      end
      return SRC[b][FIELD], SRC[a][FIELD]
    end
    self.__text = AcquireFontString(self, "LEFT", 16)
    self.__text:SetPoint("LEFT", 8, -2)
    self.__icon = AcquireTexture(self, 'OVERLAY', 0)
    self.__icon:SetPoint("LEFT", 20, -2)
    self.__icon:SetSize(self:GetHeight() / 1.2, self:GetHeight() / 1.2)
    self.__icon:SetTexture([[Interface\\BUTTONS\\Arrow-Up-Down]])
    self.__icon:Hide()
    self.Text:SetPoint("RIGHT", -8, 0)
    return next(self, ...)
  end
  local function cleanup(self, ...)
    unwind(self.__text)
    self.__text = nil
    self.__icon:SetTexCoord(0, 1, 0, 1)
    unwind(self.__icon)
    self.__icon = nil
    self.__func = nil
    self.__key = key
    self.__tbl = tbl
    self.Text:ClearAllPoints()
    self.Text:SetPoint("CENTER", 0, 0)
    return next(self, ...)
  end
  local function onClick(self, button)
    self:dispatch()
  end
  return function(parent, ...)
    return next(push(AcquireButton(parent, onClick), cleanup), setup, ...)
  end

end)

--local AcquireSortButton = next(nil, function()
  --local function SetValue(self, order)
    --if self.__val == 0 then
      --self.__icon:Hide()
      --self.__text:SetText("")
      --return
    --elseif self.__val > 0 then
      --self.__icon:SetTexCoord(0, 1, 0.5, 1.0)
    --else
      --self.__icon:SetTexCoord(0, 1, 1, 0.5)
    --end
    --self.__icon:Show()
    --self.__text:SetText(order)
  --end
  --local function onclick(self)
    --local tbl = self.__tbl
    --local val = self.__val
    --if val == 0 then
      --self.__val = 1
      --table.insert(tbl, self)
    --elseif val > 0 then
      --self.__val = -1
    --else
      --self.__val = 0
      --for i = 1, #tbl do
        --if self == tbl[i] then
          --table.remove(tbl, i)
          --self:__func(nil)
          --break
        --end
      --end
    --end
    --for i = 1, #tbl do
      --tbl[i]:__func(i)
    --end
    --self.__update()
  --end
  --local function setup(self, tbl, updateFN, SRC, FIELD, ...)
    ---- self.__func = func
    --self.__tbl = tbl
    --self.__val = 0
    --self.__update = updateFN
    --self.__func = SetValue
    --self.__sort = function(a, b)
      --if self.__val > 0 then
        --return SRC[a][FIELD], SRC[b][FIELD]
      --end
      --return SRC[b][FIELD], SRC[a][FIELD]
    --end
    --self.__text = AcquireFontString(self, "LEFT", 16)
    --self.__text:SetPoint("LEFT", 8, -2)
    --self.__icon = AcquireTexture(self, 'OVERLAY', 0)
    --self.__icon:SetPoint("LEFT", 20, -2)
    --self.__icon:SetSize(self:GetHeight() / 1.2, self:GetHeight() / 1.2)
    --self.__icon:SetTexture([[Interface\\BUTTONS\\Arrow-Up-Down]])
    --self.__icon:Hide()
    --self.Text:SetPoint("RIGHT", -8, 0)
    --return next(self, ...)
  --end
  --local function cleanup(self, ...)
    --unwind(self.__text)
    --self.__text = nil
    --self.__icon:SetTexCoord(0, 1, 0, 1)
    --unwind(self.__icon)
    --self.__icon = nil
    --self.__func = nil
    --self.__key = key
    --self.__tbl = tbl
    --self.Text:ClearAllPoints()
    --self.Text:SetPoint("CENTER", 0, 0)
    --return next(self, ...)
  --end
  --return function(parent, ...)
    --return next(push(AcquireButton(parent, onclick), cleanup), setup, ...)
  --end
--end)


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

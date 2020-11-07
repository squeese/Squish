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

local TMP = {}
local function reportCreate(self, kind, ...)
  local key = tostring(self):sub(8)
  TMP[key] = (TMP[key] or 0) + 1
  --print("___CREATE", key, TMP[key], kind, unpack(self))
  return next(self, ...)
end

local function reportReuse(self, kind, ...)
  local key = tostring(self):sub(8)
  TMP[key] = (TMP[key] or 0) + 1
  --print("____REUSE", key, TMP[key], kind)
  return next(self, ...)
end

local function reportRelease(self, pool, ...)
  local key = tostring(self):sub(8)
  TMP[key] = (TMP[key] or 0) - 1
  --print("__RELEASE", key, TMP[key])
  return next(self, ...)
end

local function reportSummary(name)
  local count = 0
  for k, v in pairs(TMP) do
    -- print("SUMMARY", name, k, v)
    count = count + 1
  end
  print("SUMMARY", name, count)
end

local function push(self, ...)
  for i = 1, select("#", ...) do
    local arg = select(i, ...)
    table.insert(self, i, arg)
  end
  return self
end

local function pushN(self, n, ...)
  for i = 1, n do
    local arg = select(i, ...)
    table.insert(self, i, arg)
  end
  return next(self, select(n+1, ...))
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

local function iclean(self)
  for i in ipairs(self) do
    self[i] = nil
  end
  return self
end

local function release(self, pool, ...)
  table.insert(pool, iclean(self))
  reportRelease(self, pool)
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

local AcquireFrame
do
  local pool = {}
  function AcquireFrame(...)
    if #pool > 0 then
      return next(push(table.remove(pool), release, pool), reportReuse, "frame", ...)
    end
    return next(push(CreateFrame("frame", nil, self, "BackdropTemplate"), release, pool), reportCreate, "frame", ...)
  end
end

local AcquireButton
do
  local pool = {}
  function AcquireButton(...)
    if #pool > 0 then
      return next(push(table.remove(pool), release, pool), reportReuse, "button", ...)
    end
    return next(push(CreateFrame("button", nil, self, "UIPanelButtonTemplate"), release, pool), reportCreate, "button", ...)
  end
end

local AcquireFontString
do
  local pool = {}
  function AcquireFontString(...)
    if #pool > 0 then
      return next(push(table.remove(pool), release, pool), reportReuse, "font", ...)
    end
    return next(push(self:CreateFontString(nil, nil, "GameFontNormal"), release, pool), reportCreate, "font", ...)
  end
end

local AcquireTexture
do
  local pool = {}
  local function init(self, layer, sublevel)
    self:SetDrawLayer(layer or 'ARTWORK', sublevel or 0)
    self:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    return self
  end
  function AcquireTexture(layer, sublevel, ...)
    local texture
    local fn
    if #pool > 0 then
      texture = table.remove(pool)
      fn = reportReuse
    else
      texture = self:CreateTexture()
      fn = reportCreate
    end
    return next(push(init(texture, layer, sublevel), release, pool), fn, "texture", ...)
  end
end

--local dropdown
--do
  --local function callback(_, self, value)
    --self.__data[self.__field] = value
    --self.__func(self.__row, self.__index)
  --end
  --local function initialize(self)
    --local current = self.button:GetText()
    --self.info.func = callback
    --self.info.arg1 = self.button
    --if type(self.button.__source) == 'function' then
      --self.button:__source(self.info)
    --else
      --for index, value in ipairs(self.button.__source) do
        --self.info.text = value 
        --self.info.checked = value == current
        --self.info.arg2 = index
        --UIDropDownMenu_AddButton(self.info)
      --end
    --end
  --end
  --local frame
  --local function OnClick(self)
    --if not frame then
      --frame = CreateFrame("frame", nil, self, "UIDropDownMenuTemplate")
      --frame.initialize = initialize
      --frame.displayMode = "MENU"
      --frame.info = UIDropDownMenu_CreateInfo()
    --end
    --frame.button = self
    --ToggleDropDownMenu(1, nil, frame, self, 0, 0)
  --end
  --local function update(self, row, index, data)
    --self:SetText(self.__source[data[self.__field]])
    --self.__data = data
    --self.__row = row
    --self.__index = index
  --end
  --local function cleanup(self, ...)
    --self.__source = nil
    --self.__field = nil
    --self.__func = nil
    --self.__data = nil
    --self.__row = nil
    --self.__index = nil
    --self.Update = nil
    --self:SetScript("OnClick", nil)
    --return next(self, ...)
  --end
  --function dropdown(self, source, field, func, ...)
    --self.__source = source
    --self.__field = field
    --self.__func = func
    --self.Update = update
    --self:SetScript("OnClick", OnClick)
    --return next(push(self, cleanup), ...)
  --end
--end


--local AcquireDropdown
--do
  --local pool = {}

  --local function SetSelectedValue(self, ...)
    --local args = select("#", ...)-1
    --for i = (args+1), self.__dropdownArgs do
      --self['__dropdownArg'..i] = nil
    --end
    --for i = 1, args do
      --self['__dropdownArg'..i] = select(i, ...)
    --end
    --self.__dropdownArgs = args
    --UIDropDownMenu_Initialize(self, self.__dropdownInit)
    --UIDropDownMenu_SetSelectedValue(self, select(args+1, ...))
  --end

  --local function setup(self, init, func, ...)
    --self.__dropdownInit = init
    --self.__dropdownFunc = func
    --self.__dropdownArgs = 0
    --self.SetSelectedValue = SetSelectedValue
    --return next(self, ...)
  --end

  --local function cleanup(self, ...)
    --self.__dropdownInit = nil
    --self.__dropdownFunc = nil
    --for i = 1, self.__dropdownArgs do
      --self['__dropdownArg'..i] = nil
    --end
    --self.__dropdownArgs = nil
    --self.SetSelectedValue = nil
    --return next(self, ...)
  --end

  --function AcquireDropdown(init, func, ...)
    --local frame
    --if #pool > 0 then
      --frame = table.remove(pool)
    --else
      --frame = CreateFrame("frame", nil, self, "UIDropDownMenuTemplate")
    --end

    --return next(push(frame, cleanup, release, pool), setup, func, ...)
  --end
--end


--local AcquireRowIcon
--local AcquireRowText
--local AcquireRowDropdown
--local AcquireRowButton
--do
  --local function cleanup(self, ...)
    --self.__width = nil
    --self.__weight = nil
    --return next(self, ...)
  --end
  --local function setup(self, width, weight, ...)
    --self.__width = width or 0
    --self.__weight = weight or 0
    --return next(self, ...)
  --end
  --function AcquireRowIcon(parent, ...)
    --return push(AcquireTexture('OVERLAY', 0, setParentAndShow, parent, setup, parent:GetHeight(), nil, ...), cleanup)
  --end
  --function AcquireRowText(parent, width, weight, ...)
    --return push(AcquireFontString(setParentAndShow, parent, setup, width, weight, ...), cleanup)
  --end
  --function AcquireRowDropdown(parent, width, weight, init, func, ...)
    --return push(AcquireDropdown(init, func, setParentAndShow, parent, setup, width, weight, ...), cleanup)
  --end
  --function AcquireRowButton(parent, width, weight, ...)
    --return push(AcquireButton(setParentAndShow, parent, setup, width, weight, ...), cleanup)
  --end
--end

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



--local function CreateDropdownInitializer(source)
  --local tbl = {}
  --local info = UIDropDownMenu_CreateInfo()
  --function info:func(self, index)
    --for i = 1, self.__dropdownArgs do
      --table.insert(tbl, self['__dropdownArg'..i])
    --end
    --table.insert(tbl, index)
    --self.__dropdownFunc(unpack(tbl))
    --for i = 1, (self.__dropdownArgs+1) do
      --tbl[i] = nil
    --end
  --end
  --return function(self)
    --info.arg1 = self
    --for index = 1, #source do
      --info.text = source[index]
      --info.checked = false
      --info.value = index
      --info.arg2 = index
      --UIDropDownMenu_AddButton(info)
    --end
  --end
--end

--local InitClassDropdown
--do
  --info.func = function(_, dropdown, index)
    --print("click", dropdown.__rowIndex, index)
  --end
  --function InitClassDropdown(self)
    --info.arg1 = self
    --for index = 1, #SquishUI.FIELD_CLASS_VALUES do
      --info.text = SquishUI.FIELD_CLASS_VALUES[index]
      --info.checked = false
      --info.value = index
      --info.arg2 = index
      --UIDropDownMenu_AddButton(info)
    --end
  --end
--end


--local function SetParentAndShow(self, parent)
  --if parent then
    --self:SetParent(parent)
  --end
  --self:Show()
  --return self
--end

--local function ClearAndHide(self)
  --self:ClearAllPoints()
  --self:Hide()
  --return self
--end

--local function RowSpellIcon(self, ...)
  --local height = self:GetParent():GetHeight()
  --self:SetSize(height, height)
  --return Modify(self, ...)
--end

--local function SetSize(self, size, ...)
  --self:SetSize(size, size)
  --return Modify(self, ...)
--end

--local function MaxHeight(self, ...)
  --self:SetHeight(self:GetParent():GetHeight())
  --return Modify(self, ...)
--end

--do
  --local framePool = {}
  --local function Release(...)
    --table.insert(framePool, ClearAndHide(Modify(...)))
  --end
  --function self:AcquireFrame(parent, ...)
    --if #framePool > 0 then
      --return Modify(SetParentAndShow(table.remove(framePool), parent), ...)
    --end
    --local frame = CreateFrame("frame", nil, self:root(), "BackdropTemplate")
    --frame.Release = Release
    --return Modify(SetParentAndShow(frame, parent), ...)
  --end
--end

--do
  --local buttonPool = {}
  --local function Release(...)
    --table.insert(buttonPool, ClearAndHide(Modify(...)))
  --end
  --function self:AcquireButton(parent, ...)
    --if #buttonPool > 0 then
      --return Modify(SetParentAndShow(table.remove(buttonPool), parent), ...)
    --end
    --local button = CreateFrame("button", nil, self:root(), "UIPanelButtonTemplate")
    --button.Release = Release
    --return Modify(SetParentAndShow(button, parent), ...)
  --end
--end

--do
  --local fontStringPool = {}
  --local function Release(...)
    --table.insert(fontStringPool, ClearAndHide(Modify(...)))
  --end
  --function self:AcquireFontString(parent, ...)
    --if #fontStringPool > 0 then
      --return Modify(SetParentAndShow(table.remove(fontStringPool), parent), ...)
    --end
    --local font = self:root():CreateFontString(nil, nil, "GameFontNormal")
    --font:SetFont(SquishUI.Media.FONT_VIXAR, 16)
    --font.Release = Release
    --return Modify(SetParentAndShow(font, parent), ...)
  --end
--end

--do
  --local texturePool = {}
  --local function Release(...)
    --table.insert(texturePool, ClearAndHide(Modify(...)))
  --end
  --function self:AcquireTexture(parent, ...)
    --if #texturePool > 0 then
      --return Modify(SetParentAndShow(table.remove(texturePool), parent), ...)
    --end
    --local texture = self:root():CreateTexture(nil, 'OVERLAY')
    --texture.Release = Release
    --return Modify(SetParentAndShow(texture, parent), ...)
  --end
--end


--do
  --local inputPool = {}
  --local function Setup(self)
    --self:SetAutoFocus(false)
    --self:SetFont(SquishUI.Media.FONT_VIXAR, 14)
    --self:SetBackdrop(SquishUI.Media:CreateBackdrop(true, nil, 0, 1))
    --self:SetBackdropColor(0, 0, 0, 0.15)
    --self.Left:Hide()
    --self.Middle:Hide()
    --self.Right:Hide()
    --return self
  --end
  --local function Cleanup(self)
    --self:SetScript("OnEnterPressed", nil)
    --self:SetScript("OnEscapePressed", nil)
    --self:SetScript("OnTextChanged", nil)
    --self:SetScript("OnTextSet", nil)
    --return self
  --end
  --local function Release(...)
    --table.insert(inputPool, ClearAndHide(Cleanup(Modify(...))))
  --end
  --function self:AcquireInput(parent, ...)
    --if #inputPool > 0 then
      --return Modify(Setup(SetParentAndShow(table.remove(inputPool), parent)), ...)
    --end
    --local input = CreateFrame("editbox", nil, self:root(), "LargeInputBoxTemplate,BackdropTemplate")
    --input.Release = Release
    --return Modify(Setup(SetParentAndShow(input, parent)), ...)
  --end
--end


--do
  --local function Push(self, ...)
    --for i = 1, select("#", ...) do
      --local arg = select(i, ...)
      --table.insert(self, i, arg)
    --end
    --return self
  --end

  --local function release(frame, pool)
    --table.insert(pool, frame)
  --end

  --local framePool = {}
  --local function createFrame(parent, ...)
    --print("createFrame", parent)
    --if #framePool > 0 then
      --return Modify(Push(table.remove(framePool), Release, framePool), ...)
    --end
    --local frame = CreateFrame("frame", nil, parent, "BackdropTemplate")
    --return Modify(Push(frame, release, framePool), ...)
  --end

  --local function clearAndHide(frame, ...)
    --print("clearAndHide", frame)
    --frame:ClearAllPoints()
    --frame:Hide()
    --return Modify(frame, ...)
  --end

  --local function setParentAndShow(frame, parent, ...)
    --print("setParentAndShow", frame, parent)
    --frame:SetParent(parent)
    --frame:Show()
    --return Modify(Push(frame, clearAndHide), ...)
  --end

  --local function remKey(frame, key, ...)
    --print("remKey", frame, key)
    --frame[key] = nil
    --return Modify(frame, ...)
  --end
  --local function setKey(frame, key, value, ...)
    --print("setke", key, value)
    --frame[key] = value
    --return Modify(Push(frame, remKey, key), ...)
  --end

  --local function BOB(self, width, height, ...)
    --self:SetSize(width, height)
    --self:SetPoint(...)
  --end

  --local function unsetBackdrop(frame, ...)
    --print("unset backrop", frame)
    --frame:SetBackdrop(nil)
    --return Modify(frame, ...)
  --end

  --local function setBackdrop(frame, r, g, b, a, ...)
    --print("setbackdrop", r, g, b, a)
    --frame:SetBackdrop(SquishUI.Media:CreateBackdrop(true, nil, 0, 0))
    --frame:SetBackdropColor(r, g, b, a)
    --return Modify(Push(frame, unsetBackdrop), ...)
  --end

  --local f = createFrame(UIParent, setParentAndShow, UIParent, setKey, "BOB", BOB, setBackdrop, 0, 0, 0, 1)
  --f:BOB(100, 100, "CENTER", 0, 0)
  --print(BOB, f.BOB)
  --Modify(f, unpack(f))
--end

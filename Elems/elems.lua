local Squish = select(2, ...)
local Elems = Squish.Elems
local Set = Elems.Set

Elems("Base", nil, {
  upgrade = function(self, props)
    for index, child in ipairs(props) do
      if type(child) == "table" and child.__index == nil then
        props[index] = Set(child)
      end
    end
    return props
  end
})

Elems("Frame", "Base", {
  __pool = CreateFramePool("frame", UIParent, nil, nil),
  mount = function(self, parent)
    self.__super.mount(self, parent)
    self.__frame = self.__pool:Acquire()
    self.__frame:SetParent(self.__parent.__frame)
    self.__frame:ClearAllPoints()
    self.__frame:Show()
  end,
  copy = function(self, other, parent)
    self.__super.copy(self, other, parent)
    self.__frame:ClearAllPoints()
  end,
  remove = function(self)
    self.__pool:Release(self.__frame)
    self.__super.remove(self)
  end,
})

Elems("Text", "Base", {
  __pool = CreateFontStringPool(UIParent, nil, nil, 'GameFontNormal'),
  mount = function(self, parent)
    self.__super.mount(self, parent)
    self.__frame = self.__pool:Acquire()
    self.__frame:SetParent(self.__parent.__frame)
    self.__frame:ClearAllPoints()
    self.__frame:Show()
  end,
  copy = function(self, other, parent)
    self.__super.copy(self, other, parent)
    self.__frame:ClearAllPoints()
  end,
  remove = function(self)
    self.__pool:Release(self.__frame)
    self.__super.remove(self)
  end,
})

Elems("Button", "Base", {
  __pool = CreateFramePool("button", UIParent, 'UIPanelButtonTemplate', nil),
  mount = function(self, parent)
    self.__super.mount(self, parent)
    self.__frame = self.__pool:Acquire()
    self.__frame:SetParent(self.__parent.__frame)
    self.__frame:ClearAllPoints()
    self.__frame:Show()
  end,
  remove = function(self)
    self.__pool:Release(self.__frame)
    self.__super.remove(self)
  end,
})
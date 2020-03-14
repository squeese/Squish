local Squish = select(2, ...)

local Frame = Squish.Elems.Base{ __name = 'Frame' }
Squish.Elems.Frame = Frame

function Frame:mount(parent)
  self.__super.mount(self, parent)
  self.__frame = CreateFrame('frame', nil, self.__parent.__frame)
  self.__frame:ClearAllPoints()
  self.__frame:Show()
end

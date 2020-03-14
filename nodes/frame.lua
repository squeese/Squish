local Nodes = select(2, ...).Nodes

Nodes.Frame = Nodes.Base {
  __kind = 'Frame',

  setFrame = function(self)
    local frame = table.remove(self:getPool()) or CreateFrame('frame', nil, self.__parent.__frame)
    frame:SetParent(self.__parent.__frame)
    frame:ClearAllPoints()
    frame:Show()
    return frame
  end,

  remove = function(self, ...)
    self.__frame:SetParent(UIParent)
    self.__frame:Hide()
    table.insert(self:getPool(), self.__frame)
    return Nodes.Base.remove(self, ...)
  end,

  __tooltipBackdrop = {
    bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
    tile = true, tileSize = 16, edgeSize = 16, 
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
  }
}
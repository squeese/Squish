local Nodes = select(2, ...).Nodes

Nodes.Button = Nodes.Base {
  __kind = 'Button',
  __pool = 'buttons',
  __template = 'UIPanelButtonTemplate',

  setFrame = function(self)
    local frame = table.remove(self:getPool()) or CreateFrame('Button', nil, self.__parent.__frame, self.__template)
    frame:SetParent(self.__parent.__frame)
    frame:ClearAllPoints()
    frame:Show()
    return frame
  end,

  remove = Nodes.Frame.remove
}
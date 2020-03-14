local Nodes = select(2, ...).Nodes

Nodes.Text = Nodes.Base {
  __kind = 'Text',
  __template = 'GameFontNormal',

  getPoolIdentifier = function(self)
    return (self.__pool or self.__parent.__frame)
  end,

  setFrame = function(self)
    local frame = table.remove(self:getPool()) or self.__parent.__frame:CreateFontString(nil, nil, self.__template)
    frame:SetParent(self.__parent.__frame)
    frame:ClearAllPoints()
    frame:Show()
    return frame
  end,

  remove = Nodes.Frame.remove
}
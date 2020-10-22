local Q = select(2, ...)
local OnEvent
local OnAttributeChanged

function Q.Party(parent, ...)
  local frame = CreateFrame('frame', 'SquishHeader_Party', parent, 'SecureGroupHeaderTemplate')
  frame:SetAttribute('template', 'SecureActionButtonTemplate,BackdropTemplate')
  frame:SetAttribute('initialConfigFunction', [[
    self:SetWidth(101)
    self:SetHeight(46)
    self:SetAttribute('*type1', 'target')
    self:SetAttribute('*type2', 'togglemenu')
    self:SetAttribute('toggleForVehicle', true)
    RegisterUnitWatch(self)
    self:GetParent():CallMethod('initialConfigFunction', self:GetName())
  ]])

  function frame:initialConfigFunction(name)
    local button = _G[name]
    button:RegisterForClicks('AnyUp')
    button:SetScript('OnEnter', UnitFrame_OnEnter)
    button:SetScript('OnLeave', UnitFrame_OnLeave)
    button:SetScript('OnEvent', OnEvent)
    button:SetScript('OnAttributeChanged', OnAttributeChanged)
  end

  frame:SetAttribute('showParty', true)
  frame:SetAttribute('showPlayer', true)
  frame:SetAttribute('xOffset', 0)
  frame:SetAttribute('yOffset', 4)
  frame:SetAttribute('point', 'BOTTOM')
  frame:SetAttribute('groupBy', 'ASSIGNEDROLE')
  frame:SetAttribute('groupingOrder', 'TANK,DAMAGER,HEALER')
  RegisterAttributeDriver(frame, 'state-visibility', '[group:party] show; hide')

  
  
  

  return frame
end

OnEvent = function(self, event, ...)
end

OnAttributeChanged = function(self, key, value)
end

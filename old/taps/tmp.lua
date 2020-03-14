local Observable = require and require('./libs/Observable')


--[[
if false then
  local h = CreateFrame('frame', 'PSHeader', UIParent, 'SecureGroupHeaderTemplate')
  h:SetAttribute('template', 'SecureActionButtonTemplate')
  h:SetAttribute('initialConfigFunction', [--[
    self:SetWidth(120)
    self:SetHeight(40)
    self:SetAttribute('*type1', 'target')
    self:SetAttribute('*type2', 'togglemenu')
    self:SetAttribute('toggleForVehicle', true)
    RegisterUnitWatch(self)
    self:GetParent():CallMethod('InitializeButton', self:GetName())
  ]--])
  function h:InitializeButton(name)
    local button = _G[name]
    button:SetBackdrop({
      bgFile   = "Interface/Tooltips/UI-Tooltip-Background", 
      edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
      tile     = true, tileSize = 16, edgeSize = 16, 
      insets   = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    local text = button:CreateFontString(nil, nil, 'GameFontNormal')
    text:SetAllPoints()
    text:SetText('unit')
    local spam = {}
    button:SetScript('OnAttributeChanged', function(self, key, value)
      if spam[key] ~= value then
        spam[key] = value
        if key == 'unit' then
          if value then
            text:SetText(value .. ' / ' .. UnitName(value))
          else
            text:SetText('-------')
          end
        end
      end
    end)
  end
  h:SetAttribute('showRaid', true)
  h:SetAttribute('showParty', true)
  h:SetAttribute('showPlayer', true)
  h:SetAttribute('showSolo', true)
  h:SetAttribute('xOffset', -1)
  h:SetAttribute('columnSpacing')
  h:SetAttribute('point', 'RIGHT')
  h:SetAttribute('columnAnchorPoint', 'BOTTOM')
  h:SetAttribute('groupBy', 'ASSIGNEDROLE')
  h:SetAttribute('groupingOrder', 'TANK,DAMAGER,HEALER')
  h:SetAttribute('groupFilter', 1)
  h:SetPoint('CENTER', 0, 0)
  RegisterAttributeDriver(h, 'state-visibility', 'show')
end


local function Button(point, text, onclick)
  local button = CreateFrame('button', nil, UIParent, 'UIPanelButtonTemplate')
  button:SetSize(21 + 8 * string.len(text), 30)
  button:SetPoint(unpack(point))
  button:SetText(text)
  button:SetScript('OnClick', onclick)
  return button
end
]]

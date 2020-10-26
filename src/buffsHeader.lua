${template('PlayerBuffsHeader', (parent, size, unit, filter, clickable, name) => `
  local self = CreateFrame('frame', 'Squish'..'${name}', ${parent}, 'SecureAuraHeaderTemplate')
  self:SetAttribute('template', 'SecureActionButtonTemplate BackdropTemplate')
  self:SetAttribute("_ignore", "attributeChanges")
  self:SetAttribute('initialConfigFunction', [[
    self:SetWidth(${size})
    self:SetHeight(${size})
    ${clickable ? `self:SetAttribute('type', 'cancelaura')` : ""}
    self:GetParent():CallMethod('configure', self:GetName())
  ]])
  self:SetAttribute('point', 'TOPRIGHT')
  self:SetAttribute('unit', '${unit}')
  self:SetAttribute('filter', '${filter}')
  self:SetAttribute('sortDirection', '-')
  self:SetAttribute('sortMethod', 'TIME,NAME')
  self:SetAttribute('minWidth', ${size})
  self:SetAttribute('minHeight', ${size})
  self:SetAttribute('xOffset', ${-size-2})
  self:SetAttribute('yOffset', 0) 
  function self:configure(name)
    local button = _G[name]
    button.filter = "${filter}"
    button.unit = "${unit}"
    ${clickable ? `button:RegisterForClicks("RightButtonUp")` : ""}
    button:SetBackdrop(MEDIA:BACKDROP(nil, true, 4, 0))
    button:SetBackdropColor(0, 0, 0, 0.75)
    button.icon = button:CreateTexture()
    button.icon:SetPoint("TOPLEFT", 4, -4)
    button.icon:SetPoint("BOTTOMRIGHT", -4, 4)
    button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    ${FontString_Aura("button.time", 12, "button")}
    button.time:SetPoint("TOP", button, "BOTTOM", 0, -4)
    ${FontString_Aura("button.stack", 18, "button")}
    button.stack:SetPoint("BOTTOMRIGHT", -4, 4)
    button:RegisterUnitEvent("UNIT_AURA", "${unit}")
    button:SetScript('OnAttributeChanged', OnAttributeChanged_AuraButton)
    button:SetScript('OnEnter', OnEnter_AuraButton)
    button:SetScript('OnLeave', OnLeave_AuraButton)
    button:SetScript('OnEvent', OnEvent_AuraButton)
  end
  RegisterAttributeDriver(self, 'unit', '[vehicleui] vehicle; player')
  RegisterStateDriver(self, 'visibility', '[petbattle] hide; show')
`)}

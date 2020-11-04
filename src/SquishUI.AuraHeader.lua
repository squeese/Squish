${locals.use("table.remove")}
${locals.use("table.insert")}
local CreateAuraHeader
do
  local OnAttributeChanged
  local OnEnter_AuraButton
  local OnLeave_AuraButton
  ${cleanup.add("CreateAuraHeader")}
  function CreateAuraHeader(parent, size, unit, filter, clickable, name)
    local self = CreateFrame('frame', 'Squish'..name, parent, 'SecureAuraHeaderTemplate')
    self:SetAttribute('template', 'SecureActionButtonTemplate BackdropTemplate')
    self:SetAttribute("_ignore", "attributeChanges")
    self:SetAttribute('initialConfigFunction', [[
      self:SetWidth(]]..size..[[)
      self:SetHeight(]]..size..[[)
      ]]..(clickable and "self:SetAttribute('type', 'cancelaura')" or "")..[[
      self:GetParent():CallMethod('configure', self:GetName())
    ]])
    self:SetAttribute('point', 'TOPRIGHT')
    self:SetAttribute('unit', unit)
    self:SetAttribute('filter', filter)
    self:SetAttribute('sortDirection', '-')
    self:SetAttribute('sortMethod', 'TIME,NAME')
    self:SetAttribute('minWidth', size)
    self:SetAttribute('minHeight', size)
    self:SetAttribute('xOffset', -size-2)
    self:SetAttribute('yOffset', 0) 
    function self:configure(name)
      local button = _G[name]
      button.filter = filter
      button.unit = unit
      if clickable then
        button:RegisterForClicks("RightButtonUp")
      end
      button:SetBackdrop(Media:CreateBackdrop(nil, true, 4, 0))
      button:SetBackdropColor(0, 0, 0, 0.75)
      button.icon = button:CreateTexture()
      button.icon:SetPoint("TOPLEFT", 4, -4)
      button.icon:SetPoint("BOTTOMRIGHT", -4, 4)
      button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
      ${FontString_Aura("button.time", 12, "button")}
      button.time:SetPoint("TOP", button, "BOTTOM", 0, -4)
      ${FontString_Aura("button.stack", 18, "button")}
      button.stack:SetPoint("BOTTOMRIGHT", -4, 4)
      button:RegisterUnitEvent("UNIT_AURA", unit)
      button:SetScript('OnAttributeChanged', OnAttributeChanged_AuraButton)
      button:SetScript('OnEnter', OnEnter_AuraButton)
      button:SetScript('OnLeave', OnLeave_AuraButton)
      button:SetScript('OnEvent', OnEvent_AuraButton)
    end
    RegisterAttributeDriver(self, 'unit', '[vehicleui] vehicle; player')
    RegisterStateDriver(self, 'visibility', '[petbattle] hide; show')
    return self
  end

  function OnEnter_AuraButton(self)
    if not self:IsVisible() then return end
    GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMRIGHT')
    GameTooltip:SetUnitAura(self.unit, self.index, self.filter)
    local _, _, _, _, _, _, _, _, _, id = UnitAura(self.unit, self.index, self.filter)
    GameTooltip:AddLine("ID: " .. tostring(id), 1, 1, 1) 
  end

  function OnLeave_AuraButton()
    GameTooltip:Hide()
  end

  do
    local ticker = {}
    do
      local function SetDuration(button, now)
        local duration = button.expires - now
        if duration < 60 then
          button.time:SetFormattedText("%ds", duration)
        elseif duration < 3600 then
          button.time:SetFormattedText("%dm", ceil(duration / 60))
          button.padd = (duration % 60) - 0.5
        else
          button.time:SetText("alot")
        end
      end
      local prev = GetTime()
      C_Timer.NewTicker(0.5, function()
        local now = GetTime()
        local elapsed = now - prev
        for index = 1, #ticker do
          local button = ticker[index]
          if button.padd > 0 then
            button.padd = button.padd - elapsed
          else
            SetDuration(button, now)
          end
        end
        prev = now
      end)
      function ticker:insert(button)
        button.padd = 0
        SetDuration(button, GetTime())
        if button.active then return end
        button.active = true
        Table_Insert(self, button)
      end
      function ticker:remove(button)
        if not button.active then return end
        button.active = false
        for i = 1, #self do
          if button == self[i] then
            Table_Remove(self, i)
            return
          end
        end
      end
    end

    local function Update(self)
      local name, texture, count, kind, duration, expires, x, _, c = UnitAura(self.unit, self.index, self.filter)
      self.icon:SetTexture(texture)
      if count and count > 0 then
        self.stack:Show()
        self.stack:SetText(count)
      else
        self.stack:Hide()
      end
      if kind then
        local color = DebuffTypeColor[kind]
        self:SetBackdropBorderColor(color.r, color.g, color.b, 1)
      else
        self:SetBackdropBorderColor(0, 0, 0, 0)
      end
      if duration > 0 then
        self.time:Show()
        self.expires = expires
        ticker:insert(self)
      else
        self.time:Hide()
        ticker:remove(self)
      end
    end

    local function OnEvent_AuraButton(self)
      if not self:IsVisible() then
        ticker:remove(self)
        self:SetScript("OnEvent", nil)
      end
    end

    function OnAttributeChanged_AuraButton(self, key, value)
      if key == 'index' then
        self.index = value
        Update(self)
        self:SetScript("OnEvent", OnEvent_AuraButton)
      end
    end
  end
end

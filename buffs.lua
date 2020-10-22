local Q = select(2, ...)

local function OnUpdate(self, elapsed)
  self.duration = self.duration - elapsed
  if self.duration < 60 then
    self.time:SetFormattedText("%ds", self.duration)
  elseif self.duration < 3600 then
    self.time:SetFormattedText("%dm", ceil(self.duration / 60))
  else
    self.time:SetText("alot")
  end
  -- print(SecondsToTime(self.duration, false, true))
  if self.duration <= 0 then
    self.time:SetText("0 s")
    self:SetScript("OnUpdate", nil)
  end
end

function Q.Buffs(parent, ...)
  local header = CreateFrame('frame', 'SquishBuffs', parent, 'SecureAuraHeaderTemplate')

  header:SetAttribute('template', 'SecureActionButtonTemplate')
  header:SetAttribute('initialConfigFunction', [[
    self:SetWidth(48)
    self:SetHeight(48)
    self:SetAttribute('type', 'cancelaura')
    self:GetParent():CallMethod('initialConfigFunction', self:GetName())
  ]])

  local function OnEnter(self)
    if not self:IsVisible() then return end
    GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMRIGHT')
    GameTooltip:SetUnitAura("player", self.index, "HELPFUL")
  end

  local function OnLeave()
    GameTooltip:Hide()
  end

  function header:initialConfigFunction(name)
    local button = _G[name]
    button:RegisterForClicks("RightButtonUp")
    button:SetBackdrop(Q.BACKDROP)
    button:SetBackdropColor(0, 0, 0, 0.75)
    button:SetScript('OnEnter', OnEnter)
    button:SetScript('OnLeave', OnLeave)

    local icon = button:CreateTexture()
    icon:SetAllPoints()
    icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

    local time = button:CreateFontString(nil, nil, "GameFontNormal")
    time:SetPoint("BOTTOM", 0, -20)
    time:SetFont(Q.FONT, 13, "OUTLINE")
    button.time = time

    local stack = button:CreateFontString(nil, nil, "GameFontNormal")
    stack:SetPoint("BOTTOMRIGHT", -2, 2)
    stack:SetFont(Q.FONT, 15, "OUTLINE")

    button:SetScript('OnAttributeChanged', function(_, key, value)
      if key == 'index' then -- and button.index ~= value then
        local name, texture, count, _, duration, expires = UnitAura("player", value)
        icon:SetTexture(texture)
        if duration > 0 then
          time:Show()
          button.duration = Round(expires - GetTime(), 3)
          button:SetScript("OnUpdate", OnUpdate)
        else
          time:Hide()
          button:SetScript("OnUpdate", nil)
        end
        if count and count > 0 then
          stack:Show()
          stack:SetText(count)
        else
          stack:Hide()
        end
        button.index = value
      end
    end)
  end

  header:SetAttribute('point', 'RIGHT')
  header:SetAttribute('unit', 'player')
  header:SetAttribute('filter', 'HELPFUL')
  header:SetAttribute('sortMethod', 'TIME')
  header:SetAttribute('sortDirection', '-')
  header:SetAttribute('minWidth', 48)
  header:SetAttribute('minHeight', 48)
  header:SetAttribute('xOffset', -52)
  -- header:SetAttribute('wrapYOffset', 0)
  -- header:SetAttribute('wrapAfter', 3)
  -- header:SetAttribute('maxWraps', 3)
  RegisterAttributeDriver(header, 'unit', '[vehicleui] vehicle; player')
  RegisterStateDriver(header, 'visibility', '[petbattle] hide; show')

  header:SetPoint(...)
  header:Show()
end

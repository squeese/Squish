local Q = select(2, ...)
local Range = Q.Range
local HealthBar = Q.HealthBar
local BACKDROP = Q.BACKDROP
local BAR = Q.BAR
local FONT = Q.FONT

local function StackIcons(self, POINT, RELPOINT, X, Y, point, relpoint, x, y, ...)
  local anchor = nil
  for i = 1, select("#", ...) do
    local icon = select(i, ...)
    if icon:IsShown() then
      if anchor == nil then
        icon:SetPoint(POINT, self, RELPOINT, X, Y)
      else
        icon:SetPoint(point, anchor, relpoint, x, y)
      end
      anchor = icon
    end
  end
end


local function UpdateHealth(self)
  local maxHealth = UnitHealthMax(self.unit)
  local curHealth = UnitHealth(self.unit)
  self.health:SetMinMaxValues(0, maxHealth)
  self.shield:SetMinMaxValues(0, maxHealth)
  self.absorb:SetMinMaxValues(0, maxHealth)
  self.health:SetValue(curHealth)
  self.shield:SetValue(curHealth + UnitGetTotalAbsorbs(self.unit))
  self.absorb:SetValue(UnitGetTotalHealAbsorbs(self.unit))
  local r, g, b = Q.ClassColor(self.unit)
  self.health:SetStatusBarColor(r, g, b)
  self.healthBG:SetVertexColor(r*0.2, g*0.2, b*0.2, 0.2)
  self.textName:SetText(UnitName(self.unit):sub(1, 4))
end

local function UpdateLeaderIcons(self)
  self.leader:Hide()
  self.assistant:Hide()
  if UnitInParty(self.unit) then
    if UnitIsGroupLeader(self.unit) then
      self.leader:Show()
    elseif UnitIsGroupAssistant(self.unit) then
      self.assistant:Show()
    end
  end
end

local function UpdateRoleIcon(self)
  self.role:Hide()
  local role = UnitGroupRolesAssigned(self.unit)
  if role == 'TANK' or role == 'HEALER' then
    self.role:Show()
    self.role:SetTexCoord(GetTexCoordsForRoleSmallCircle(role))
  end
end

local function OnEvent(self, event, unit, ...)
  if event == "PLAYER_ENTERING_WORLD"
    or event == "GROUP_ROSTER_UPDATE"
    or event == "PARTY_LEADER_CHANGED"
    or event == "PLAYER_ROLES_ASSIGNED" then
    UpdateHealth(self)
    UpdateLeaderIcons(self)
    UpdateRoleIcon(self)
    StackIcons(self, "TOPLEFT", "TOPLEFT", 2, -4, "TOP", "BOTTOM", 0, 0, self.role, self.leader, self.assistant)

  elseif unit ~= nil and self.unit ~= unit then
    return

  elseif event == "UNIT_MAXHEALTH" or event == "UNIT_FACTION" or event == "UNIT_CONNECTION" then
    UpdateHealth(self)

  elseif event == "UNIT_HEALTH" or event == "UNIT_ABSORB_AMOUNT_CHANGED" then
    local value = UnitHealth(unit)
    self.health:SetValue(value)
    self.shield:SetValue(value + UnitGetTotalAbsorbs(self.unit))

  elseif event == "UNIT_AURA" then
    -- update...atonement

  elseif event == "UNIT_PHASE" then
    -- local isInSamePhase = not UnitPhaseReason(unit)
    -- if(not isInSamePhase and UnitIsPlayer(unit) and UnitIsConnected(unit)) then

  elseif event == "UNIT_HEAL_ABSORB_AMOUNT_CHANGED" then
    self.absorb:SetValue(UnitGetTotalHealAbsorbs(self.unit))
  end
end

local function OnAttributeChanged(self, key, value)
  if key ~= 'unit' or self.unit == value then
    -- skip non unit attributes
    -- skip non changing unit attribute values
    return
  elseif self.unit == nil then
    -- button's unit is being set for the first time, button is now active, was idle/new
    -- register all the events we need to keep the button updated
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("PLAYER_ROLES_ASSIGNED")
    self:RegisterEvent("GROUP_ROSTER_UPDATE")
    self:RegisterEvent("PARTY_LEADER_CHANGED")
    self:RegisterEvent("UNIT_MAXHEALTH")
    self:RegisterEvent("UNIT_HEALTH")
    self:RegisterEvent("UNIT_FACTION")
    self:RegisterEvent("UNIT_CONNECTION")
    self:RegisterEvent('UNIT_ABSORB_AMOUNT_CHANGED')
    self:RegisterEvent('UNIT_HEAL_ABSORB_AMOUNT_CHANGED')
    self:RegisterEvent("UNIT_AURA")
    self:RegisterEvent("UNIT_PHASE")
    if not UnitIsUnit(value, "player") then
      Range:Register(self)
    end
    self.unit = value
    OnEvent(self, "GROUP_ROSTER_UPDATE")
  elseif value ~= nil then
    -- button's unit is being changed to a new unit
    Range:Unregister(self)
    if not UnitIsUnit(value, "player") then
      Range:Register(self)
    end
    self.unit = value
    OnEvent(self, "GROUP_ROSTER_UPDATE")
  else
    -- button's unit is being removed, button is now idle
    self:UnregisterAllEvents()
    Range:Unregister(self)
    self.unit = nil
  end
end

function Q.Party(parent, ...)
  local header = CreateFrame('frame', 'SquishParty', parent, 'SecureGroupHeaderTemplate')
  header:SetAttribute('template', 'SecureActionButtonTemplate,BackdropTemplate')
  header:SetAttribute('initialConfigFunction', [[
    self:SetWidth(101)
    self:SetHeight(64)
    self:SetAttribute('*type1', 'target')
    self:SetAttribute('*type2', 'togglemenu')
    self:SetAttribute('toggleForVehicle', true)
    RegisterUnitWatch(self)
    self:GetParent():CallMethod('initialConfigFunction', self:GetName())
  ]])

  function header:initialConfigFunction(name)
    local button = _G[name]
    button:SetBackdrop(BACKDROP)
    button:SetBackdropColor(0, 0, 0, 0.75)
    button:RegisterForClicks('AnyUp')
    button:SetScript('OnEnter', UnitFrame_OnEnter)
    button:SetScript('OnLeave', UnitFrame_OnLeave)
    button:SetScript("OnEvent", OnEvent)
    button:SetScript('OnAttributeChanged', OnAttributeChanged)

    button.shield = CreateFrame("statusbar", nil, button)
    button.shield:SetStatusBarTexture(BAR)
    button.shield:SetAllPoints()
    button.shield:SetStatusBarColor(1.0, 1.0, 1.0, 1.0)
    button.shield:SetFrameLevel(2)

    button.health = CreateFrame("statusbar", nil, button)
    button.health:SetStatusBarTexture(BAR)
    button.health:SetAllPoints()
    button.health:SetFrameLevel(3)

    button.absorb = CreateFrame("statusbar", nil, button)
    button.absorb:SetStatusBarTexture(BAR)
    button.absorb:SetAllPoints()
    button.absorb:SetStatusBarColor(1.0, 0.0, 0.0, 0.65)
    button.absorb:SetFrameLevel(4)

    button.healthBG = button.health:CreateTexture(nil, "BACKGROUND")
    button.healthBG:SetAllPoints()
    button.healthBG:SetTexture(BAR)

    button.textName = button.health:CreateFontString(nil, nil, "GameFontNormal")
    button.textName:SetPoint("CENTER", 0, 0)
    button.textName:SetFont(FONT, 14, "OUTLINE")

    button.textStatus = button.health:CreateFontString(nil, nil, "GameFontNormal")
    button.textStatus:SetPoint("BOTTOMRIGHT", -4, 4)
    button.textStatus:SetFont(FONT, 10, "OUTLINE")
    button.textStatus:SetText("status")

    button.leader = button.health:CreateTexture(nil, 'OVERLAY')
    button.leader:SetSize(16, 16)
    button.leader:SetTexture([[Interface\GroupFrame\UI-Group-LeaderIcon]])

    button.assistant = button.health:CreateTexture(nil, 'OVERLAY')
    button.assistant:SetSize(16, 16)
    button.assistant:SetTexture([[Interface\GroupFrame\UI-Group-AssistantIcon]])

    button.role = button.health:CreateTexture(nil, 'OVERLAY')
    button.role:SetSize(16, 16)
    button.role:SetTexture([[Interface\LFGFrame\UI-LFG-ICON-PORTRAITROLES]])

    --button.phased = button.health:CreateTexture(nil, 'OVERLAY')
    --button.phased:SetSize(16, 16)
    --button.phased:SetPoint("BOTTOMLEFT", 36, 4)
    --button.phased:SetTexture([[Interface\TargetingFrame\UI-PhasingIcon]])
  end

  -- header:SetAttribute('showRaid', true)
  -- header:SetAttribute('showSolo', true)
  header:SetAttribute('showParty', true)
  header:SetAttribute('showPlayer', true)
  header:SetAttribute('xOffset', 0)
  header:SetAttribute('yOffset', 4)
  header:SetAttribute('point', 'BOTTOM')
  header:SetAttribute('groupBy', 'ASSIGNEDROLE')
  header:SetAttribute('groupingOrder', 'TANK,DAMAGER,HEALER')
  RegisterAttributeDriver(header, 'state-visibility', '[group:party] show; hide')

  header:SetPoint(...)
  header:Show()
end

--local TEST = [[
  --print("hello world", ...)
--]]

--local FN = loadstring(TEST)
--pcall(FN, 1, 2, 3)





-- local IconPool = CreateFramePool("frame", UIParent, nil, nil)
-- local atonement = Square(button, 194384, 16, 1, 1, 0, 1, "TOPRIGHT", 0, 0)
--local function Square(parent, id, size, r, g, b, a, point, x, y)
  --local t = {}
  --t.frame = CreateFrame("frame", nil, parent)
  --t.frame:SetBackdrop({
    --bgFile = 'Interface\\Addons\\Squish\\media\\backdrop.tga',
    --insets = { left = 0, right = 0, top = 0, bottom = 0 },
  --})
  --t.frame:SetBackdropColor(r, g, b, a)
  --t.frame:SetSize(size, size)
  --t.frame:SetPoint(point, x, y)
  --t.frame:SetFrameLevel(5)
  --t.frame:Hide()
  --t.cd = CreateFrame("cooldown", nil, t.frame, "CooldownFrameTemplate")
  --t.cd:SetReverse(true)
  --t.id = id
  --return t
--end

--local function updateLeaderIndicator()
--end

--atonement.hide = true
--for index = 1, 40 do
  --local _, _, _, _, duration, expiration, source, _, _, id = UnitAura(self.unit, index, "HELPFUL")
  --if not id then break end
  --if id == atonement.id then
    --atonement.hide = false
    --atonement.cd:SetCooldown(expiration - duration, duration)
    --atonement.frame:Show()
  --end
--end
--if atonement.hide then
  --atonement.cd:Clear()
  --atonement.frame:Hide()
--end

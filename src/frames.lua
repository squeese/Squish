local function CreateUnitButton(parent)
  local button = CreateFrame("button", nil, parent, "SecureActionButtonTemplate,BackdropTemplate")
  button:SetScript("OnAttributeChanged", OnAttributeChanged)
  button:RegisterForClicks("AnyUp")
  button:SetAttribute('*type1', 'target')
  button:SetAttribute('*type2', 'togglemenu')
  button:SetBackdrop(MEDIA:BACKDROP())
  button:SetBackdropColor(0, 0, 0, 0.75)
  return button
end

local function StatusBar(parent, ...)
  local bar = CreateFrame("statusbar", nil, parent, ...)
  bar:SetMinMaxValues(0, 1)
  bar:SetStatusBarTexture(MEDIA:STATUSBAR())
  return bar
end

local function FontString(parent, size)
  local font = parent:CreateFontString(nil, nil, "GameFontNormal")
  font:SetFont(MEDIA:FONT(), size or 20)
  font:SetShadowColor(1, 1, 1, 0.5)
  return font
end

local function RoleIcon(parent, size, ...)
  local texture = parent:CreateTexture(...)
  texture:SetSize(size, size)
  texture:SetTexture([[Interface\\LFGFrame\\UI-LFG-ICON-ROLES]])
  return texture
end

local function RoleIconUpdate(unit, icon)
  icon:Hide()
  local role = UnitGroupRolesAssigned(unit)
  if role then -- == 'TANK' or role == 'HEALER' then
    icon:Show()
    icon:SetTexCoord(GetTexCoordsForRole(role))
  end
end

local function LeaderIcon(parent, size, ...)
  local texture = parent:CreateTexture(...)
  texture:SetSize(size, size)
  texture:SetTexture([[Interface\\GroupFrame\\UI-Group-LeaderIcon]])
  texture:SetTexCoord(-0.1, 1, 0, 1)
  texture:SetRotation(0.2, 0.5, 0.5)
  return texture
end

local function AssistIcon(parent, size, ...)
  local texture = parent:CreateTexture(...)
  texture:SetSize(size, size)
  texture:SetTexture([[Interface\\GroupFrame\\UI-Group-AssistantIcon]])
  return texture
end

local function LeadAndAssistIconUpdate(unit, leader, assist)
  leader:Hide()
  assist:Hide()
  if UnitInParty(unit) then
    if UnitIsGroupLeader(unit) then
      leader:Show()
    elseif UnitIsGroupAssistant(unit) then
      assist:Show()
    end
  end
end

local function RestedIcon(parent, size, ...)
  local texture = parent:CreateTexture(...)
  texture:SetSize(size, size)
  texture:SetTexture([[Interface\\CharacterFrame\\UI-StateIcon]])
  texture:SetTexCoord(0.05, .55, 0, .49)
  return texture
end

local function CombatIcon(parent, size, ...)
  local texture = parent:CreateTexture(...)
  texture:SetSize(size, size)
  texture:SetTexture([[Interface\\CharacterFrame\\UI-StateIcon]])
  texture:SetTexCoord(.5, 1, 0, .49)
  return texture
end

local function ResserIcon(parent, size, ...)
  local texture = parent:CreateTexture(nil, 'OVERLAY')
  texture:SetSize(size, size)
  texture:SetTexture([[Interface\\RaidFrame\\Raid-Icon-Rez]])
  return texture
end

${source.set("UnitName", "GUID_SET GUID_MOD UNIT_NAME_UPDATE",
  GET`local ${"name"} = UnitName(self.unit)`
)}

${source.set("UnitHealthMax", "GUID_SET GUID_MOD UNIT_MAXHEALTH",
  GET`local ${"max"} = UnitHealthMax(self.unit)`
)}

${source.set("UnitPowerMax", "GUID_SET GUID_MOD UNIT_MAXPOWER UNIT_POWER_UPDATE",
  GET`local ${"max"} = UnitPowerMax(self.unit)`
)}

${source.set("UnitHealth", "GUID_SET GUID_MOD UNIT_HEALTH",
  GET`local ${"hp"} = UnitHealth(self.unit)`
)}

${source.set("UnitPower", "GUID_SET GUID_MOD UNIT_POWER_FREQUENT UNIT_POWER_UPDATE",
  GET`local ${"val"} = UnitPower(self.unit)`
)}


${source.set("ClassColor", "GUID_SET GUID_MOD",
  GET`local ${"color"} = ClassColor(self.unit)`
)}

${source.set("PowerColor", "GUID_SET GUID_MOD UNIT_POWER_UPDATE",
  GET`local ${"color"} = PowerColor(self.unit)`
)}


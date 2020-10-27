${template("SetText",          element => value => `${element}:SetText(${value})`)}
${template("SetValue",         element => value => `${element}:SetValue(${value})`)}
${template("SetMinMaxValues",  element => value => `${element}:SetMinMaxValues(0, ${value})`)}
${template("Show",             element => () => `${element}:Show()`)}
${template("Hide",             element => () => `${element}:Hide()`)}


${template("UnitName", [
  "GUID_SET GUID_MOD UNIT_NAME_UPDATE",
  _ => GET`local ${_} = UnitName(self.unit)`,
])}

${template("UnitHealth", [
  "GUID_SET GUID_MOD UNIT_HEALTH",
  _ => GET`local ${_} = UnitHealth(self.unit)`
])}

${template("UnitHealthMax", [
  "GUID_SET GUID_MOD UNIT_MAXHEALTH",
  _ => GET`local ${_} = UnitHealthMax(self.unit)`,
])}

${template("UnitPower", [
  "GUID_SET GUID_MOD UNIT_POWER_FREQUENT UNIT_POWER_UPDATE",
  _ => GET`local ${_} = UnitPower(self.unit)`
])}

${template("UnitPowerMax", [
  "GUID_SET GUID_MOD UNIT_MAXPOWER UNIT_POWER_UPDATE",
  _ => GET`local ${_} = UnitPowerMax(self.unit)`,
])}

${template("UnitClassColor", [
  "GUID_SET GUID_MOD",
  _ => GET`local ${_} = ClassColor(self.unit)`
])}

${template("UnitPowerColor", [
  "GUID_SET GUID_MOD UNIT_DISPLAYPOWER UNIT_POWER_UPDATE",
  _ => GET`local ${_} = PowerColor(self.unit)`
])}

${template("UnitShieldAbsorb", [
  "GUID_SET GUID_MOD UNIT_ABSORB_AMOUNT_CHANGED",
  _ => GET`local ${_} = UnitGetTotalAbsorbs(self.unit)`,
])}

${template("UnitHealAbsorb", [
  "GUID_SET GUID_MOD UNIT_HEAL_ABSORB_AMOUNT_CHANGED",
  _ => GET`local ${_} = UnitGetTotalHealAbsorbs(self.unit)`,
])}

${template("UnitAffectingCombat", [
  "GUID_SET GUID_MOD",
  _ => GET`local ${_} = UnitAffectingCombat(self.unit)`,
])}

${template("IsResting", [
  "GUID_SET GUID_MOD PLAYER_UPDATE_RESTING",
  _ => GET`local ${_} = IsResting()`,
])}

${template("UnitGroupRolesAssigned", [
  "GUID_SET GUID_MOD PLAYER_ROLES_ASSIGNED",
  _ => GET`local ${_} = UnitGroupRolesAssigned(self.unit)`,
])}

${template("UnitInParty", [
  "GUID_SET GUID_MOD GROUP_ROSTER_UPDATE",
  _ => GET`local ${_} = UnitInParty(self.unit)`,
])}

${template("UnitIsGroupLeader", [
  "GUID_SET GUID_MOD GROUP_ROSTER_UPDATE PARTY_LEADER_CHANGED",
  _ => GET`local ${_} = UnitIsGroupLeader(self.unit)`,
])}

${template("UnitIsGroupAssistant", [
  "GUID_SET GUID_MOD GROUP_ROSTER_UPDATE",
  _ => GET`local ${_} = UnitIsGroupAssistant(self.unit)`,
])}

${template("UnitHasIncomingResurrection", [
  "GUID_SET GUID_MOD INCOMING_RESURRECT_CHANGED",
  _ => GET`local ${_} = UnitHasIncomingResurrection(self.unit)`,
])}

${template("UnitIsQuestBoss", [
  "GUID_SET GUID_MOD UNIT_CLASSIFICATION_CHANGED",
  _ => GET`local ${_} = UnitIsQuestBoss(self.unit)`,
])}

${template("GetRaidTargetIndex", [
  "GUID_SET GUID_MOD RAID_TARGET_UPDATE",
  _ => GET`local ${_} = GetRaidTargetIndex(self.unit)`,
])}

${template('UnitButton', (name, parent) => `
  ${name} = CreateFrame("button", nil, ${parent}, "SecureActionButtonTemplate,BackdropTemplate")
  ${name}:SetScript("OnAttributeChanged", OnAttributeChanged)
  ${name}:RegisterForClicks("AnyUp")
  ${name}:SetAttribute('*type1', 'target')
  ${name}:SetAttribute('*type2', 'togglemenu')
  ${name}:SetBackdrop(MEDIA:BACKDROP(true, nil, 0, -1))
  ${name}:SetBackdropColor(0, 0, 0, 1)
`)}

${template('StatusBar', (name, parent = 'self') => `
  ${name} = CreateFrame("statusbar", nil, ${parent})
  ${name}:SetMinMaxValues(0, 1)
  ${name}:SetStatusBarTexture(MEDIA:STATUSBAR())
`)};

${template('FontString', (name, size = 20, parent = 'self') => `
  ${name} = ${parent}:CreateFontString(nil, nil, "GameFontNormal")
  ${name}:SetFont(MEDIA:FONT(), ${size})
  ${name}:SetTextColor(0, 0, 0)
  ${name}:SetShadowColor(1, 1, 1, 0.5)
`)}

${template('FontString_Aura', (name, size, parent) => `
  ${name} = ${parent}:CreateFontString(nil, nil, "GameFontNormal")
  ${name}:SetFont(MEDIA:FONT(), ${size}, "OUTLINE")
`)}

${template('AuraIndicator', (name, size, parent) => `
  ${name} = CreateFrame('frame', nil, ${parent}, "BackdropTemplate")
  ${name}:SetSize(${size}, ${size})
  ${name}.cd = CreateFrame("cooldown", nil, ${name}, "CooldownFrameTemplate")
  ${name}.cd:SetReverse(true)
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
`)}

${template('RoleIcon', (context, name, parent, size, layer = '"OVERLAY"') => `
  ${name} = ${parent}:CreateTexture(nil, ${layer})
  ${name}:SetSize(${size}, ${size})
  ${name}:SetTexture([[Interface\\LFGFrame\\UI-LFG-ICON-ROLES]])
  ${context.use(UnitGroupRolesAssigned, role => `UpdateRoleIcon(${name}, ${role})`)}
`, `local function UpdateRoleIcon(element, role)
  if role ~= 'NONE' then -- == 'TANK' or role == 'HEALER' then
    element:SetTexCoord(GetTexCoordsForRole(role))
    element:Show()
  else
    element:Hide()
  end
end
`)}

${template('LeaderIcon', (context, name, parent, size, layer = '"OVERLAY"') => `
  ${name} = ${parent}:CreateTexture(nil, ${layer})
  ${name}:SetSize(${size}, ${size})
  ${name}:SetTexture([[Interface\\GroupFrame\\UI-Group-LeaderIcon]])
  ${context.use(UnitInParty, UnitIsGroupLeader, (party, leader) => `ToggleVisible(${name}, (${party} and ${leader}))`)}
`)}

${template('AssistIcon', (context, name, parent, size, layer = '"OVERLAY"') => `
  ${name} = ${parent}:CreateTexture(nil, ${layer})
  ${name}:SetSize(${size}, ${size})
  ${name}:SetTexture([[Interface\\GroupFrame\\UI-Group-AssistantIcon]])
  ${context.use(UnitInParty, UnitIsGroupAssistant, (party, assist) => `ToggleVisible(${name}, (${party} and ${assist}))`)}
`)}

${template('RestedIcon', (context, name, parent, size, layer = '"OVERLAY"') => `
  ${name} = ${parent}:CreateTexture(nil, ${layer})
  ${name}:SetSize(${size}, ${size})
  ${name}:SetTexture([[Interface\\CharacterFrame\\UI-StateIcon]])
  ${name}:SetTexCoord(0.05, .55, 0, .49)
  ${context.use(IsResting, value => `ToggleVisible(${name}, ${value})`)}
`)}

${template('CombatIcon', (context, name, parent, size, layer = '"OVERLAY"') => `
  ${name} = ${parent}:CreateTexture(nil, ${layer})
  ${name}:SetSize(${size}, ${size})
  ${name}:SetTexture([[Interface\\CharacterFrame\\UI-StateIcon]])
  ${name}:SetTexCoord(.5, 1, 0, .49)
  ${context.use(["PLAYER_REGEN_ENABLED"], Hide(name))}
  ${context.use(["PLAYER_REGEN_DISABLED"], Show(name))}
  ${context.use(UnitAffectingCombat, value => `ToggleVisible(${name}, ${value})`)}
`)}

${template('ResserIcon', (context, name, parent, size, layer = '"OVERLAY"') => `
  ${name} = ${parent}:CreateTexture(nil, ${layer})
  ${name}:SetSize(${size}, ${size})
  ${name}:SetTexture([[Interface\\RaidFrame\\Raid-Icon-Rez]])
  ${context.use(UnitHasIncomingResurrection, value => `ToggleVisible(${name}, ${value})`)}
`)}

${template('QuestIcon', (context, name, parent, size, layer = '"OVERLAY"') => `
  ${name} = ${parent}:CreateTexture(nil, ${layer})
  ${name}:SetSize(${size}, ${size})
  ${name}:SetTexture([[Interface\\TargetingFrame\\PortraitQuestBadge]])
  ${context.use(UnitIsQuestBoss, value => `ToggleVisible(${name}, ${value})`)}
`)}

${template('RaidTargetIcon', (context, name, parent, size, layer = '"OVERLAY"') => `
  ${name} = ${parent}:CreateTexture(nil, ${layer})
  ${name}:SetSize(${size}, ${size})
  ${name}:SetTexture([[Interface\\TargetingFrame\\UI-RaidTargetingIcons]])
  ${context.use(GetRaidTargetIndex, index => `UpdateRaidIcon(${name}, ${index})`)}
`, `local function UpdateRaidIcon(element, index)
  if index then
    SetRaidTargetIconTexture(element, index)
    element:Show()
  else
    element:Hide()
  end
end
`)}

${template('SpecializationIcon', (context, name, parent, size, layer = '"OVERLAY"') => `
  ${name} = ${parent}:CreateTexture(nil, ${layer})
  ${name}:SetSize(${size}, ${size})
  ${name}:SetTexCoord(0.1, 0.9, 0.1, 0.9)
`, ``)}

${template('UnitStatus', (context, element) => context.use([
  "GUID_SET GUID_MOD UNIT_HEALTH UNIT_CONNECTION",
  _ => GET`local ${_} = UnitIsDead(self.unit)`,
  _ => GET`local ${_} = UnitIsGhost(self.unit)`,
  _ => GET`local ${_} = UnitIsConnected(self.unit)`],
  (...args) => `SetUnitStatus(${element}, ${args.join(", ")})`
), `local function SetUnitStatus(element, dead, ghost, connected)
  if dead then
    element:SetText("dead")
  elseif ghost then
    element:SetText("ghost")
  elseif not connected then
    element:SetText("offline")
  else
    element:SetText("")
  end
end`)}

${template('UnitClassification', (context, element) => context.use([
  "GUID_SET GUID_MOD UNIT_CLASSIFICATION_CHANGED",
  _ => GET`local ${_} = UnitClassification(self.unit)`],
  value => `SetUnitClassification(${element}, ${value})`
), `local function SetUnitClassification(element, classification)
  if classification == 'rare' then
    element:SetText('Rare')
  elseif classification == 'rareelite' then
    element:SetText('Rare Elite')
  elseif classification == 'elite' then
    element:SetText('Elite')
  elseif classification == 'worldboss' then
    element:SetText('Boss')
  elseif classification == 'minus' then
    element:SetText('Affix')
  else
    element:SetText("")
  end
end`)}

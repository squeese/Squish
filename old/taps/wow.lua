local Observable = require and require('./libs/Observable') or select(2, ...).Observable
local Event = require and require('./libs/Event') or select(2, ...).Event

local function registerScriptHook(frame, name, fn, ctx)
  if not frame.HookScript then
    return false
  end
  local key = '__hook_'..name
  if not frame[key] then
    frame[key] = {}
    frame:HookScript(name, function(self, ...)
      for i = 1, #self[key], 2 do
        local _fn = self[key][i]
        local _ctx = self[key][i+1]
        if _ctx then
          _fn(_ctx, self, ...)
        else
          _fn(self, ...)
        end
      end
    end)
  end
  table.insert(frame[key], 1, ctx)
  table.insert(frame[key], 1, fn)
end

local function unregisterScriptHook(frame, name, fn, ctx)
  if not frame.HookScript then
    return false
  end
  local key = '__hook_'..name
  for i = 1, #frame[key] do
    if frame[key][i] == fn and frame[key][i+1] == ctx then
      table.remove(frame[key], i+1)
      table.remove(frame[key], i)
      break
    end
  end
end

local function tile(anchor, initial, attach, ...)
  local frames = {...}
  local function update()
    local prev  
    for i = 1, #frames do
      local curr = frames[i]
      if curr:IsShown() then
        curr:ClearAllPoints()
        if not prev then
          local a, b, x, y = unpack(initial)
          curr:SetPoint(a, anchor, b, x, y)
        else
          local a, b, x, y = unpack(attach)
          curr:SetPoint(a, prev, b, x, y)
        end
        prev = curr
      end
    end
  end
  for i = 1, #frames do
    registerScriptHook(frames[i], 'OnShow', update, anchor)
    registerScriptHook(frames[i], 'OnHide', update, anchor)
  end
  return function()
    for i = 1, #frames do
      unregisterScriptHook(frames[i], 'OnShow', update, anchor)
      unregisterScriptHook(frames[i], 'OnHide', update, anchor)
    end
  end
end

local Name = Observable.extend
  :refreshOn(Event.UNIT_NAME_UPDATE)
  :map(UnitName)

local Power = Observable.extend
  :refreshOn(Observable.merge(
    Event.UNIT_POWER_FREQUENT,
    Event.UNIT_POWER_MAX))
  :map(function(unit)
    return UnitPower(unit), UnitPowerMax(unit)
  end)

local Health = Observable.extend
  :refreshOn(Observable.merge(
    Event.UNIT_HEALTH_FREQUENT,
    Event.UNIT_HEALTH_MAX))
  :map(function(unit)
    return UnitHealth(unit), UnitHealthMax(unit)
  end)

local ClassColor = Observable.extend
  :refreshOn(Event.UNIT_NAME_UPDATE)
  :map(function(unit)
    local color = RAID_CLASS_COLORS[select(2, UnitClass(unit))]
    if color then return color.r, color.g, color.b end
    return 0.5, 0.5, 0.5
  end)

local UnitIsSelected = Observable.extend
  :refreshOn(Event.PLAYER_TARGET_CHANGED, Observable.ident)
  :map(function(unit)
    return UnitIsUnit('target', unit)
  end)

local Role = Observable.extend
  :refreshOn(Event.PLAYER_ROLES_ASSIGNED, Observable.ident)
  :map(UnitGroupRolesAssigned)

local BuffIndices = Observable.extend
  :refreshOn(Event.UNIT_AURA)
  :expand(function(send, done, ...)
    return function(unit, filter)
      filter = filter or 'HELPFUL'
      for i = 1, 40 do
        if not UnitAura(unit, i, filter) then break end
        send(unit, i, filter)
      end
      done()
    end, nil, ...
  end)

local UnitIsBossTarget
do
  local bosses = {
    'boss1target',
    'boss2target',
    'boss3target',
    'boss4target',
    'boss5target',
  }
  UnitIsBossTarget = Observable.extend
    :refreshOn(Observable.merge(
      Event.ENCOUNTER_END,
      Event.UNIT_TARGET:filter(function(unit)
        return unit:match('boss(%d)')
      end)),
      Observable.ident)
    :map(function(unit)
      for i = 1, 5 do
        if UnitIsUnit(unit, bosses[i]) then
          return bosses[i]
        end
      end
      return nil
    end)
end

local function priorityCombiner(_, ...)
  for i = 1, select('#', ...) do
    local val = select(i, ...)
    if val ~= false then
      return val
    end
  end
end

local UnitIsOffline = Observable.extend
  :refreshOn(Event.UNIT_CONNECTION)
  :map(function(unit) return not UnitIsConnected(unit) end)

local UnitIsCharmed = Observable.extend
  :refreshOn(Event.UNIT_FLAGS)
  :map(UnitIsCharmed)

local UnitInVehicle = Observable.extend
  :refreshOn(Observable.merge(
    Event.UNIT_ENTERED_VEHICLE,
    Event.UNIT_EXITED_VEHICLE))
  :map(UnitInVehicle)

local UnitInPhase = Observable.extend
  :refreshOn(Event.UNIT_PHASE)
  :map(UnitInPhase)

local UnitIsDead = Observable.extend
  :refreshOn(Event.UNIT_HEALTH)
  :map(UnitIsDead)

local UnitIsGhost = Observable.extend
  :refreshOn(Event.UNIT_HEALTH)
  :map(UnitIsGhost)

local Aura = Observable.extend
  :refreshOn(Event.UNIT_AURA)
  :map(UnitAura)

local UnitInRange = Observable.extend
  :mapOnTicker(0.5, function(unit)
    return unit == 'player' or UnitInRange(unit)
  end)

local unitCanDispel, playerCanDispel
do
  local classes = {
    Paladin = { Poison = true, Disease = true, Magic = true },
    Monk    = { Poison = true, Disease = true, Magic = true },
    Priest  = { Poison = true, Disease = true, Magic = true },
    Mage    = { Curse = true },
    Druid   = {},
    Shaman  = {},
    Rogue   = {},
    Warrior = {},
    Warlock = {},
    ['Death Knight'] = {},
  }
  function unitCanDispel(unit, school)
    return classes[UnitClass(unit)][school]
  end
  function playerCanDispel(school)
    return classes[UnitClass('player')][school]
  end
end

local defaultBackdrop = {
  bgFile   = "Interface/Tooltips/UI-Tooltip-Background", 
  edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
  insets   = { left = 4, right = 4, top = 4, bottom = 4 },
  tile     = true,
  tileSize = 16,
  edgeSize = 16
}
local flatBackdrop = {
  bgFile   = 'Interface\\Addons\\ONodesUI\\media\\backdrop.tga',
  edgeFile = 'Interface\\Addons\\ONodesUI\\media\\edgefile.tga',
  insets   = { left = 1, right = 1, top = 1, bottom = 1 },
  edgeSize = 1
}

local auraBigIconFramePool = {}
local auraBarFramePool = {}
local auraBarFilter = {}
auraBarFilter['Atonement']        = { class = 'Priest',  color = { 1.0, 1.0, 1.0 }}
auraBarFilter['Renew']            = { class = 'Priest',  color = { 1.0, 1.0, 1.0 }}
auraBarFilter['Bestow Faith']     = { class = 'Paladin', color = { 0.2, 0.9, 0.4 }}
auraBarFilter['Beacon of Virtue'] = { class = 'Paladin', color = { 0.9, 0.2, 0.4 }}
auraBarFilter['Renewing Mist']    = { class = 'Monk', color = { 0.3, 0.8, 0.6 }}
auraBarFilter['Enveloping Mist']  = { class = 'Monk', color = { 0.6, 0.8, 0.3 }}

local function updateAuraBar(self, e)
  local duration, expires = select(6, UnitAura(self.__unit, self.__index, self.__filter))
  self:SetValue(expires and ((expires-GetTime())/duration) or 0)
end

local BuffBarIndices = BuffIndices
  :filter(function(unit, index, filter)
    local name, _, _, _, _, _, _, caster = UnitAura(unit, index, filter)
    return auraBarFilter[name] and caster and UnitIsUnit(caster, 'player') and auraBarFilter[name].class == UnitClass('player')
  end)
  :map(function(unit, index, filter)
    return unit, index, filter, auraBarFilter[UnitAura(unit, index, filter)].color
  end)

local dangerNoodleDebuffs = {}

local PriorityDebuffs = BuffIndices
  :filter(function(unit, index, filter)
    local _, _, _, _, dispelType, _, _, _, _, _, _, _, isBoss = UnitAura(unit, index, filter)
    return isBoss or playerCanDispel(dispelType)
  end)
  :take(1)

local StatusText = Observable.combine(
  UnitIsCharmed,
  UnitIsOffline,
  UnitIsDead,
  UnitIsGhost,
  UnitIsBossTarget,
  function(_, charmed, offline, dead, ghost, bossUnit)
    if charmed then
      return 'Charmed'
    elseif offline then
      return 'Offline'
    elseif dead then
      return 'Dead'
    elseif ghost then
      return 'Ghost'
    elseif bossUnit then
      return '' -- string.sub(bossUnit, 1, 6)
    end
    return ''
  end)

local function selectIndex(_, index)
  return index
end



local RaidButton
do
  local function applyBase(button, subs, ctx)
    button:SetScript('OnEnter', UnitFrame_OnEnter)
    button:SetScript('OnLeave', UnitFrame_OnLeave)
    button:RegisterForClicks('AnyUp')
    button:SetBackdrop(flatBackdrop)
    button:SetBackdropColor(0, 0, 0, 0.95)
    button:SetBackdropBorderColor(0, 0, 0, 1)
    table.insert(subs, UnitInRange
      :either(1, 0.4)
      :applyTo(button, 'SetAlpha')
      :subscribe(nil, nil, ctx))
  end

  local highlightSelected = {1, 1, 1, 1}
  local highlightDefault = {0, 0, 0, 0}
  local function applyHighlight(button, subs, ctx)
    local frame = CreateFrame('frame', nil, button)
    frame:SetFrameLevel(1)
    frame:SetFrameStrata(button:GetFrameStrata())
    frame:SetPoint('TOPLEFT', -1, 1)
    frame:SetPoint('BOTTOMRIGHT', 1, -1)
    frame:SetBackdrop({
      edgeFile = 'Interface\\AddOns\\ElvUI\\media\\textures\\glowTex.tga',
      edgeSize = 1,
      insets   = { left = 5, right = 5, top = 5, bottom = 5 },
    })
    frame:SetBackdropColor(0, 0, 0, 0)
    table.insert(subs, UnitIsSelected
      :either(highlightSelected, highlightDefault)
      :map(unpack)
      :applyTo(frame, 'SetBackdropBorderColor')
      :subscribe(nil, nil, ctx))
  end

  local function applyHealthBar(button, subs, ctx)
    local frame = CreateFrame('statusbar', nil, button)
    frame:SetStatusBarTexture('Interface\\Addons\\ONodesUI\\media\\flat.tga')
    frame:SetOrientation('VERTICAL')
    frame:SetPoint('TOP', 0, -1)
    frame:SetPoint('BOTTOM', 0, 1)
    frame:SetPoint('LEFT', 1, 0)
    frame:SetFrameLevel(3)
    table.insert(subs, Health
      :tap(function(cur, max)
        frame:SetMinMaxValues(0, max)
        frame:SetValue(cur)
      end)
      :subscribe(nil, nil, ctx))
    table.insert(subs, ClassColor
      :applyTo(frame, 'SetStatusBarColor')
      :subscribe(nil, nil, ctx))
    return frame
  end

  local function applyBoss(button, subs, ctx)
    local frame = CreateFrame('playermodel', nil, button)
    frame:SetSize(20, 20)
    frame:SetFrameLevel(4)
    frame:SetPortraitZoom(1)
    local bg = frame:CreateTexture()
    bg:SetPoint('TOPLEFT', 0, 0)
    bg:SetPoint('BOTTOMRIGHT', 1, -1)
    bg:SetDrawLayer('BACKGROUND', -1)
    bg:SetColorTexture(0, 0, 0, 1)
    table.insert(subs, UnitIsBossTarget:subscribe(function(unit, ...)
      if unit then
        frame:SetUnit(string.sub(unit, 1, 5))
        frame:Show()
      else
        frame:Hide()
      end
    end, nil, ctx))
    return frame
  end

  local function applyStatus(health, subs, ctx)
    local text = health:CreateFontString(nil, nil, 'GameFontNormal')
    text:SetFont('Interface\\Addons\\ONodesUI\\media\\vixar.ttf', 12)
    text:SetPoint('BOTTOMLEFT', 3, 15)
    text:SetTextColor(1, 1, 1, 1)
    table.insert(subs, StatusText
      :applyTo(text, 'SetText')
      :subscribe(nil, nil, ctx))
  end

  local function applyName(health, subs, ctx)
    local text = health:CreateFontString(nil, nil, 'GameFontNormal')
    text:SetFont('Interface\\Addons\\ONodesUI\\media\\vixar.ttf', 10)
    text:SetPoint('BOTTOMLEFT', 3, 0)
    text:SetTextColor(1, 1, 1, 0.9)
    table.insert(subs, Name
      :map(function(name)
        return string.sub(name, 1, 6)
      end)
      :applyTo(text, 'SetText')
      :subscribe(nil, nil, ctx))
  end

  local function applyRole(button, subs, ctx)
    local frame = CreateFrame('frame', nil, button)
    frame:SetFrameLevel(4)
    frame:SetSize(10, 10)
    frame:SetPoint('BOTTOMRIGHT', 3, 2)
    local icon = frame:CreateTexture()
    icon:SetAllPoints()
    icon:SetTexture('Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES')
    table.insert(subs, Role
      :map(function(role)
        if role == 'HEALER' or role == 'TANK' then
          return GetTexCoordsForRoleSmallCircle(role)
        end
        return 0, 0, 0, 0
      end)
      :applyTo(icon, 'SetTexCoord')
      :subscribe(nil, nil, ctx))
  end

  local debuffSize = 18
  local auraIconFramePool = {}
  local function applyDebuffs(button, subs, ctx)
    local tray = CreateFrame('frame', nil, button)
    tray:SetSize(1, 10)
    tray:SetFrameLevel(4)
    table.insert(subs, BuffIndices
      :filter(function(unit, index, filter)
        -- only debuffs from enemies
        return select(8, UnitAura(unit, index, filter)) == nil
      end)
      :take(2)
      :upgrade(selectIndex, function(unit, index)
        local frame = table.remove(auraIconFramePool)
        if not frame then
          frame = CreateFrame('frame', nil, UIParent)
          frame:SetBackdrop(flatBackdrop)
          frame:SetBackdropColor(0, 0, 0, 0)
          frame:SetBackdropBorderColor(0, 0, 0, 1)
          frame:SetSize(debuffSize, debuffSize)
          frame.icon = frame:CreateTexture()
          frame.icon:SetPoint('TOPLEFT', 1, -1)
          frame.icon:SetPoint('BOTTOMRIGHT', -1, 1)
          frame.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
          frame.icon:SetDrawLayer('BACKGROUND', -1)
          frame.stack = frame:CreateFontString()
          frame.stack:SetFont('Interface\\Addons\\ONodesUI\\media\\vixar.ttf', 10, 'OUTLINE')
          frame.stack:SetPoint('BOTTOMRIGHT', 3, 0)
          frame.stack:SetTextColor(1, 1, 1, 1)
          frame.stack:SetText('3')
        end
        frame:SetParent(tray)
        frame:Show()
        return function(unit, index, filter)
          local _, _, icon, count, dispel = UnitAura(unit, index, filter)
          frame.icon:SetTexture(icon)
          frame.stack:SetText(count > 1 and count or '')
          return frame
        end, function()
          frame:Hide()
          table.insert(auraIconFramePool, frame)
        end
      end)
      :collect()
      :subscribe(function(...)
        local prev  
        for i = 1, select('#', ...) do
          local curr = select(i, ...)
          if not prev then
            curr:SetPoint('TOPLEFT', tray, 'TOPLEFT', 0, 0)
          else
            curr:SetPoint('TOPLEFT', prev, 'BOTTOMLEFT', 0, 0)
          end
          prev = curr
        end
      end, nil, ctx:map(function(unit)
        return unit, 'HARMFUL'
      end)))
    return tray
  end

  local function applyHotbars(button, subs, ctx)
    local auraBarWidth = 7
    table.insert(subs, BuffBarIndices
      :upgrade(selectIndex, function(unit, index)
        local bar = table.remove(auraBarFramePool)
        if not bar then
          bar = CreateFrame('statusbar', nil, UIParent)
          bar:SetStatusBarTexture('Interface\\Addons\\ONodesUI\\media\\flat.tga')
          bar:SetMinMaxValues(0, 1)
          bar:SetOrientation('VERTICAL')
          bar:SetWidth(auraBarWidth)
          bar:SetScript('OnUpdate', updateAuraBar)
        end
        bar:SetParent(button)
        bar:SetPoint('TOP', 0, -1)
        bar:SetPoint('BOTTOM', 0, 1)
        bar:Show()
        return function(unit, index, filter, color)
          bar:SetStatusBarColor(unpack(color))
          bar.__unit = unit
          bar.__index = index
          bar.__filter = filter
          return bar, unit, index, filter, color
        end, function()
          bar:Hide()
          table.insert(auraBarFramePool, bar)
        end
      end)
      :expand(function(send, done, ...)
        local previous
        return function(bar, ...)
          if not previous then
            bar:SetPoint('RIGHT', button, 'RIGHT', -1, 0)
          else
            bar:SetPoint('RIGHT', previous, 'LEFT', -1, 0)
          end
          previous = bar
          send(bar, ...)
        end, function()
          if not previous then
            hp:SetPoint('RIGHT', button, 'RIGHT', -1, 0)
          else
            hp:SetPoint('RIGHT', previous, 'LEFT', -1, 0)
          end
          previous = nil
          done()
        end, ...
      end)
      :subscribe(nil, nil, UnitAttribute
        :map(function(unit)
          return unit, 'HELPFUL'
        end)))
  end

  function RaidButton(button)
    local subs = {}
    local context = Observable
      .onAttribute(button, 'unit')
      :filter()
      :distinct(UnitGUID)
      :tap(function(unit)
        button.unit = unit
      end)
    
    applyBase(button, subs, context)
    applyHighlight(button, subs, context)
    local boss = applyBoss(button, subs, context)
    local health = applyHealthBar(button, subs, context)
    applyStatus(health, subs, context)
    applyName(health, subs, context)
    applyRole(button, subs, context)
    local debuffs = applyDebuffs(button, subs, context)
    -- local hotbars = applyHotbars(button, subs, context)

    tile(button, {'TOPLEFT', 'TOPLEFT', 0, 0}, {'TOPLEFT', 'BOTTOMLEFT', 0, 0}, boss, debuffs)

    --[[
    do -- major debuffs
      local size = 32
      table.insert(subs, PriorityDebuffs
        :upgrade(selectIndex, function(unit, index)
          local frame = table.remove(auraBigIconFramePool)
          if not frame then
            frame = CreateFrame('frame', nil, UIParent)
            frame:SetBackdrop(flatBackdrop)
            frame:SetBackdropColor(0, 0, 0, 0)
            frame:SetBackdropBorderColor(0, 0, 0, 1)
            frame:SetSize(size, size)
            frame.icon = frame:CreateTexture()
            frame.icon:SetPoint('TOPLEFT', 1, -1)
            frame.icon:SetPoint('BOTTOMRIGHT', -1, 1)
            frame.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
            frame.icon:SetDrawLayer('BACKGROUND', -1)
            frame.overlay = frame:CreateTexture(nil, 'OVERLAY')
            frame.overlay:SetAllPoints()
            frame.overlay:SetBlendMode('BLEND')
            frame.stack = frame:CreateFontString()
            frame.stack:SetFont('Interface\\Addons\\ONodesUI\\media\\vixar.ttf', 12, 'OUTLINE')
            frame.stack:SetPoint('BOTTOMRIGHT', 3, 0)
            frame.stack:SetTextColor(1, 1, 1, 1)
            frame.stack:SetText('3')
          end
          frame:SetParent(button)
          frame:SetFrameLevel(2)
          frame:SetPoint('CENTER', 0, 0)
          frame:Show()
          return function(unit, index, filter)
            local _, _, icon, count, dispel = UnitAura(unit, index, filter)
            frame.icon:SetTexture(icon)
            frame.stack:SetText(count > 1 and count or '')
            if dispel then
              local color = DebuffTypeColor[dispel]
              frame.overlay:SetColorTexture(color.r, color.g, color.b, 0.65)
              frame.overlay:Show()
            else
              frame.overlay:Hide()
            end
            return frame
          end, function()
            frame:Hide()
            table.insert(auraBigIconFramePool, frame)
          end
        end)
        :subscribe(nil, nil, UnitAttribute:map(function(unit)
          return unit, 'HARMFUL'
        end)))
    end

    do -- debuffs in corner
    end

    ]]

    return button, function()
      for i = 1, #subs do
        subs[i]()
      end
    end
  end
end

local Group = Observable.header('PSRaidGroup', UIParent, nil, nil, [[
  self:SetWidth(80)
  self:SetHeight(66)
  self:SetAttribute('*type1', 'target')
  self:SetAttribute('*type2', 'togglemenu')
  self:SetAttribute('toggleForVehicle', true)
  RegisterUnitWatch(self)
]])

do
  local previous
  for i = 1, 8 do
    Group
      :map(function(frame, buttons)
        frame:SetAttribute('showRaid', true)
        frame:SetAttribute('showParty', true)
        frame:SetAttribute('showPlayer', true)
        frame:SetAttribute('showSolo', true)
        frame:SetAttribute('xOffset', -1)
        frame:SetAttribute('columnSpacing')
        frame:SetAttribute('point', 'RIGHT')
        frame:SetAttribute('columnAnchorPoint', 'BOTTOM')
        frame:SetAttribute('groupBy', 'ASSIGNEDROLE')
        frame:SetAttribute('groupingOrder', 'TANK,DAMAGER,HEALER')
        frame:SetAttribute('groupFilter', i)
        RegisterAttributeDriver(frame, 'state-visibility', 'show')
        if not previous then
          frame:SetPoint('BOTTOMRIGHT', UIParent, 'BOTTOMLEFT', 480, 460)
        else
          frame:SetPoint('BOTTOMRIGHT', previous, 'TOPRIGHT', 0, 1)
        end
        previous = frame
        return buttons
      end)
      :switch()
      :upgrade(RaidButton)
      :subscribe()
  end
end
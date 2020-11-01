local ClassColor
local PowerColor
do
  local COLOR_CLASS
  local COLOR_POWER
  local default = { 0.5, 0.5, 0.5 }
  do
    function copyColors(src, dst)
      for key, value in pairs(src) do
        if not dst[key] then
          dst[key] = { value.r, value.g, value.b }
        end
      end
      return dst
    end
    COLOR_POWER = copyColors(PowerBarColor, { MANA = { 0.31, 0.45, 0.63 }})
    COLOR_CLASS = copyColors(RAID_CLASS_COLORS, {})
  end
  function ClassColor(unit)
    local color = COLOR_CLASS[select(2, UnitClass(unit))]
    if not color then
      return default
    end
    return color
  end
  function PowerColor(unit)
    local color = COLOR_POWER[select(2, UnitPowerType(unit))]
    if not color then
      return default
    end
    return color
  end
end

local function ToggleVisible(frame, condition)
  if condition then
    frame:Show()
  else
    frame:Hide()
  end
end

local function Stack(self, P, R, X, Y, p, r, x, y, ...)
  local anchor
  for i = 1, select("#", ...) do
    local icon = select(i, ...)
    if icon:IsShown() then
      if anchor == nil then
        icon:SetPoint(P, self, R, X, Y)
      else
        icon:SetPoint(p, anchor, r, x, y)
      end
      anchor = icon
    end
  end
end

local CreateSpring
do
  local FPS = 60
  local MPF = 1000/FPS
  local SPF = MPF/1000
  local function stepper(x, v, t, k, b)
    local fs = -k * (x - t)
    local fd = -b * v
    local a = fs + fd
    local V = v + a * SPF
    local X = x + V * SPF
    return X, V
  end
  local insert = table.insert
  local remove = table.remove
  local floor = math.floor
  local abs = math.abs
  local function update(s, elapsed)
    s.__update_e = s.__update_e + elapsed
    local delta = (s.__update_e - floor(s.__update_e / MPF) * MPF) / MPF
    local frames = floor(s.__update_e / MPF)
    for i = 0, frames-1 do
      s.__update_C, s.__update_V = stepper(s.__update_C, s.__update_V, s.__update_t, s.__update_k, s.__update_b)
    end
    local c, v = stepper(s.__update_C, s.__update_V, s.__update_t, s.__update_k, s.__update_b)
    s.__update_c = s.__update_C + (c - s.__update_C) * delta
    s.__update_v = s.__update_V + (v - s.__update_V) * delta
    s.__update_e = s.__update_e - frames * MPF
  end
  local function idle(s)
    if (abs(s.__update_v) < s.__update_p and abs(s.__update_c - s.__update_t) < s.__update_p) then
      s.__update_c = s.__update_t
      s.__update_C = s.__update_t
      s.__update_v = 0
      s.__update_V = 0
      s.__update_e = 0
      return true
    end
    return false
  end
  local frame = CreateFrame("frame", nil, UIParent)
  local SPRING = {}
  SPRING.__index = SPRING
  local function OnUpdate(_, elapsed)
    local elapsedMS = elapsed * 1000
    local elapsedDT = elapsedMS / MPF
    for i = #SPRING, 1, -1 do
      local s = SPRING[i]
      if idle(s) then
        s.__active = nil
        remove(SPRING, i)
        if #SPRING == 0 then
          frame:SetScript("OnUpdate", nil)
        end
      else
        update(s, elapsedMS)
      end
      s.__update_fn(s, s.__update_c)
    end
  end
  function CreateSpring(FN, K, B, P)
    return setmetatable({
      __update_fn = FN,
      __initialized = false,
      __update_p = P or 0.01,
      __update_k = K or 170,
      __update_b = B or 26,
    }, SPRING)
  end
  function SPRING:__call(target)
    if not self.__initialized then
      self.__initialized = true
      self.__update_c = target
      self.__update_C = target
      self.__update_v = 0
      self.__update_V = 0
      self.__update_e = 0
    end
    self.__update_t = target
    if not self.__active then
      self.__active = true
      if #SPRING == 0 then
        frame:SetScript("OnUpdate", OnUpdate)
      end
      insert(SPRING, self)
    end
  end
  function SPRING:stop(target)
    self.__update_t = target
    self.__update_c = target
    self.__update_C = target
    self.__update_v = 0
    self.__update_V = 0
    self.__update_e = 0
    if self.__active then
      self.__active = nil
      for i = 1, #SPRING do
        if self == SPRING[i] then
          remove(SPRING, i)
          break
        end
      end
      if #SPRING == 0 then
        frame:SetScript("OnUpdate", nil)
      end
    end
    self.__update_fn(self, target)
  end
end
local MEDIA = {}
do
  local bgFlat = [[Interface\\Addons\\Squish\\media\\backdrop.tga]]
  local edgeFile = [[Interface\\Addons\\Squish\\media\\edgeFile.tga]] 
  local barFlat = [[Interface\\Addons\\Squish\\media\\flat.tga]]
  local barMini = [[Interface\\Addons\\Squish\\media\\minimalist.tga]]
  local vixar = [[interface\\addons\\squish\\media\\vixar.ttf]]
  function MEDIA:BACKDROP(bg, edge, edgeSize, inset)
    return {
      bgFile = bg and bgFlat,
      edgeFile = edge and edgeFile,
      edgeSize = edgeSize,
      insets = {
        left = inset, right = inset, top = inset, bottom = inset
      }
    }
  end
  function MEDIA:STATUSBAR(mini)
    if mini then
      return barMini
    end
    return barFlat
  end
  function MEDIA:FONT()
    return vixar
  end
end


local function OnEnter_AuraButton(self)
  if not self:IsVisible() then return end
  GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMRIGHT')
  GameTooltip:SetUnitAura(self.unit, self.index, self.filter)
end
local function OnLeave_AuraButton()
  GameTooltip:Hide()
end
local OnAttributeChanged_AuraButton
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
    local insert = table.insert
    function ticker:insert(button)
      button.padd = 0
      SetDuration(button, GetTime())
      if button.active then return end
      button.active = true
      insert(self, button)
    end
    local remove = table.remove
    function ticker:remove(button)
      if not button.active then return end
      button.active = false
      for i = 1, #self do
        if button == self[i] then
          remove(self, i)
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

local DisableBlizzard
do -- https://github.com/oUF-wow/oUF/blob/master/blizzard.lua
  local MAX_ARENA_ENEMIES = MAX_ARENA_ENEMIES or 5
  local MAX_BOSS_FRAMES = MAX_BOSS_FRAMES or 5
  local MAX_PARTY_MEMBERS = MAX_PARTY_MEMBERS or 4
  local hiddenParent = CreateFrame('Frame', nil, UIParent)
  hiddenParent:SetAllPoints()
  hiddenParent:Hide()
  local function handleFrame(baseName)
    local frame
    if type(baseName) == 'string' then
      frame = _G[baseName]
    else
      frame = baseName
    end
    if frame then
      frame:UnregisterAllEvents()
      frame:Hide()
      frame:SetParent(hiddenParent)
      local health = frame.healthBar or frame.healthbar
      if health then
        health:UnregisterAllEvents()
      end
      local power = frame.manabar
      if power then
        power:UnregisterAllEvents()
      end
      local spell = frame.castBar or frame.spellbar
      if spell then
        spell:UnregisterAllEvents()
      end
      local altpowerbar = frame.powerBarAlt
      if altpowerbar then
        altpowerbar:UnregisterAllEvents()
      end
      local buffFrame = frame.BuffFrame
      if buffFrame then
        buffFrame:UnregisterAllEvents()
      end
    end
  end
  function DisableBlizzard(unit)
    if(not unit) then return end
    if(unit == 'player') then
      handleFrame(PlayerFrame)
      PlayerFrame:RegisterEvent('PLAYER_ENTERING_WORLD')
      PlayerFrame:RegisterEvent('UNIT_ENTERING_VEHICLE')
      PlayerFrame:RegisterEvent('UNIT_ENTERED_VEHICLE')
      PlayerFrame:RegisterEvent('UNIT_EXITING_VEHICLE')
      PlayerFrame:RegisterEvent('UNIT_EXITED_VEHICLE')
      PlayerFrame:SetUserPlaced(true)
      PlayerFrame:SetDontSavePosition(true)
    elseif(unit == 'pet') then
      handleFrame(PetFrame)
    elseif(unit == 'target') then
      handleFrame(TargetFrame)
      handleFrame(ComboFrame)
    elseif(unit == 'focus') then
      handleFrame(FocusFrame)
      handleFrame(TargetofFocusFrame)
    elseif(unit == 'targettarget') then
      handleFrame(TargetFrameToT)
    elseif(unit:match('boss%d?$')) then
      local id = unit:match('boss(%d)')
      if(id) then
        handleFrame('Boss' .. id .. 'TargetFrame')
      else
        for i = 1, MAX_BOSS_FRAMES do
          handleFrame(string.format('Boss%dTargetFrame', i))
        end
      end
    elseif(unit:match('party%d?$')) then
      local id = unit:match('party(%d)')
      if(id) then
        handleFrame('PartyMemberFrame' .. id)
      else
        for i = 1, MAX_PARTY_MEMBERS do
          handleFrame(string.format('PartyMemberFrame%d', i))
        end
      end
    elseif(unit:match('arena%d?$')) then
      local id = unit:match('arena(%d)')
      if(id) then
        handleFrame('ArenaEnemyFrame' .. id)
      else
        for i = 1, MAX_ARENA_ENEMIES do
          handleFrame(string.format('ArenaEnemyFrame%d', i))
        end
      end
      -- Blizzard_ArenaUI should not be loaded
      Arena_LoadUI = function() end
      SetCVar('showArenaEnemyFrames', '0', 'SHOW_ARENA_ENEMY_FRAMES_TEXT')
    elseif(unit:match('nameplate%d+$')) then
      local frame = C_NamePlate.GetNamePlateForUnit(unit)
      if(frame and frame.UnitFrame) then
        handleFrame(frame.UnitFrame)
      end
    end
  end
end

local function OnEvent_PlayerTarget(self, event)
  local guid = UnitGUID("playertarget")
  local header = self.header
  if guid then
    for index = 1, #header do
      if header[index].guid == guid then
        self.playerTargetAlpha(1)
        return self.playerTargetPosition(index)
      end
    end
  end
  self.playerTargetAlpha(0)
end

local function Ticker_BossTarget(self)
end

local function AuraList_Push(list, ...)
  local length = select('#', ...)
  for i = 1, length do
    list[i+list.cursor] = select(i, ...)
  end
  list.cursor = list.cursor + length
end

local OnEvent_SpellCollector
do
  --SquishData.TEST = nil
  --SquishData.SCAN = {}
  --GetInstanceInfo()
  local function GetEntry(tbl, key)
    if not tbl[key] then
      tbl[key] = {}
    end
    return tbl[key]
  end
  local function IncEntry(tbl, key)
    tbl[key] = (tbl[key] or 0) + 1
  end
  local function OnEvent_CEUF(_, event, _, sourceGUID, sourceName, sourceFlag, _, destGUID, destName, destFlag, _, spellID, spellName) 
    if not spellID or not spellName then 
      print("skip", event, spellID, spellName)
      return
    end
    local db = GetEntry(SquishData.SCAN, spellID)
    IncEntry(db, event)
    IncEntry(GetEntry(db, 'sourceFlag'), sourceFlag)
    IncEntry(GetEntry(db, 'destFlag'), destFlag)
    if sourceGUID and sourceGUID ~= " " and bit.band(sourceFlag, COMBATLOG_OBJECT_CONTROL_PLAYER) > 0 then
      local _, sourceClass = GetPlayerInfoByGUID(sourceGUID)
      if sourceClass then
        IncEntry(GetEntry(db, 'sourceClass'), sourceClass)
      end
    end
    if destGUID and destGUID ~= " " and bit.band(destFlag, COMBATLOG_OBJECT_CONTROL_PLAYER) > 0 then
      local _, destFlag = GetPlayerInfoByGUID(destGUID)
      if destClass then
        IncEntry(GetEntry(db, 'destClass'), destClass)
      end
    end
  end
  function OnEvent_SpellCollector(self, event, ...)
    OnEvent_CEUF(CombatLogGetCurrentEventInfo())
  end
end

local function AuraTable_Clear(tbl)
  tbl.cursor = 0
  tbl.offset = 1000
end

local AuraTable_Insert
do
  local function write(t, offset, ...)
    local l = select("#", ...)
    for i = 1, l do
      t[offset+i] = select(i, ...)
    end
    return l
  end
  local insert = table.insert
  function AuraTable_Insert(t, priority, ...)
    for i = 1, t.cursor do
      if priority > t[t[i]] then
        t.cursor = t.cursor + 1
        insert(t, i, t.offset)
        t.offset = t.offset + write(t, t.offset-1, priority, ...)
        return
      end
    end
    t.cursor = t.cursor + 1
    t[t.cursor] = t.offset
    t.offset = t.offset + write(t, t.offset-1, priority, ...)
  end
end

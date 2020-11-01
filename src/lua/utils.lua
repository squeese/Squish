local Table_Insert = table.insert
local Table_Remove = table.remove
local Math_Floor = math.floor
local Math_Abs = math.abs
local Math_Ceil = math.ceil

local ClassColor
local PowerColor
local DebuffColor
do
  local COLOR_CLASS
  local COLOR_POWER
  local COLOR_DEBUFF
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
    COLOR_DEBUFF = copyColors(DebuffTypeColor, {})
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
  function DebuffColor(kind)
    local color = COLOR_DEBUFF[kind]
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

local function CountVisible(...)
  local n = 0
  for i = 1, select("#", ...) do
    if not select(i, ...):IsShown() then
      break
    end
    n = n + 1
  end
  return n
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
  local _, _, _, _, _, _, _, _, _, id = UnitAura(self.unit, self.index, self.filter)
  GameTooltip:AddLine("ID: " .. tostring(id), 1, 1, 1) 
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


--local function OnEvent_PlayerTarget(self, event)
  --local guid = UnitGUID("playertarget")
  --local header = self.header
  --if guid then
    --for index = 1, #header do
      --if header[index].guid == guid then
        --self.playerTargetAlpha(1)
        --return self.playerTargetPosition(index)
      --end
    --end
  --end
  --self.playerTargetAlpha(0)
--end

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




local function RangeChecker(self)
  if UnitIsConnected(self.unit) then
    local close, checked = UnitInRange(self.unit)
    if checked and (not close) then
      self:SetAlpha(0.45)
    else
      self:SetAlpha(1.0)
    end
  else
    -- self:SetAlpha(0.45)
    self:SetAlpha(1.0)
  end
end


local CanDispel = {}
function CanDispel:RegisterEvents(frame)
  frame:RegisterEvent("PLAYER_ENTERING_WORLD")
  frame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
  self.RegisterEvents = nil
  return function(_, event)
    if event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_SPECIALIZATION_CHANGED" then
      local class = UnitClass("player")
      for k, _ in pairs(CanDispel) do
        CanDispel[k] = nil
      end
      if class == "Priest" then
        if IsSpellKnown(527) then
          CanDispel.Magic = true
          CanDispel.Disease = true
        else
          CanDispel.Disease = true
        end
      else
        print("unhandled dispel", class)
      end
    end
  end
end

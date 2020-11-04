local Table_Insert = table.insert
local Table_Remove = table.remove
local Table_Sort = table.sort
local Math_Floor = math.floor
local Math_Abs = math.abs
local Math_Ceil = math.ceil
local Math_Max = math.max
local Math_Min = math.min


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


local MEDIA = {
  BACKDROP_FLAT  = [[Interface\\Addons\\SquishUI\\media\\backdrop.tga]],
  BACKDROP_EDGE  = [[Interface\\Addons\\SquishUI\\media\\edgeFile.tga]],
  STATUSBAR_FLAT = [[Interface\\Addons\\SquishUI\\media\\flat.tga]],
  STATUSBAR_MIN  = [[Interface\\Addons\\SquishUI\\media\\minimalist.tga]],
  FONT_VIXAR     = [[interface\\addons\\squishUI\\media\\vixar.ttf]],
}

do
  function MEDIA:BACKDROP(bg, edge, edgeSize, inset, right, top, bottom)
    return {
      bgFile = bg and bgFlat,
      edgeFile = edge and edgeFile,
      edgeSize = edgeSize,
      insets = {
        left = inset,
        right = (right or inset),
        top = (top or inset),
        bottom = (bottom or inset),
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

    --self:UnregisterAllEvents()
    ---- self:RegisterEvent("UNIT_AURA")
    ---- self:RegisterEvent("UNIT_SPELLCAST_START")
    ---- self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    --self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    --self:SetScript("OnEvent", OnEvent_SpellCollector)
--local OnEvent_SpellCollector
--do
  ----SquishData.TEST = nil
  ----SquishData.SCAN = {}
  ----GetInstanceInfo()
  --local function GetEntry(tbl, key)
    --if not tbl[key] then
      --tbl[key] = {}
    --end
    --return tbl[key]
  --end
  --local function IncEntry(tbl, key)
    --tbl[key] = (tbl[key] or 0) + 1
  --end
  --local function OnEvent_CEUF(_, event, _, sourceGUID, sourceName, sourceFlag, _, destGUID, destName, destFlag, _, spellID, spellName) 
    --if not spellID or not spellName then 
      --print("skip", event, spellID, spellName)
      --return
    --end
    --local db = GetEntry(SquishData.SCAN, spellID)
    --IncEntry(db, event)
    --IncEntry(GetEntry(db, 'sourceFlag'), sourceFlag)
    --IncEntry(GetEntry(db, 'destFlag'), destFlag)
    --if sourceGUID and sourceGUID ~= " " and bit.band(sourceFlag, COMBATLOG_OBJECT_CONTROL_PLAYER) > 0 then
      --local _, sourceClass = GetPlayerInfoByGUID(sourceGUID)
      --if sourceClass then
        --IncEntry(GetEntry(db, 'sourceClass'), sourceClass)
      --end
    --end
    --if destGUID and destGUID ~= " " and bit.band(destFlag, COMBATLOG_OBJECT_CONTROL_PLAYER) > 0 then
      --local _, destFlag = GetPlayerInfoByGUID(destGUID)
      --if destClass then
        --IncEntry(GetEntry(db, 'destClass'), destClass)
      --end
    --end
  --end
  --function OnEvent_SpellCollector(self, event, ...)
    --OnEvent_CEUF(CombatLogGetCurrentEventInfo())
  --end
--end




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

${cleanup.add("HookSpellBookTooltips")}
local function HookSpellBookTooltips()
  local fn = GameTooltip.SetSpellBookItem
  function GameTooltip:SetSpellBookItem(...)
    local _, id = GetSpellBookItemInfo(...)
    fn(GameTooltip, ...)
    GameTooltip:AddLine("ID: " .. tostring(id), 1, 1, 1)
  end
end

${cleanup.add("ScanGameTooltips")}
local function ScanGameTooltips()
  local mt = getmetatable(GameTooltip).__index
  for k, v in pairs(mt) do
    if string.sub(k, 1, 3) == 'Set' then
      print(k)
    end
  end
end



${include("./SquishScan/cleanup.lua")}

local frame = CreateFrame("button", nil, UIParent)
frame:RegisterEvent("VARIABLES_LOADED")
frame:SetScript("OnEvent", function(self)
  if not _G.SquishScanData or type(_G.SquishScanData) ~= "table" then
    _G.SquishScanData = {}
  end
  for i = #_G.SquishScanData, 1, -1 do
    if CLEANUP[_G.SquishScanData[i][1]] then
      print("remove", i)
      table.remove(_G.SquishScanData, i)
    end
  end

  local ICON_IDLE = 132852
  local ICON_ACTIVE = 134468
  self:SetSize(32, 32)
  self:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 4, -4)
  local icon = self:CreateTexture(nil, "OVERLAY")
  icon:SetAllPoints()
  icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

  local DATA = _G.SquishScanData
  local SetActive
  local SetIdle
  local OnEvent_Idle
  local OnEvent_Active
  local current = nil
  local cursor = 0
  local enabled = nil

  local function write(...)
    local length = select("#", ...)
    current[cursor] = length
    for i = 1, length do
      current[cursor+i] = select(i, ...)
    end
    cursor = cursor + length + 1
    --print("WRITE", length, ...)
  end

  function SetIdle()
    print("Scanner -> IDLE")
    icon:SetTexture(ICON_IDLE)
    self:UnregisterAllEvents()
    self:RegisterEvent("ENCOUNTER_START")
    self:RegisterEvent("PLAYER_REGEN_DISABLED")
    self:SetScript("OnEvent", OnEvent_Idle)
    current = nil
  end

  function SetActive(...)
    print("Scanner -> ACTIVE")
    icon:SetTexture(ICON_ACTIVE)
    current = {date("%a %b %d %H:%M:%S %Y")}
    cursor = 2
    table.insert(DATA, 1, current)
    write(...)
    write(GetInstanceInfo())
    self:UnregisterAllEvents()
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    self:RegisterEvent("UNIT_SPELLCAST_START")
    self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    self:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE")
    self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
    self:RegisterEvent("CHAT_MSG_MONSTER_SAY")
    self:SetScript("OnEvent", OnEvent_Active)
  end

  function OnEvent_Idle(_, event, ...)
    if not UnitInParty("player") then return end
    if event == "ENCOUNTER_START" then
      SetActive(event, ...)
    elseif event == "PLAYER_REGEN_DISABLED" then
      SetActive(event, ...)
    end
  end

  local function CLEU(_, event, _, sourceGUID, sourceName, sourceFlag, _, destGUID, destName, destFlag, _, spellID, spellName)
    if spellID and spellName then
      if event == "SPELL_CAST_FAILED" then return end
      write(event, sourceGUID, sourceName, sourceFlag, destGUID, destName, destFlag, spellID, spellName)
    end
  end

  function OnEvent_Active(_, event, ...)
    if event == "PLAYER_REGEN_ENABLED" then
      SetIdle()
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
      CLEU(CombatLogGetCurrentEventInfo())
    else
      write(event, ...)
    end
  end

  SetIdle()
  self:SetScript("OnClick", function()
    if current == nil then
      SetActive("MANUAL")
    else
      SetIdle()
    end
  end)
end)

-- start/stop record button

-- SPELL_CAST_START
-- SPELL_CAST_SUCCESS
-- SPELL_AURA_APPLIED
-- SPELL_AURA_REMOVED
-- UNIT_AURA
-- CHAT_MSG_RAID_BOSS_EMOTE
-- CHAT_MSG_MONSTER_YELL
-- CHAT_MSG_MONSTER_SAY
-- UNIT_SPELLCAST_SUCCEEDED boss1, etc

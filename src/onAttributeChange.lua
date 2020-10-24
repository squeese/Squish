local OnAttributeChanged
do
  local function UpdateGUID(self, guid)
    if self.guid == guid then
      return
    elseif self.guid == nil then
      self.guid = guid
      self:handler("GUID_SET", guid)
    elseif guid ~= nil then
      local old = self.guid
      self.guid = guid
      self:handler("GUID_MOD", guid, old)
    else
      local old = self.guid
      self.guid = nil
      self:handler("GUID_REM", old)
    end
  end
  local function OnEvent_Player(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
      assert(self.unit == "player")
      return UpdateGUID(self, UnitGUID("player"))
    end
    self:handler(event, ...)
  end
  local function OnEvent_Target(self, event, ...)
    if event == "PLAYER_TARGET_CHANGED" then
      assert(self.unit == "target")
      return UpdateGUID(self, UnitGUID("target"))
    end
    self:handler(event, ...)
  end
  local function OnEvent_Group(self, event, ...)
    if event == "GROUP_ROSTER_UPDATE" then
      return UpdateGUID(self, UnitGUID(self.unit))
    end
    self:handler(event, ...)
  end
  local function OnEvent_Mouse() end
  local function OnEvent_Focus() end
  local function OnEvent_Boss() end
  local function OnEvent_Arena() end
  local function OnUpdate_Target() end
  local function SetGUIDChangeEvents(self, unit)
    if unit == "player" then
      self:RegisterEvent("PLAYER_ENTERING_WORLD")
      self:SetScript("OnEvent", OnEvent_Player)
    elseif unit == "target" then
      self:RegisterEvent("PLAYER_TARGET_CHANGED")
      self:SetScript("OnEvent", OnEvent_Target)
    elseif unit:match('raid%d?$') or unit:match('party%d?$') then
      self:RegisterEvent("GROUP_ROSTER_UPDATE")
      self:SetScript("OnEvent", OnEvent_Group)
    elseif unit == "mouseover" then
      self:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
      self:SetScript("OnEvent", OnEvent_Mouse)
    elseif unit == "focus" then
      self:RegisterEvent("PLAYER_FOCUS_CHANGED")
      self:SetScript("OnEvent", OnEvent_Focus)
    elseif unit:match('boss%d?$') then
      self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
      self:RegisterEvent("UNIT_TARGETABLE_CHANGED")
      self:SetScript("OnEvent", OnEvent_Boss)
    elseif unit:match('arena%d?$') then
      self:RegisterEvent("ARENA_OPPONENT_UPDATE")
      self:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")
      self:SetScript("OnEvent", OnEvent_Arena)
    elseif unit:match('%w+target') then
      self:SetScript("OnUpdate", OnUpdate_Target)
    else
      print("SetGUIDChangeEvents uncatched", unit)
    end
  end
  local function RemGUIDChangeEvents(self, unit)
    if unit == "player" then
      self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    elseif unit == "mouseover" then
      self:UnregisterEvent("UPDATE_MOUSEOVER_UNIT")
    elseif unit == "target" then
      self:UnregisterEvent("PLAYER_TARGET_CHANGED")
    elseif unit:match('raid%d?$') or unit:match('party%d?$') then
      self:UnregisterEvent("GROUP_ROSTER_UPDATE")
    elseif unit == "focus" then
      self:UnregisterEvent("PLAYER_FOCUS_CHANGED")
    elseif unit:match('boss%d?$') then
      self:UnregisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
      self:UnregisterEvent("UNIT_TARGETABLE_CHANGED")
    elseif unit:match('arena%d?$') then
      self:UnregisterEvent("ARENA_OPPONENT_UPDATE")
      self:UnregisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")
    elseif unit:match('%w+target') then
      self:SetScript("OnUpdate", nil)
      return
    else
      print("RemGUIDChangeEvents uncatched", unit)
    end
    self:SetScript("OnEvent", nil)
  end
  function OnAttributeChanged(self, key, val)
    if key ~= "unit" or self.unit == val then
      return
    elseif self.unit == nil then
      SetGUIDChangeEvents(self, val)
      self:handler("UNIT_SET", val)
      UpdateGUID(self, UnitGUID(val))
    elseif val ~= nil then
      RemGUIDChangeEvents(self, self.unit)
      SetGUIDChangeEvents(self, val)
      self:handler("UNIT_MOD", val)
      UpdateGUID(self, UnitGUID(val))
    else
      RemGUIDChangeEvents(self, self.unit)
      self:handler("UNIT_REM")
      UpdateGUID(self, nil)
    end
    self.unit = val
  end
end

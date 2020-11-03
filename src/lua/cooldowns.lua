local CreateCooldowns
do
  local function FilterCooldown(spell, class, specc)
    if type(spell) == "table" then
      if spell.item then
        return IsEquippedItem(spell.id)
      end
      if not IsSpellKnown(spell.id) then return false end
      if spell.specc and spell.specc ~= specc then return false end
      if spell.class and spell.class ~= class then return false end
      return true
    end
    return IsSpellKnown(spell)
  end

  local function CreateIcon(self, ...)
    local frame = CreateFrame("statusbar", nil, self.parent)
    -- frame:SetBackdrop(MEDIA:BACKDROP(true, false, 0, 0))
    -- frame:SetBackdropColor(0, 0, 0, 0.75)
    frame:SetStatusBarTexture(MEDIA:STATUSBAR())
    frame:SetStatusBarColor(0, 0, 0, 0.75)
    frame:SetOrientation("VERTICAL")
    frame:SetMinMaxValues(0, 1)
    frame:SetValue(0)
    frame.icon = frame:CreateTexture(nil, 'BACKGROUND', nil, 7)
    frame.icon:SetAllPoints()
    -- frame.icon:SetPoint("TOPLEFT", 1, -1)
    -- frame.icon:SetPoint("BOTTOMRIGHT", -1, 1)
    frame.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    frame.time = frame:CreateFontString(nil, nil, "GameFontNormal")
    frame.time:SetFont(MEDIA:FONT(), 18, "OUTLINE")
    frame.time:SetPoint("BOTTOM", 0, 4)
    --frame.time:SetTextColor(1, 1, 1, 1)
    frame.stack = frame:CreateFontString(nil, nil, "GameFontNormal")
    frame.stack:SetFont(MEDIA:FONT(), 22, "OUTLINE")
    frame.stack:SetPoint("TOP", 0, -4)
    --frame.stack:SetTextColor(1, 1, 1, 1)
    return frame
  end

  local function StopUpdate(self)
    self.duration = nil
    self.__tick = nil
    Queue:Remove(self)
    self.time:Hide()
    self:SetValue(0)
    self.icon:SetVertexColor(1, 1, 1, 1)
    self:SetScript("OnUpdate", nil)
  end

  local function ResetIcon(self, frame)
    frame:SetScript("OnUpdate", nil)
    frame:SetScript("OnEvent", nil)
    frame:UnregisterAllEvents()
    frame:ClearAllPoints()
    frame:Hide()
    frame.stack:SetText("")
    frame.charges = nil
    StopUpdate(frame)
  end

  local function OnUpdate_ShortDuration(self, elapsed)
    self.duration = self.duration - elapsed
    if self.duration < 0 then
      StopUpdate(self)
    else
      self:SetValue(self.duration)
      self.time:SetText(Math_Floor(self.duration * 10) / 10)
    end
  end

  local function OnUpdate_LongDuration(self, elapsed)
    self.duration = self.duration - elapsed
    if self.duration < 2 then
      self:SetValue(self.duration)
      self:SetScript("OnUpdate", OnUpdate_ShortDuration)
      self.__tick = nil
      Queue:Remove(self)
    else
      self:SetValue(self.duration)
    end
  end

  local function OnUpdate_TickDuration(self)
    if self.duration > 60 then
      self.time:SetFormattedText("%dm", Math_Ceil(self.duration / 60))
    else
      self.time:SetFormattedText("%d", self.duration + self.__delay)
    end
    Queue:Insert(self, self.duration - Math_Floor(self.duration))
  end

  local function StartUpdate(self, elapsed, duration)
    if not self.__tick then
      self.__tick = OnUpdate_TickDuration
    else
      Queue:Remove(self)
    end
    self.duration = elapsed
    self:SetMinMaxValues(0, duration)
    self.time:Show()
    self.icon:SetVertexColor(1, 0.35, 0.35, 0.85)
    self.__delay = 0
    self:__tick()
    self:SetScript("OnUpdate", OnUpdate_LongDuration)
  end

  local function OnEvent_SpellCooldown(self)
    local started, duration = GetSpellCooldown(self.spell)
    local charges, maxCharges, lastStarted, lastDuration = GetSpellCharges(self.spell)
    if charges ~= nil then
      if charges ~= self.charges then
        self.charges = charges
        self.stack:SetText(charges)
      end
      if charges > 0 and charges < maxCharges then
        started = lastStarted
        duration = lastDuration
      end
    end
    if started == 0 or duration == 0 then
      return
    end
    local elapsed = GetTime() - started
    if elapsed < 1.5 and duration < 1.5 then
      return
    end
    StartUpdate(self, duration - elapsed, duration)
  end

  local function OnEvent_ItemCooldown(self)
    local started, duration = GetItemCooldown(self.spell)
    if started == 0 or duration == 0 then
      return
    end
    local elapsed = GetTime() - started
    if elapsed < 1.5 and duration < 1.5 then
      return
    end
    StartUpdate(self, duration - elapsed, duration)
  end

  local function OnEvent_CreateIcons(self)
    local class = UnitClass("player")
    local _, specc = GetSpecializationInfo(GetSpecialization())
    while #self > 0 do
      self.pool:Release(Table_Remove(self))
    end
    for _, spell in ipairs(self.spells) do
      if FilterCooldown(spell, class, specc) then
        local frame = self.pool:Acquire()
        frame:SetParent(self)
        frame:SetSize(self.size, self.size)
        frame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
        frame:RegisterEvent("SPELL_UPDATE_USABLE")
        frame:Show()
        if type(spell) == "table" then
          frame.spell = spell.id
          frame.item = spell.item
        else
          frame.spell = spell
          frame.item = false
        end
        if frame.item then
          frame.icon:SetTexture(select(10, GetItemInfo(frame.spell)))
          frame:SetScript("OnEvent", OnEvent_ItemCooldown)
          OnEvent_ItemCooldown(frame)
        else
          frame.icon:SetTexture(select(3, GetSpellInfo(frame.spell)))
          frame:SetScript("OnEvent", OnEvent_SpellCooldown)
          OnEvent_SpellCooldown(frame)
        end
        Table_Insert(self, frame)
      end
    end
    Stack(self, "RIGHT", "RIGHT", -1, 0, "RIGHT", "LEFT", -1, 0, unpack(self))
    self:SetSize(self.size * #self + #self + 1, self.size + 2)
  end

  local pool = nil
  ${cleanup.add("CreateCooldowns")}
  function CreateCooldowns(parent, size, spells)
    local frame = CreateFrame("frame", nil, parent, "BackdropTemplate")
    frame:SetBackdrop(MEDIA:BACKDROP(true, false, 0, 0))
    frame:SetBackdropColor(0, 0, 0, 0.75)
    if not pool then
      pool = CreateObjectPool(CreateIcon, ResetIcon)
      pool.parent = parent
    end
    frame.pool = pool
    frame.spells = spells
    frame.size = size
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    frame:RegisterEvent("PLAYER_TALENT_UPDATE")
    frame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    frame:SetScript("OnEvent", OnEvent_CreateIcons)
    return frame
  end
end

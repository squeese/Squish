local CooldownsRegisterEvents
do
  local spells = {
    { id = 47540,  item = false }, -- penance
    { id = 8092,   item = false }, -- mind blast
    { id = 129250, item = false }, -- power word: solace
    { id = 34433,  item = false }, -- shadowfiend
    { id = 194509, item = false }, -- power word: radiance
    { id = 33206,  item = false }, -- painsup
    { id = 47540,  item = false }, -- penance
    { id = 47540,  item = false }, -- penance
    { id = 47540,  item = false }, -- penance
    { id = 47540,  item = false }, -- penance
    { id = 47540,  item = false }, -- penance
    { id = 47540,  item = false }, -- penance
    { id = 47540,  item = false }, -- penance
    { id = 47540,  item = false }, -- penance
    { id = 47540,  item = false }, -- penance
    { id = 47540,  item = false }, -- penance
  }

  local function valid(spell, class, specc)
    if spell.item then return false end
    if not IsSpellKnown(spell.id) then return false end
    if spell.specc and spell.specc ~= specc then return false end
    if spell.class and spell.class ~= class then return false end
    return true
  end

  local function create(self, ...)
    local self = CreateFrame("statusbar", nil, UIParent, "BackdropTemplate")
    self:SetBackdrop(MEDIA:BACKDROP(true, false, 0, 0))
    self:SetStatusBarTexture(MEDIA:STATUSBAR())
    self:SetBackdropColor(0, 0, 0, 0.75)
    self:SetStatusBarColor(0, 0, 0, 0.75)
    self:SetOrientation("VERTICAL")
    self:SetMinMaxValues(0, 1)
    self:SetValue(0)
    self.icon = self:CreateTexture(nil, 'BACKGROUND', nil, 7)
    self.icon:SetPoint("TOPLEFT", 1, -1)
    self.icon:SetPoint("BOTTOMRIGHT", -1, 1)
    self.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    self.time = self:CreateFontString(nil, nil, "GameFontNormal")
    self.time:SetFont(MEDIA:FONT(), 18, "OUTLINE")
    self.time:SetPoint("CENTER", 0, 0)
    self.time:SetTextColor(1, 1, 1, 1)
    self.stack = self:CreateFontString(nil, nil, "GameFontNormal")
    self.stack:SetFont(MEDIA:FONT(), 14, "OUTLINE")
    self.stack:SetPoint("TOPRIGHT", -4, -4)
    self.stack:SetTextColor(1, 1, 1, 1)
    self.stack:Hide()
    return self
  end

  local function reset(self, frame)
    frame:SetScript("OnUpdate", nil)
    frame:SetScript("OnEvent", nil)
    frame:ClearAllPoints()
    frame:SetSize(48, 48)
    frame:UnregisterAllEvents()
    frame:Hide()
    frame.stack:Hide()
    frame.spell = nil
    frame.charges = nil
    frame.duration = nil
    frame.throttle = nil
  end

  local pool = CreateObjectPool(create, reset)

  local function OnUpdate_test_2(self, elapsed)
    self.duration = self.duration - elapsed
    if self.duration <= 0 then
      self.duration = nil
      self:SetScript("OnUpdate", nil)
      Queue:Remove(self)
      self.__tick = nil
      self.time:SetText("")
    elseif self.duration < 1 then
      self:SetValue(self.duration)
    else
      self:SetValue(self.duration)
    end
  end

  local function tick(self)
          --self.time:SetFormattedText("%dm", Math_Ceil(self.duration / 60))
    self.time:SetFormattedText("%d", self.duration + 0.5 + self.__delay)
    Queue:Insert(self, self.duration - Math_Floor(self.duration))
  end

  local function OnEvent_test_2(self, event, ...)
    local curCharges, maxCharges, lastStarted, lastDuration = GetSpellCharges(self.spell.id)
    if curCharges ~= self.charges then
      self.charges = curCharges
      self.stack:Show()
      self.stack:SetText(curCharges)
    end
    local started, duration = GetSpellCooldown(self.spell.id)
    if duration > 0 then
      if (duration < 1.5 and (curCharges or not self.duration)) then
        return
      end
      self.duration = duration - (GetTime() - started)
      self:SetMinMaxValues(0, duration)
      self:SetScript("OnUpdate", self.fn)
      --if self.__tick then
        --Queue:Remove()
      --else
        --self.__tick = tick
        --self.__delay = 0
        --self:__tick()
      --end
    elseif curCharges and curCharges < maxCharges then
      --self.duration = lastDuration - (GetTime() - lastStarted)
      --self:SetMinMaxValues(0, lastDuration)
      --self:SetScript("OnUpdate", self.fn)
    elseif self.duration then
      self.duration = nil
      self:SetScript("OnUpdate", nil)
      self.time:Hide()
    end
  end

  --started, duration = GetItemCooldown(self.spell.id)



  --local f = CreateFrame("frame", nil, UIParent)
  --f:SetPoint(point, x, y)
  --f:SetSize(1, 1)
  --f:Show()
  --f:RegisterEvent("PLAYER_TALENT_UPDATE")
  --f:SetScript("OnEvent", function(self, event)
    --local class = UnitClass("player")
    --local _, specc = GetSpecializationInfo(GetSpecialization())
    --print(event, class, specc)
    --while #self > 0 do
      --pool:Release(Table_Remove(self))
    --end
    --for _, spell in ipairs(spells) do
      --if valid(spell, class, specc) then
        --local frame = pool:Acquire()
        --frame.spell = spell
        --frame:SetParent(f)
        --frame.icon:SetTexture(select(3, GetSpellInfo(spell.id)))
        --frame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
        --frame:RegisterEvent("SPELL_UPDATE_USABLE")
        --frame.fn = fn
        --frame:Show()
        --if spell.item then
          --frame:SetScript("OnEvent", OnEvent_ItemCooldowns)
        --else
          --frame:SetScript("OnEvent", fn2)
          --fn2(frame)
        --end
        --Table_Insert(self, frame)
      --end
    --end
    --Stack(self, "CENTER", "CENTER", 0, 0, "RIGHT", "LEFT", -1, 0, unpack(self))
  --end)

  --local a = spawn("CENTER", 0, -64, OnUpdate_test_1, OnEvent_test_1)
  -- local b = spawn("CENTER", 0, 64, OnUpdate_test_2, OnEvent_test_2)

  --local t = CreateFrame("frame")
  --t:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
  --t:SetScript("OnEvent", function(self, event, _, _, spell)
    --if spell == 47540 then
      --self:UnregisterAllEvents()
      --self:SetScript("OnEvent", nil)
      --print("start")
      --C_Timer.After(5, function()
        --print("a", GetFrameCPUUsage(a, true))
        --print("b", GetFrameCPUUsage(b, true))
        --print("c", GetFrameCPUUsage(Queue, true))
      --end)
    --end
  --end)
  function CooldownsRegisterEvents(frame)
    CooldownsRegisterEvents = nil
    frame:RegisterEvent("PLAYER_TALENT_UPDATE")
    return function(self, event, ...)
      print("ok", event, ...)
      return true
    end
  end
end

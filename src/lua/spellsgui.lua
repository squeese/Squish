do
  -- text input
  -- order columns
  -- resize
  -- column sizes
  -- saved variables

  local WIDTH = 1024
  local HEIGHT = 512
  local NUMROWS = 16
  local NUMCOLS = 4
  local ROWHEIGHT = HEIGHT/NUMROWS
  local CURSOR = 1
  local DATA = {}
  for i = 1, NUMROWS do
    table.insert(DATA, {1, 2, 3, 4})
  end

  local frame = CreateFrame("frame", nil, UIParent, "BackdropTemplate")
  frame:RegisterEvent("VARIABLES_LOADED")
  frame:SetScript("OnEvent", function(self)
    self:UnregisterAllEvents()
    self:SetScript("OnEvent", nil)
    self:SetSize(WIDTH, HEIGHT * NUMROWS + 8)
    self:SetPoint("CENTER", 0, 0)
    self:SetBackdrop(MEDIA:BACKDROP(true, true, 1, 0))
    self:SetBackdropColor(0, 0, 0, 0.7)
    self:SetBackdropBorderColor(0, 0, 0, 1)
    self:SetFrameStrata("HIGH")
    self:EnableMouseWheel(true)

    local edit = CreateFrame("editbox", nil, frame, "InputBoxTemplate")
    edit:SetWidth(256)
    edit:SetHeight(32)
    edit:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 8, 4)
    edit:SetAutoFocus(false)
    edit:Show()
    edit:SetFontObject("ChatFontNormal")
    edit:SetScript("OnEscapePressed", function(self)
      self:ClearFocus()
    end)

    local scrollbar = CreateFrame("frame", nil, frame, "BackdropTemplate")
    scrollbar:SetBackdrop(MEDIA:BACKDROP(true, nil, 0, 0))
    scrollbar:SetBackdropColor(0, 0, 0, 0.5)
    scrollbar:EnableMouse(true)
    scrollbar:SetWidth(20)

    function scrollbar:update()
      local height = 
      local offset = 
      -- :SetPoint("TOPRIGHT", -4, -(index-1)/(max-1)*bar.travel-4)
      -- bar.travel = (HEIGHT * NUMROWS) - height
      bar:SetPoint("TOPRIGHT", -4, -4-(CURSOR-1)*HEIGHT/#DATA)
      bar:SetHeight(math.min(1, NUMROWS/#DATA)*ROWHEIGHT)
    end

  end)


  local function update(row, index)
    local spell, kind = unpack(DATA[index])
    local name, _, icon = GetSpellInfo(spell)
    row.spell = spell
    row.icon:SetTexture(icon)
    row[1]:SetText(name)
    row[2]:SetText(types[kind])
    row[3]:SetText("")
    row[4]:SetText("")
  end

  local prev
  for rowIndex = 1, NUMROWS do
    local row = CreateFrame("frame", nil, frame, "BackdropTemplate")
    row:SetSize(WIDTH-8-24, HEIGHT)
    row:SetBackdrop(MEDIA:BACKDROP(true, false, 0, 0))
    if rowIndex % 2 == 0 then
      row:SetBackdropColor(0, 0, 0, 0.48)
    else
      row:SetBackdropColor(0, 0, 0, 0.52)
    end
    if rowIndex == 1 then
      row:SetPoint("TOPLEFT", 4, -4)
    else
      row:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, 0)
    end
    row.icon = row:CreateTexture()
    row.icon:SetPoint("TOPLEFT", 1, -1)
    row.icon:SetPoint("BOTTOMRIGHT", row, "TOPLEFT", HEIGHT-2, -HEIGHT+2)
    row.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    for colIndex = 1, NUMCOLS do
      local cell = row:CreateFontString(nil, nil, "GameFontNormal")
      cell:SetFont(MEDIA:FONT(), 10)
      cell:SetPoint("LEFT", HEIGHT + ((WIDTH-HEIGHT-(NUMCOLS+1)*4) / (NUMCOLS)) * (colIndex-1) + (colIndex * 4), 0)
      table.insert(row, cell)
    end
    row:SetScript('OnEnter', function(self)
      if not self.spell then return end
      GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMLEFT')
      GameTooltip:SetSpellByID(self.spell)
      GameTooltip:Show()
    end)
    row:SetScript('OnLeave', function()
      GameTooltip:Hide()
    end)
    table.insert(frame, row)
    update(row, rowIndex)
    prev = row
  end

  local mt = getmetatable(GameTooltip).__index
  for k, v in pairs(mt) do
    if k:sub(1, 3) == "Set" then
      print(k)
    end
  end

  local index = 1
  local max = #DATA - NUMROWS + 1
  frame:SetScript('OnMouseWheel', function(self, delta)
    if delta < 0 then -- up
      if (index - delta) > max then return end
      frame[2]:SetPoint("TOPLEFT", frame, "TOPLEFT", 4, -4)
      frame[1]:SetPoint("TOPLEFT", frame[NUMROWS], "BOTTOMLEFT", 0, 0)
      update(frame[1], index+NUMROWS)
      table.insert(frame, frame[1])
      table.remove(frame, 1)
      index = index - delta
    else
      if (index - delta) < 1 then return end
      index = index - delta
      frame[NUMROWS]:SetPoint("TOPLEFT", frame, "TOPLEFT", 4, -4)
      frame[1]:SetPoint("TOPLEFT", frame[NUMROWS], "BOTTOMLEFT", 0, 0)
      update(frame[NUMROWS], index)
      table.insert(frame, 1, frame[NUMROWS])
      table.remove(frame)
    end
    bar:SetPoint("TOPRIGHT", -4, -(index-1)/(max-1)*bar.travel-4)
  end)

  do
    local sy
    local si
    local ei
    local hy = (NUMROWS*HEIGHT/#DATA) * UIParent:GetScale()
    bar:SetScript("OnEnter", function(self)
      self:SetBackdropColor(0.5, 0.5, 0.5, 0.5)
    end)
    local function OnLeave(self)
      self:SetBackdropColor(0, 0, 0, 0.5)
    end
    bar:SetScript("OnLeave", OnLeave)
    local function OnUpdate(self)
      local _, my = GetCursorPosition()
      local dy = my - sy
      local n = math.floor(dy / hy)
      ei = math.max(1, math.min(max, si - n))
      for r = 1, NUMROWS do
        update(frame[r], ei + r - 1)
      end
      bar:SetPoint("TOPRIGHT", -4, -(ei-1)/(max-1)*bar.travel-4)
    end
    local function OnMouseUp(self)
      index = ei
      self:SetScript("OnUpdate", nil)
      self:SetScript("OnMouseUp", nil)
      self:SetScript("OnLeave", OnLeave)
      OnLeave(self)
    end
    bar:SetScript("OnMouseDown", function(self)
      si = index
      _, sy = GetCursorPosition()
      self:SetScript("OnUpdate", OnUpdate)
      self:SetScript("OnMouseUp", OnMouseUp)
      self:SetScript("OnLeave", nil)
    end)
  end
end

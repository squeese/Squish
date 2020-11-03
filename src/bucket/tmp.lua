    --if not SquishData then
      --SquishData = {}
    --end
    --if not SquishData.SpellsData then
      --SquishData.SpellsData = {}
    --end
    --

    -- local NUMROWS = 32
    -- local ROWHEIGHT = HEIGHT/NUMROWS
    -- local CURSOR = 1
    -- local CURSOR_MAX = 1
    -- local DATA = {}
    -- local SECTION = 1
      -- Section_Spells,
      --{"Spells", 237542, PrepareRows_Spells, UpdateRows_Spells},
      -- {"Scanned", 134952},


    -- self:Hide()
    -- self.buttonPool = CreateFramePool("button", self, "UIPanelButtonTemplate")
    -- self.checkPool = CreateFramePool("checkbutton", self, "OptionsCheckButtonTemplate")
    -- self.texturePool = CreateTexturePool(self)
    -- self.fontPool = CreateFontStringPool(self, nil, nil, 'GameFontNormal')
    --for rowIndex = 1, NUMROWS do
      --local row = CreateFrame("frame", nil, frame, "BackdropTemplate")
      --row:SetSize(WIDTH-32, ROWHEIGHT-1)
      --row:SetBackdrop(MEDIA:BACKDROP(true, true, 1, 0))
      --row.color = rowIndex % 2 == 0 and 0.46 or 0.54
      --row:SetBackdropColor(0, 0, 0, row.color)
      --row:SetBackdropBorderColor(0, 0, 0, 0)
      --if rowIndex == 1 then
        --row:SetPoint("TOPLEFT", 4, -4-ROWHEIGHT)
      --else
        --row:SetPoint("TOPLEFT", self[rowIndex-1], "BOTTOMLEFT", 0, -1)
      --end
      --table.insert(self, row)
      --row:Hide()
    --end
    local OnMouseWheel
    local updateScroll
    local OnClick_CloseGUI

    do
      local close = CreateFrame("button", nil, self, "UIPanelButtonTemplate")
      close:SetSize(32, 32)
      close:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 2, 1)
      close:SetText("X")
      --function OnClick_CloseGUI()
        --SquishData.SpellsGUIOpen = false
        --SECTIONS[SECTION].CleanupRows(self)
        --self:Hide()
      --end
      --close:SetScript("OnClick", OnClick_CloseGUI)
    end

    do
      local scrollbar = CreateFrame("frame", nil, frame, "BackdropTemplate")
      scrollbar:SetBackdrop(MEDIA:BACKDROP(true, nil, 0, 0))
      scrollbar:SetBackdropColor(0.5, 0.4, 0.8, 0.3)
      scrollbar:EnableMouse(true)
      scrollbar:SetWidth(20)
      --function updateScroll()
        --scrollbar:SetPoint("TOPRIGHT", -4, -4-ROWHEIGHT-(CURSOR-1)*HEIGHT/#DATA)
        --scrollbar:SetHeight(math.min(1, NUMROWS/#DATA) * HEIGHT)
      --end
      --scrollbar:SetScript("OnEnter", function(self)
        --self:SetBackdropColor(0.5, 0.4, 0.8, 0.7)
      --end)
      --local function OnLeave(self)
        --self:SetBackdropColor(0.5, 0.5, 0.8, 0.3)
      --end
      --local function OnMouseUp(self)
        --self:SetScript("OnUpdate", nil)
        --self:SetScript("OnMouseUp", nil)
        --self:SetScript("OnLeave", OnLeave)
        --OnLeave(self)
      --end
      --local function OnUpdate(self)
        --local position = select(2, GetCursorPosition())
        --local offset = position - self.start
        --local delta
        --if offset < 0 then
          --delta = math.ceil(offset / self.height)
        --else
          --delta = math.floor(offset / self.height)
        --end
        --if delta ~= 0 then
          --self.start = self.start + delta * self.height
          --local sign = delta < 0 and -1 or 1
          --for i = delta, sign, sign*-1 do
            --OnMouseWheel(frame, sign)
          --end
        --end
      --end
      --local function OnMouseDown(self)
        --self.height = (HEIGHT/#DATA) * UIParent:GetScale()
        --self.start = select(2, GetCursorPosition())
        --self:SetScript("OnUpdate", OnUpdate)
        --self:SetScript("OnMouseUp", OnMouseUp)
        --self:SetScript("OnLeave", nil)
      --end
      --scrollbar:SetScript("OnLeave", OnLeave)
      --scrollbar:SetScript("OnMouseDown", OnMouseDown)
    end

    --do
      --local buttons = {}
      --local function OnClick(button)
        --buttons[SECTION]:SetAlpha(0.5)
        --buttons[SECTION]:SetHeight(20)
        --buttons[SECTION].icon:SetTexCoord(0.1, 0.9, 0.1, 0.6)
        --SECTION = button.index
        --SquishData.SpellsGUISection = button.index
        --button:SetAlpha(1)
        --button:SetHeight(32)
        --button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        --for i = #DATA, 1, -1 do DATA[i] = nil end
        --SECTIONS[SECTION].SetupRows(self)
        --SECTIONS[SECTION].PopulateData(self, DATA)
        --CURSOR = 1
        --CURSOR_MAX = math.max(1, #DATA-NUMROWS+1)
        --for i = 1, NUMROWS do
          --SECTIONS[SECTION].UpdateRow(self, self[i], DATA[i])
        --end
        --updateScroll()
      --end
      --local function OnEnter(self)
        --self:SetAlpha(1)
      --end
      --local function OnLeave(self)
        --if self.index == SECTION then return end
        --self:SetAlpha(0.5)
      --end
      --for index = 1, #SECTIONS do
        --local button = CreateFrame("button", nil, self, "BackdropTemplate")
        --button:SetSize(32, 32)
        --button:SetBackdrop(MEDIA:BACKDROP(true, nil, 0, -1))
        --button:SetBackdropColor(0, 0, 0, 0.75)
        --button:SetAlpha(0.5)
        --button:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 1+(index-1)*32, 1)
        --button:SetHeight(20)
        --button.icon = button:CreateTexture()
        --button.icon:SetAllPoints()
        --button.icon:SetTexture(SECTIONS[index].icon)
        --button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.6)
        --button.index = index
        --button:RegisterForClicks("anyup")
        ----button:SetScript("OnClick", OnClick)
        ----button:SetScript("OnEnter", OnEnter)
        ----button:SetScript("OnLeave", OnLeave)
        --table.insert(buttons, button)
      --end
      --if SquishData.SpellsGUIOpen then
        --self:Show()
        --OnClick(buttons[SECTION])
      --end
      --_G.Squish = {}
      --_G.Squish.ToggleSpellsGUI = function()
        --SquishData.SpellsGUIOpen = not SquishData.SpellsGUIOpen
        --if SquishData.SpellsGUIOpen then
          --self:Show()
          --OnClick(buttons[SECTION])
        --else
          --OnClick_CloseGUI()
        --end
      --end
    --end

    --function OnMouseWheel(self, delta)
      --if delta < 0 then -- up
        --if (CURSOR - delta) > CURSOR_MAX then return end
        --self[2]:SetPoint("TOPLEFT", self, "TOPLEFT", 4, -4-ROWHEIGHT)
        --self[1]:SetPoint("TOPLEFT", self[NUMROWS], "BOTTOMLEFT", 0, -1)
        --SECTIONS[SECTION].UpdateRow(self, self[1], DATA[CURSOR+NUMROWS])
        ----updateData(frame[1], CURSOR+NUMROWS)
        --table.insert(self, self[1])
        --table.remove(self, 1)
        --CURSOR = CURSOR - delta
      --else
        --if (CURSOR - delta) < 1 then return end
        --CURSOR = CURSOR - delta
        --self[NUMROWS]:SetPoint("TOPLEFT", self, "TOPLEFT", 4, -4-ROWHEIGHT)
        --self[1]:SetPoint("TOPLEFT", self[NUMROWS], "BOTTOMLEFT", 0, -1)
        --SECTIONS[SECTION].UpdateRow(self, self[NUMROWS], DATA[CURSOR])
        ----updateData(self[NUMROWS], CURSOR)
        --table.insert(self, 1, self[NUMROWS])
        --table.remove(self)
      --end
      --updateScroll()
    --end
    --self:SetScript('OnMouseWheel', OnMouseWheel)

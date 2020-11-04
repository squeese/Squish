do
  local function OnClick_CloseGUI()
    SquishData.GUIOpen = false
    SECTIONS[SELECTED]:Unload(self)
    SELECTED = nil
    self:Hide()
  end
  local closeButton = CreateFrame("button", nil, self, "UIPanelButtonTemplate")
  closeButton:SetSize(32, 32)
  closeButton:SetPoint("TOPRIGHT", self, "TOPLEFT", -1, -1)
  closeButton:SetText("X")
  closeButton:SetScript("OnClick", OnClick_CloseGUI)

  local menuButtons = {}
  local function OnClick_SectionButton(button)
    if SELECTED ~= nil then
      SECTIONS[SELECTED]:Unload(self)
      menuButtons[SELECTED].icon:SetAlpha(0.5)
      --menuButtons[SELECTED].icon:SetPoint("TOPLEFT", 4, 0)
      --menuButtons[SELECTED].icon:SetPoint("BOTTOMRIGHT", 0, 0)
    end
    SELECTED = button.index
    SquishData.GUISection = SELECTED
    button.icon:SetAlpha(1)
    --button.icon:SetPoint("TOPLEFT", 0, 0)
    --button.icon:SetPoint("BOTTOMRIGHT", -4, 0)
    SECTIONS[SELECTED]:Load(self)
  end
  local function OnEnter_SectionButton(self)
    self.icon:SetAlpha(1)
  end
  local function OnLeave_SectionButton(self)
    if self.index == SELECTED then return end
    self.icon:SetAlpha(0.5)
  end
  for index = 1, #SECTIONS do
    local button = CreateFrame("button", nil, self, "BackdropTemplate")
    button:SetSize(52, 48)
    button:SetBackdrop(MEDIA:BACKDROP(true, nil, 0, -1))
    button:SetBackdropColor(0, 0, 0, 0.75)
    button:SetPoint("TOPRIGHT", self, "TOPLEFT", 0, (index-1)*-54-64)
    button.icon = button:CreateTexture()
    button.icon:SetPoint("TOPLEFT", 0, 0)
    button.icon:SetPoint("BOTTOMRIGHT", -4, 0)
    button.icon:SetTexture(SECTIONS[index].icon)
    button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    button.icon:SetAlpha(0.5)
    button.index = index
    button:RegisterForClicks("anyup")
    button:SetScript("OnClick", OnClick_SectionButton)
    button:SetScript("OnEnter", OnEnter_SectionButton)
    button:SetScript("OnLeave", OnLeave_SectionButton)
    table.insert(menuButtons, button)
  end

  BINDING_HEADER_SQUISH = 'Squish'
  BINDING_NAME_SPELLS_TOGGLE = 'Toggle Spells Panel'
  _G.Squish = {}
  _G.Squish.ToggleSpellsGUI = function()
    SquishData.GUIOpen = not SquishData.GUIOpen
    if SquishData.GUIOpen then
      self:Show()
      OnClick_SectionButton(menuButtons[SquishData.GUISection or 1])
    else
      OnClick_CloseGUI()
    end
  end

  if SquishData.GUIOpen then
    self:Show()
    OnClick_SectionButton(menuButtons[SquishData.GUISection or 1])
  end
end

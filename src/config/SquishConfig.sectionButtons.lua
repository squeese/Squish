do
  local function OnEnter_SectionButton(button)
    button.icon:SetAlpha(1)
  end
  local function OnLeave_SectionButton(button)
    button.icon:SetAlpha(0.5)
  end
  local function OnClick_SectionButton(button)
    for index = 1, #self do
      if self[index] == button then
        button:SetScript("OnLeave", nil)
        OnEnter_SectionButton(button)
        self:SelectSection(index)
      else
        self[index]:SetScript("OnLeave", OnLeave_SectionButton)
        OnLeave_SectionButton(self[index])
      end
    end
  end
  for index = 1, #Sections do
    local button = CreateFrame("button", nil, self, "BackdropTemplate")
    button:SetSize(52, 48)
    button:SetBackdrop(SquishUI.Media:CreateBackdrop(true, nil, 0, -1))
    button:SetBackdropColor(0, 0, 0, 0.75)
    button:SetPoint("TOPRIGHT", self, "TOPLEFT", 0, (index-1)*-54-64)
    button.icon = button:CreateTexture()
    button.icon:SetPoint("TOPLEFT", 0, 0)
    button.icon:SetPoint("BOTTOMRIGHT", -4, 0)
    button.icon:SetTexture(Sections[index].icon)
    button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    button.icon:SetAlpha(0.5)
    button:RegisterForClicks("anyup")
    button:SetScript("OnEnter", OnEnter_SectionButton)
    button:SetScript("OnLeave", OnLeave_SectionButton)
    button:SetScript("OnClick", OnClick_SectionButton)
    table.insert(self, button)
  end
end

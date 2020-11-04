do
  local function SetSelectedID(self, index)
    self.selected = index
    UIDropDownMenu_Initialize(self, self.initialize, self.mode)
    UIDropDownMenu_SetSelectedID(self, index)
  end

  local function SetSelectedValue(self, value)
    self.selected = value
    UIDropDownMenu_Initialize(self, self.initialize, self.mode)
    UIDropDownMenu_SetSelectedValue(self, value)
  end

  local function CreateMenuFrame(pool)
    local frame = CreateFrame("frame", nil, self, "UIDropDownMenuTemplate,BackdropTemplate")
    frame:SetBackdrop(SquishUI.Media:CreateBackdrop(true, nil, 0, 1))
    frame:SetBackdropColor(0, 0, 0, 0.15)
    frame.Text:ClearAllPoints()
    frame.Text:SetPoint("TOPLEFT", 4, 0)
    frame.Text:SetPoint("BOTTOMRIGHT", -4, 0)
    frame.Text:SetJustifyH("LEFT")
    frame.Button:ClearAllPoints()
    frame.Button:SetPoint("RIGHT", frame, "RIGHT", 0, 0)
    frame.Button:SetScale(1.4)
    frame.Button:Show()
    frame.Left:Hide()
    frame.Middle:Hide()
    frame.Right:Hide()
    frame.info = UIDropDownMenu_CreateInfo()
    frame.SetSelectedID = SetSelectedID
    frame.SetSelectedValue = SetSelectedValue
    return frame
  end

  local function ResetMenuFrame(pool, frame)
    frame.__self = nil
    frame.__func = nil
    frame.mode = nil
    frame.info.notCheckable = nil
    frame:ClearAllPoints()
    frame:Hide()
  end

  self.menuPool = CreateObjectPool(CreateMenuFrame, ResetMenuFrame)
end

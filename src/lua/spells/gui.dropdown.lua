do
  local function SetSelected(self, index)
    self.selected = index
    UIDropDownMenu_Initialize(self, self.initialize)
    UIDropDownMenu_SetSelectedID(self, index)
  end

  local function CreateMenuFrame(pool)
    local frame = CreateFrame("frame", nil, self, "UIDropDownMenuTemplate")
    frame.info = UIDropDownMenu_CreateInfo()
    frame.Select = SetSelected
    return frame
  end

  local function ResetMenuFrame(pool, frame)
    frame:ClearAllPoints()
    frame:Hide()
  end

  self.menuPool = CreateObjectPool(CreateMenuFrame, ResetMenuFrame)
end

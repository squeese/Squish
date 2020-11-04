do
  local function OnEnter_ScrollBar(self)
    self:SetBackdropColor(1.0, 0.5, 0, 0.8)
  end

  local function OnLeave_ScrollBar(self)
    self:SetBackdropColor(1.0, 0.5, 0, 0.3)
  end

  local function UpdateScrollbar(frame)
    frame.scrollbar:SetHeight(math.min(1, frame.rowCount/frame.length) * frame.totHeight)
    frame.scrollbar:SetPoint("TOPRIGHT", -4, (frame.cursor-1) * -frame.totHeight / Math_Max(frame.length, 1))
  end

  function OnMouseWheel_Scroll(frame, delta)
    if delta < 0 then -- up
      if (frame.cursor - delta) > frame.rowMax then return end
      frame[2]:SetPoint("TOP", frame, "TOP", 0, 0)
      frame[1]:SetPoint("TOP", frame[frame.rowCount], "BOTTOM", 0, -1)
      frame:UpdateRow(frame[1], frame.cursor+frame.rowCount)
      table.insert(frame, frame[1])
      table.remove(frame, 1)
      frame.cursor = frame.cursor - delta
    else
      if (frame.cursor - delta) < 1 then return end
      frame.cursor = frame.cursor - delta
      frame[frame.rowCount]:SetPoint("TOP", frame, "TOP", 0, 0)
      frame[1]:SetPoint("TOP", frame[frame.rowCount], "BOTTOM", 0, -1)
      frame:UpdateRow(frame[frame.rowCount], frame.cursor)
      table.insert(frame, 1, frame[frame.rowCount])
      table.remove(frame)
    end
    UpdateScrollbar(frame)
  end

  local function OnMouseUp_Scrollbar(frame)
    frame:SetScript("OnUpdate", nil)
    frame:SetScript("OnMouseUp", nil)
    frame.__height = nil
    frame.__start = nil
    frame:SetScript("OnLeave", OnLeave_ScrollBar)
    OnLeave_ScrollBar(frame)
  end

  local function OnUpdate_Scrollbar(frame)
    local position = select(2, GetCursorPosition())
    local offset = position - frame.__start
    local delta
    if offset < 0 then
      delta = Math_Ceil(offset / frame.__height)
    else
      delta = Math_Floor(offset / frame.__height)
    end
    if delta ~= 0 then
      frame.__start = frame.__start + delta * frame.__height
      local sign = delta < 0 and -1 or 1
      for i = delta, sign, sign*-1 do
        OnMouseWheel_Scroll(frame:GetParent(), sign)
      end
    end
  end

  local function OnMouseDown_ScrollBar(frame)
    local scroll = frame:GetParent()
    frame.__height = (scroll.totHeight / scroll.length) * UIParent:GetScale()
    frame.__start = select(2, GetCursorPosition())
    frame:SetScript("OnMouseUp", OnMouseUp_Scrollbar)
    frame:SetScript("OnUpdate", OnUpdate_Scrollbar)
    frame:SetScript("OnLeave", nil)
  end

  local rowPool = nil
  local fontPool = nil
  local texturePool = nil
  local buttonPool = nil

  local function ReleaseIcon(row, icon)
    texturePool:Release(icon)
  end

  local function ReleaseFontString(row, font)
    fontPool:Release(font)
  end

  local function ReleaseButton(row, button)
    buttonPool:Release(button)
  end

  local function ReleaseElement(row, element)
    element.__release(row, element)
    element.__release = nil
  end

  local function AcquireButton(row)
    local button = buttonPool:Acquire()
    button:SetParent(row)
    button:Show()
    button:SetHeight(row:GetHeight())
    if width then
      button:SetWidth(width)
    else
      button.weight = weight or 1
    end
    button.__release = ReleaseButton
    return button
  end

  local function AcquireIcon(row)
    local icon = texturePool:Acquire()
    icon:SetParent(row)
    icon:Show()
    local size = row:GetHeight()
    icon:SetSize(size, size)
    icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    icon.__release = ReleaseIcon
    return icon
  end

  local function AcquireFontString(row, width, weight)
    local font = fontPool:Acquire()
    font:SetParent(row)
    font:Show()
    font:SetHeight(row:GetHeight())
    if width then
      font:SetWidth(width)
    else
      font.weight = weight or 1
    end
    font.__release = ReleaseFontString
    return font
  end


  local function StackElements(row, gap, ...)
    local length = select("#", ...)
    local width = row:GetWidth() - gap * (length - 1)
    local sum = 0
    for i = 1, length do
      local element = select(i, ...)
      if element.weight then
        sum = sum + element.weight
      else
        width = width - element:GetWidth()
      end
    end
    for i = 1, length do
      local element = select(i, ...)
      if i == 1 then
        element:SetPoint("LEFT", row, "LEFT", 0, 0)
      else
        local prev = select(i-1, ...)
        element:SetPoint("LEFT", prev, "RIGHT", gap, 0)
      end
      if element.weight then
        element:SetWidth(width * (element.weight / sum))
      end
    end
  end

  local function Init(frame, rows, length, height)
    frame.length = length
    frame.rowCount = rows
    frame.rowHeight = height-- Math_Floor(frame:GetHeight() / rows)
    frame.rowMax = Math_Max(1, length - rows + 1)
    frame.totHeight = frame.rowHeight * rows
    frame.cursor = Math_Max(1, Math_Min(frame.rowMax, frame.cursor))
    frame:SetHeight(rows * height)
    for rowIndex = 1, rows do
      local dataIndex = frame.cursor + rowIndex - 1
      if dataIndex > frame.length then
        while #frame >= rowIndex do
          local row = frame[#frame]
          frame:ReleaseRow(row, #frame)
          rowPool:Release(row)
          Table_Remove(frame)
        end
        break
      end
      local row = frame[rowIndex]
      if rowIndex > #frame then
        row = rowPool:Acquire()
        row:SetParent(frame)
        row:SetPoint("LEFT", 0, 0)
        row:SetPoint("RIGHT", -32, 0)
        row:SetHeight(frame.rowHeight-1)
        if rowIndex == 1 then
          row:SetPoint("TOP", 0, -1)
        else
          row:SetPoint("TOP", frame[rowIndex-1], "BOTTOM", 0, -1)
        end
        frame:CreateRow(row, rowIndex)
        row:Show()
        table.insert(frame, row)
      end
      frame:UpdateRow(row, dataIndex)
    end
    UpdateScrollbar(frame)
    if frame.rowMax > 0 then
      frame:SetScript("OnMouseWheel", OnMouseWheel_Scroll)
      frame.scrollbar:SetScript("OnEnter", OnEnter_ScrollBar)
      frame.scrollbar:SetScript("OnLeave", OnLeave_ScrollBar)
      frame.scrollbar:SetScript("OnMouseDown", OnMouseDown_ScrollBar)
    end
  end

  local function CreateScrollFrame(pool)
    local frame = CreateFrame("frame", nil, self)
    frame.scrollbar = CreateFrame("frame", nil, frame, "BackdropTemplate")
    frame.scrollbar:SetBackdrop(MEDIA:BACKDROP(true, nil, 0, 0))
    frame.scrollbar:SetBackdropColor(1, 0.5, 0, 0.3)
    frame.scrollbar:EnableMouse(true)
    frame.scrollbar:SetWidth(20)
    frame.Init = Init
    if not rowPool then
      rowPool = CreateObjectPool(function()
        local frame = CreateFrame("frame", nil, self, "BackdropTemplate")
        frame:SetBackdrop(MEDIA:BACKDROP(true, nil, 0, 0))
        frame.AcquireFontString = AcquireFontString
        frame.AcquireIcon = AcquireIcon
        frame.AcquireButton = AcquireButton
        frame.ReleaseElement = ReleaseElement
        frame.StackElements = StackElements
        return frame
      end, function(_, frame)
        frame:ClearAllPoints()
        frame:SetBackdropColor(1, 0.5, 0, 0.15)
        frame:Hide()
      end)
      fontPool = CreateObjectPool(function()
        local font = self:CreateFontString(nil, nil, "GameFontNormal")
        font:SetFont(MEDIA:FONT(), 16)
        font:SetJustifyH("LEFT")
        return font
      end, function(_, font)
        font.weight = nil
        font:ClearAllPoints()
        font:Hide()
      end)
      texturePool = CreateObjectPool(function()
        local texture = self:CreateTexture(nil, "OVERLAY")
        return texture
      end, function(_, texture)
        texture.weight = nil
        texture:ClearAllPoints()
        texture:Hide()
      end)
      buttonPool = CreateObjectPool(function()
        local button = CreateFrame("button", nil, self, "UIPanelButtonTemplate")
        return button
      end, function(_, button)
        button.weight = nil
        button:ClearAllPoints()
        button:Hide()
      end)
    end
    return frame
  end

  local function ResetScrollFrame(pool, frame)
    frame.cursor = 1
    frame.length = nil
    frame.rowCount = nil
    frame.rowHeight = nil
    frame.totHeight = nil
    frame:ClearAllPoints()
    while #frame > 0 do
      local row = frame[#frame]
      frame:ReleaseRow(row, #frame)
      rowPool:Release(row)
      Table_Remove(frame)
    end
    frame:SetScript("OnMouseWheel", nil)
    frame.scrollbar:SetScript("OnEnter", nil)
    frame.scrollbar:SetScript("OnLeave", nil)
    frame.scrollbar:SetScript("OnMouseDown", nil)
    frame:Hide()
  end

  self.scrollPool = CreateObjectPool(CreateScrollFrame, ResetScrollFrame)
end

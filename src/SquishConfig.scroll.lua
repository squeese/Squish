local AcquireScroll
do
  local function updateScrollbar(frame)
    frame.__scrollbar:SetHeight(math.min(1, frame.__rowMax/math.max(frame.__length, 1)) * frame.__totHeight)
    frame.__scrollbar:SetPoint("TOPRIGHT", -4, (frame.__cursorCur-1) * -frame.__totHeight / math.max(frame.__length, 1))
  end

  local function OnMouseWheel_Scroll(frame, delta)
    if delta < 0 then -- up
      if (frame.__cursorCur - delta) > frame.__cursorMax then return end
      frame[frame.__rowCount-1]:SetPoint("TOP", frame, "TOP", 0, -1)
      frame[frame.__rowCount]:SetPoint("TOP", frame[1], "BOTTOM", 0, -1)
      frame.__updateRow(frame[frame.__rowCount], frame.__cursorCur + frame.__rowCount)
      table.insert(frame, 1, frame[frame.__rowCount])
      table.remove(frame, frame.__rowCount+1)
      frame.__cursorCur = frame.__cursorCur - delta
    else
      if (frame.__cursorCur - delta) < 1 then return end
      frame.__cursorCur = frame.__cursorCur - delta
      frame[1]:SetPoint("TOP", frame, "TOP", 0, -1)
      frame[frame.__rowCount]:SetPoint("TOP", frame[1], "BOTTOM", 0, -1)
      frame.__updateRow(frame[1], frame.__cursorCur)
      table.insert(frame, frame.__rowCount+1, frame[1])
      table.remove(frame, 1)
    end
    updateScrollbar(frame)
  end

  local function init(frame, rows, height)
    frame.__rowMax = rows
    frame.__rowCount = 0
    frame.__rowHeight = height
    frame.__totHeight = height * rows
    frame:SetHeight(frame.__totHeight)
  end

  local function cleanupRow(self, ...)
    self:SetBackdrop(nil)
    self.__index = nil
    return next(self, ...)
  end

  local function update(frame, length, cursor)
    frame.__length = length
    frame.__cursorMax = math.max(1, length - frame.__rowMax + 1)
    frame.__cursorCur = math.max(1, math.min(frame.__cursorMax, cursor or frame.__cursorCur or 1))

    for rowIndex = 1, frame.__rowMax do
      local dataIndex = frame.__cursorCur + rowIndex - 1

      if dataIndex > length then
        while frame.__rowCount >= rowIndex do
          next(table.remove(frame, 1), frame.__removeRow)
          frame.__rowCount = frame.__rowCount - 1
        end
        break
      end

      local row
      if rowIndex > frame.__rowCount then
        row = push(AcquireFrame(frame, useSet), cleanupRow)
        row:SetPoint("LEFT", 0, 0)
        row:SetPoint("RIGHT", -28, 0)
        row:SetHeight(frame.__rowHeight-1)
        if rowIndex == 1 then
          row:SetPoint("TOP", 0, -1)
        else
          row:SetPoint("TOP", frame[1], "BOTTOM", 0, -1)
        end
        frame.__createRow(row, rowIndex)
        frame.__rowCount = frame.__rowCount + 1
        table.insert(frame, 1, row)
      else
        row = frame[frame.__rowCount - rowIndex + 1]
      end
      row.__index = dataIndex
      frame.__updateRow(row, dataIndex)
    end

    updateScrollbar(frame)
    if frame.__cursorMax > 0 then
      frame:SetScript("OnMouseWheel", OnMouseWheel_Scroll)
      -- frame.scrollbar:SetScript("OnEnter", OnEnter_ScrollBar)
      -- frame.scrollbar:SetScript("OnLeave", OnLeave_ScrollBar)
      -- frame.scrollbar:SetScript("OnMouseDown", OnMouseDown_ScrollBar)
    end
  end

  local function cleanup(frame, ...)
    frame:SetBackdrop(nil)
    frame:EnableMouseWheel(false)
    frame.__scrollbar:SetBackdrop(nil)
    frame.__scrollbar:EnableMouse(false)
    frame.__scrollbar:SetScript("OnEnter", nil)
    frame.__scrollbar:SetScript("OnLeave", nil)
    frame.__scrollbar:SetScript("OnMouseDown", nil)
    unwind(frame.__scrollbar)
    frame.__scrollbar = nil
    frame.__createRow = nil
    frame.__updateRow = nil
    frame.__removeRow = nil
    frame:SetScript('OnMouseWheel', nil)
    frame.update = nil
    return next(frame, ...)
  end

  local function setup(frame, rows, height, fnCreateRow, fnUpdateRow, fnRemoveRow, ...)
    frame:SetBackdrop(SquishUI.Media:CreateBackdrop(true, nil, -4))
    frame:SetBackdropColor(0, 0, 0, 0.75)
    frame:EnableMouseWheel(true)
    frame.__scrollbar = AcquireFrame(frame)
    frame.__scrollbar:SetBackdrop(SquishUI.Media:CreateBackdrop(true, nil, 0, 0))
    frame.__scrollbar:SetBackdropColor(1, 0.5, 0, 0.3)
    frame.__scrollbar:EnableMouse(true)
    frame.__scrollbar:SetWidth(20)
    frame.__createRow = fnCreateRow or ident
    frame.__updateRow = fnUpdateRow or ident
    frame.__removeRow = fnRemoveRow or unwind
    frame.update = update
    init(frame, rows, height)
    return next(push(frame, cleanup), ...)
  end

  function AcquireScroll(parent, ...)
    return AcquireFrame(parent, setup, ...)
  end
end

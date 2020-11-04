${locals.use("table.remove")}
${locals.use("table.insert")}
${locals.use("math.ceil")}

local function AuraTable_Clear(tbl)
  tbl.starts = 1
  tbl.cursor = 0
  tbl.offset = 1000
end

local AuraTable_Insert
do
  local function write(t, offset, ...)
    local l = select("#", ...)
    for i = 1, l do
      t[offset+i] = select(i, ...)
    end
    return l
  end
  function AuraTable_Insert(t, priority, ...)
    for i = 1, t.cursor do
      if priority > t[t[i]] then
        t.cursor = t.cursor + 1
        Table_Insert(t, i, t.offset)
        t.offset = t.offset + write(t, t.offset-1, priority, ...)
        return
      end
    end
    t.cursor = t.cursor + 1
    t[t.cursor] = t.offset
    t.offset = t.offset + write(t, t.offset-1, priority, ...)
  end
end

local AuraTable_Write
do
  local function OnUpdate(self, elapsed)
    self.value = self.value - elapsed
    self:SetValue(self.value)
    if self.time then
      if self.value > 1 then
        self.time:SetText(Math_Ceil(self.value))
      else
        self.time:SetText(Math_Ceil(self.value * 10) / 10)
      end
    end
  end
  function AuraTable_Write(t, unit, filter, ...)
    local l = select("#", ...)
    local i = 1
    local j = 1
    while (i <= l) do
      local button = select(i, ...)
      if t.cursor >= j then
        local offset = t[j]
        if not button.priority or button.priority <= t[offset] then
          button:Show()
          button.unit = unit
          button.index = t[offset + 1]
          button.filter = filter
          button.texture:SetTexture(t[offset + 2])
          button.value = t[offset + 4] - GetTime()
          button:SetMinMaxValues(0, t[offset + 3])
          local kind = t[offset + 5]
          if kind then
            local r, g, b = unpack(DebuffColor(kind))
            button:SetBackdropColor(r, g, b, 0.75)
            button:SetStatusBarColor(r, g, b, 0.75)
          else
            button:SetBackdropColor(0, 0, 0, 0.75)
            button:SetStatusBarColor(0, 0, 0, 0.75)
          end
          if button.stack then
            local count = t[offset + 6]
            if count > 0 then
              button.stack:SetText(count)
              button.stack:Show()
            else
              button.stack:Hide()
            end
          end
          button:SetScript("OnUpdate", OnUpdate)
          j = j + 1 -- next value
        else
          button:Hide()
          button:SetScript("OnUpdate", nil)
        end
      else
        button:Hide()
        button:SetScript("OnUpdate", nil)
      end
      i = i + 1 -- next button
    end
  end
end

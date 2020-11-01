local BossTarget
do
  local function OnUpdate(self, elapsed)
    self.elapsed = self.elapsed + elapsed
    if self.elapsed > 0.05 then
      local guid = UnitGUID("playertarget")
      if guid ~= self.current then
        self.current = guid
        self:handler(self.current)
      end
      self.elapsed = 0
    end
  end

  function BossTarget(parent, handler)
    local frame = CreateFrame('frame', nil, parent, "BackdropTemplate")
    frame:SetSize(parent:GetWidth(), parent:GetHeight())
    frame:SetPoint("BOTTOMRIGHT", 0, 28)
    frame:SetAlpha(0)
    frame:SetBackdrop(MEDIA:BACKDROP(true, nil, 0, 0))
    frame:SetBackdropColor(0, 0, 0, 0.5)

    frame.elapsed = 0
    frame.current = nil
    frame:SetScript("OnUpdate", OnUpdate)
    return frame
  end
end

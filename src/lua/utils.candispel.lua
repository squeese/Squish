local CanDispel = CreateFrame("frame")
CanDispel:RegisterEvent("PLAYER_ENTERING_WORLD")
CanDispel:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
CanDispel:SetScript("OnEvent", function(self)
  local class = UnitClass("player")
  for i = 1, #self do
    self[self[i]] = false
  end
  if class == "Priest" then
    if IsSpellKnown(527) then
      self.Magic = true
      self.Disease = true
    else
      self.Disease = true
    end
  else
    print("unhandled dispel", class)
  end
end)
Table_Insert(CanDispel, "Magic")
Table_Insert(CanDispel, "Disease")
Table_Insert(CanDispel, "Curse")
Table_Insert(CanDispel, "Poison")

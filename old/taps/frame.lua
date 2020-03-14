if require then
  local frame = {}
  function frame:SetScript() end
  function frame:RegisterEvent() end
  function frame:UnregisterEvent() end
  return frame
else
  select(2, ...).frame = CreateFrame('frame', nil, UIParent)
end
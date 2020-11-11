local name, SquishCFG = ...
_G[name] = SquishCFG

local frame = CreateFrame("frame", nil, UIParent, "BackdropTemplate")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self)
  if type(_G.SquishUIConfig) ~= "table" then
    _G.SquishUIConfig = {}
  end
  local SquishUIConfig = _G.SquishUIConfig
  self:Hide()

  function SquishCFG.OpenGUI()
  end

  function SquishCFG.CloseGUI()
  end
end)

local name, SquishCFG = ...
_G[name] = SquishCFG

${include("src/SquishConfig.shared.lua")}

local frame = CreateFrame("frame", nil, UIParent, "BackdropTemplate")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, ...)
  self:SetPoint("TOPLEFT", UIParent, "TOP", 0, 0)
  self:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 0)
  self:SetBackdrop(SquishUI.Media:CreateBackdrop(true, nil, 0, 0))
  self:SetBackdropColor(0, 0, 0, 0.7)
  self:EnableMouse(true)
  self:SetFrameStrata("HIGH")
  --self:Hide()
  self:SetScale(0.533333333 / UIParent:GetScale())

end)

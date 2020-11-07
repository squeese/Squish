local name, SquishCFG = ...
_G[name] = SquishCFG


local frame = CreateFrame("frame", nil, UIParent, "BackdropTemplate")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self)
  if type(_G.SquishUIConfig) ~= "table" then
    _G.SquishUIConfig = {}
  end
  local SquishUIConfig = _G.SquishUIConfig

  local Sections = {}
  ${include("src/SquishConfig.widgets.lua")}
  ${include("src/SquishConfig.scroll.lua")}
  ${include("src/SquishConfig.dropdown.lua")}
  ${include("src/SquishConfig.sectionPositive.lua")}
  ${include("src/SquishConfig.sectionNegative.lua")}

  function self:Initialize()
    self:SetPoint("TOPLEFT", UIParent, "TOP", 0, 0)
    self:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 0)
    self:SetBackdrop(SquishUI.Media:CreateBackdrop(true, nil, 0, 0))
    self:SetBackdropColor(0, 0, 0, 0.7)
    self:EnableMouse(true)
    self:SetFrameStrata("HIGH")
    self:SetScale(0.533333333 / UIParent:GetScale())
    ${include("src/SquishConfig.sectionButtons.lua")}
    self.Initialize = nil
  end

  function self:SelectSection(index)
    if self.section then
      unwind(self.section)
    end
    SquishUIConfig.SelectedSection = index
    self.section = next(Sections[index]:init())
  end

  function SquishCFG.OpenGUI()
    if self.Initialize then
      self:Initialize()
    end
    self[SquishUIConfig.SelectedSection or 1]:Click()
    self:Show()
  end

  function SquishCFG.CloseGUI()
    unwind(self.section)
    self.section = nil
    self:Hide()
  end
end)

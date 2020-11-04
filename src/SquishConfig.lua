local name, SquishCFG = ...
_G[name] = SquishCFG

-- local Positive = { title = "Positive", icon = 134468 }
-- local Negative = { title = "Negative", icon = 134466 }
local Sections = {}


    --self.scroll = gui.scrollPool:Acquire()
    --self.scroll:SetPoint("LEFT", 8, 0)
    --self.scroll:SetPoint("RIGHT", -8, 0)
    --self.scroll:SetPoint("CENTER", 0, 0)
    --self.scroll.CreateRow = CreateRow
    --self.scroll.UpdateRow = UpdateRow
    --self.scroll.ReleaseRow = ReleaseRow
    --self.scroll.cursor = 1


local frame = CreateFrame("frame", nil, UIParent, "BackdropTemplate")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self)
  if type(_G.SquishUIConfig) ~= "table" then
    _G.SquishUIConfig = {}
  end
  local SquishUIConfig = _G.SquishUIConfig

  function self:Initialize()
    self:SetPoint("TOPLEFT", UIParent, "TOP", 0, 0)
    self:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 0)
    self:SetBackdrop(SquishUI.Media:CreateBackdrop(true, nil, 0, 0))
    self:SetBackdropColor(0, 0, 0, 0.7)
    self:EnableMouse(true)
    self:SetFrameStrata("HIGH")
    self:SetScale(0.533333333 / UIParent:GetScale())
    --self.header = self:CreateFontString(nil, nil, "GameFontNormal")
    --self.header:SetFont(SquishUI.Media.FONT_VIXAR, 22)
    --self.header:SetPoint("TOP", 0, -16)
    ${include("src/SquishConfig.widgets.lua")}
    ${include("src/SquishConfig.scroll.lua")}
    ${include("src/SquishConfig.row.lua")}
    ${include("src/SquishConfig.sectionPositive.lua")}
    ${include("src/SquishConfig.sectionButtons.lua")}
    self.__index = self
    self.Initialize = nil
  end

  function self:Release()
    while #self > 0 do
      table.remove(self):Release()
    end
  end

  function self:root()
    return self.__index or getmetatable(self).__index
  end

  function self:SelectSection(index)
    if self.section then
      self.section:Release()
    end
    SquishUIConfig.SelectedSection = index
    self.section = setmetatable(Sections[index], self)
    self.section:Init()
  end

  function SquishCFG.OpenGUI()
    if self.Initialize then
      self:Initialize()
    end
    self[SquishUIConfig.SelectedSection or 1]:Click()
    self:Show()
  end

  function SquishCFG.CloseGUI()
    self.section:Unload()
    self.section = nil
    self:Hide()
  end
end)

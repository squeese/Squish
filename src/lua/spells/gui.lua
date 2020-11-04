do
  ${include("src/lua/spells/gui.shared.lua")}
  ${include("src/lua/spells/section.positive.lua")}

  local frame = CreateFrame("frame", nil, UIParent, "BackdropTemplate")
  frame:RegisterEvent("VARIABLES_LOADED")
  frame:SetScript("OnEvent", function(self)
    if not SquishData then SquishData = {} end
    --SquishData = {
      --GUIOpen = true,
      --GUISection = 1,
    --}

    local SELECTED = nil
    local SECTIONS = {
      Section_Positive,
    }

    self:SetPoint("TOPLEFT", UIParent, "TOP", 0, 0)
    self:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 0)
    self:SetBackdrop(MEDIA:BACKDROP(true, false, 1, 0))
    self:SetBackdropColor(0, 0, 0, 0.7)
    self:EnableMouse(true)
    self:SetFrameStrata("HIGH")
    self:Hide()
    self:SetScale(0.533333333 / UIParent:GetScale())
    self.header = self:CreateFontString(nil, nil, "GameFontNormal")
    self.header:SetFont(MEDIA:FONT(), 22)
    self.header:SetPoint("TOP", 0, -16)
    --self.dropdown = CreateFrame("frame", nil, self, "UIDropDownMenuTemplate")

    ${include("src/lua/spells/gui.tables.lua")}
    ${include("src/lua/spells/gui.dropdown.lua")}
    ${include("src/lua/spells/gui.scroll.lua")}
    ${include("src/lua/spells/gui.menu.lua")}

    self:SetScript("OnHide", function()
      print("hide", #self.tablePool.inactiveObjects)
      for index = #self.tablePool.inactiveObjects, 1, -1 do
        self.tablePool[index] = nil
      end
      collectgarbage("collect")
    end)
  end)
end

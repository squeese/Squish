do
  ${include("src/lua/spells/section.positive.lua")}

  local function Load(self)
    print("load", self.title)
  end

  local function Unload(self)
    print("unload", self.title)
  end

  local frame = CreateFrame("frame", nil, UIParent, "BackdropTemplate")
  frame:RegisterEvent("VARIABLES_LOADED")
  frame:SetScript("OnEvent", function(self)
    local SELECTED = nil
    local SECTIONS = {
      { title = "Spells", icon = 237542, Load = Load, Unload = Unload },
      Section_Positive,
    }

    self:SetPoint("TOPLEFT", UIParent, "TOP", 0, 0)
    self:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 0)
    self:SetBackdrop(MEDIA:BACKDROP(true, false, 1, 0))
    self:SetBackdropColor(0, 0, 0, 0.9)
    self:SetFrameStrata("HIGH")
    self:EnableMouseWheel(true)
    self:Hide()
    self:SetScale(0.533333333 / UIParent:GetScale())
    self.header = self:CreateFontString(nil, nil, "GameFontNormal")
    self.header:SetFont(MEDIA:FONT(), 32)
    self.header:SetPoint("TOPLEFT", 32, -8)

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

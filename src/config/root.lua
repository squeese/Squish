local name, SquishCFG = ...
_G[name] = SquishCFG

${"" && include("src/SquishConfig.widgets.lua")}

local Sections = {}
${"" && include("src/SquishConfig.sectionPositive.lua")}
${"" && include("src/SquishConfig.sectionNegative.lua")}
${"" && include("src/SquishConfig.sources.lua")}

local frame = CreateFrame("frame", nil, UIParent, "BackdropTemplate")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self)
  if type(_G.SquishUIConfig) ~= "table" then
    _G.SquishUIConfig = {}
  end
  local SquishUIConfig = _G.SquishUIConfig

  ${"" && include("src/SquishConfig.scroll.lua")}
  ${"" && include("src/SquishConfig.dropdown.lua")}
  ${"" && include("src/SquishConfig.order.lua")}

  function self:Initialize()
    self:SetPoint("TOPLEFT", UIParent, "TOP", 0, 0)
    self:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 0)
    self:SetBackdrop(SquishUI.Media:CreateBackdrop(true, nil, 0, 0))
    self:SetBackdropColor(0, 0, 0, 0.7)
    self:EnableMouse(true)
    self:SetFrameStrata("HIGH")
    self:SetScale(0.533333333 / UIParent:GetScale())
    ${"" && include("src/SquishConfig.sectionButtons.lua")}
    self.Initialize = nil
  end

  local init
  do
    local subs = {}
    local function stop(section, ...)
      assert(#subs == 0, "should be zero")
      while #section > select("#", ...) do
        table.remove(section, 1)
      end
      return section
    end
    local function unsubscribe(self, key, ...)
      self[key] = nil
      if self.__subscribed then
        self.__subscribed = false
        for i = #subs, 1, -1 do
          if subs[i] == self then
            table.remove(subs, i)
            return next(self, ...)
          end
        end
        assert(false, "wat?")
      end
      return next(self, ...)
    end
    local function subscribe(self, key, func, ...)
      if not self.__subscribed then
        table.insert(subs, self)
        self.__subscribed = true
      end
      self[key] = self[key] or func or next
      return next(push(self, unsubscribe, key), ...)
    end
    local function dispatch(name, ...)
      for i = 1, #subs do
        if subs[i][name] then
          subs[i][name](subs[i], ...)
          -- next(subs[i], subs[i][name], ...)
        end
      end
    end
    function init(section, fn, ...)
      return next(push(section, stop), fn, self, subscribe, dispatch, ...)
    end
  end

  function self:SelectSection(index)
    if self.section then
      next(self.section, unpack(self.section))
    end
    SquishUIConfig.SelectedSection = index
    self.section = next(Sections[index], init, unpack(Sections[index]))
  end

  function SquishCFG.OpenGUI()
    if self.Initialize then
      self:Initialize()
    end
    self[SquishUIConfig.SelectedSection or 1]:Click()
    self:Show()
  end

  function SquishCFG.CloseGUI()
    next(self.section, unpack(self.section))
    self.section = nil
    self:Hide()
  end
end)

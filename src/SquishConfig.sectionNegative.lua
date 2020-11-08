do
  local dropdown = CreateFrame("frame", nil, UIParent, "UIDropDownMenuTemplate")
  dropdown.displayMode = "MENU"
  do
    local info = UIDropDownMenu_CreateInfo()
    function dropdown:initialize()
      for i = 1, 5 do
        info.text = "option"..i
        info.value = i
        UIDropDownMenu_AddButton(info)
      end
    end
  end

  local function init(self, root, subscribe, dispatch, ...)

    next(self, subscribe, "DROPDOWN_INITIALIZE", function(self, button)
      ToggleDropDownMenu(1, nil, dropdown, button, 0, 0)
    end)

    local header = AcquireFontString(root, nil, nil, "Hello")
    header:SetPoint("TOP", 0, -256)
    next(header, subscribe, "TITLE")
    next(header, subscribe, "TEST")

    local function TMP(self)
      dispatch("DROPDOWN_INITIALIZE", self)
    end

    local button = AcquireButton(root, TMP)
    button:SetPoint("TOP", 0, -128)
    button:SetSize(128, 32)
    button:SetText("okiewookie")

    return next(push(self, header), ...)
  end

  table.insert(Sections, { title = "Negative", icon = 134466, init })
end

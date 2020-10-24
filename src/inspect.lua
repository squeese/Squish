do
  local NAMES = {
    "HEADSLOT",
    "NECKSLOT",
    "SHOULDERSLOT",
    "BACKSLOT",
    "SHIRTSLOT",
    "CHESTSLOT",
    "WAISTSLOT",
    "LEGSSLOT",
    "FEETSLOT",
    "WRISTSLOT",
    "HANDSSLOT",
    "FINGER0SLOT",
    "FINGER1SLOT",
    "TRINKET0SLOT",
    "TRINKET1SLOT",
    "MAINHANDSLOT",
    "SECONDARYHANDSLOT",
    "TABARDSLOT",
  }
  local f = CreateFrame("frame", nil, UIParent, "BackdropTemplate")
  f:SetBackdrop({
    bgFile = [[Interface\\Addons\\Squish\\media\\backdrop.tga]],
    edgeSize = 1,
    insets = {
      left = -1,
      right = -1,
      top = -1,
      bottom = -1
    }
  })
  f:SetBackdropColor(0, 0, 0, 0.5)
  f:SetSize(64, 256)
  f:SetPoint("CENTER", 0, 0)
  f:Show()
  local anchor
  local icons = {}
  local unit = "player"
  for index = 1, #NAMES do
    local slot, texture = GetInventorySlotInfo(NAMES[index])
    local icon = CreateFrame("frame", nil, f)
    icon:SetSize(32, 32)
    icon:SetScript("OnEnter", function(self)
      if not self.link then return end
      GameTooltip:SetOwner(self, 'ANCHOR_TOPRIGHT')
      -- GameTooltip:SetInventoryItem(unit, slot)
      GameTooltip:SetHyperlink(self.link)
      GameTooltip:Show()
      -- print("?", GameTooltip:NumLines())
    end)
    icon:SetScript("OnLeave", function()
      GameTooltip:Hide()
    end)
    icon.slot = slot
    icon.empty = texture
    icon.texture = icon:CreateTexture()
    icon.texture:SetAllPoints()
    icon.texture:SetTexture(texture)
    if not anchor then
      icon:SetPoint("TOP", 0, 0)
    else
      icon:SetPoint("TOP", anchor, "BOTTOM", 0, 0)
    end
    anchor = icon
    table.insert(icons, icon)
  end
  function TEST()
    if CanInspect(unit, true) then
      print("NotifyInspect()")
      NotifyInspect(unit)
    end
  end
  f:RegisterEvent("INSPECT_READY")
  f:SetScript("OnEvent", function(_, _, guid)
    if UnitGUID(unit) ~= guid then
      print("INSPECT_READY", "abort")
      return
    else
      print("INSPECT_READY", "scanning")
    end
    for _, icon in ipairs(icons) do
      local texture = GetInventoryItemTexture(unit, icon.slot)
      if texture then
        icon.texture:SetTexture(texture)
        GameTooltip:SetInventoryItem(unit, icon.slot)
        local name, link = GameTooltip:GetItem();
        local id = GetInventoryItemID(unit, icon.slot)
        print("ok", icon.slot, name, link, id)
        icon.link = link
        -- icon.link = GetInventoryItemLink(unit, icon.slot)
      else
        icon.texture:SetTexture(icon.empty)
        icon.link = nil
      end
    end
    print("INSPECT_READY", "ClearInspectPlayer()")
    ClearInspectPlayer()
  end)
end

      -- GetInventoryItemID(unit, icon.slot)
      --local location = ItemLocation:CreateFromEquipmentSlot(slot)
      --if C_Item.DoesItemExist(location) then
        --local name = C_Item.GetItemName(location)
        --local icon = C_Item.GetItemIcon(location)
        --local link = C_Item.GetItemLink(location)
        --

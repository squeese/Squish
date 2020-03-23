local Squish = select(2, ...)
-- local Driver, Render = Squish.Create()

-- Render()

--function Driver:mount(node, container)
  --node.frame = self.pool:Acquire()
  --node.frame:SetParent(container.frame or UIParent)
  --node.frame:ClearAllPoints()
  --node.frame:Show()
--end

--function Driver:remove(node, ...)
  --self.pool:Release(node.frame)
  --node.frame = nil
--end

--local Frame = Driver{
  --pool = CreateFramePool("frame", UIParent, nil, nil),
  --render = function(self, node, width, height, ...)
    --node.frame:SetSize(width, height)
    --node.frame:SetPoint("CENTER", 0, 0)
    --node.frame:SetBackdrop({
      --bgFile = 'Interface\\Addons\\Squish\\media\\backdrop.tga',
      --edgeFile = 'Interface\\Addons\\Squish\\media\\edgefile.tga',
      --insets   = { left = 1, right = 1, top = 1, bottom = 1 },
      --edgeSize = 1
    --})
    --node.frame:SetBackdropColor(0, 0, 0, 0.5)
    --node.frame:SetBackdropBorderColor(0, 0, 0, 0.8)
    --return ...
  --end,
--}

--local Button = Driver{
  --pool = CreateFramePool("button", UIParent, 'UIPanelButtonTemplate', nil),
  --render = function(self, node, point, text)
    --node.frame:SetSize(32, 32)
    --node.frame:SetPoint(point, 0, 0)
    --node.frame:SetText(text)
  --end,
--}

--local Texture = Driver{
  --pool = CreateTexturePool(UIParent, nil, nil, nil),
  --render = function(self, node, icon)
    --node.frame:SetAllPoints()
    --node.frame:SetTexCoord(0, 1, 0, 1)
    --node.frame:SetDrawLayer("BACKGROUND")
    --node.frame:SetTexture(icon)
  --end,
--}

--local Aura = Driver{}

--do
  --local on = true
  --local App = function()
    --return on and Frame(nil, 256, 64,
      --Button(nil, "TOPLEFT", "-"),
      --Button(nil, "TOPRIGHT", "+"))
      ----function()
        ----local tbl = {}
        ----for i = 1, 40 do
          ----local icon = select(2, UnitAura("PLAYER", i))
          ----if not icon then break end
          ----table.insert(tbl, Texture(nil, icon))
        ----end
        ----print("return", #tbl)
        ----return unpack(tbl)
      ----end)
  --end
  --local btn = CreateFrame("button", nil, UIParent, "UIPanelButtonTemplate", nil)
  --btn:SetSize(32, 32)
  --btn:SetPoint("CENTER", 0, 100)
  --btn:SetText("x")
  --btn:SetScript("OnClick", function()
    --on = not on and true or nil
    --Render(1, App)
  --end)

  --Render(1, App)
  --Render(2, function()
  --end)
--end

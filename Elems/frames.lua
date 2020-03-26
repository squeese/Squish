local Q = select(2, ...)
local Set = Q.Set

local function upgrade(self)
  for index, child in ipairs(self) do
    if type(child) == "table" and getmetatable(child) == nil then
      child.key = table.remove(child, 1)
      Set(child)
    end
  end
end

local function render(self, container, parent, key, ...)
  container.state = parent.state
  container.frame = self.pool:Acquire()
  container.frame:SetParent(parent.frame or UIParent)
  container.frame:ClearAllPoints()
  container.frame:Show()
  return ...
end

local function remove(self, container)
  self.pool:Release(container.frame)
  container.frame = nil
  container.state = nil
end

Q.Frame = Q.Driver{
  pool = CreateFramePool("frame", UIParent, nil, nil),
  name = "Frame",
  render = render,
  remove = remove,
  upgrade = upgrade,
}

Q.Box = Q.Driver(function(self, container, parent, key, ...)
  container.state = parent.state
  print("?", key, ...)
  return Q.Frame(nil,
    Q.Set("SetPoint", self.point or "CENTER", self.x or 0, self.y or 0),
    Q.Set("SetSize", self.width or 128, self.height or 32),
    Q.Set("SetBackdrop", Q.Backdrop),
    Q.Set("SetBackdropColor", 0, 0, 0, 0.5),
    Q.Set("SetBackdropBorderColor", 0, 0, 0, 0.8),
    ...
  )
end)
Q.Box.remove = remove

Q.Button = Q.Driver{
  pool = CreateFramePool("button", UIParent, 'UIPanelButtonTemplate', nil),
  name = "Button",
  render = render,
  remove = remove,
  upgrade = upgrade,
}

Q.Text = Q.Driver{
  pool = CreateFontStringPool(UIParent, nil, nil, 'GameFontNormal'),
  name = "Text",
  render = render,
  remove = remove,
  upgrade = upgrade,
}

Q.Texture = Q.Driver{
  pool = CreateTexturePool(UIParent, nil, nil, nil),
  name = "Texture",
  render = render,
  remove = remove,
  upgrade = upgrade,
}

local Q = select(2, ...)

local function upgrade(self)
  for index, child in ipairs(self) do
    if type(child) == "table" and getmetatable(child) == nil then
      child.key = table.remove(child, 1)
      Set(child)
    end
  end
end

local function mount(self, container, parent)
  container.state = parent.state
  container.frame = self.pool:Acquire()
  container.frame:SetParent(parent.frame or UIParent)
  container.frame:ClearAllPoints()
  container.frame:Show()
end

local function remove(self, container)
  self.pool:Release(container.frame)
  container.frame = nil
  container.state = nil
end

Q.Frame = Q.Driver{
  pool = CreateFramePool("frame", UIParent, nil, nil),
  name = "Frame",
  mount = mount,
  remove = remove,
  upgrade = upgrade,
}

local Button = Driver{
  pool = CreateFramePool("button", UIParent, 'UIPanelButtonTemplate', nil),
  name = "Button",
  mount = mount,
  remove = remove,
  upgrade = upgrade,
}

local Text = Driver{
  pool = CreateFontStringPool(UIParent, nil, nil, 'GameFontNormal'),
  name = "Text",
  mount = mount,
  remove = remove,
  upgrade = upgrade,
}

local Texture = Driver{
  pool = CreateTexturePool(UIParent, nil, nil, nil),
  name = "Texture",
  mount = mount,
  remove = remove,
  upgrade = upgrade,
}

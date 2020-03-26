local Q = select(2, ...)
local Set = Q.Set

local Base = Q.Driver{}

function Base:UPGRADE()
  for index, child in ipairs(self) do
    if type(child) == "table" and getmetatable(child) == nil then
      child.key = table.remove(child, 1)
      Set(child)
    end
  end
end

function Base:RENDER(container, parent, key, ...)
  container.state = parent.state
  if self.pool then
    container.frame = self.pool:Acquire()
    container.frame:SetParent(parent.frame or UIParent)
    container.frame:ClearAllPoints()
    container.frame:Show()
  else
    container.frame = parent.frame or UIParent
  end
  return ...
end

function Base:REMOVE(container)
  if self.pool then
    self.pool:Release(container.frame)
  end
  container.frame = nil
  container.state = nil
end

Q.Frame = Base{
  pool = CreateFramePool("frame", UIParent, nil, nil),
  name = "Frame",
}

Q.Button = Base{
  pool = CreateFramePool("button", UIParent, 'UIPanelButtonTemplate', nil),
}

Q.Text = Base{
  pool = CreateFontStringPool(UIParent, nil, nil, 'GameFontNormal'),
}

Q.Texture = Base{
  pool = CreateTexturePool(UIParent, nil, nil, nil),
}

Q.Box = Base(function(self, container, parent, key, ...) return
  Q.Frame(nil,
    Q.Set("SetPoint", self.point or "CENTER", self.x or 0, self.y or 0),
    Q.Set("SetSize", self.width or 128, self.height or 32),
    Q.Set("SetBackdrop", Q.Backdrop),
    Q.Set("SetBackdropColor", 0, 0, 0, 0.5),
    Q.Set("SetBackdropBorderColor", 0, 0, 0, 0.8),
    ...)
end)

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

local Context = Driver{
  mount = function(self, container, parent)
    container.state = container
  end,
  remove = function(self, container)
    container.state = nil
  end
}

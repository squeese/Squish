local Squish = select(2, ...)
Squish.Elems = {}
Squish.tooltipBackground = {
  bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
  edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
  tile = true, tileSize = 16, edgeSize = 16, 
  insets = { left = 4, right = 4, top = 4, bottom = 4 }
}

local Set = Squish.Node{ __name = 'Set' }
function Set:mount(parent)
  self.super.mount(self, parent)
  self.args = {}
end

function Set:copy(prev)
  self.super.copy(self, prev)
  self.args = prev.args
end

local function changed(a, b)
  if #a ~= #b then return true end
  for i, v in ipairs(a) do
    if v ~= b[i] then
      return true
    end
  end
  return false
end

function Set:render(prev)
  self.super.render(self, prev)
  if prev == nil or changed(self, prev) then
    for i, value in ipairs(self) do
    end
  end



  self.frame[self[1]](self.frame, select(2, unpack(self)))
  return nil
end
Squish.Elems.Set = Set

local Frame = Squish.Node{ __name = 'Frame' }

function Frame:mount(parent)
  self.super.mount(self, parent)
  self.frame = CreateFrame('frame', nil, self.parent.frame)
  self.frame:ClearAllPoints()
  self.frame:Show()
end

function Frame:upgrade(props)
  for index, child in ipairs(props) do
    if child.__index == nil then
      props[index] = Set(child)
    end
  end
end

Squish.Elems.Frame = Frame


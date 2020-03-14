local Squish = select(2, ...)

local Base = Squish.Node{ __name = 'Base' }
Squish.Elems.Base = Base

local Set = Squish.Elems.Set
function Base:upgrade(props)
  -- self.__super.render(self, parent)
  for index, child in ipairs(props) do
    if type(child) == "table" and child.__index == nil then
      -- print("upgrade", unpack(child))
      props[index] = Set(child)
    end
  end
end

Squish.media = {}
Squish.media.mini = 'Interface\\Addons\\Squish\\media\\minimalist.tga'
Squish.media.flat = 'Interface\\Addons\\Squish\\media\\flat.tga'
Squish.media.vixar = 'Interface\\Addons\\Squish\\media\\vixar.ttf'
Squish.media.defbar = 'Interface\\TARGETINGFRAME\\UI-StatusBar'
Squish.media.square = {
  bgFile = 'Interface\\Addons\\Squish\\media\\backdrop.tga',
  edgeFile = 'Interface\\Addons\\Squish\\media\\edgefile.tga',
  insets   = { left = 1, right = 1, top = 1, bottom = 1 },
  edgeSize = 1
}
--[[
Squish.media.edgeBottomLeft = Q.copy(UI.square, {
  edgeFile = 'Interface\\Addons\\Squish\\media\\corner_bottomleft.blp',
  edgeSize = 1,
})
Squish.media.edgeBottomRight = Q.copy(UI.square, {
  edgeFile = 'Interface\\Addons\\Squish\\media\\corner_bottomright.blp',
  edgeSize = 2,
})
]]

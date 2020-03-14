_, PS = ...
PS.Packer = {}
local NIL = {}
PS.Packer.__index = PS.Packer

function PS.Packer.create(size, pendingPlaceHolder)
  assert(type(size) == 'number' and size > 0, 'size must be a number')
  local packer = setmetatable({
    __offsets = {},
    __pending = pendingPlaceHolder and true or false,
  }, PS.Packer)
  for i = 1, (size or 1) do
    packer.__offsets[#packer.__offsets+1] = #packer+1
    packer[#packer+1] = pendingPlaceHolder and NIL or nil
  end
  return packer
end

function PS.Packer:isPending()
  if self.__pending then
    for i = 1, #self do
      if self[i] == NIL then
        return true
      end
    end
    self.__pending = false
  end
  return false
end

PS.Packer.__call = function(self, i, ...)
  assert(self.__offsets[i] ~= nil, 'invalid index')
  local changed = false
  local currOffset = self.__offsets[i]
  local nextOffset = self.__offsets[i+1] or #self+1
  local needed = select('#', ...)
  local change = needed - (nextOffset - currOffset)
  for ii = i+1, #self.__offsets do
    self.__offsets[ii] = self.__offsets[ii] + change
  end
  if change > 0 then -- move all to the right 'change' times
    changed = true
    for ii = #self+change, currOffset+needed-1, -1 do
      self[ii] = self[ii-change]
    end
  elseif change < 0 then -- move all to the left 'change' times
    changed = true
    for ii = currOffset+needed, #self do
      self[ii] = self[ii-change]
    end
  end
  for ii = 1, needed do
    local index, val = (currOffset+ii-1), select(ii, ...)
    changed = (self[index] ~= val) or changed
    self[index] = val
  end
  return changed, self:isPending()
end
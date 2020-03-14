local PS = select(2, ...)

local SetStream = PS.Stream.create(function(send, done, self)
  local size = #self
  PS.Utils.Packer_init(self, size * 2 + 1, size)
  for i = 1, size do
    if type(self[i]) == 'table' and getmetatable(self[i]) == PS.Stream then
      self[size + i] = self[i]:subscribe(function(...)
        if PS.Utils.Packer_write(self, i, ...) then
          send(self:propertyChanged(unpack(self, self[self.__packer_ind_s], self[self.__packer_ind_e - 1])))
        end
      end, PS.Utils.noop, self)
    else
      if PS.Utils.Packer_write(self, i, self[i]) then
          send(self:propertyChanged(unpack(self, self[self.__packer_ind_s], self[self.__packer_ind_e - 1])))
      end
    end
  end
  return function(...)
    for i = size, 1, -1 do
      if self[size + i] then
        self[size + i]()
        self[size + i] = nil
      end
    end
    for i = size * 2 + 1, self[self.__packer_ind_e - 1] do
      self[i] = nil
    end
    return ...
  end
end)

PS.Nodes.Set = PS.Nodes.Base {
  __kind = 'Set',

  cloneProps = PS.Utils.noop,
  cloneNodes = function(self, dest)
    for i = 1, #self do
      dest[i] = self[i]
    end
  end,

  createStream = function(self)
    self.__propStream = self.__parent.__propStream
    return SetStream
  end,

  propertyChanged = function(self, fn, ...)
    if type(fn) == 'string' then
      self.__frame[fn](self.__frame, ...)
    else
      fn(...)
    end
    return self, fn, ...
  end
}
local Squish = select(2, ...)
local Elems = Squish.Elems
local Stream = Squish.Stream
local tableFill = Squish.tableFill
local tableEquals = Squish.tableEquals
local subscribe
local unsubscribe

Elems("Set", nil, {
  build = function(self, props, ...)
    return tableFill(props, ...)
  end,
  mount = function(self, parent)
    self.__super.mount(self, parent)
    self.__args = {}
    self.__subs = 0
    self.__gate = 0
    subscribe(self)
  end,
  copy = function(self, prev, parent)
    self.__super.copy(self, prev, parent)
    self.__args = prev.__args
    prev.__args = nil
    self.__subs = prev.__subs
    self.__gate = prev.__gate
    self.__subs = prev.__subs
    for i = 0, self.__subs-1 do
      self[32 + i] = prev[32 + i]
    end
    if not tableEquals(self, prev) then
      unsubscribe(self)
      subscribe(self)
    end
  end,
  render = function(self)
    self.__super.render(self, prev)
    local open = bit.lshift(1, #self) - 1
    if self.__gate == open then
      self.__frame[self.__args[1]](self.__frame, select(2, unpack(self.__args)))
    end
    return nil
  end,
  remove = function(self)
    unsubscribe(self)
    self.__super.remove(self)
  end
})

subscribe = function(self)
  self.__gate = 0
  self.__subs = 0
  local open = bit.lshift(1, #self) - 1
  for i, arg in ipairs(self) do
    if type(arg) == "table" and getmetatable(arg) == Stream then
      self[32 + self.__subs] = arg:subscribe(function(value)
        self.__args[i] = value
        self.__gate = bit.bor(self.__gate, bit.lshift(1, i-1))
        if self.__gate == open then
          self.__frame[self.__args[1]](self.__frame, select(2, unpack(self.__args)))
        end
      end, self:context("unit"))
      self.__subs = self.__subs + 1
    else
      self.__gate = bit.bor(self.__gate, bit.lshift(1, i-1))
      self.__args[i] = arg
    end
  end
  if self.__gate == open then
    self.__frame[self.__args[1]](self.__frame, select(2, unpack(self.__args)))
  end
end

unsubscribe = function(self)
  for i = 0, self.__subs-1 do
    self[32 + i]()
  end
end

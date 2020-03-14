local Squish = select(2, ...)
local Stream = Squish.Stream

local Set = Squish.Node{ __name = 'Set' }
Squish.Elems.Set = Set

function Set:mount(parent)
  self.__super.mount(self, parent)
  self.__args = {}
  self.__subs = 0
  self.__gate = 0
end

function Set:copy(prev)
  self.__super.copy(self, prev)
  self.__args = prev.__args
  self.__subs = prev.__subs
  self.__gate = prev.__gate
  self.__subs = prev.__subs
  for i = 0, self.__subs-1 do
    self[32 + i] = prev[32 + i]
  end
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

local function subscribe(self)
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
      end, nil, self)
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

local function unsubscribe(self)
  for i = 0, self.__subs-1 do
    self[32 + i]()
  end
end

function Set:render(prev)
  self.__super.render(self, prev)
  if prev == nil then
    subscribe(self)
  elseif changed(self, prev) then
    unsubscribe(self)
    subscribe(self)
  end
  return nil
end

function Set:remove()
  unsubscribe(self)
end

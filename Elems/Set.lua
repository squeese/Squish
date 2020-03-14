local Squish = select(2, ...)
local Stream = Squish.Stream
local changed = Squish.changed

local Set = Squish.Node({}, "Set")

function Set:mount(parent)
  self.__super.mount(self, parent)
  self.__args = {}
  self.__subs = 0
  self.__gate = 0
  -- print("unit!", self:context("unit"))
end

function Set:copy(prev, parent)
  -- print("unit?", prev:context("unit"))
  self.__super.copy(self, prev, parent)
  self.__args = prev.__args
  self.__subs = prev.__subs
  self.__gate = prev.__gate
  self.__subs = prev.__subs
  for i = 0, self.__subs-1 do
    self[32 + i] = prev[32 + i]
  end
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
      end, self:context("unit"))

      self.__subs = self.__subs + 1
    else
      self.__gate = bit.bor(self.__gate, bit.lshift(1, i-1))
      self.__args[i] = arg
    end
  end
  if self.__gate == open then
    -- print("SET", unpack(self.__args))
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
  self.__super.remove(self)
end

local function upgrade(self, props)
  for index, child in ipairs(props) do
    if type(child) == "table" and child.__index == nil then
      props[index] = Set(child)
    end
  end
end

Squish.Elems = setmetatable({
  Set = Set,
}, {
  __call = function(self, name, props)
    props.upgrade = upgrade
    if name then
      self[name] = Squish.Node(props, name)
      return self[name]
    else
      return Squish.Node(props, name)
    end
  end,
})

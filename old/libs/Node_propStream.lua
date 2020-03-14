local Utils = require 'libs/Utils'
local Observable = require 'libs/Observable'

local saveStaticProperties, restoreStaticProperties
do
  local keys = {}

  function saveStaticProperties(self)
    for key, value in pairs(self) do
      if Utils.isProperty(key, value) then
        table.insert(keys, key)
      end
    end
    while #keys > 0 do
      local key = table.remove(keys)
      self['__property__'..key] = self[key]
    end
  end

  local function restoreStaticProperties(self)
    for key, value in pairs(self) do
      if string.sub(key, 1, 12) == '__property__' then
        table.insert(keys, string.sub(key, 13))
      end
    end
    while #keys > 0 do
      local key = table.remove(keys)
      self[key] = self['__property__'..key]
      self['__property__'..key] = nil
    end
  end
end

--[[
local function setPropertyValue(self, key, value)
  if self[key] ~= value then
    self[key] = value
    return true
  end
  return false
end
--]]

local nodePropStream = Observable.create(function(send, done, self)
  if not rawget(self, '__propRecievers') then
    self.__propRecievers = {}
    -- init(self)

    local stream = self.__parent.__propStream
    --[[
    if false and rawget(self, '__withSubject') then
      self.__subject = Q.Subject.create()
      stream = self.__parent.__propStream:refreshOn(self.__subject:filter(setPropertyValue, true))
    else
      stream = self.__parent.__propStream
    end
    ]]

    self.__propSubscription = stream:subscribe(function()
      self.__dispatchIndex = 1
      while self.__propRecievers and self.__dispatchIndex <= #self.__propRecievers do
        self.__propRecievers[self.__dispatchIndex](self)
        self.__dispatchIndex = self.__dispatchIndex + 1
      end
      self.__dispatchIndex = nil
    end, nil, self)
  end

  table.insert(self.__propRecievers, send)
  send(self)

  return function()
    for i = 1, #self.__propRecievers do
      if send == self.__propRecievers[i] then
        if self.__dispatchIndex ~= nil and i <= self.__dispatchIndex then
          self.__dispatchIndex = self.__dispatchIndex - 1
        end
        table.remove(self.__propRecievers, i)
        break
      end
    end
    if #self.__propRecievers == 0 then
      self.__propSubscription()
      self.__propSubscription = nil
      self.__dispatchIndex = nil
      self.__propRecievers = nil
      self.__subject = nil
      -- wipe(self)
    end
  end
end)

if require then
  return nodePropStream
else
  select(2, ...).nodePropStream = nodePropStream
end

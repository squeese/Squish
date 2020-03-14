local Utils = require 'libs/Utils'
local Observable = require 'libs/Observable'
local NIL = {}

local function init(self)
  self.__nodeSizeInitial = #self
  self.__nodeSizeActual = #self
  self.__nodeStart = #self+1
  self.__nodeEnd = #self*2+1
  self.__nodePending = #self > 0
  for i = 1, self.__nodeSizeInitial+1 do
    self[self.__nodeSizeInitial+i] = self.__nodeSizeInitial*2+i+1
  end
  for i = self.__nodeStart, self.__nodeEnd-1 do
    self[self[i]] = NIL
  end
  self.__tmp = {}
end

local function wipe(self)
  for i = self.__nodeSizeInitial+1, #self do
    self[i] = nil
  end
  self.__nodeSizeInitial = nil
  self.__nodeSizeActual = nil
  self.__nodeStart = nil
  self.__nodeEnd = nil
  self.__nodePending = nil
end

local function pending(self)
  for i = self.__nodeStart, self.__nodeEnd-1 do
    if rawget(self, rawget(self, i)) == NIL then
      self.__nodePending = true
      return true
    end
  end
  self.__nodePending = false
  return false
end

local function write(self, i, ...)
  local hasChanged = false
  local currOffset = rawget(self, self.__nodeStart+i-1)
  local nextOffset = rawget(self, self.__nodeStart+i)
  local spaceNeeded = select('#', ...)
  local spaceChange = spaceNeeded - (nextOffset - currOffset)
  if spaceChange ~= 0 then
    hasChanged = true
    self.__nodeSizeActual = self.__nodeSizeActual + spaceChange
    for ii = self.__nodeStart+i, self.__nodeEnd do
      self[ii] = rawget(self, ii) + spaceChange
    end
    if spaceChange > 0 then
      for ii = #self+spaceChange, currOffset+spaceNeeded-1, -1 do
        self[ii] = rawget(self, ii-spaceChange)
      end
    elseif spaceChange < 0 then
      for ii = currOffset+spaceNeeded, #self do
        self[ii] = rawget(self, ii-spaceChange)
      end
    end
  end
  for ii = 1, spaceNeeded do
    local index, value = (currOffset+ii-1), select(ii, ...)
    hasChanged = (rawget(self, index) ~= value) or hasChanged
    self[index] = value
  end
  return hasChanged, pending(self)
end

local nodeChildStream = Observable.create(function(send, _, self)
  init(self)
  local subscription, subscriptions = nil, nil
  local sent = false
  for i = 1, self.__nodeSizeInitial do
    if Utils.isStream(self[i]) then
      subscription = self[i]:subscribe(function(...)
        if self.__nodePending then
          local changed, pending = write(self, i, ...)
          if changed and not pending then
            sent = true
            send(1, self.__nodeSizeActual)
          end
        elseif write(self, i, ...) then
          send(self[self.__nodeStart+i-1]-self.__nodeEnd, select('#', ...))
        end
      end, nil, self)
      if subscription then
        if not subscriptions then
          subscriptions = {}
        end
        table.insert(subscriptions, subscription)
      end
    else
      write(self, i, self[i])
    end
  end
  if not sent and not self.__nodePending then
    send(1, self.__nodeSizeInitial)
  end
  return function()
    if subscriptions then
      for i = 1, #subscriptions do
        subscriptions[i]()
      end
    end
    wipe(self)
  end
end)

if require then
  return nodeChildStream
else
  select(2, ...).nodeChildStream = nodeChildStream
end
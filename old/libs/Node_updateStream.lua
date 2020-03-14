local Observable = require 'libs/Observable'

local nodeUpdateStream = Observable.create(function (send, done, self)
  local props, nodes, initial, offset, size = nil, nil, true, nil, nil

  local unsubProps = self.__propStream:subscribe(function()
    props = true
    if nodes then
      send(self, initial, offset, size, select(self.__nodeEnd+1, unpack(self)))
      initial = false
    end
  end, nil, self)

  local unsubNodes = self.__nodeStream:subscribe(function(o, s)
    nodes, offset, size = true, o, s
    if props then
      send(self, initial, offset, size, select(self.__nodeEnd+1, unpack(self)))
      initial = false
    end
  end, nil, self)
  
  return function()
    unsubProps()
    unsubNodes()
    self:remove()
  end
end)

if require then
  return nodeUpdateStream
else
  select(2, ...).nodeUpdateStream = nodeUpdateStream
end
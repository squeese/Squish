local Observable = require and require('./libs/Observable') or select(2, ...).Observable
local frame = require and require('./libs/frame') or select(2, ...).frame
local Event = {}

local subscriptions = {}
function subscriptions.__index(self, name)
  self[name] = {}
  return self[name]
end
setmetatable(subscriptions, subscriptions)

frame:SetScript('OnEvent', function(_, name, ...)
  for i = 1, #subscriptions[name] do
    subscriptions[name][i](...)
  end
end)

function Event.__index(self, name)
  self[name] = Observable.create(function(cb, _, ...)
    if #subscriptions[name] == 0 then
      frame:RegisterEvent(name)
    end
    table.insert(subscriptions[name], cb)
    return function()
      for i = 1, #subscriptions[name] do
        if cb == subscriptions[name][i] then
          table.remove(subscriptions[name], i)
          break
        end
      end
      if #subscriptions[name] == 0 then
        frame:UnregisterEvent(name)
      end
    end
  end)
  return self[name]
end
setmetatable(Event, Event)

if require then
  return Event
else
  select(2, ...).Event = Event
end
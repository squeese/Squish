local Squish = select(2, ...)

local Stream = {}
Stream.__index = Stream
Squish.Stream = Stream
Squish.ident = function(...) return ... end

local weak = {__mode = "v"}
local instances = setmetatable({}, weak)
local function insert(tbl, offset, ...)
  for index = 1, select("#", ...) do
    tbl[index + offset] = select(index, ...)
  end
  return tbl
end

function REPORT()
  print("report", collectgarbage("count"))
  collectgarbage("collect")
  for k, v in pairs(instances) do
    print(k, v, unpack(v))
  end
end

function Stream.create(subscriber, ...)
  local instance = { subscriber = subscriber, ... }
  table.insert(instances, instance)
  -- print("created instance", instance)
  return setmetatable(instance, Stream)
end

function Stream.of(...)
  return Stream.create(function(next, send)
    send(unpack(next))
    return Squish.ident()
  end, ...)
end

function Stream.switch(...)
  local length = select("#", ...)
  return Stream.create(function(next, send, ctx)
    for i = 1, length do
      next[length + i] = next[i]:subscribe(send, ctx)
    end
    return function()
      for i = length + 1, #next do
        next[i]()
        next[i] = nil
      end
    end
  end, ...)
end

function Stream.unitContext(streams)
  for key, val in pairs(streams) do
    streams[key] = Stream.create(function(_, send, ctx)
      send(ctx)
      return val:subscribe(send, ctx)
    end)
  end
  return Stream.create(function(_, send, unit)
    if unit == "player" then
      return streams.player:subscribe(send, unit)
    elseif unit == "target" then
      return streams.target:subscribe(send, unit)
    elseif unit == "focus" then
      return streams.focus:subscribe(send, unit)
    elseif string.match(unit, "%w+target") then
      return streams.subtarget:subscribe(send, unit)
    elseif string.match(unit, "party%d$") or string.match(unit, "raid%d+$") then
      return streams.friends:subscribe(send, unit)
    else
      return streams.other:subscribe(send, unit)
    end
  end)
end

Stream.empty = Stream.create(function()
  return Squish.ident
end)

function Stream:subscribe(send, ctx)
  return self.subscriber(self, send, ctx) or Squish.ident
end

function Stream:map(fn)
  return Stream.create(function(_, send, ctx)
    return self:subscribe(function(...)
      send(fn(ctx, ...))
    end, ctx)
  end)
end

function Stream:select(offset)
  return Stream.create(function(_, send, ctx)
    return self:subscribe(function(...)
      send(select(offset, ...))
    end, ctx)
  end)
end

function Stream:filter(fn)
  return Stream.create(function(next, send, ctx)
    return self:subscribe(function(...)
      if fn(ctx, ...) then send(...) end
    end, ctx)
  end)
end

function Stream:use(ctx)
  return Stream.create(function(_, send)
    return self:subscribe(send, ctx)
  end)
end

function Stream:insert(...)
  return insert(self, 0, ...)
end

function Stream:once()
  return Stream.create(function(_, send, ctx)
    local done = false
    return self:subscribe(function(...)
      if done then return end
      done = true
      send(...)
    end, ctx)
  end)
end

function Stream:tap(fn)
  return Stream.create(function(_, send, ctx)
    return self:subscribe(function(...)
      fn(ctx, ...)
      send(...)
    end, ctx)
  end)
end

function Stream:flatten()
  return Stream.create(function(_, send, ctx)
    local previous = Squish.ident
    local current = self:subscribe(function(stream, ...)
      if type(stream) == "table" and getmetatable(stream) == Stream then
        previous()
        previous = stream and stream:subscribe(send, ctx) or Squish.ident
      else
        send(stream, ...)
      end
    end, ctx)
    return function()
      current()
      previous()
    end
  end)
end












local Subject = {}
Subject.__index = Subject
setmetatable(Subject, Stream)

function Subject:subscribe(subscriber)
  table.insert(self, subscriber)
  return function()
    for index, value in ipairs(self) do
      if value == subscriber then
        table.remove(self, index)
        return
      end
    end
  end
end

function Subject:send(value, ...)
  self.current = value
  for i = 1, #self do
    rawget(self, i)(value, ...)
  end
end





-- ??
function Stream.value(initial, ...)
  local subject = setmetatable({}, Subject)
  return subject:init(initial):spring(initial, ...), function(...)
    subject:send(...)
  end
end






do
  local frame = CreateFrame('frame', nil, UIParent)
  local streams = {}
  local senders = {}
  function Stream.event(name)
    if not streams[name] then
      senders[name] = {}
      streams[name] = Stream.create(function(_, send)
        if #senders[name] == 0 then
          frame:RegisterEvent(name)
        end
        table.insert(senders[name], send)
        return function()
          for i, fn in pairs(senders[name]) do
            if fn == send then
              table.remove(senders[name], i)
              break
            end
          end
          if #senders[name] == 0 then
            frame:UnregisterEvent(name)
          end
        end
      end)
    end
    return streams[name]
  end
  local tmp = {}
  function Stream.events(...)
    local length = select('#', ...)
    for i = 1, length do
      tmp[i] = Stream.event(select(i, ...))
    end
    return Stream.switch(unpack(tmp, 1, length))
  end
  streams.__index = function(self, name)
    if string.sub(name, 1, 4) == 'CLEU_' then
      local actual = string.sub(name, 6)
      local Event = Stream
        .event('COMBAT_LOG_EVENT_UNFILTERED')
        :filter(function(_, _, event) return event == actual end)
      rawset(self, name, Event)
      return Event
    end
    return nil
  end
  setmetatable(streams, streams)
  frame:SetScript('OnEvent', function(_, name, ...)
    for i, sender in pairs(senders[name]) do
      sender(name, ...)
    end
  end)
end








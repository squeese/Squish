local Q = select(2, ...)
local Stream = {}
Q.Stream = Stream
Stream.__index = Stream
local function ident(...)
  return ...
end
Q.ident = ident
local function noop()
end
Q.noop = noop


function Stream.create(subscriber, ...)
  return setmetatable({subscriber = subscriber, ...}, Stream)
end

function Stream:subscribe(...)
  return self:subscriber(...) or ident
end

--function Stream.of(...)
  --return Stream.create(function(next, send)
    --send(unpack(next))
    --return Q.ident()
  --end, ...)
--end

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

Stream.empty = Stream.create(function()
  return ident
end)

function Stream:map(fn)
  return Stream.create(function(next, send, ctx)
    return self:subscribe(function(...)
      send(fn(ctx, ...))
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

function Stream:use(arg)

end

--function Stream:select(offset)
  --return Stream.create(function(_, send, ctx)
    --return self:subscribe(function(...)
      --send(select(offset, ...))
    --end, ctx)
  --end)
--end


--function Stream:use(ctx)
  --return Stream.create(function(_, send)
    --return self:subscribe(send, ctx)
  --end)
--end

--function Stream:insert(...)
  --return insert(self, 0, ...)
--end

--function Stream:once()
  --return Stream.create(function(_, send, ctx)
    --local done = false
    --return self:subscribe(function(...)
      --if done then return end
      --done = true
      --send(...)
    --end, ctx)
  --end)
--end

--function Stream:tap(fn)
  --return Stream.create(function(_, send, ctx)
    --return self:subscribe(function(...)
      --fn(ctx, ...)
      --send(...)
    --end, ctx)
  --end)
--end

--function Stream:flatten()
  --return Stream.create(function(_, send, ctx)
    --local previous = Q.ident
    --local current = self:subscribe(function(stream, ...)
      --if type(stream) == "table" and getmetatable(stream) == Stream then
        --previous()
        --previous = stream and stream:subscribe(send, ctx) or Q.ident
      --else
        --send(stream, ...)
      --end
    --end, ctx)
    --return function()
      --current()
      --previous()
    --end
  --end)
--end












--local Subject = {}
--Subject.__index = Subject
--setmetatable(Subject, Stream)

--function Subject:subscribe(subscriber)
  --table.insert(self, subscriber)
  --return function()
    --for index, value in ipairs(self) do
      --if value == subscriber then
        --table.remove(self, index)
        --return
      --end
    --end
  --end
--end

--function Subject:send(value, ...)
  --self.current = value
  --for i = 1, #self do
    --rawget(self, i)(value, ...)
  --end
--end





---- ??
--function Stream.value(initial, ...)
  --local subject = setmetatable({}, Subject)
  --return subject:init(initial):spring(initial, ...), function(...)
    --subject:send(...)
  --end
--end






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








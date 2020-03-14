_, PS = ...
PS.Stream = {}
PS.Stream.__index = PS.Stream

function PS.Stream.create(subscriber)
  return setmetatable({ subscriber = subscriber }, PS.Stream)
end

function PS.Stream:subscribe(send, done, ctx)
  send = send or PS.Utils.identity
  done = senf or PS.Utils.identity
  return self.subscriber(send, done, ctx, self)
end

PS.Stream.empty = PS.Stream.create(function(_, done)
  done()
  return PS.Utils.identity
end)

function PS.Stream.of(...)
  return PS.Stream.create(function(send, done, ctx, self)
    send(unpack(self))
    done()
    return PS.Utils.identity
  end):insert(...)
end

function PS.Stream.switch(...)
  local length = select('#', ...)
  if length == 1 then
    local stream = select(1, ...)
    if getmetatable(stream) == PS.Stream then
      return stream
    end
  end
  return PS.Stream.create(function(send, done, ctx, self)
    for i = 1, length do
      self[length + i] = self[i]:subscribe(send, done, ctx, self)
    end
    return function(...)
      for i = #self, (length+1), -1 do
        self[i]();
        self[i] = nil
      end
      return ...
    end
  end):insert(...)
end

function PS.Stream.merge(...)
  local size = select('#', ...)
  return PS.Stream.create(function(send, done, node, self)
    PS.Utils.Packer_init(self, size * 2 + 1, size)
    for i = 1, size do
      self[size + i] = self[i]:subscribe(function(...)
        if (PS.Utils.Packer_write(self, i, ...)) then
          send(unpack(self, self[self.__packer_ind_s], self[self.__packer_ind_e - 1]))
        end
      end, done, node, self)
    end
    return function(...)
      for i = size, 1, -1 do
        self[size + i]()
        self[size + i] = nil
      end
      for i = self[self.__packer_ind_s], self[self.__packer_ind_e - 1] do
        self[i] = nil
      end
      return ...
    end
  end):insert(...)
end

do
  local Subject = {}
  Subject.__index = Subject
  setmetatable(Subject, PS.Stream)
  function Subject:subscribe(send)
    table.insert(self, send)
    return function(...)
      for i = 1, #self do
        if self[i] == send then
          table.remove(self, i)
        end
      end
      return ...
    end
  end
  function Subject:send(...)
    for i = 1, #self do
      rawget(self, i)(...)
    end
  end
  function PS.Stream.subject()
    return setmetatable({}, Subject)
  end
end

do
  local frame = CreateFrame('frame', nil, UIParent)
  local streams = {}
  local senders = {}
  function PS.Stream.event(name)
    if not streams[name] then
      senders[name] = {}
      streams[name] = PS.Stream.create(function(send, done)
        if #senders[name] == 0 then
          frame:RegisterEvent(name)
        end
        table.insert(senders[name], send)
        return function(...)
          for i, fn in pairs(senders[name]) do
            if fn == send then
              table.remove(senders[name], i)
              break
            end
          end
          if #senders[name] == 0 then
            frame:UnregisterEvent(name)
          end
          return ...
        end
      end)
    end
    return streams[name]
  end
  local t = {}
  function PS.Stream.events(...)
    local n = select('#', ...)
    for i = 1, n do
      t[i] = PS.Stream.event(select(i, ...))
    end
    return PS.Stream.switch(unpack(t, 1, n))
  end
  streams.__index = function(self, name)
    if string.sub(name, 1, 4) == 'CLEU_' then
      local actual = string.sub(name, 6)
      local Event = PS.Stream
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

function PS.Stream:map(fn, ctx)
  fn = fn or PS.Utils.identity
  return PS.Stream.create(function(send, done, ...)
    return self:subscribe(function(...)
      if ctx then send(fn(ctx, ...))
      else send(fn(...)) end
    end, done, ...)
  end)
end

function PS.Stream:filter(fn)
  fn = fn or PS.Utils.identity
  return PS.Stream.create(function(send, done, ...)
    return self:subscribe(function(...)
      if fn(...) then
        send(...)
      end
    end, done, ...)
  end)
end

function PS.Stream:filtern(n, val)
  return self:filter(function(...)
    return select(n, ...) == val
  end)
end

function PS.Stream:tap(fn)
  fn = fn or print
  return PS.Stream.create(function(send, done, ...)
    return self:subscribe(function(...)
      fn(...)
      send(...)
    end, done, ...)
  end)
end

function PS.Stream:init(...)
  return PS.Stream.create(function(send, done, ...)
    send(unpack(self))
    return self:subscribe(send, done, ...)
  end):insert(...)
end

function PS.Stream:log(prefix)
  return self:tap(function(...)
    print(prefix, ...)
  end)
end

function PS.Stream:after(fn)
  return PS.Stream.create(function(send, done, ...)
    local unsub = self:subscribe(send, done, ...)
    return function(value)
      return fn(unsub, value)
    end
  end)
end

function PS.Stream:insert(...)
  return PS.Utils.insert(self, ...)
end

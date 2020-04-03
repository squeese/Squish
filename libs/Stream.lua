local Q = select(2, ...)
local insert = table.insert
local remove = table.remove
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

function Stream:__call(...)
  for i = 1, select("#", ...) do
    self[i] = select(i, ...)
  end
  return self
end

function Stream.create(subscriber, ...)
  return setmetatable({subscriber = subscriber, ...}, Stream)
end

function Stream:subscribe(...)
  return self:subscriber(...) or ident
end

function Stream.of(...)
  return Stream.create(function(self, send)
    send(unpack(self))
    return Q.ident
  end, ...)
end

Stream.empty = Stream.create(function()
  return noop
end)

function Stream:extend(fn)
  return Stream.create(function(next, send, ...)
    local map = fn(next)
    return self:subscribe(function(driver, container, ...)
      send(driver, container, send(map(...)))
    end)
  end)
end

function Stream:map(fn)
  return Stream.create(function(next, send, ...)
    return self:subscribe(function(driver, container, ...)
      send(driver, container, fn(...))
    end, ...)
  end)
end

function Stream:filter(fn)
  return Stream.create(function(next, send, ...)
    return self:subscribe(function(driver, container, ...)
      if fn(...) then
        send(driver, container, ...)
      end
    end, ...)
  end)
end


function Stream:select(n)
  return Stream.create(function(next, send, ...)
    return self:subscribe(function(driver, container, ...)
      send(driver, container, select(n, ...))
    end, ...)
  end)
end

function Stream:sticky(initial)
  return Stream.create(function(next, send, ...)
    local value = initial
    return self:subscribe(function(driver, container, next, ...)
      value = next or value
      send(driver, container, value, ...)
    end, ...)
  end)
end

do
  local function dispatch(timer)
    for i = 1, #timer do
      timer[i]()
    end
  end
  local timer = nil
  Stream.tocker = Stream.create(function(_, send, ...)
    if not timer then
      timer = C_Timer.NewTicker(0.2, dispatch)
    end
    insert(timer, send)
    return function()
      for i = 1, #timer do
        if timer[i] == send then
          remove(timer, i)
          break
        end
      end
      if #timer == 0 then
        timer:Cancel()
        timer = nil
      end
    end
  end)
end

do
  local function write(t, ...)
    local l = select("#", ...)
    for i = 1, l do    t[i] = select(i, ...) end
    for i = l+1, #t do t[i] = nil end
  end
  local function dispatch(timer)
    timer[1](unpack(timer, 2))
  end
  function Stream:ticker(interval)
    return Stream.create(function(_, send, ...)
      local timer = nil
      local cleanup = self:subscribe(function(...)
        if not timer then
          timer = C_Timer.NewTicker(interval, dispatch)
        end
        write(timer, send, ...)
      end, ...)
      return function()
        cleanup()
        if timer then
          write(timer)
          timer:Cancel()
        end
      end
    end)
  end
end

do
  local frame = CreateFrame("frame", nil, UIParent)
  local active = {}
  local length = 0
  local fps = 1000/60
  local springUpdate = Q.springUpdate
  local springIdle = Q.springIdle
  local function lerp(a, b, t, dt)
    return a + (t * (b - a)) * dt
  end
  local function update(_, elapsed)
    local elapsedMS = elapsed * 1000
    local elapsedDt = elapsedMS / fps
    for i = length, 1, -1 do
      local c = active[i]
      if c.__update_spring then
        springUpdate(c, elapsedMS)
        if springIdle(c) then
          c.__update_send(c.__driver, c, c.__update_c, elapsedDt)
          remove(active, i)
          length = length - 1
          c.__update_send = nil
        else
          c.__update_send(c.__driver, c, c.__update_c, elapsedDt)
        end
      else
        c.__update_c = c.__update_c + (elapsed * c.__update_s)
        local diff = c.__update_t - c.__update_c
        if math.abs(diff) <= c.__update_p then
          c.__update_send(c.__driver, c, c.__update_t, c.__update_t, elapsedDt)
          remove(active, i)
          length = length - 1
          c.__update_send = nil
        else
          c.__update_send(c.__driver, c, c.__update_c, c.__update_t, elapsedDt)
        end
      end
    end
    if length == 0 then
      frame:SetScript("OnUpdate", nil)
    end
  end
  local function start()
    if length > 0 then return end
    frame:SetScript("OnUpdate", update)
  end
  local function remove(container)
    for i = 1, length do
      if active[i] == container then
        remove(active, i)
        break
      end
    end
  end
  local function sign(value)
    if value < 0 then return -1 end
    if value > 0 then return 1 end
    return 0
  end
  function Stream:update(c, t, p)
    return Stream.create(function(_, send, ...)
      local current = nil
      local cleanup = self:subscribe(function(driver, container, current, target)
        start()
        if not container.__update_send then
          container.__update_send = send
          container.__update_p = math.abs(p or 0.001)
          length = length + 1
          insert(active, container)
        end
        container.__update_c = current or container.__update_c or c
        container.__update_t = target or container.__update_c or t
        container.__update_s = sign(container.__update_t - container.__update_c)
        current = container
      end, ...)
      return function()
        if current then
          remove(current)
          container.__update_send = nil
          container.__update_c = nil
          container.__update_t = nil
          container.__update_s = nil
          container.__update_p = nil
        end
        cleanup()
      end
    end)
  end
  function Stream:spring(K, B, P)
    return Stream.create(function(_, send, ...)
      local current = nil
      local cleanup = self:subscribe(function(driver, container, target, k, b)
        start()
        if not container.__update_spring then
          container.__update_spring = true
          container.__update_p = P or 0.01
          container.__update_c = target
          container.__update_C = target
          container.__update_v = 0
          container.__update_V = 0
          container.__update_e = 0
        end
        if not container.__update_send then
          container.__update_send = send
          length = length + 1
          insert(active, container)
        end
        container.__update_t = target
        container.__update_k = k or K or 170
        container.__update_b = b or B or 26
        current = container
      end, ...)
      return function()
        if current then
          remove(current)
          container.__update_spring = nil
          container.__update_send = nil
          container.__update_k = nil
          container.__update_b = nil
          container.__update_p = nil
          container.__update_c = nil
          container.__update_C = nil
          container.__update_v = nil
          container.__update_V = nil
        end
        cleanup()
      end
    end)
  end
end


function Stream.switch(...)
  local length = select("#", ...)
  return Stream.create(function(next, send, ...)
    for i = 1, length do
      next[length + i] = next[i]:subscribe(send, i, ...)
    end
    return function()
      for i = length + 1, #next do
        next[i]()
        next[i] = nil
      end
    end
  end, ...)
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
        insert(senders[name], send)
        return function()
          for i, fn in pairs(senders[name]) do
            if fn == send then
              remove(senders[name], i)
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
  streams.__index = function(self, name)
    if string.sub(name, 1, 5) == 'CLEU_' then
      local actual = string.sub(name, 6)
      local Event = Stream.event('COMBAT_LOG_EVENT_UNFILTERED')
        :map(CombatLogGetCurrentEventInfo)
        :filter(function(_, event)
          return event == actual
        end)
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

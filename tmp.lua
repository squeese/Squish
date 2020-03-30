
    -- ,G(nil, "player")
    -- ,Input(S, "hello")
    -- ,Test(nil, 1, G("player"), 3)
-- name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal,
-- spellId, canApplyAura, isBossDebuff, castByPlayer

local Fixed = Q.Driver{
  ATTACH = function(self, parent, cursor, _, value)
    local container = parent[cursor]
    if container and type(container) == "table" and container.__driver then
      container.__driver:RELEASE(container, nil)
    end
    parent[cursor] = value
    return cursor + 1
  end,
}

local Dynamic = Q.Driver{
  ATTACH = function(self, parent, cursor, _, value)
    local container = parent[cursor]
    if not container or type(container) ~= "table" then
      container = parent(#parent+1)
      container.__driver = self
      container.__unsub = value:subscribe(function(...)
        self:QUEUE(container, self.SEND, ...)
      end)
      -- self:RELEASE(self:CHILDREN(container, 1, self:RENDER(container, parent, value)))
    else
      -- self:RELEASE(self:CHILDREN(container, 1, self:UPDATE(container, value)))
    end
    return cursor + 1
  end,

  SEND = function(self, container, ...)
    print("SEND", ...)
  end,

  --RENDER = function(self, container, parent, value)
    --print("Dynamic render", value)
  --end,

  --UPDATE = function(self, container, value)
    --print("Dynamic update", value)
  --end,

  REMOVE = function(self, container)
    container.__unsub()
    container.__unsub = nil
  end
}

local map = Q.map
local tmp = function(index, value)
  local kind = type(value)
  if kind == "table" and getmetatable(value) == Q.Stream then
    return Dynamic(nil, value)
  else
    return Fixed(nil, value)
  end
end

local Test = Q.Driver{
  RENDER = function(self, container, parent, key, ...)
    return map(tmp, ...)
  end,
  UPDATE = function(self, container, ...)
    return map(tmp, ...)
  end,
  RELEASE = function(self, container, offset)
    for index = offset or 1, #container do
      if type(container[index]) == "table" then
        container[index].__driver:RELEASE(container[index], nil)
      end
      container[index] = nil
    end
    if not offset then
      container.__driver:REMOVE(container)
      container.__driver = nil
      container.__pool:Release(container)
    end
  end
}

local S = Q.Stream.create(function(_, send)
  local timer = C_Timer.NewTicker(0.5, function()
    send(math.random())
  end)
  return function()
    timer:Cancel()
  end
end)

local SS = Q.Stream.create(function(_, send, input)
  local a = input:subscribe(send)
  return function()
    print("?")
    return a()
  end
end)



Q.Something = Q.Driver{

  subscribe = function(container, subscriber)
    container.subscriber = subscriber
    return Q.noop
  end,

  RENDER = function(self, container, parent, key, value)
    print("render", key, value)
    container.subscribe = self.subscribe
    --container.subscription = self.stream:subscribe(function(...)
      --print("value", ...)
    --end, container)
    -- container.subscriber(value)
    -- return dispatch()
  end,

  UPDATE = function(self, container, value)
    print("update", value)
  end,

  REMOVE = function(self, container)
    container.subscription()
    container.subscribe = nil
    container.subscriber = nil
    container.subscription = nil
  end,
}


local G = Q.Something{ stream = SS }















    end)
    ,Base(nil
      ,"hello"
      ,"world"
      --,Fixed(nil, "hello")
      --,Dynamic(nil)
      --,Fixed(nil, "world")
      -- ,Dynamic(nil, SS, "player")
    )




local Fixed = Q.Driver{
  ATTACH = function(self, parent, cursor, _, value)
    local container = parent[cursor]
    if container and type(container) == "table" and container.__driver then
      container.__driver:RELEASE(container, nil)
    end
    parent[cursor] = value
    return container, cursor + 1
  end,
}


local Dynamic = Q.Driver{
  ATTACH = function(self, parent, cursor, _, ...)
    return parent, cursor
  end,
  RENDER = function(self, container, parent, key, stream, value)
    -- upgrade...
  end,
  UPDATE = function(self, container, stream, value)
  end,
  RELEASE = function(self, container)
  end,
}

local map = Q.map
local Attach = Q.Driver.ATTACH
local Base = Q.Driver{
  --ATTACH = function(self, ...)
    --return self:POST(select("#", ...), Attach(self, ...))
  --end,
  RENDER = function(self, container, parent, key, ...)
    for i = 1, select("#", ...) do
      container[i] = select(i, ...)

    end
  end,
  --UPDATE = function(self, container, ...)
    --return ...
  --end,
  --POST = function(self, count, container, cursor)
    --print("ok", cursor, count, unpack(container))
    --return container, cursor
  --end,
}



--[[

  base needs to be able todo
    child:subscribe(...)



]]












--do
  --local function init(size)
    --return bit.lshift(1, size) - 1
  --end
  --local function open(gate, index)
    --return bit.bxor(gate, bit.lshift(1, index-1))
  --end
  --local function update(container)
    --if container.gate ~= 0 then return end
    --local frame = container.frame
    --local name = container[3]
    --frame[name](frame, unpack(container, 4, container.length+2))
  --end

  --Q.S3t = Q.Driver{
    --render = function(self, container, parent, ...)
      --container.frame = parent.frame
      --local length = select("#", ...)
      --container.gate = init(length)
      --container.length = length
      --for index = 1, length do
        --local value = select(index, ...)
        --if type(value) == "table" and getmetatable(value) == Q.Stream then
          --container[-index] = value:subscribe(function(value)
            --container[index+2] = value
            --container.gate = open(container.gate, index)
            --update(container)
          --end)
        --else
          --container.gate = open(container.gate, index)
          --container[index+2] = value
        --end
      --end
      --update(container)
    --end,

    --update = function(self, container)
      --update(container)
    --end,

    --remove = function(self, container)
      --container.frame = nil
      --container.gate = nil
      --for i = -1, -container.length, -1 do
        --local value = container[i]
        --if value then
          --value()
        --end
        --container[i] = nil
      --end
      --for i = 3, container.length+2 do
        --container[i] = nil
      --end
      --container.length = nil
    --end,
  --}
  ----Set.__call = function(driver, key, ...)
    ----return Driver.__call(Static, key, key, ...)
  ----end
--end

--Q.Val = Q.Driver{
  --acquire = function(self, parent, index, key)
    --return parent, index + 1
  --end,
  --render = function(self, _, parent, value)
    --print("Val", value)
  --end,
--}

--Q.Sex = Q.Driver{
  --render = function(self, container, parent, key, ...)
    --print("Sex")
    --return ...
  --end,
--}

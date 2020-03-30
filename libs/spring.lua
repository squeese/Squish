local Squish = select(2, ...)
local Stream = Squish.Stream

local FPS = 60
local MPF = 1000/FPS
local SPF = MPF/1000

local function stepper(x, v, t, k, b)
  local fs = -k * (x - t)
  local fd = -b * v
  local a = fs + fd
  local V = v + a * SPF
  local X = x + V * SPF
  return X, V
end

local function update(spring, elapsed)
  spring.e = spring.e + elapsed
  local delta = (spring.e - math.floor(spring.e / MPF) * MPF) / MPF
  local frames = math.floor(spring.e / MPF)
  for i = 0, frames-1 do
    spring.C, spring.V = stepper(spring.C, spring.V, spring.t, spring.k, spring.b)
  end
  local c, v = stepper(spring.C, spring.V, spring.t, spring.k, spring.b)
  spring.c = spring.C + (c - spring.C) * delta
  spring.v = spring.V + (v - spring.V) * delta
  spring.e = spring.e - frames * MPF
  return spring.c
end

local function idle(spring)
  if (math.abs(spring.v) < spring.p and math.abs(spring.c - spring.t) < spring.p) then
    spring.c = spring.t
    spring.C = spring.t
    spring.v = 0
    spring.V = 0
    spring.e = 0
    return true
  end
  return false
end

local springs = {}
local function tick(self, elapsed)
  if #springs == 0 then
    self:SetScript("OnUpdate", nil)
    print("empty")
    return
  end
  for i = #springs, 1, -1 do
    local spring = springs[i]
    if not spring.active then
      table.remove(springs, i)
    else
      spring.send(spring._a, spring._b, update(spring, elapsed * 1000))
      if idle(spring) then
        spring.active = false
      end
    end
  end
end

local frame = CreateFrame("frame", nil, UIParent)
local function run(spring)
  if not spring.active then
    spring.active = true
    table.insert(springs, spring)
    frame:SetScript("OnUpdate", tick)
  end
end

function Stream:spring(t, k, b, c, p)
  return Stream.create(function(next, send, ...)
    local spring = {
      t = t or 0,
      c = c or 0,
      C = c or 0,
      v = 0,
      V = 0,
      k = k or 170,
      b = b or 26,
      p = p or 0.01,
      e = 0,
      send = send
    }
    local subscription = self:subscribe(function(a, b, target)
      spring.t = target
      spring._a = a
      spring._b = b
      run(spring)
    end, ...)

    return function()
      for index, value in ipairs(springs) do
        if value == spring then
          table.remove(springs, index)
          break
        end
      end
      subscription()
    end
  end)
end

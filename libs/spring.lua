local Q = select(2, ...)
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

local function update(s, elapsed)
  s.__update_e = s.__update_e + elapsed
  local delta = (s.__update_e - math.floor(s.__update_e / MPF) * MPF) / MPF
  local frames = math.floor(s.__update_e / MPF)
  for i = 0, frames-1 do
    s.__update_C, s.__update_V = stepper(s.__update_C, s.__update_V, s.__update_t, s.__update_k, s.__update_b)
  end
  local c, v = stepper(s.__update_C, s.__update_V, s.__update_t, s.__update_k, s.__update_b)
  s.__update_c = s.__update_C + (c - s.__update_C) * delta
  s.__update_v = s.__update_V + (v - s.__update_V) * delta
  s.__update_e = s.__update_e - frames * MPF
end

local function idle(s)
  if (math.abs(s.__update_v) < s.__update_p and math.abs(s.__update_c - s.__update_t) < s.__update_p) then
    s.__update_c = s.__update_t
    s.__update_C = s.__update_t
    s.__update_v = 0
    s.__update_V = 0
    s.__update_e = 0
    return true
  end
  return false
end

Q.springUpdate = update
Q.springIdle = idle

--[[
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
end]]

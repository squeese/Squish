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

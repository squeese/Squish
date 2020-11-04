${locals.use("math.abs")}
${locals.use("math.floor")}
${locals.use("table.remove")}
${locals.use("table.insert")}

local Spring = CreateFrame('frame')
do
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
    local delta = (s.__update_e - Math_Floor(s.__update_e / MPF) * MPF) / MPF
    local frames = Math_Floor(s.__update_e / MPF)
    for i = 0, frames-1 do
      s.__update_C, s.__update_V = stepper(s.__update_C, s.__update_V, s.__update_t, s.__update_k, s.__update_b)
    end
    local c, v = stepper(s.__update_C, s.__update_V, s.__update_t, s.__update_k, s.__update_b)
    s.__update_c = s.__update_C + (c - s.__update_C) * delta
    s.__update_v = s.__update_V + (v - s.__update_V) * delta
    s.__update_e = s.__update_e - frames * MPF
  end
  local function idle(s)
    if (Math_Abs(s.__update_v) < s.__update_p and Math_Abs(s.__update_c - s.__update_t) < s.__update_p) then
      s.__update_c = s.__update_t
      s.__update_C = s.__update_t
      s.__update_v = 0
      s.__update_V = 0
      s.__update_e = 0
      return true
    end
    return false
  end

  local function OnUpdate_Spring(self, elapsed)
    local elapsedMS = elapsed * 1000
    local elapsedDT = elapsedMS / MPF
    for i = #self, 1, -1 do
      local s = self[i]
      if idle(s) then
        s.__active = nil
        Table_Remove(self, i)
        if #self == 0 then
          self:SetScript("OnUpdate", nil)
        end
      else
        update(s, elapsedMS)
      end
      s.__update_fn(s, s.__update_c)
    end
  end

  function Spring:Update(s, target)
    if not s.__initialized then
      s.__initialized = true
      s.__update_c = target
      s.__update_C = target
      s.__update_v = 0
      s.__update_V = 0
      s.__update_e = 0
    end
    s.__update_t = target
    if not s.__active then
      s.__active = true
      if #self == 0 then
        self:SetScript("OnUpdate", OnUpdate_Spring)
      end
      Table_Insert(self, s)
    end
  end

  function Spring:Stop(s, target)
    s.__update_t = target
    s.__update_c = target
    s.__update_C = target
    s.__update_v = 0
    s.__update_V = 0
    s.__update_e = 0
    if s.__active then
      s.__active = nil
      for i = 1, #self do
        if s == self[i] then
          Table_Remove(self, i)
          break
        end
      end
      if #self == 0 then
        self:SetScript("OnUpdate", nil)
      end
    end
    s.__update_fn(s, target)
  end

  function Spring:Create(FN, K, B, P)
    local s = {}
    s.__update_fn = FN
    s.__initialized = false
    s.__update_p = P or 0.01
    s.__update_k = K or 170
    s.__update_b = B or 26
    return s
  end
end

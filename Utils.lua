local Squish = select(2, ...)

do
  local frame = CreateFrame('frame', nil, UIParent)
  local timers = {}
  function Squish.setTimeout(delay, interval, fn, ...)
    local timer = {fn = fn, duration = delay, delay = delay, interval = interval, args = {...}}
    table.insert(timers, timer)
    frame:SetScript("OnUpdate", frame:GetScript("OnUpdate") or function(self, e)
      if #timers == 0 then
        self:SetScript("OnUpdate", nil)
      end
      for i = #timers, 1, -1 do
        timers[i].duration = timers[i].duration - e
        if timers[i].duration <= 0 then
          local fn = timers[i].fn
          local args = timers[i].args
          if type(timers[i].interval) == "boolean" then
            timers[i].duration = timers[i].delay
          elseif type(timers[i].interval) == "number" and timers[i].interval > 0 then
            timers[i].interval = timers[i].interval - 1
            timers[i].duration = timers[i].delay
          else
            table.remove(timers, i)
          end
          fn(unpack(args))
          return
        end
      end
    end)
    return timer
  end

  function Squish.clearTimeout(timer)
    for index, value in ipairs(timers) do
      if value == timer then
        table.remove(timers, index)
        break
      end
    end
  end
end

do
  local frame = CreateFrame("frame", nil, UIParent)
  function Squish.dev(fn)
    frame:RegisterEvent("ADDON_LOADED")
    frame:SetScript("OnEvent", function(self, _, name)
      if (name == "ViragDevTool") then
        self:UnregisterEvent("ADDON_LOADED")
        self:SetScript("OnEvent", nil)
        fn()
      end
    end)
  end
end

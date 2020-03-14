local Squish = select(2, ...)

Squish.Root = {
  __frame = UIParent,
  __parent = UIParent,
}
Squish.tooltipBackground = {
  bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
  edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
  tile = true, tileSize = 16, edgeSize = 16, 
  insets = { left = 4, right = 4, top = 4, bottom = 4 }
}

Squish.media = {}
Squish.media.mini = 'Interface\\Addons\\Squish\\media\\minimalist.tga'
Squish.media.flat = 'Interface\\Addons\\Squish\\media\\flat.tga'
Squish.media.vixar = 'Interface\\Addons\\Squish\\media\\vixar.ttf'
Squish.media.defbar = 'Interface\\TARGETINGFRAME\\UI-StatusBar'
Squish.media.square = {
  bgFile = 'Interface\\Addons\\Squish\\media\\backdrop.tga',
  edgeFile = 'Interface\\Addons\\Squish\\media\\edgefile.tga',
  insets   = { left = 1, right = 1, top = 1, bottom = 1 },
  edgeSize = 1
}

Squish.changed = function(a, b)
  if #a ~= #b then return true end
  for i, v in ipairs(a) do
    if v ~= b[i] then
      return true
    end
  end
  return false
end

do
  local frame = CreateFrame('frame', nil, UIParent)
  local timers = {}
  function Squish.setTimeout(delay, interval, fn, ...)
    local timer = {fn = fn, duration = delay, delay = delay, interval = interval}
    table.insert(timers, timer)
    frame:SetScript("OnUpdate", frame:GetScript("OnUpdate") or function(self, e)
      if #timers == 0 then
        self:SetScript("OnUpdate", nil)
      end
      for i = #timers, 1, -1 do
        timers[i].duration = timers[i].duration - e
        local arg = 0
        if timers[i].duration <= 0 then
          local fn = timers[i].fn
          if type(timers[i].interval) == "boolean" then
            timers[i].duration = timers[i].delay
          elseif type(timers[i].interval) == "number" and timers[i].interval > 1 then
            timers[i].interval = timers[i].interval - 1
            arg = timers[i].interval
            timers[i].duration = timers[i].delay
          else
            table.remove(timers, i)
          end
          fn(arg)
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

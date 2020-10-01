local Q = select(2, ...)

--function Q.Index(root, call)
  --root.__call = call or function(self, next)
    --next.__index = self
    --next.__call = self.__call
    --return setmetatable(next, next)
  --end
  --return setmetatable(root, root)
--end

--local function unwind(tbl, min, max, ...)
  --for i = min, max do
    --tbl[i] = nil
  --end
  --return ...
--end

--function Q.decimals(n, value)
  --local N = math.pow(10, n)
  --return math.floor(value * N) / N
--end

--local function write(t, ...)
  --local l = select("#", ...) 
  --for i = 1, l do
    --t[i] = select(i, ...)
  --end
  --for i = l+1, #t do
    --t[i] = nil
  --end
--end

--local function lighten(s, r, g, b)
  --return r+(1-r)*s, g+(1-g)*s, b+(1-b)*s
--end

--local function darken(s, r, g, b)
  --return r*(1-s), g*(1-s), b*(1-s)
--end

--Q.unwind = unwind
--Q.write = write
--Q.lighten = lighten
--Q.darken = darken

--function Q.copyColors(src, dst)
  --for key, value in pairs(src) do
    --if not dst[key] then
      --dst[key] = { value.r, value.g, value.b }
    --end
  --end
  --return dst
--end

--do
  --local remove = table.remove
  --local insert = table.insert
  --local pool = {}
  --local function release(tbl, ...)
    --for i = 1, #tbl do
      --tbl[i] = nil
    --end
    --return ...
  --end
  --function Q.iterator(fn)
    --return function()
      --local tbl = remove(pool) or {}
      --local index = 0
      --repeat
        --index = index + 1
        --tbl[index] = fn(index)
      --until not tbl[index]
      --return release(tbl, 1, index, unpack(tbl))
    --end
  --end
  --function Q.range(b, e, fn)
    --if not fn then
      --fn, e, b = e, b, 1
    --end
    --return function()
      --local tbl = remove(pool) or {}
      --for i = b, e do
        --tbl[i] = fn(i)
      --end
      --return release(tbl, unpack(tbl))
    --end
  --end

  --local function apply(fn, tbl, index, ...)
    --if select("#", ...) > 0 then
      --tbl[index] = fn(index, ...)
      --return false
    --end
    --return true
  --end
  --function Q.iterate(iterator, fn)
    --local tbl, index = remove(pool) or {}, 0
    --repeat index = index + 1
    --until apply(fn, tbl, index, iterator(index))
    --return release(tbl, unpack(tbl))
  --end
  --function Q.map(fn, ...)
    --local tbl = remove(pool) or {}
    --for i = 1, select("#", ...) do
      --local a = select(i, ...)
      --local b = fn(i, a)
      --if b then insert(tbl, b) end
    --end
    --return release(tbl, unpack(tbl))
  --end
--end

do -- https://github.com/oUF-wow/oUF/blob/master/blizzard.lua
  local MAX_ARENA_ENEMIES = MAX_ARENA_ENEMIES or 5
  local MAX_BOSS_FRAMES = MAX_BOSS_FRAMES or 5
  local MAX_PARTY_MEMBERS = MAX_PARTY_MEMBERS or 4
  local hiddenParent = CreateFrame('Frame', nil, UIParent)
  hiddenParent:SetAllPoints()
  hiddenParent:Hide()
  local function handleFrame(baseName)
    local frame
    if type(baseName) == 'string' then
      frame = _G[baseName]
    else
      frame = baseName
    end
    if frame then
      frame:UnregisterAllEvents()
      frame:Hide()
      frame:SetParent(hiddenParent)
      local health = frame.healthBar or frame.healthbar
      if health then
        health:UnregisterAllEvents()
      end
      local power = frame.manabar
      if power then
        power:UnregisterAllEvents()
      end
      local spell = frame.castBar or frame.spellbar
      if spell then
        spell:UnregisterAllEvents()
      end
      local altpowerbar = frame.powerBarAlt
      if altpowerbar then
        altpowerbar:UnregisterAllEvents()
      end
      local buffFrame = frame.BuffFrame
      if buffFrame then
        buffFrame:UnregisterAllEvents()
      end
    end
  end
  function Q.DisableBlizzard(unit)
    if(not unit) then return end
    if(unit == 'player') then
      handleFrame(PlayerFrame)
      PlayerFrame:RegisterEvent('PLAYER_ENTERING_WORLD')
      PlayerFrame:RegisterEvent('UNIT_ENTERING_VEHICLE')
      PlayerFrame:RegisterEvent('UNIT_ENTERED_VEHICLE')
      PlayerFrame:RegisterEvent('UNIT_EXITING_VEHICLE')
      PlayerFrame:RegisterEvent('UNIT_EXITED_VEHICLE')
      PlayerFrame:SetUserPlaced(true)
      PlayerFrame:SetDontSavePosition(true)
    elseif(unit == 'pet') then
      handleFrame(PetFrame)
    elseif(unit == 'target') then
      handleFrame(TargetFrame)
      handleFrame(ComboFrame)
    elseif(unit == 'focus') then
      handleFrame(FocusFrame)
      handleFrame(TargetofFocusFrame)
    elseif(unit == 'targettarget') then
      handleFrame(TargetFrameToT)
    elseif(unit:match('boss%d?$')) then
      local id = unit:match('boss(%d)')
      if(id) then
        handleFrame('Boss' .. id .. 'TargetFrame')
      else
        for i = 1, MAX_BOSS_FRAMES do
          handleFrame(string.format('Boss%dTargetFrame', i))
        end
      end
    elseif(unit:match('party%d?$')) then
      local id = unit:match('party(%d)')
      if(id) then
        handleFrame('PartyMemberFrame' .. id)
      else
        for i = 1, MAX_PARTY_MEMBERS do
          handleFrame(string.format('PartyMemberFrame%d', i))
        end
      end
    elseif(unit:match('arena%d?$')) then
      local id = unit:match('arena(%d)')
      if(id) then
        handleFrame('ArenaEnemyFrame' .. id)
      else
        for i = 1, MAX_ARENA_ENEMIES do
          handleFrame(string.format('ArenaEnemyFrame%d', i))
        end
      end
      -- Blizzard_ArenaUI should not be loaded
      Arena_LoadUI = function() end
      SetCVar('showArenaEnemyFrames', '0', 'SHOW_ARENA_ENEMY_FRAMES_TEXT')
    elseif(unit:match('nameplate%d+$')) then
      local frame = C_NamePlate.GetNamePlateForUnit(unit)
      if(frame and frame.UnitFrame) then
        handleFrame(frame.UnitFrame)
      end
    end
  end
end

local Table_Insert = table.insert
local Table_Remove = table.remove
local Table_Sort = table.sort
local Math_Floor = math.floor
local Math_Abs = math.abs
local Math_Ceil = math.ceil
local Math_Max = math.max
local Math_Min = math.min
local ClassColor
local PowerColor
local DebuffColor
do
	local COLOR_CLASS
	local COLOR_POWER
	local COLOR_DEBUFF
	local default = { 0.5, 0.5, 0.5 }
	do
		function copyColors(src, dst)
			for key, value in pairs(src) do
				if not dst[key] then
					dst[key] = { value.r, value.g, value.b }
				end
			end
			return dst
		end
		COLOR_POWER = copyColors(PowerBarColor, {
			MANA = { 0.31, 0.45, 0.63 }
		})
		COLOR_CLASS = copyColors(RAID_CLASS_COLORS, {})
		COLOR_DEBUFF = copyColors(DebuffTypeColor, {})
	end
	function ClassColor(unit)
		local color = COLOR_CLASS[select(2, UnitClass(unit))]
		if not color then
			return default
		end
		return color
	end
	function PowerColor(unit)
		local color = COLOR_POWER[select(2, UnitPowerType(unit))]
		if not color then
			return default
		end
		return color
	end
	function DebuffColor(kind)
		local color = COLOR_DEBUFF[kind]
		if not color then
			return default
		end
		return color
	end
end
local function ToggleVisible(frame, condition)
	if condition then
		frame:Show()
	else
		frame:Hide()
	end
end
local function Stack(self, P, R, X, Y, p, r, x, y, ...)
	local anchor
	for i = 1, select("#", ...) do
		local icon = select(i, ...)
		if icon:IsShown() then
			if anchor == nil then
				icon:SetPoint(P, self, R, X, Y)
			else
				icon:SetPoint(p, anchor, r, x, y)
			end
			anchor = icon
		end
	end
end
local function CountVisible(...)
	local n = 0
	for i = 1, select("#", ...) do
		if not select(i, ...):IsShown() then
			break
		end
		n = n + 1
	end
	return n
end
local MEDIA = {}
do
	local bgFlat = [[Interface\Addons\Squish\media\backdrop.tga]]
	local edgeFile = [[Interface\Addons\Squish\media\edgeFile.tga]]
	local barFlat = [[Interface\Addons\Squish\media\flat.tga]]
	local barMini = [[Interface\Addons\Squish\media\minimalist.tga]]
	local vixar = [[interface\addons\squish\media\vixar.ttf]]
	function MEDIA:BACKDROP(bg, edge, edgeSize, inset, right, top, bottom)
		return {
			bgFile = bg and bgFlat,
			edgeFile = edge and edgeFile,
			edgeSize = edgeSize,
			insets = {
				left = inset,
				right = (right or inset),
				top = (top or inset),
				bottom = (bottom or inset)
			}
		}
	end
	function MEDIA:STATUSBAR(mini)
		if mini then
			return barMini
		end
		return barFlat
	end
	function MEDIA:FONT()
		return vixar
	end
end
--local function OnEvent_PlayerTarget(self, event)
--local guid = UnitGUID("playertarget")
--local header = self.header
--if guid then
--for index = 1, #header do
--if header[index].guid == guid then
--self.playerTargetAlpha(1)
--return self.playerTargetPosition(index)
--end
--end
--end
--self.playerTargetAlpha(0)
--end
--self:UnregisterAllEvents()
---- self:RegisterEvent("UNIT_AURA")
---- self:RegisterEvent("UNIT_SPELLCAST_START")
---- self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
--self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
--self:SetScript("OnEvent", OnEvent_SpellCollector)
--local OnEvent_SpellCollector
--do
----SquishData.TEST = nil
----SquishData.SCAN = {}
----GetInstanceInfo()
--local function GetEntry(tbl, key)
--if not tbl[key] then
--tbl[key] = {}
--end
--return tbl[key]
--end
--local function IncEntry(tbl, key)
--tbl[key] = (tbl[key] or 0) + 1
--end
--local function OnEvent_CEUF(_, event, _, sourceGUID, sourceName, sourceFlag, _, destGUID, destName, destFlag, _, spellID, spellName)
--if not spellID or not spellName then
--print("skip", event, spellID, spellName)
--return
--end
--local db = GetEntry(SquishData.SCAN, spellID)
--IncEntry(db, event)
--IncEntry(GetEntry(db, 'sourceFlag'), sourceFlag)
--IncEntry(GetEntry(db, 'destFlag'), destFlag)
--if sourceGUID and sourceGUID ~= " " and bit.band(sourceFlag, COMBATLOG_OBJECT_CONTROL_PLAYER) > 0 then
--local _, sourceClass = GetPlayerInfoByGUID(sourceGUID)
--if sourceClass then
--IncEntry(GetEntry(db, 'sourceClass'), sourceClass)
--end
--end
--if destGUID and destGUID ~= " " and bit.band(destFlag, COMBATLOG_OBJECT_CONTROL_PLAYER) > 0 then
--local _, destFlag = GetPlayerInfoByGUID(destGUID)
--if destClass then
--IncEntry(GetEntry(db, 'destClass'), destClass)
--end
--end
--end
--function OnEvent_SpellCollector(self, event, ...)
--OnEvent_CEUF(CombatLogGetCurrentEventInfo())
--end
--end
local function RangeChecker(self)
	if UnitIsConnected(self.unit) then
		local close, checked = UnitInRange(self.unit)
		if checked and not close then
			self:SetAlpha(0.45)
		else
			self:SetAlpha(1.0)
		end
		-- self:SetAlpha(0.45)
	else
		self:SetAlpha(1.0)
	end
end
local function HookSpellBookTooltips()
	local fn = GameTooltip.SetSpellBookItem
	function GameTooltip:SetSpellBookItem(...)
		local _, id = GetSpellBookItemInfo(...)
		fn(GameTooltip, ...)
		GameTooltip:AddLine("ID: " .. tostring(id), 1, 1, 1)
	end
end
local function ScanGameTooltips()
	local mt = getmetatable(GameTooltip).__index
	for k, v in pairs(mt) do
		if string.sub(k, 1, 3) == "Set" then
			print(k)
		end
	end
end
local Spring = CreateFrame("frame")
do
	local FPS = 60
	local MPF = 1000 / FPS
	local SPF = MPF / 1000
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
		for i = 0, frames - 1 do
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
local DisableBlizzard
do
	-- https://github.com/oUF-wow/oUF/blob/master/blizzard.lua
	local MAX_ARENA_ENEMIES = MAX_ARENA_ENEMIES or 5
	local MAX_BOSS_FRAMES = MAX_BOSS_FRAMES or 5
	local MAX_PARTY_MEMBERS = MAX_PARTY_MEMBERS or 4
	local hiddenParent = CreateFrame("Frame", nil, UIParent)
	hiddenParent:SetAllPoints()
	hiddenParent:Hide()
	local function handleFrame(baseName)
		local frame
		if type(baseName) == "string" then
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
	function DisableBlizzard(unit)
		if not unit then return end
		if (unit == "player") then
			handleFrame(PlayerFrame)
			PlayerFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
			PlayerFrame:RegisterEvent("UNIT_ENTERING_VEHICLE")
			PlayerFrame:RegisterEvent("UNIT_ENTERED_VEHICLE")
			PlayerFrame:RegisterEvent("UNIT_EXITING_VEHICLE")
			PlayerFrame:RegisterEvent("UNIT_EXITED_VEHICLE")
			PlayerFrame:SetUserPlaced(true)
			PlayerFrame:SetDontSavePosition(true)
		elseif (unit == "pet") then
			handleFrame(PetFrame)
		elseif (unit == "target") then
			handleFrame(TargetFrame)
			handleFrame(ComboFrame)
		elseif (unit == "focus") then
			handleFrame(FocusFrame)
			handleFrame(TargetofFocusFrame)
		elseif (unit == "targettarget") then
			handleFrame(TargetFrameToT)
		elseif unit:match("boss%d?$") then
			local id = unit:match("boss(%d)")
			if id then
				handleFrame("Boss" .. id .. "TargetFrame")
			else
				for i = 1, MAX_BOSS_FRAMES do
					handleFrame(string.format("Boss%dTargetFrame", i))
				end
			end
		elseif unit:match("party%d?$") then
			local id = unit:match("party(%d)")
			if id then
				handleFrame("PartyMemberFrame" .. id)
			else
				for i = 1, MAX_PARTY_MEMBERS do
					handleFrame(string.format("PartyMemberFrame%d", i))
				end
			end
		elseif unit:match("arena%d?$") then
			local id = unit:match("arena(%d)")
			if id then
				handleFrame("ArenaEnemyFrame" .. id)
			else
				for i = 1, MAX_ARENA_ENEMIES do
					handleFrame(string.format("ArenaEnemyFrame%d", i))
				end
			end
			-- Blizzard_ArenaUI should not be loaded
			Arena_LoadUI = function() end
			SetCVar("showArenaEnemyFrames", "0", "SHOW_ARENA_ENEMY_FRAMES_TEXT")
		elseif unit:match("nameplate%d+$") then
			local frame = C_NamePlate.GetNamePlateForUnit(unit)
			if (frame and frame.UnitFrame) then
				handleFrame(frame.UnitFrame)
			end
		end
	end
end
local function AuraTable_Clear(tbl)
	tbl.starts = 1
	tbl.cursor = 0
	tbl.offset = 1000
end
local AuraTable_Insert
do
	local function write(t, offset, ...)
		local l = select("#", ...)
		for i = 1, l do
			t[offset + i] = select(i, ...)
		end
		return l
	end
	function AuraTable_Insert(t, priority, ...)
		for i = 1, t.cursor do
			if priority > t[t[i]] then
				t.cursor = t.cursor + 1
				Table_Insert(t, i, t.offset)
				t.offset = t.offset + write(t, t.offset - 1, priority, ...)
				return
			end
		end
		t.cursor = t.cursor + 1
		t[t.cursor] = t.offset
		t.offset = t.offset + write(t, t.offset - 1, priority, ...)
	end
end
local AuraTable_Write
do
	local function OnUpdate(self, elapsed)
		self.value = self.value - elapsed
		self:SetValue(self.value)
		if self.time then
			if self.value > 1 then
				self.time:SetText(Math_Ceil(self.value))
			else
				self.time:SetText(Math_Ceil(self.value * 10) / 10)
			end
		end
	end
	function AuraTable_Write(t, unit, filter, ...)
		local l = select("#", ...)
		local i = 1
		local j = 1
		while (i <= l) do
			local button = select(i, ...)
			if t.cursor >= j then
				local offset = t[j]
				if not button.priority or button.priority <= t[offset] then
					button:Show()
					button.unit = unit
					button.index = t[offset + 1]
					button.filter = filter
					button.texture:SetTexture(t[offset + 2])
					button.value = t[offset + 4] - GetTime()
					button:SetMinMaxValues(0, t[offset + 3])
					local kind = t[offset + 5]
					if kind then
						local r, g, b = unpack(DebuffColor(kind))
						button:SetBackdropColor(r, g, b, 0.75)
						button:SetStatusBarColor(r, g, b, 0.75)
					else
						button:SetBackdropColor(0, 0, 0, 0.75)
						button:SetStatusBarColor(0, 0, 0, 0.75)
					end
					if button.stack then
						local count = t[offset + 6]
						if count > 0 then
							button.stack:SetText(count)
							button.stack:Show()
						else
							button.stack:Hide()
						end
					end
					button:SetScript("OnUpdate", OnUpdate)
					j = j + 1 -- next value
				else
					button:Hide()
					button:SetScript("OnUpdate", nil)
				end
			else
				button:Hide()
				button:SetScript("OnUpdate", nil)
			end
			i = i + 1 -- next button
		end
	end
end
local Ticker = {}
do
	Ticker.__frame = CreateFrame("frame", nil, UIParent)
	Ticker.__index = Ticker
	local msWait = 1.0
	local cursor
	local elapsed
	local function OnUpdate_Ticker(self, e)
		elapsed = elapsed + e
		if elapsed < msWait then return end
		elapsed = 0
		local tbl = Ticker[cursor]
		cursor = cursor - 1
		tbl:__tick()
	end
	Table_Insert(Ticker, Ticker)
	function Ticker:__tick()
		cursor = #self
		msWait = 1.0 / cursor
	end
	function Ticker:Remove(tbl)
		for index = 1, #self do
			if tbl == self[index] then
				Table_Remove(self, index)
				if cursor >= index then
					cursor = cursor - 1
				end
				break
			end
		end
		for index = 1, #self do
			assert(self[index] ~= tbl)
		end
		if #self == 1 then
			self.__frame:SetScript("OnUpdate", nil)
		end
	end
	function Ticker:Add(tbl, doUpdate)
		for index = 1, #self do
			assert(self[index] ~= tbl)
		end
		if #self == 1 then
			elapsed = 0
			cursor = 2
			self.__frame:SetScript("OnUpdate", OnUpdate_Ticker)
		end
		Table_Insert(self, tbl)
		if doUpdate then
			tbl:__tick()
		end
	end
end
local Queue = CreateFrame("frame", nil, UIParent)
do
	local function OnUpdate_Queue(self, elapsed)
		self[1].__delay = self[1].__delay - elapsed
		if self[1].__delay < 0 then
			if #self > 1 then
				self[2].__delay = self[2].__delay + self[1].__delay
			end
			local tbl = self[1]
			Table_Remove(self, 1)
			tbl:__tick()
			if #self == 0 then
				self:SetScript("OnUpdate", nil)
			end
		end
	end
	function Queue:Insert(tbl, delay)
		if #self == 0 then
			self:SetScript("OnUpdate", OnUpdate_Queue)
		end
		tbl.__delay = delay
		for i = 1, #self do
			if tbl.__delay < self[i].__delay then
				self[i].__delay = self[i].__delay - tbl.__delay
				Table_Insert(self, i, tbl)
				return
			else
				tbl.__delay = tbl.__delay - self[i].__delay
			end
		end
		Table_Insert(self, tbl)
	end
	function Queue:Remove(tbl)
		for i = 1, #self do
			if tbl == self[i] then
				if i < #self then
					self[i + 1].__delay = self[i + 1].__delay + tbl.__delay
				end
				Table_Remove(self, i)
				break
			end
		end
		if #self == 0 then
			self:SetScript("OnUpdate", nil)
		end
	end
end
local CanDispel = CreateFrame("frame")
CanDispel:RegisterEvent("PLAYER_ENTERING_WORLD")
CanDispel:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
CanDispel:SetScript("OnEvent", function(self)
	local class = UnitClass("player")
	for i = 1, #self do
		self[self[i]] = false
	end
	if class == "Priest" then
		if IsSpellKnown(527) then
			self.Magic = true
			self.Disease = true
		else
			self.Disease = true
		end
	else
		print("unhandled dispel", class)
	end
end)
Table_Insert(CanDispel, "Magic")
Table_Insert(CanDispel, "Disease")
Table_Insert(CanDispel, "Curse")
Table_Insert(CanDispel, "Poison")
local OnAttributeChanged
do
	local function UpdateGUID(self, guid)
		if self.guid == guid then return
		elseif self.guid == nil then
			self.guid = guid
			self:handler("GUID_SET", guid)
		elseif guid ~= nil then
			local old = self.guid
			self.guid = guid
			self:handler("GUID_MOD", guid, old)
		else
			local old = self.guid
			self.guid = nil
			self:handler("GUID_REM", old)
		end
	end
	local function OnEvent_Player(self, event, ...)
		if event == "PLAYER_ENTERING_WORLD" then
			assert(self.unit == "player")
			UpdateGUID(self, UnitGUID("player"))
		end
		self:handler(event, ...)
	end
	local function OnEvent_Target(self, event, ...)
		if event == "PLAYER_TARGET_CHANGED" then
			assert(self.unit == "target")
			UpdateGUID(self, UnitGUID("target"))
		end
		self:handler(event, ...)
	end
	local function OnEvent_Group(self, event, ...)
		if event == "GROUP_ROSTER_UPDATE" then
			UpdateGUID(self, UnitGUID(self.unit))
		end
		self:handler(event, ...)
	end
	local function OnEvent_Mouse()
	end
	local function OnEvent_Focus()
	end
	local function OnEvent_Boss()
	end
	local function OnEvent_Arena()
	end
	local function OnUpdate_Target()
	end
	local function SetGUIDChangeEvents(self, unit)
		if unit == "player" then
			self:RegisterEvent("PLAYER_ENTERING_WORLD")
			self:SetScript("OnEvent", OnEvent_Player)
		elseif unit == "target" then
			self:RegisterEvent("PLAYER_TARGET_CHANGED")
			self:SetScript("OnEvent", OnEvent_Target)
		elseif unit:match("raid%d?$") or unit:match("party%d?$") then
			self:RegisterEvent("GROUP_ROSTER_UPDATE")
			self:SetScript("OnEvent", OnEvent_Group)
		elseif unit == "mouseover" then
			self:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
			self:SetScript("OnEvent", OnEvent_Mouse)
		elseif unit == "focus" then
			self:RegisterEvent("PLAYER_FOCUS_CHANGED")
			self:SetScript("OnEvent", OnEvent_Focus)
		elseif unit:match("boss%d?$") then
			self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
			self:RegisterEvent("UNIT_TARGETABLE_CHANGED")
			self:SetScript("OnEvent", OnEvent_Boss)
		elseif unit:match("arena%d?$") then
			self:RegisterEvent("ARENA_OPPONENT_UPDATE")
			self:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")
			self:SetScript("OnEvent", OnEvent_Arena)
		elseif unit:match("%w+target") then
			self:SetScript("OnUpdate", OnUpdate_Target)
		else
			print("SetGUIDChangeEvents uncatched", unit)
		end
	end
	local function RemGUIDChangeEvents(self, unit)
		if unit == "player" then
			self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		elseif unit == "mouseover" then
			self:UnregisterEvent("UPDATE_MOUSEOVER_UNIT")
		elseif unit == "target" then
			self:UnregisterEvent("PLAYER_TARGET_CHANGED")
		elseif unit:match("raid%d?$") or unit:match("party%d?$") then
			self:UnregisterEvent("GROUP_ROSTER_UPDATE")
		elseif unit == "focus" then
			self:UnregisterEvent("PLAYER_FOCUS_CHANGED")
		elseif unit:match("boss%d?$") then
			self:UnregisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
			self:UnregisterEvent("UNIT_TARGETABLE_CHANGED")
		elseif unit:match("arena%d?$") then
			self:UnregisterEvent("ARENA_OPPONENT_UPDATE")
			self:UnregisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")
		elseif unit:match("%w+target") then
			self:SetScript("OnUpdate", nil)
			return
		else
			print("RemGUIDChangeEvents uncatched", unit)
		end
		self:SetScript("OnEvent", nil)
	end
	function OnAttributeChanged(self, key, val)
		if key ~= "unit" or self.unit == val then return
		elseif self.unit == nil then
			SetGUIDChangeEvents(self, val)
			self.unit = val
			self:handler("UNIT_SET", val)
			UpdateGUID(self, UnitGUID(val))
		elseif val ~= nil then
			RemGUIDChangeEvents(self, self.unit)
			SetGUIDChangeEvents(self, val)
			local old = self.unit
			self.unit = val
			self:handler("UNIT_MOD", val, old)
			UpdateGUID(self, UnitGUID(val))
		else
			RemGUIDChangeEvents(self, self.unit)
			local old = self.unit
			self.unit = nil
			self:handler("UNIT_REM", nil)
			UpdateGUID(self, nil)
		end
	end
end
local CreateCastBar
do
	local function OnUpdate_Casting(self, elapsed)
		self.elapsed = self.elapsed + elapsed
		self.bar:SetValue(self.elapsed)
	end
	local function OnUpdate_Channel(self, elapsed)
		self.elapsed = self.elapsed - elapsed
		self.bar:SetValue(self.elapsed)
	end
	local function OnUpdate_Fading(self, elapsed)
		self.delay = self.delay - elapsed
		local v = math.min(self.delay * 2, 1)
		self:SetAlpha(v * v)
		if self.delay <= 0 then
			self:SetScript("OnUpdate", nil)
		end
	end
	local function OnEvent(self, event, unit, castID, spellID)
		if not UnitExists(self.unit) then
			self:Hide()
			self.castID = nil
			self.spellID = nil
			self:SetAlpha(0)
			self:SetScript("OnUpdate", nil)
			self:UnregisterEvent("UNIT_SPELLCAST_START")
			self:UnregisterEvent("UNIT_SPELLCAST_DELAYED")
			self:UnregisterEvent("UNIT_SPELLCAST_STOP")
			self:UnregisterEvent("UNIT_SPELLCAST_INTERRUPTED")
			self:UnregisterEvent("UNIT_SPELLCAST_FAILED")
			self:UnregisterEvent("UNIT_SPELLCAST_INTERRUPTIBLE")
			self:UnregisterEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE")
			self:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_START")
			self:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE")
			self:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
		elseif event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_DELAYED" then
			local name, _, texture, sTime, eTime, _, castID, shield, spellID = UnitCastingInfo(self.unit)
			if name then
				self.delay = 1
				self.castID = castID
				self.spellID = spellID
				self.duration = (eTime - sTime) / 1000
				self.elapsed = GetTime() - (sTime / 1000)
				self.bar:SetStatusBarColor(1.0, 0.7, 0.0)
				self.bar:SetMinMaxValues(0, self.duration)
				self.bar:SetValue(self.elapsed)
				self.icon:SetTexture(texture)
				self.text:SetText(name)
				if shield then
					self.shield:Show()
				else
					self.shield:Hide()
				end
				self:SetAlpha(1.0)
				self:SetScript("OnUpdate", OnUpdate_Casting)
				return true
			end
		elseif event == "UNIT_SPELLCAST_CHANNEL_START" or event == "UNIT_SPELLCAST_CHANNEL_UPDATE" then
			local name, _, texture, sTime, eTime, _, _, shield = UnitChannelInfo(self.unit)
			if name then
				self.delay = 1
				self.duration = (eTime - sTime) / 1000
				self.elapsed = self.duration - (GetTime() - (sTime / 1000))
				self.bar:SetStatusBarColor(1.0, 0.7, 0.0)
				self.bar:SetMinMaxValues(0, self.duration)
				self.bar:SetValue(self.elapsed)
				self.icon:SetTexture(texture)
				self.text:SetText(name)
				if shield then
					self.shield:Show()
				else
					self.shield:Hide()
				end
				self:SetAlpha(1.0)
				self:SetScript("OnUpdate", OnUpdate_Channel)
			end
		elseif event == "UNIT_SPELLCAST_INTERRUPTIBLE" then
			if self.castID == castID then
				self.shield:Hide()
			end
		elseif event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE" then
			if self.castID == castID then
				self.shield:Show()
			end
		elseif event == "UNIT_SPELLCAST_INTERRUPTED" then
			if self.castID == castID then
				self.bar:SetStatusBarColor(1.0, 0.0, 0.0)
				self.text:SetText("Interrupted")
				self.delay = 1.5
			end
		elseif event == "UNIT_SPELLCAST_FAILED" then
			if self.castID == castID then
				self.bar:SetStatusBarColor(1.0, 0.0, 0.0)
				self.text:SetText("Failed")
				self.delay = 1.5
			end
		elseif event == "UNIT_SPELLCAST_CHANNEL_STOP" then
			if self.castID == castID then
				self.castID = nil
				self.bar:SetValue(0)
				self:SetScript("OnUpdate", OnUpdate_Fading)
			end
		elseif event == "UNIT_SPELLCAST_STOP" then
			if self.castID == castID then
				self.castID = nil
				self.bar:SetValue(self.duration)
				self:SetScript("OnUpdate", OnUpdate_Fading)
			end
		else
			self:Show()
			self:RegisterUnitEvent("UNIT_SPELLCAST_START", self.unit)
			self:RegisterUnitEvent("UNIT_SPELLCAST_DELAYED", self.unit)
			self:RegisterUnitEvent("UNIT_SPELLCAST_STOP", self.unit)
			self:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTEd", self.unit)
			self:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", self.unit)
			self:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTIBLE", self.unit)
			self:RegisterUnitEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE", self.unit)
			self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", self.unit)
			self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", self.unit)
			self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", self.unit)
			if not OnEvent(self, "UNIT_SPELLCAST_START") then
				OnEvent(self, "UNIT_SPELLCAST_CHANNEL_START")
			end
		end
	end
	function CreateCastBar(parent, unit, height)
		local self = CreateFrame("frame", nil, parent, "SecureHandlerStateTemplate,BackdropTemplate")
		self:SetBackdrop(MEDIA:BACKDROP(true, false, 0, -1))
		self:SetBackdropColor(0, 0, 0, 0.75)
		self:SetHeight(height)
		self:SetAlpha(0)
		self.icon = self:CreateTexture()
		self.icon:SetPoint("TOPLEFT", 0, 0)
		self.icon:SetPoint("BOTTOMRIGHT", self, "BOTTOMLEFT", height, 0)
		self.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		self.bar = CreateFrame("statusbar", nil, self)
		self.bar:SetPoint("TOPLEFT", height + 1, 0)
		self.bar:SetPoint("BOTTOMRIGHT", 0, 0)
		self.bar:SetStatusBarTexture(MEDIA:STATUSBAR())
		self.shield = self.bar:CreateTexture(nil, "OVERLAY")
		self.shield:SetPoint("CENTER", self.icon, "CENTER", height * 0.55, -height * 0.05)
		self.shield:SetSize(height * 3, height * 3)
		self.shield:SetTexture([[Interface\CastingBar\UI-CastingBar-Arena-Shield]])
		self.text = self.bar:CreateFontString(nil, nil, "GameFontNormal")
		self.text:SetPoint("CENTER", -(height / 2), 0)
		self.text:SetFont(MEDIA:FONT(), 14, "OUTLINE")
		self.unit = unit
		self:RegisterUnitEvent("UNIT_SPELLCAST_START", self.unit)
		self:RegisterUnitEvent("UNIT_SPELLCAST_DELAYED", self.unit)
		self:RegisterUnitEvent("UNIT_SPELLCAST_STOP", self.unit)
		self:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", self.unit)
		self:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", self.unit)
		self:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTIBLE", self.unit)
		self:RegisterUnitEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE", self.unit)
		self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", self.unit)
		self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", self.unit)
		self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", self.unit)
		self:RegisterEvent("PLAYER_ENTERING_WORLD")
		if unit == "target" then
			self:RegisterEvent("PLAYER_TARGET_CHANGED")
		elseif unit:match("raid%d?$") or unit:match("party%d?$") then
			self:RegisterEvent("GROUP_ROSTER_UPDATE")
		elseif unit == "mouseover" then
			self:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
		elseif unit == "focus" then
			self:RegisterEvent("PLAYER_FOCUS_CHANGED")
		elseif unit:match("boss%d?$") then
			self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
			self:RegisterEvent("UNIT_TARGETABLE_CHANGED")
		elseif unit:match("arena%d?$") then
			self:RegisterEvent("ARENA_OPPONENT_UPDATE")
			self:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")
		end
		self:SetScript("OnEvent", OnEvent)
		return self
	end
end
local function CreateAuraIcon(parent, size)
	local icon = CreateFrame("frame", nil, parent, "BackdropTemplate")
	icon:SetBackdrop(MEDIA:BACKDROP(true, true, 1, -4))
	icon:SetBackdropColor(0, 0, 0, 0)
	icon:SetBackdropBorderColor(0, 0, 0, 0.75)
	icon:SetSize(size, size)
	icon.texture = icon:CreateTexture()
	icon.texture:SetPoint("TOPLEFT", 1, -1)
	icon.texture:SetPoint("BOTTOMRIGHT", -1, 1)
	icon.texture:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	icon.cd = CreateFrame("cooldown", nil, icon, "CooldownFrameTemplate")
	return icon
end
local function CreateAuraIcon_Bar(parent, size, timeSize, stackSize)
	local icon = CreateFrame("statusbar", nil, parent, "BackdropTemplate")
	icon:SetBackdrop(MEDIA:BACKDROP(true, false, 0, 0))
	icon:SetStatusBarTexture(MEDIA:STATUSBAR())
	icon:SetSize(size, size)
	icon:SetBackdropColor(0, 0, 0, 0.75)
	icon:SetStatusBarColor(0, 0, 0, 0.5)
	icon:SetOrientation("VERTICAL")
	icon.texture = icon:CreateTexture(nil, "BACKGROUND", nil, 7)
	icon.texture:SetPoint("TOPLEFT", 1, -1)
	icon.texture:SetPoint("BOTTOMRIGHT", -1, 1)
	icon.texture:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	if timeSize then
		icon.time = icon:CreateFontString(nil, nil, "GameFontNormal")
		icon.time:SetFont(MEDIA:FONT(), timeSize or 18, "OUTLINE")
		icon.time:SetPoint("CENTER", 0, 0)
		icon.time:SetTextColor(1, 1, 1, 1)
	end
	if stackSize then
		icon.stack = icon:CreateFontString(nil, nil, "GameFontNormal")
		icon.stack:SetFont(MEDIA:FONT(), stackSize or 18, "OUTLINE")
		icon.stack:SetPoint("BOTTOMRIGHT", -4, 4)
		icon.stack:SetTextColor(1, 1, 1, 1)
		icon.stack:SetText(4)
	end
	icon:SetScript("OnEnter", OnEnter_AuraButton)
	icon:SetScript("OnLeave", OnLeave_AuraButton)
	return icon
end
local function UpdateRoleIcon(element, role)
	if role ~= "NONE" then -- == 'TANK' or role == 'HEALER' then
		--element:SetTexCoord(GetTexCoordsForRole(role))
		element:SetTexCoord(GetTexCoordsForRoleSmallCircle(role))
		element:Show()
	else
		element:Hide()
	end
end
local function UpdateRaidIcon(element, index)
	if index then
		SetRaidTargetIconTexture(element, index)
		element:Show()
	else
		element:Hide()
	end
end
local function SetUnitStatus(element, dead, ghost, connected)
	if dead then
		element:SetText("dead")
	elseif ghost then
		element:SetText("ghost")
	elseif not connected then
		element:SetText("offline")
	else
		element:SetText("")
	end
end
local function SetUnitClassification(element, classification)
	if classification == "rare" then
		element:SetText("Rare")
	elseif classification == "rareelite" then
		element:SetText("Rare Elite")
	elseif classification == "elite" then
		element:SetText("Elite")
	elseif classification == "worldboss" then
		element:SetText("Boss")
	elseif classification == "minus" then
		element:SetText("Affix")
	else
		element:SetText("")
	end
end
local SPELLS = {}
local SPELLS_SOURCE_VALUES = { "UNIT_AURA_HELPFUL", "UNIT_AURA_HARMFUL" }
local SPELLS_CLASS_VALUES = {}
for i = 1, #CLASS_SORT_ORDER do
	Table_Insert(SPELLS_CLASS_VALUES, CLASS_SORT_ORDER[i])
end
Table_Insert(SPELLS_CLASS_VALUES, "HOSTILE")
Table_Insert(SPELLS_CLASS_VALUES, "OTHER")
RAID_CLASS_COLORS.HOSTILE = {
	r = 0.7,
	g = 0.5,
	b = 0.3
}
RAID_CLASS_COLORS.OTHER = {
	r = 0.3,
	g = 0.5,
	b = 0.7
}
local SPELLS_STATUS_NEGATIVE_FIELD_SOURCE = 1
local SPELLS_STATUS_NEGATIVE_FIELD_PRIORITY = 2
SPELLS.StatusNegative = {
	[243237] = { 2, 5 }, -- M+ Affix Bursting
	[240559] = { 2, 5 }, -- M+ Affix Grievous Wound
	[226512] = { 2, 5 } -- M+ Affix Sanguine
}
local SPELLS_STATUS_POSITIVE_FIELD_SOURCE = 1
local SPELLS_STATUS_POSITIVE_FIELD_PRIORITY = 2
local SPELLS_STATUS_POSITIVE_FIELD_CLASS = 3
local SPELLS_STATUS_POSITIVE_FIELD_NOTES = 4
SPELLS.StatusPositive = {
	-- WARRIOR
	[184364] = { 1, 1, 1, "war" },
	[97463] = { 1, 1, 1, "war" },
	[23920] = { 1, 1, 1, "war" },
	[12975] = { 1, 1, 1, "war" },
	[197690] = { 1, 1, 1, "war" },
	[118038] = { 1, 1, 1, "war" },
	[871] = { 1, 1, 1, "war" },
	[190456] = { 1, 1, 1, "war" },
	-- DEATHKNIGHT
	[48792] = { 1, 1, 2, "dk" },
	[194679] = { 1, 1, 2, "dk" },
	[48743] = { 2, 1, 2, "dk" },
	[48707] = { 1, 1, 2, "dk" },
	[81256] = { 1, 1, 2, "dk" },
	[55233] = { 1, 1, 2, "dk" },
	[219809] = { 1, 1, 2, "dk" },
	-- PALADIN
	[6940] = { 1, 1, 3 },
	[498] = { 1, 1, 3 },
	[86659] = { 1, 1, 3 },
	[642] = { 1, 1, 3 },
	[1022] = { 1, 1, 3 },
	[1044] = { 1, 1, 3 },
	[31850] = { 1, 1, 3 },
	[204018] = { 1, 1, 3 },
	[184662] = { 1, 1, 3 },
	[205191] = { 1, 1, 3 },
	-- MONK
	[201325] = { 1, 1, 4 },
	[122783] = { 1, 1, 4 },
	[116849] = { 1, 1, 4 },
	[122278] = { 1, 1, 4 },
	[120954] = { 1, 1, 4 },
	[115176] = { 1, 1, 4 },
	[243435] = { 1, 1, 4 },
	-- DRUID
	[192081] = { 1, 1, 7 },
	[22842] = { 1, 1, 7 },
	[102558] = { 1, 1, 7 },
	[102342] = { 1, 1, 7 },
	[61336] = { 1, 1, 7 },
	[22812] = { 1, 1, 7 },
	-- DEMONHUNTER
	[187827] = { 1, 1, 12 },
	[196555] = { 1, 1, 12 },
	[203819] = { 1, 1, 12 },
	[162264] = { 1, 1, 12 },
	[212800] = { 1, 1, 12 }
}
SPELLS.CooldownRotation = { 47540, 8092, 32379, 129250, 34433, 194509, { -- penance -- mind blast -- shadow word: death -- power word: solace -- shadowfiend -- power word: radiance
	id = 128318,
	item = true
} } -- leveling trinket
SPELLS.CooldownSituational = { 19236, 8122, 33206, 62618, 47536 } -- desperate prayer -- psychic scream -- painsup -- power word: barrier -- rapture
SPELLS.CooldownOther = { 32375, 586, 73325, 605, 121536, 527 } -- mass dispel -- fade -- leap of faith -- mind control -- angelic feather -- purify
do
	local function InitClassFilter(self)
		self.info.text = "All"
		self.info.checked = self.selected == 0
		self.info.value = 0
		self.info.arg2 = nil
		UIDropDownMenu_AddButton(self.info)
		for index = 1, #SPELLS_CLASS_VALUES do
			self.info.text = SPELLS_CLASS_VALUES[index]
			self.info.checked = index == self.selected
			self.info.value = index
			self.info.arg2 = index
			UIDropDownMenu_AddButton(self.info)
		end
	end
	local function InitSourceDropdown(self)
		for index = 1, #SPELLS_SOURCE_VALUES do
			self.info.text = SPELLS_SOURCE_VALUES[index]
			self.info.checked = index == self.selected
			self.info.arg2 = index
			UIDropDownMenu_AddButton(self.info)
		end
	end
	local function InitClassDropdown(self)
		for index = 1, #SPELLS_CLASS_VALUES do
			self.info.text = SPELLS_CLASS_VALUES[index]
			self.info.checked = index == self.selected
			self.info.arg2 = index
			UIDropDownMenu_AddButton(self.info)
		end
	end
	local function InitOptionsDropdown(self)
		self.info.text = "Delete"
		self.info.notCheckable = true
		self.info.arg2 = "delete"
		UIDropDownMenu_AddButton(self.info)
	end
	--function CreateClassFilter(gui, section, func)
	--local dropdown = gui.menuPool:Acquire()
	--dropdown.Text:SetFont(MEDIA:FONT(), 18)
	--dropdown:SetPoint("BOTTOMRIGHT", section.scroll, "TOPRIGHT", -32, 0)
	--dropdown:SetWidth(200)
	--dropdown:Show()
	--dropdown.initialize = InitClassFilter
	--dropdown.info.func = callback
	--dropdown.info.arg1 = dropdown
	--dropdown.__self = section
	--dropdown.__func = func
	--return dropdown
	--end
	--function CreateOptionsDropdown(dropdown, self, func)
	--dropdown.initialize = InitOptionsDropdown
	--dropdown.info.func = callback
	--dropdown.info.arg1 = dropdown
	--dropdown.__self = self
	--dropdown.__func = func
	--UIDropDownMenu_Initialize(dropdown, dropdown.initialize, "MENU")
	--dropdown.Icon:SetTexture([[Interface\BUTTONS\UI-OptionsButton]])
	--dropdown.Icon:Show()
	--dropdown.Icon:ClearAllPoints()
	--dropdown.Icon:SetPoint("RIGHT", -8, 0)
	--return dropdown
	--end
	local Section_Positive = {
		title = "Positive",
		icon = 134468
	}
	do
		local data = nil
		local UpdateRow
		local lastEdited = nil
		local function OnClick_IncrementPriority(button)
			local row = button:GetParent()
			local index = row:GetIndex()
			local priority = SPELLS.StatusPositive[data[index]][SPELLS_STATUS_POSITIVE_FIELD_PRIORITY]
			SPELLS.StatusPositive[data[index]][SPELLS_STATUS_POSITIVE_FIELD_PRIORITY] = priority + 1
			UpdateRow(nil, row, index)
		end
		local function OnClick_DecrementPriority(button)
			local row = button:GetParent()
			local index = row:GetIndex()
			local priority = SPELLS.StatusPositive[data[index]][SPELLS_STATUS_POSITIVE_FIELD_PRIORITY]
			SPELLS.StatusPositive[data[index]][SPELLS_STATUS_POSITIVE_FIELD_PRIORITY] = Math_Max(1, priority - 1)
			UpdateRow(nil, row, index)
		end
		local function SetClassFilter(self, index)
			SquishData.GUISectionPositive.filterClass = index
			self.classFilter:SetSelectedValue(index or 0)
			self:UpdateData()
		end
		local function SetSource(row, source)
			local index = row:GetIndex()
			SPELLS.StatusPositive[data[index]][SPELLS_STATUS_POSITIVE_FIELD_SOURCE] = source
			UpdateRow(nil, row, index)
		end
		local function SetClass(row, class)
			local index = row:GetIndex()
			SPELLS.StatusPositive[data[index]][SPELLS_STATUS_POSITIVE_FIELD_CLASS] = class
			UpdateRow(nil, row, index)
		end
		local function SetOption(row, value)
			local index = row:GetIndex()
			SPELLS.StatusPositive[data[index]] = nil
			Section_Positive:UpdateData()
		end
		local function SetNotes(input)
			local row = input:GetParent()
			local index = row:GetIndex()
			local value = input:GetText()
			input:ClearFocus()
			input:SetText(input.__initial)
			SPELLS.StatusPositive[data[index]][SPELLS_STATUS_POSITIVE_FIELD_NOTES] = value
			UpdateRow(nil, row, index)
		end
		local function CreateRow(scroll, row, rowIndex)
			Table_Insert(row, row:AcquireIcon())
			Table_Insert(row, row:AcquireFontString(nil, 3))
			Table_Insert(row, row:AcquireFontString(nil, 1, "RIGHT"))
			Table_Insert(row, row:AcquireButton(row:GetHeight(), nil, OnClick_IncrementPriority))
			Table_Insert(row, row:AcquireButton(row:GetHeight(), nil, OnClick_DecrementPriority))
			Table_Insert(row, row:AcquireInput(nil, 3, SetNotes))
			Table_Insert(row, row:AcquireDropdown(250, nil, InitSourceDropdown, row, SetSource))
			Table_Insert(row, row:AcquireFontString(128))
			Table_Insert(row, row:AcquireDropdown(200, nil, InitClassDropdown, row, SetClass))
			Table_Insert(row, row:AcquireDropdown(row:GetHeight(), nil, InitOptionsDropdown, row, SetOption))
			row:StackElements(4, unpack(row))
		end
		function UpdateRow(scroll, row, index)
			local name, _, icon = GetSpellInfo(data[index])
			local source = SPELLS.StatusPositive[data[index]][SPELLS_STATUS_POSITIVE_FIELD_SOURCE]
			local prio = SPELLS.StatusPositive[data[index]][SPELLS_STATUS_POSITIVE_FIELD_PRIORITY]
			local class = SPELLS.StatusPositive[data[index]][SPELLS_STATUS_POSITIVE_FIELD_CLASS]
			local notes = SPELLS.StatusPositive[data[index]][SPELLS_STATUS_POSITIVE_FIELD_NOTES]
			local edited = data[index] == lastEdited
			local ICON, NAME, PRIOVAL, PRIOUP, PRIODN, NOTES, SOURCE, SPELLID, CLASS, _ = unpack(row)
			ICON:SetTexture(icon)
			NAME:SetText(name)
			PRIOVAL:SetText(prio)
			PRIOUP.icon:SetTexture([[Interface\BUTTONS\Arrow-Up-Down]])
			PRIODN.icon:SetTexture([[Interface\BUTTONS\Arrow-Down-Down]])
			NOTES:SetText(notes or "")
			SOURCE:SetSelectedID(source)
			SPELLID:SetText(data[index])
			CLASS:SetSelectedID(class)
			if class then
				local color = RAID_CLASS_COLORS[SPELLS_CLASS_VALUES[class]]
				local alpha = edited and 0.6 or 0.3
				row:SetBackdropColor(color.r, color.g, color.b, alpha)
			end
		end
		local function ReleaseRow(scroll, row)
			while #row > 0 do
				row:ReleaseElement(Table_Remove(row))
			end
		end
		local function SortData(a, b)
			local classA = SPELLS.StatusPositive[a][SPELLS_STATUS_POSITIVE_FIELD_CLASS]
			local classB = SPELLS.StatusPositive[b][SPELLS_STATUS_POSITIVE_FIELD_CLASS]
			if classA == classB then
				local priorityA = SPELLS.StatusPositive[a][SPELLS_STATUS_POSITIVE_FIELD_PRIORITY]
				local priorityB = SPELLS.StatusPositive[b][SPELLS_STATUS_POSITIVE_FIELD_PRIORITY]
				if priorityA == priorityB then
					return a < b
				end
				return priorityA > priorityB
			end
			return classA < classB
		end
		function Section_Positive:UpdateData()
			for k in pairs(data) do
				data[k] = nil
			end
			local filterClass = SquishData.GUISectionPositive.filterClass
			for id, spell in pairs(SPELLS.StatusPositive) do
				if not filterClass or filterClass == spell[SPELLS_STATUS_POSITIVE_FIELD_CLASS] then
					Table_Insert(data, id)
				end
			end
			Table_Sort(data, SortData)
			self.scroll:Init(32, #data, 32)
		end
		local function Footer_Update(header)
			local INPUT, NAME, SOURCE, CLASS, ADD, RESET = unpack(header)
			NAME:SetText(header.__spellName)
			SOURCE:SetSelectedID(header.__source)
			CLASS:SetSelectedID(header.__class)
			ADD:SetText("Add")
			RESET:SetText("Reset")
			if header.__valid then
				ADD:Enable()
				RESET:Enable()
			else
				ADD:Disable()
				RESET:Disable()
			end
		end
		local function Footer_SetSpell(input)
			local value = input:GetText()
			local name, _, _, _, _, _, spellId = GetSpellInfo(value)
			local footer = input:GetParent()
			footer.__spellId = spellId
			footer.__spellName = name
			footer.__valid = name ~= nil
			Footer_Update(footer)
		end
		local function Footer_SetSource(footer, value)
			footer.__source = value
			Footer_Update(footer)
		end
		local function Footer_SetClass(footer, value)
			footer.__class = value
			Footer_Update(footer)
		end
		local function Footer_OnClickReset(button)
			local footer = button:GetParent()
			footer[1]:SetText("")
			footer.__spellName = ""
			footer.__spellId = nil
			footer.__source = 1
			footer.__class = #SPELLS_CLASS_VALUES
			footer.__valid = false
			Footer_Update(footer)
		end
		local function Footer_OnClickAdd(button)
			local footer = button:GetParent()
			local entry = {}
			entry[SPELLS_STATUS_POSITIVE_FIELD_SOURCE] = footer.__source
			entry[SPELLS_STATUS_POSITIVE_FIELD_PRIORITY] = 1
			entry[SPELLS_STATUS_POSITIVE_FIELD_CLASS] = footer.__class
			entry[SPELLS_STATUS_POSITIVE_FIELD_NOTES] = ""
			SPELLS.StatusPositive[footer.__spellId] = entry
			Footer_OnClickReset(button)
			Section_Positive:UpdateData()
		end
		function Section_Positive:Load(gui)
			if not SquishData.GUISectionPositive then
				SquishData.GUISectionPositive = {}
			end
			gui.header:SetText("Status Positive Spells")
			self.scroll = gui.scrollPool:Acquire()
			self.scroll:SetPoint("LEFT", 8, 0)
			self.scroll:SetPoint("RIGHT", -8, 0)
			self.scroll:SetPoint("CENTER", 0, 0)
			self.scroll.CreateRow = CreateRow
			self.scroll.UpdateRow = UpdateRow
			self.scroll.ReleaseRow = ReleaseRow
			self.scroll.cursor = 1
			-- self.classFilter = CreateClassFilter(gui, self, SetClassFilter)
			-- self.classFilter:SetSelectedValue(SquishData.GUISectionPositive.filterClass or 0)
			data = gui.tablePool:Acquire()
			self:UpdateData()
			self.scroll:Show()
			self.footer = self.scroll.rowPool:Acquire()
			self.footer:SetBackdrop(MEDIA:BACKDROP(true, false, 0, -4, -36, -4, -8))
			self.footer:SetBackdropColor(0, 0, 0, 0.75)
			self.footer:SetSize(self.scroll:GetWidth() - 32, 32)
			self.footer:SetPoint("TOPLEFT", self.scroll, "BOTTOMLEFT", 0, -8)
			self.footer:Show()
			self.footer.__spellName = ""
			self.footer.__spellId = nil
			self.footer.__source = 1
			self.footer.__class = #SPELLS_CLASS_VALUES
			self.footer.__valid = false
			Table_Insert(self.footer, self.footer:AcquireInput(nil, 1, Footer_SetSpell))
			Table_Insert(self.footer, self.footer:AcquireFontString(nil, 1))
			Table_Insert(self.footer, self.footer:AcquireDropdown(200, nil, InitSourceDropdown, self.footer, Footer_SetSource))
			Table_Insert(self.footer, self.footer:AcquireDropdown(200, nil, InitClassDropdown, self.footer, Footer_SetClass))
			Table_Insert(self.footer, self.footer:AcquireButton(64, nil, Footer_OnClickAdd))
			Table_Insert(self.footer, self.footer:AcquireButton(64, nil, Footer_OnClickReset))
			self.footer:StackElements(4, unpack(self.footer))
			Footer_Update(self.footer)
		end
		function Section_Positive:Unload(gui)
			data = gui.tablePool:Release(data)
			gui.header:SetText("")
			self.scroll:ReleaseRow(self.footer)
			self.scroll.rowPool:Release(self.footer)
			self.footer = nil
			gui.menuPool:Release(self.classFilter)
			self.classFilter = nil
			gui.scrollPool:Release(self.scroll)
			self.scroll = nil
		end
	end
	local frame = CreateFrame("frame", nil, UIParent, "BackdropTemplate")
	frame:RegisterEvent("VARIABLES_LOADED")
	frame:SetScript("OnEvent", function(self)
		if not SquishData then
			SquishData = {}
		end
		--SquishData = {
		--GUIOpen = true,
		--GUISection = 1,
		--}
		local SELECTED = nil
		local SECTIONS = { Section_Positive }
		self:SetPoint("TOPLEFT", UIParent, "TOP", 0, 0)
		self:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 0)
		self:SetBackdrop(MEDIA:BACKDROP(true, false, 1, 0))
		self:SetBackdropColor(0, 0, 0, 0.7)
		self:EnableMouse(true)
		self:SetFrameStrata("HIGH")
		self:Hide()
		self:SetScale(0.533333333 / UIParent:GetScale())
		self.header = self:CreateFontString(nil, nil, "GameFontNormal")
		self.header:SetFont(MEDIA:FONT(), 22)
		self.header:SetPoint("TOP", 0, -16)
		--self.dropdown = CreateFrame("frame", nil, self, "UIDropDownMenuTemplate")
		do
			local function CreateTable(pool)
				return {}
			end
			local function ResetTable(pool, tbl)
				for k in pairs(tbl) do
					tbl[k] = nil
				end
			end
			self.tablePool = CreateObjectPool(CreateTable, ResetTable)
		end
		do
			local function SetSelectedID(self, index)
				self.selected = index
				UIDropDownMenu_Initialize(self, self.initialize, self.mode)
				UIDropDownMenu_SetSelectedID(self, index)
				--if self.mode then
				--self.Icon:Show()
				--end
			end
			local function SetSelectedValue(self, value)
				self.selected = value
				UIDropDownMenu_Initialize(self, self.initialize, self.mode)
				UIDropDownMenu_SetSelectedValue(self, value)
				--if self.mode then
				--self.Icon:Show()
				--end
			end
			local function CreateMenuFrame(pool)
				local frame = CreateFrame("frame", nil, self, "UIDropDownMenuTemplate,BackdropTemplate")
				frame:SetBackdrop(MEDIA:BACKDROP(true, false, 0, 1))
				frame:SetBackdropColor(0, 0, 0, 0.15)
				frame.Text:ClearAllPoints()
				frame.Text:SetPoint("TOPLEFT", 4, 0)
				frame.Text:SetPoint("BOTTOMRIGHT", -4, 0)
				frame.Text:SetJustifyH("LEFT")
				frame.Button:ClearAllPoints()
				frame.Button:SetPoint("RIGHT", frame, "RIGHT", 0, 0)
				frame.Button:SetScale(1.4)
				frame.Button:Show()
				frame.Left:Hide()
				frame.Middle:Hide()
				frame.Right:Hide()
				frame.info = UIDropDownMenu_CreateInfo()
				frame.SetSelectedID = SetSelectedID
				frame.SetSelectedValue = SetSelectedValue
				return frame
			end
			local function ResetMenuFrame(pool, frame)
				frame.__self = nil
				frame.__func = nil
				frame.mode = nil
				frame.info.notCheckable = nil
				frame:ClearAllPoints()
				frame:Hide()
			end
			self.menuPool = CreateObjectPool(CreateMenuFrame, ResetMenuFrame)
		end
		do
			local function OnEnter_ScrollBar(self)
				self:SetBackdropColor(1.0, 0.5, 0, 0.8)
			end
			local function OnLeave_ScrollBar(self)
				self:SetBackdropColor(1.0, 0.5, 0, 0.3)
			end
			local function UpdateScrollbar(frame)
				frame.scrollbar:SetHeight(Math_Min(1, frame.rowCount / Math_Max(frame.length, 1)) * frame.totHeight)
				frame.scrollbar:SetPoint("TOPRIGHT", -4, (frame.cursor - 1) * -frame.totHeight / Math_Max(frame.length, 1))
			end
			function OnMouseWheel_Scroll(frame, delta)
				if delta < 0 then -- up
					if (frame.cursor - delta) > frame.rowMax then return end
					frame[2]:SetPoint("TOP", frame, "TOP", 0, 0)
					frame[1]:SetPoint("TOP", frame[frame.rowCount], "BOTTOM", 0, -1)
					frame:UpdateRow(frame[1], frame.cursor + frame.rowCount)
					table.insert(frame, frame[1])
					table.remove(frame, 1)
					frame.cursor = frame.cursor - delta
				else
					if (frame.cursor - delta) < 1 then return end
					frame.cursor = frame.cursor - delta
					frame[frame.rowCount]:SetPoint("TOP", frame, "TOP", 0, 0)
					frame[1]:SetPoint("TOP", frame[frame.rowCount], "BOTTOM", 0, -1)
					frame:UpdateRow(frame[frame.rowCount], frame.cursor)
					table.insert(frame, 1, frame[frame.rowCount])
					table.remove(frame)
				end
				UpdateScrollbar(frame)
			end
			local function OnMouseUp_Scrollbar(frame)
				frame:SetScript("OnUpdate", nil)
				frame:SetScript("OnMouseUp", nil)
				frame.__height = nil
				frame.__start = nil
				frame:SetScript("OnLeave", OnLeave_ScrollBar)
				OnLeave_ScrollBar(frame)
			end
			local function OnUpdate_Scrollbar(frame)
				local position = select(2, GetCursorPosition())
				local offset = position - frame.__start
				local delta
				if offset < 0 then
					delta = Math_Ceil(offset / frame.__height)
				else
					delta = Math_Floor(offset / frame.__height)
				end
				if delta ~= 0 then
					frame.__start = frame.__start + delta * frame.__height
					local sign = delta < 0 and -1 or 1
					for i = delta, sign, sign * -1 do
						OnMouseWheel_Scroll(frame:GetParent(), sign)
					end
				end
			end
			local function OnMouseDown_ScrollBar(frame)
				local scroll = frame:GetParent()
				frame.__height = (scroll.totHeight / scroll.length) * UIParent:GetScale()
				frame.__start = select(2, GetCursorPosition())
				frame:SetScript("OnMouseUp", OnMouseUp_Scrollbar)
				frame:SetScript("OnUpdate", OnUpdate_Scrollbar)
				frame:SetScript("OnLeave", nil)
			end
			local rowPool = nil
			local fontPool = nil
			local texturePool = nil
			local buttonPool = nil
			local inputPool = nil
			local function ReleaseIcon(row, icon)
				texturePool:Release(icon)
			end
			local function ReleaseFontString(row, font)
				fontPool:Release(font)
			end
			local function ReleaseButton(row, button)
				buttonPool:Release(button)
			end
			local function ReleaseDropdown(row, dropdown)
				self.menuPool:Release(dropdown)
			end
			local function ReleaseInput(row, input)
				inputPool:Release(input)
			end
			local function ReleaseElement(row, element)
				element.weight = nil
				element.__release(row, element)
				element.__release = nil
			end
			local function AcquireButton(row, width, weight, OnClick, icon)
				local button = buttonPool:Acquire()
				button:SetParent(row)
				button:Show()
				button:SetHeight(row:GetHeight())
				if width then
					button:SetWidth(width)
				else
					button.weight = weight or 1
				end
				if icon then
					button.icon:SetTexture(icon)
				end
				button:SetScript("OnClick", OnClick)
				button.__release = ReleaseButton
				return button
			end
			local AcquireInput
			do
				local function OnEscapePressed(self)
					self:SetText(self.__initial)
					self:ClearFocus()
				end
				local function OnTextSet(self)
					self.__initial = self:GetText()
				end
				local function OnTextChanged(self)
					local dirty = self.__initial ~= self:GetText()
					if dirty then
						self:SetBackdropColor(0, 0, 0, 0.75)
					else
						self:SetBackdropColor(0, 0, 0, 0.15)
					end
				end
				function AcquireInput(row, width, weight, func)
					local input = inputPool:Acquire()
					input:SetParent(row)
					input:Show()
					input:SetHeight(row:GetHeight())
					if width then
						input:SetWidth(width)
					else
						input.weight = weight or 1
					end
					input.__initial = ""
					input:SetScript("OnEscapePressed", OnEscapePressed)
					input:SetScript("OnEnterPressed", func)
					input:SetScript("OnTextChanged", OnTextChanged)
					input:SetScript("OnTextSet", OnTextSet)
					input.__release = ReleaseInput
					return input
				end
			end
			local function AcquireIcon(row)
				local icon = texturePool:Acquire()
				icon:SetParent(row)
				icon:Show()
				local size = row:GetHeight()
				icon:SetSize(size, size)
				icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
				icon.__release = ReleaseIcon
				return icon
			end
			local function AcquireFontString(row, width, weight, justify)
				local font = fontPool:Acquire()
				font:SetParent(row)
				font:Show()
				font:SetHeight(row:GetHeight())
				if width then
					font:SetWidth(width)
				else
					font.weight = weight or 1
				end
				if justify then
					font:SetJustifyH(justify)
				end
				font.__release = ReleaseFontString
				return font
			end
			local AcquireDropdown
			do
				local function callback(_, dropdown, value)
					dropdown.__func(dropdown.__self, value)
				end
				function AcquireDropdown(row, width, weight, initialize, ctx, func)
					local dropdown = self.menuPool:Acquire()
					dropdown.Text:SetFont(MEDIA:FONT(), 14)
					dropdown:SetParent(row)
					dropdown:Show()
					dropdown:SetHeight(row:GetHeight())
					if width then
						dropdown:SetWidth(width)
					else
						dropdown.weight = weight or 1
					end
					dropdown.initialize = initialize
					dropdown.info.func = callback
					dropdown.info.arg1 = dropdown
					dropdown.__self = ctx
					dropdown.__func = func
					dropdown.__release = ReleaseDropdown
					return dropdown
				end
			end
			local function StackElements(row, gap, ...)
				local length = select("#", ...)
				local width = row:GetWidth() - gap * (length - 1)
				local sum = 0
				for i = 1, length do
					local element = select(i, ...)
					if element.weight then
						sum = sum + element.weight
					else
						width = width - element:GetWidth()
					end
				end
				for i = 1, length do
					local element = select(i, ...)
					if i == 1 then
						element:SetPoint("LEFT", row, "LEFT", 0, 0)
					else
						local prev = select(i - 1, ...)
						element:SetPoint("LEFT", prev, "RIGHT", gap, 0)
					end
					if element.weight then
						element:SetWidth(width * (element.weight / sum))
					end
				end
			end
			local function GetRowIndex(self)
				local scroll = self:GetParent()
				for i = 1, #scroll do
					if scroll[i] == self then
						return scroll.cursor + i - 1
					end
				end
				return nil
			end
			local function Init(frame, rows, length, height)
				frame.length = length
				frame.rowCount = rows
				frame.rowHeight = height -- Math_Floor(frame:GetHeight() / rows)
				frame.rowMax = Math_Max(1, length - rows + 1)
				frame.totHeight = frame.rowHeight * rows
				frame.cursor = Math_Max(1, Math_Min(frame.rowMax, frame.cursor))
				frame:SetHeight(rows * height)
				for rowIndex = 1, rows do
					local dataIndex = frame.cursor + rowIndex - 1
					if dataIndex > frame.length then
						while #frame >= rowIndex do
							local row = frame[#frame]
							frame:ReleaseRow(row, #frame)
							rowPool:Release(row)
							Table_Remove(frame)
						end
						break
					end
					local row = frame[rowIndex]
					if rowIndex > #frame then
						row = rowPool:Acquire()
						row:SetParent(frame)
						row:SetPoint("LEFT", 0, 0)
						row:SetPoint("RIGHT", -32, 0)
						row:SetHeight(frame.rowHeight - 1)
						if rowIndex == 1 then
							row:SetPoint("TOP", 0, -1)
						else
							row:SetPoint("TOP", frame[rowIndex - 1], "BOTTOM", 0, -1)
						end
						frame:CreateRow(row, rowIndex)
						row:Show()
						table.insert(frame, row)
					end
					frame:UpdateRow(row, dataIndex)
				end
				UpdateScrollbar(frame)
				if frame.rowMax > 0 then
					frame:SetScript("OnMouseWheel", OnMouseWheel_Scroll)
					frame.scrollbar:SetScript("OnEnter", OnEnter_ScrollBar)
					frame.scrollbar:SetScript("OnLeave", OnLeave_ScrollBar)
					frame.scrollbar:SetScript("OnMouseDown", OnMouseDown_ScrollBar)
				end
			end
			local function CreateScrollFrame(pool)
				local frame = CreateFrame("frame", nil, self, "BackdropTemplate")
				frame:SetBackdrop(MEDIA:BACKDROP(true, nil, 0, -4))
				frame:SetBackdropColor(0, 0, 0, 0.75)
				frame:EnableMouseWheel(true)
				frame.scrollbar = CreateFrame("frame", nil, frame, "BackdropTemplate")
				frame.scrollbar:SetBackdrop(MEDIA:BACKDROP(true, nil, 0, 0))
				frame.scrollbar:SetBackdropColor(1, 0.5, 0, 0.3)
				frame.scrollbar:EnableMouse(true)
				frame.scrollbar:SetWidth(20)
				frame.Init = Init
				if not rowPool then
					rowPool = CreateObjectPool(
						function()
							local frame = CreateFrame("frame", nil, self, "BackdropTemplate")
							frame:SetBackdrop(MEDIA:BACKDROP(true, nil, 0, 0))
							frame.AcquireFontString = AcquireFontString
							frame.AcquireIcon = AcquireIcon
							frame.AcquireInput = AcquireInput
							frame.AcquireButton = AcquireButton
							frame.AcquireDropdown = AcquireDropdown
							frame.ReleaseElement = ReleaseElement
							frame.StackElements = StackElements
							frame.GetIndex = GetRowIndex
							return frame
						end,
						function(_, frame)
							frame:ClearAllPoints()
							frame:SetBackdropColor(1, 0.5, 0, 0.15)
							frame:Hide()
						end
					)
					fontPool = CreateObjectPool(
						function()
							local font = self:CreateFontString(nil, nil, "GameFontNormal")
							font:SetFont(MEDIA:FONT(), 16)
							font:SetJustifyH("LEFT")
							return font
						end,
						function(_, font)
							font:ClearAllPoints()
							font:Hide()
						end
					)
					texturePool = CreateObjectPool(
						function()
							local texture = self:CreateTexture(nil, "OVERLAY")
							return texture
						end,
						function(_, texture)
							texture:ClearAllPoints()
							texture:Hide()
						end
					)
					buttonPool = CreateObjectPool(
						function()
							local button = CreateFrame("button", nil, self, "UIPanelButtonTemplate")
							button.icon = button:CreateTexture(nil, "OVERLAY")
							button.icon:SetPoint("LEFT", 7, 0)
							button.icon:SetSize(16, 16)
							return button
						end,
						function(_, button)
							button:ClearAllPoints()
							button:SetScript("OnClick", nil)
							button.icon:SetTexture(nil)
							button:Hide()
						end
					)
					inputPool = CreateObjectPool(
						function()
							local input = CreateFrame("editbox", nil, self, "LargeInputBoxTemplate,BackdropTemplate")
							input:SetBackdrop(MEDIA:BACKDROP(true, false, 0, 1))
							input:SetBackdropColor(0, 0, 0, 0.15)
							input:SetAutoFocus(false)
							input:SetFont(MEDIA:FONT(), 14)
							input.Left:Hide()
							input.Middle:Hide()
							input.Right:Hide()
							return input
						end,
						function(_, input)
							input:ClearAllPoints()
							input:SetScript("OnEnterPressed", nil)
							input:SetScript("OnEscapePressed", nil)
							input:SetScript("OnTextChanged", nil)
							input:SetScript("OnTextSet", nil)
							input:Hide()
						end
					)
				end
				frame.rowPool = rowPool
				return frame
			end
			local function ResetScrollFrame(pool, frame)
				frame.cursor = 1
				frame.length = nil
				frame.rowCount = nil
				frame.rowHeight = nil
				frame.totHeight = nil
				frame:ClearAllPoints()
				while #frame > 0 do
					local row = frame[#frame]
					frame:ReleaseRow(row, #frame)
					rowPool:Release(row)
					Table_Remove(frame)
				end
				frame:SetScript("OnMouseWheel", nil)
				frame.scrollbar:SetScript("OnEnter", nil)
				frame.scrollbar:SetScript("OnLeave", nil)
				frame.scrollbar:SetScript("OnMouseDown", nil)
				frame:Hide()
			end
			self.scrollPool = CreateObjectPool(CreateScrollFrame, ResetScrollFrame)
		end
		do
			local function OnClick_CloseGUI()
				SquishData.GUIOpen = false
				SECTIONS[SELECTED]:Unload(self)
				SELECTED = nil
				self:Hide()
			end
			local closeButton = CreateFrame("button", nil, self, "UIPanelButtonTemplate")
			closeButton:SetSize(32, 32)
			closeButton:SetPoint("TOPRIGHT", self, "TOPLEFT", -1, -1)
			closeButton:SetText("X")
			closeButton:SetScript("OnClick", OnClick_CloseGUI)
			local menuButtons = {}
			local function OnClick_SectionButton(button)
				if SELECTED ~= nil then
					SECTIONS[SELECTED]:Unload(self)
					menuButtons[SELECTED].icon:SetAlpha(0.5)
					--menuButtons[SELECTED].icon:SetPoint("TOPLEFT", 4, 0)
					--menuButtons[SELECTED].icon:SetPoint("BOTTOMRIGHT", 0, 0)
				end
				SELECTED = button.index
				SquishData.GUISection = SELECTED
				button.icon:SetAlpha(1)
				--button.icon:SetPoint("TOPLEFT", 0, 0)
				--button.icon:SetPoint("BOTTOMRIGHT", -4, 0)
				SECTIONS[SELECTED]:Load(self)
			end
			local function OnEnter_SectionButton(self)
				self.icon:SetAlpha(1)
			end
			local function OnLeave_SectionButton(self)
				if self.index == SELECTED then return end
				self.icon:SetAlpha(0.5)
			end
			for index = 1, #SECTIONS do
				local button = CreateFrame("button", nil, self, "BackdropTemplate")
				button:SetSize(52, 48)
				button:SetBackdrop(MEDIA:BACKDROP(true, nil, 0, -1))
				button:SetBackdropColor(0, 0, 0, 0.75)
				button:SetPoint("TOPRIGHT", self, "TOPLEFT", 0, (index - 1) * -54 - 64)
				button.icon = button:CreateTexture()
				button.icon:SetPoint("TOPLEFT", 0, 0)
				button.icon:SetPoint("BOTTOMRIGHT", -4, 0)
				button.icon:SetTexture(SECTIONS[index].icon)
				button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
				button.icon:SetAlpha(0.5)
				button.index = index
				button:RegisterForClicks("anyup")
				button:SetScript("OnClick", OnClick_SectionButton)
				button:SetScript("OnEnter", OnEnter_SectionButton)
				button:SetScript("OnLeave", OnLeave_SectionButton)
				table.insert(menuButtons, button)
			end
			BINDING_HEADER_SQUISH = "Squish"
			BINDING_NAME_SPELLS_TOGGLE = "Toggle Spells Panel"
			_G.Squish = {}
			_G.Squish.ToggleSpellsGUI = function()
				SquishData.GUIOpen = not SquishData.GUIOpen
				if SquishData.GUIOpen then
					self:Show()
					OnClick_SectionButton(menuButtons[SquishData.GUISection or 1])
				else
					OnClick_CloseGUI()
				end
			end
			if SquishData.GUIOpen then
				self:Show()
				OnClick_SectionButton(menuButtons[SquishData.GUISection or 1])
			end
		end
		self:SetScript("OnHide", function()
			print("hide", #self.tablePool.inactiveObjects)
			for index = #self.tablePool.inactiveObjects, 1, -1 do
				self.tablePool[index] = nil
			end
			collectgarbage("collect")
		end)
	end)
end
local CreateCooldowns
do
	local function FilterCooldown(spell, class, specc)
		if type(spell) == "table" then
			if spell.item then
				return IsEquippedItem(spell.id)
			end
			if not IsSpellKnown(spell.id) then
				return false
			end
			if spell.specc and spell.specc ~= specc then
				return false
			end
			if spell.class and spell.class ~= class then
				return false
			end
			return true
		end
		return IsSpellKnown(spell)
	end
	local function CreateIcon(self, ...)
		local frame = CreateFrame("statusbar", nil, self.parent)
		-- frame:SetBackdrop(MEDIA:BACKDROP(true, false, 0, 0))
		-- frame:SetBackdropColor(0, 0, 0, 0.75)
		frame:SetStatusBarTexture(MEDIA:STATUSBAR())
		frame:SetStatusBarColor(0, 0, 0, 0.75)
		frame:SetOrientation("VERTICAL")
		frame:SetMinMaxValues(0, 1)
		frame:SetValue(0)
		frame.icon = frame:CreateTexture(nil, "BACKGROUND", nil, 7)
		frame.icon:SetAllPoints()
		-- frame.icon:SetPoint("TOPLEFT", 1, -1)
		-- frame.icon:SetPoint("BOTTOMRIGHT", -1, 1)
		frame.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		frame.time = frame:CreateFontString(nil, nil, "GameFontNormal")
		frame.time:SetFont(MEDIA:FONT(), 18, "OUTLINE")
		frame.time:SetPoint("BOTTOM", 0, 4)
		--frame.time:SetTextColor(1, 1, 1, 1)
		frame.stack = frame:CreateFontString(nil, nil, "GameFontNormal")
		frame.stack:SetFont(MEDIA:FONT(), 22, "OUTLINE")
		frame.stack:SetPoint("TOP", 0, -4)
		--frame.stack:SetTextColor(1, 1, 1, 1)
		return frame
	end
	local function StopUpdate(self)
		self.duration = nil
		self.__tick = nil
		Queue:Remove(self)
		self.time:Hide()
		self:SetValue(0)
		self.icon:SetVertexColor(1, 1, 1, 1)
		self:SetScript("OnUpdate", nil)
	end
	local function ResetIcon(self, frame)
		frame:SetScript("OnUpdate", nil)
		frame:SetScript("OnEvent", nil)
		frame:UnregisterAllEvents()
		frame:ClearAllPoints()
		frame:Hide()
		frame.stack:SetText("")
		frame.charges = nil
		StopUpdate(frame)
	end
	local function OnUpdate_ShortDuration(self, elapsed)
		self.duration = self.duration - elapsed
		if self.duration < 0 then
			StopUpdate(self)
		else
			self:SetValue(self.duration)
			self.time:SetText(Math_Floor(self.duration * 10) / 10)
		end
	end
	local function OnUpdate_LongDuration(self, elapsed)
		self.duration = self.duration - elapsed
		if self.duration < 2 then
			self:SetValue(self.duration)
			self:SetScript("OnUpdate", OnUpdate_ShortDuration)
			self.__tick = nil
			Queue:Remove(self)
		else
			self:SetValue(self.duration)
		end
	end
	local function OnUpdate_TickDuration(self)
		if self.duration > 60 then
			self.time:SetFormattedText("%dm", Math_Ceil(self.duration / 60))
		else
			self.time:SetFormattedText("%d", self.duration + self.__delay)
		end
		Queue:Insert(self, self.duration - Math_Floor(self.duration))
	end
	local function StartUpdate(self, elapsed, duration)
		if not self.__tick then
			self.__tick = OnUpdate_TickDuration
		else
			Queue:Remove(self)
		end
		self.duration = elapsed
		self:SetMinMaxValues(0, duration)
		self.time:Show()
		self.icon:SetVertexColor(1, 0.35, 0.35, 0.85)
		self.__delay = 0
		self:__tick()
		self:SetScript("OnUpdate", OnUpdate_LongDuration)
	end
	local function OnEvent_SpellCooldown(self)
		local started, duration = GetSpellCooldown(self.spell)
		local charges, maxCharges, lastStarted, lastDuration = GetSpellCharges(self.spell)
		if charges ~= nil then
			if charges ~= self.charges then
				self.charges = charges
				self.stack:SetText(charges)
			end
			if charges > 0 and charges < maxCharges then
				started = lastStarted
				duration = lastDuration
			end
		end
		if started == 0 or duration == 0 then return end
		local elapsed = GetTime() - started
		if elapsed < 1.5 and duration < 1.5 then return end
		StartUpdate(self, duration - elapsed, duration)
	end
	local function OnEvent_ItemCooldown(self)
		local started, duration = GetItemCooldown(self.spell)
		if started == 0 or duration == 0 then return end
		local elapsed = GetTime() - started
		if elapsed < 1.5 and duration < 1.5 then return end
		StartUpdate(self, duration - elapsed, duration)
	end
	local function OnEvent_CreateIcons(self)
		local class = UnitClass("player")
		local _, specc = GetSpecializationInfo(GetSpecialization())
		while #self > 0 do
			self.pool:Release(Table_Remove(self))
		end
		for _, spell in ipairs(self.spells) do
			if FilterCooldown(spell, class, specc) then
				local frame = self.pool:Acquire()
				frame:SetParent(self)
				frame:SetSize(self.size, self.size)
				frame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
				frame:RegisterEvent("SPELL_UPDATE_USABLE")
				frame:Show()
				if type(spell) == "table" then
					frame.spell = spell.id
					frame.item = spell.item
				else
					frame.spell = spell
					frame.item = false
				end
				if frame.item then
					frame.icon:SetTexture(select(10, GetItemInfo(frame.spell)))
					frame:SetScript("OnEvent", OnEvent_ItemCooldown)
					OnEvent_ItemCooldown(frame)
				else
					frame.icon:SetTexture(select(3, GetSpellInfo(frame.spell)))
					frame:SetScript("OnEvent", OnEvent_SpellCooldown)
					OnEvent_SpellCooldown(frame)
				end
				Table_Insert(self, frame)
			end
		end
		Stack(self, "RIGHT", "RIGHT", -1, 0, "RIGHT", "LEFT", -1, 0, unpack(self))
		self:SetSize(self.size * #self + #self + 1, self.size + 2)
	end
	local pool = nil
	function CreateCooldowns(parent, size, spells)
		local frame = CreateFrame("frame", nil, parent, "BackdropTemplate")
		frame:SetBackdrop(MEDIA:BACKDROP(true, false, 0, 0))
		frame:SetBackdropColor(0, 0, 0, 0.75)
		if not pool then
			pool = CreateObjectPool(CreateIcon, ResetIcon)
			pool.parent = parent
		end
		frame.pool = pool
		frame.spells = spells
		frame.size = size
		frame:RegisterEvent("PLAYER_ENTERING_WORLD")
		frame:RegisterEvent("PLAYER_TALENT_UPDATE")
		frame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
		frame:SetScript("OnEvent", OnEvent_CreateIcons)
		return frame
	end
end
local CreatePlayerBuffs
do
	local OnAttributeChanged
	local OnEnter_AuraButton
	local OnLeave_AuraButton
	function CreatePlayerBuffs(parent, size, unit, filter, clickable, name)
		local self = CreateFrame("frame", "Squish" .. name, parent, "SecureAuraHeaderTemplate")
		self:SetAttribute("template", "SecureActionButtonTemplate BackdropTemplate")
		self:SetAttribute("_ignore", "attributeChanges")
		self:SetAttribute("initialConfigFunction", [[
      self:SetWidth(]] .. size .. [[)
      self:SetHeight(]] .. size .. [[)
      ]] .. (clickable and "self:SetAttribute('type', 'cancelaura')" or "") .. [[
      self:GetParent():CallMethod('configure', self:GetName())
    ]])
		self:SetAttribute("point", "TOPRIGHT")
		self:SetAttribute("unit", unit)
		self:SetAttribute("filter", filter)
		self:SetAttribute("sortDirection", "-")
		self:SetAttribute("sortMethod", "TIME,NAME")
		self:SetAttribute("minWidth", size)
		self:SetAttribute("minHeight", size)
		self:SetAttribute("xOffset", -size - 2)
		self:SetAttribute("yOffset", 0)
		function self:configure(name)
			local button = _G[name]
			button.filter = filter
			button.unit = unit
			if clickable then
				button:RegisterForClicks("RightButtonUp")
			end
			button:SetBackdrop(MEDIA:BACKDROP(nil, true, 4, 0))
			button:SetBackdropColor(0, 0, 0, 0.75)
			button.icon = button:CreateTexture()
			button.icon:SetPoint("TOPLEFT", 4, -4)
			button.icon:SetPoint("BOTTOMRIGHT", -4, 4)
			button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
			button.time = button:CreateFontString(nil, nil, "GameFontNormal")
			button.time:SetFont(MEDIA:FONT(), 12, "OUTLINE")
			button.time:SetPoint("TOP", button, "BOTTOM", 0, -4)
			button.stack = button:CreateFontString(nil, nil, "GameFontNormal")
			button.stack:SetFont(MEDIA:FONT(), 18, "OUTLINE")
			button.stack:SetPoint("BOTTOMRIGHT", -4, 4)
			button:RegisterUnitEvent("UNIT_AURA", unit)
			button:SetScript("OnAttributeChanged", OnAttributeChanged_AuraButton)
			button:SetScript("OnEnter", OnEnter_AuraButton)
			button:SetScript("OnLeave", OnLeave_AuraButton)
			button:SetScript("OnEvent", OnEvent_AuraButton)
		end
		RegisterAttributeDriver(self, "unit", "[vehicleui] vehicle; player")
		RegisterStateDriver(self, "visibility", "[petbattle] hide; show")
		return self
	end
	function OnEnter_AuraButton(self)
		if not self:IsVisible() then return end
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
		GameTooltip:SetUnitAura(self.unit, self.index, self.filter)
		local _, _, _, _, _, _, _, _, _, id = UnitAura(self.unit, self.index, self.filter)
		GameTooltip:AddLine("ID: " .. tostring(id), 1, 1, 1)
	end
	function OnLeave_AuraButton()
		GameTooltip:Hide()
	end
	do
		local ticker = {}
		do
			local function SetDuration(button, now)
				local duration = button.expires - now
				if duration < 60 then
					button.time:SetFormattedText("%ds", duration)
				elseif duration < 3600 then
					button.time:SetFormattedText("%dm", ceil(duration / 60))
					button.padd = (duration % 60) - 0.5
				else
					button.time:SetText("alot")
				end
			end
			local prev = GetTime()
			C_Timer.NewTicker(0.5, function()
				local now = GetTime()
				local elapsed = now - prev
				for index = 1, #ticker do
					local button = ticker[index]
					if button.padd > 0 then
						button.padd = button.padd - elapsed
					else
						SetDuration(button, now)
					end
				end
				prev = now
			end)
			function ticker:insert(button)
				button.padd = 0
				SetDuration(button, GetTime())
				if button.active then return end
				button.active = true
				Table_Insert(self, button)
			end
			function ticker:remove(button)
				if not button.active then return end
				button.active = false
				for i = 1, #self do
					if button == self[i] then
						Table_Remove(self, i)
						return
					end
				end
			end
		end
		local function Update(self)
			local name, texture, count, kind, duration, expires, x, _, c = UnitAura(self.unit, self.index, self.filter)
			self.icon:SetTexture(texture)
			if count and count > 0 then
				self.stack:Show()
				self.stack:SetText(count)
			else
				self.stack:Hide()
			end
			if kind then
				local color = DebuffTypeColor[kind]
				self:SetBackdropBorderColor(color.r, color.g, color.b, 1)
			else
				self:SetBackdropBorderColor(0, 0, 0, 0)
			end
			if duration > 0 then
				self.time:Show()
				self.expires = expires
				ticker:insert(self)
			else
				self.time:Hide()
				ticker:remove(self)
			end
		end
		local function OnEvent_AuraButton(self)
			if not self:IsVisible() then
				ticker:remove(self)
				self:SetScript("OnEvent", nil)
			end
		end
		function OnAttributeChanged_AuraButton(self, key, value)
			if key == "index" then
				self.index = value
				Update(self)
				self:SetScript("OnEvent", OnEvent_AuraButton)
			end
		end
	end
end
local UI = CreateFrame("frame", nil, UIParent)
UI:RegisterEvent("PLAYER_LOGIN")
UI:SetScript("OnEvent", function(self, event)
	self:UnregisterAllEvents()
	self:SetPoint("TOPLEFT", 0, 0)
	self:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMLEFT", 640, 0)
	self:SetScale(0.533333333 / UIParent:GetScale())
	HookSpellBookTooltips()
	BuffFrame:SetScript("OnUpdate", nil)
	BuffFrame:SetScript("OnEvent", nil)
	BuffFrame:UnregisterAllEvents()
	BuffFrame:Hide()
	CreatePlayerBuffs(UI, 48, "player", "HELPFUL", true, "PlayerBuffs"):SetPoint("TOPRIGHT", -4, -4)
	CreatePlayerBuffs(UI, 64, "player", "HARMFUL", false, "PlayerDebuffs"):SetPoint("TOPRIGHT", -4, -100)
	local playerButton = (function()
		local self = CreateFrame("button", nil, UI, "SecureActionButtonTemplate,BackdropTemplate")
		self:SetScript("OnAttributeChanged", OnAttributeChanged)
		self:RegisterForClicks("AnyUp")
		self:SetAttribute("*type1", "target")
		self:SetAttribute("*type2", "togglemenu")
		self:SetBackdrop(MEDIA:BACKDROP(true, nil, 0, -1))
		self:SetBackdropColor(0, 0, 0, 1)
		self:SetSize(376, 64)
		local powerBar = CreateFrame("statusbar", nil, self)
		powerBar:SetMinMaxValues(0, 1)
		powerBar:SetStatusBarTexture(MEDIA:STATUSBAR())
		powerBar:SetPoint("TOPLEFT", 65, 0)
		powerBar:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, -8)
		powerBar:SetMinMaxValues(0, 1)
		local healthBar = CreateFrame("statusbar", nil, self)
		healthBar:SetMinMaxValues(0, 1)
		healthBar:SetStatusBarTexture(MEDIA:STATUSBAR())
		healthBar:SetPoint("TOPLEFT", powerBar, "BOTTOMLEFT", 0, -1)
		healthBar:SetPoint("BOTTOMRIGHT", 0, 0)
		healthBar:SetFrameLevel(3)
		local shieldBar = CreateFrame("statusbar", nil, self)
		shieldBar:SetMinMaxValues(0, 1)
		shieldBar:SetStatusBarTexture(MEDIA:STATUSBAR())
		shieldBar:SetAllPoints(healthBar)
		shieldBar:SetStatusBarColor(0.0, 1.0, 1.0, 0.5)
		shieldBar:SetFrameLevel(2)
		local absorbBar = CreateFrame("statusbar", nil, self)
		absorbBar:SetMinMaxValues(0, 1)
		absorbBar:SetStatusBarTexture(MEDIA:STATUSBAR())
		absorbBar:SetAllPoints(healthBar)
		absorbBar:SetStatusBarColor(1.0, 0.0, 0.0, 0.5)
		absorbBar:SetFrameLevel(4)
		local background = self:CreateTexture(nil, "ARTWORK")
		background:SetPoint("TOPLEFT", healthBar, "TOPLEFT", 0, 0)
		background:SetPoint("BOTTOMRIGHT", healthBar, "BOTTOMRIGHT", 0, 0)
		background:SetTexture(MEDIA:STATUSBAR())
		background:SetAlpha(0.35)
		local overlay = healthBar:CreateTexture(nil, "ARTWORK")
		overlay:SetAllPoints()
		overlay:SetTexture([[Interface\PETBATTLES\Weather-Sunlight]])
		overlay:SetTexCoord(1, 0.26, 0, 0.7)
		overlay:SetBlendMode("ADD")
		overlay:SetAlpha(0.15)
		local specIcon = self:CreateTexture(nil, "OVERLAY")
		specIcon:SetSize(64, 64)
		specIcon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		specIcon:SetPoint("TOPLEFT", 0, 0)
		local roleIcon = healthBar:CreateTexture(nil, "OVERLAY")
		roleIcon:SetSize(28, 28)
		roleIcon:SetTexture([[Interface\LFGFrame\UI-LFG-ICON-PORTRAITROLES]])
		--roleIcon:SetTexture([[Interface\LFGFrame\UI-LFG-ICON-ROLES]])
		roleIcon:SetPoint("BOTTOMRIGHT", healthBar, "BOTTOMLEFT", 0, 0)
		local powerFont = healthBar:CreateFontString(nil, nil, "GameFontNormal")
		powerFont:SetFont(MEDIA:FONT(), 20)
		powerFont:SetTextColor(0, 0, 0)
		powerFont:SetShadowColor(1, 1, 1, 0.5)
		powerFont:SetPoint("TOP")
		powerFont:SetText("power")
		local powerWidth = 311
		local powerSpring = Spring:Create(
			function(_, percent)
				powerBar:SetValue(percent)
				powerFont:SetPoint("TOPRIGHT", -((1 - percent) * powerWidth) - 6, -2)
			end,
			180,
			30,
			0.008
		)
		local healthSpring = Spring:Create(
			function(self, health)
				healthBar:SetValue(health)
				shieldBar:SetValue(health + self.absorb)
			end,
			180,
			30,
			0.1
		)
		local resserIcon = healthBar:CreateTexture(nil, "OVERLAY")
		resserIcon:SetSize(32, 32)
		resserIcon:SetTexture([[Interface\RaidFrame\Raid-Icon-Rez]])
		resserIcon:SetPoint("CENTER", 0, 0)
		local raidIcon = healthBar:CreateTexture(nil, "OVERLAY")
		raidIcon:SetSize(24, 24)
		raidIcon:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]])
		local combatIcon = healthBar:CreateTexture(nil, "OVERLAY")
		combatIcon:SetSize(18, 18)
		combatIcon:SetTexture([[Interface\CharacterFrame\UI-StateIcon]])
		combatIcon:SetTexCoord(.5, 1, 0, .49)
		local leaderIcon = healthBar:CreateTexture(nil, "OVERLAY")
		leaderIcon:SetSize(18, 18)
		leaderIcon:SetTexture([[Interface\GroupFrame\UI-Group-LeaderIcon]])
		local assistIcon = healthBar:CreateTexture(nil, "OVERLAY")
		assistIcon:SetSize(18, 18)
		assistIcon:SetTexture([[Interface\GroupFrame\UI-Group-AssistantIcon]])
		local restedIcon = healthBar:CreateTexture(nil, "OVERLAY")
		restedIcon:SetSize(18, 18)
		restedIcon:SetTexture([[Interface\CharacterFrame\UI-StateIcon]])
		restedIcon:SetTexCoord(0.05, .55, 0, .49)
		function self:handler(event, ...)
			if event == "UNIT_SET" then
				self:RegisterEvent("PLAYER_ENTERING_WORLD")
				self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
				self:RegisterEvent("PLAYER_ROLES_ASSIGNED")
				self:RegisterEvent("GROUP_ROSTER_UPDATE")
				self:RegisterEvent("INCOMING_RESURRECT_CHANGED")
				self:RegisterEvent("RAID_TARGET_UPDATE")
				self:RegisterEvent("PLAYER_REGEN_ENABLED")
				self:RegisterEvent("PLAYER_REGEN_DISABLED")
				self:RegisterEvent("PARTY_LEADER_CHANGED")
				self:RegisterEvent("PLAYER_UPDATE_RESTING")
				self:RegisterUnitEvent("UNIT_DISPLAYPOWER", self.unit)
				self:RegisterUnitEvent("UNIT_POWER_UPDATE", self.unit)
				self:RegisterUnitEvent("UNIT_MAXPOWER", self.unit)
				self:RegisterUnitEvent("UNIT_POWER_FREQUENT", self.unit)
				self:RegisterUnitEvent("UNIT_MAXHEALTH", self.unit)
				self:RegisterUnitEvent("UNIT_HEALTH", self.unit)
				self:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", self.unit)
				self:RegisterUnitEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED", self.unit)
			elseif event == "UNIT_MOD" then
				self:RegisterUnitEvent("UNIT_DISPLAYPOWER", self.unit)
				self:RegisterUnitEvent("UNIT_POWER_UPDATE", self.unit)
				self:RegisterUnitEvent("UNIT_MAXPOWER", self.unit)
				self:RegisterUnitEvent("UNIT_POWER_FREQUENT", self.unit)
				self:RegisterUnitEvent("UNIT_MAXHEALTH", self.unit)
				self:RegisterUnitEvent("UNIT_HEALTH", self.unit)
				self:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", self.unit)
				self:RegisterUnitEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED", self.unit)
			elseif event == "UNIT_REM" then
				self:UnregisterEvent("PLAYER_ENTERING_WORLD")
				self:UnregisterEvent("PLAYER_SPECIALIZATION_CHANGED")
				self:UnregisterEvent("PLAYER_ROLES_ASSIGNED")
				self:UnregisterEvent("GROUP_ROSTER_UPDATE")
				self:UnregisterEvent("UNIT_DISPLAYPOWER")
				self:UnregisterEvent("UNIT_POWER_UPDATE")
				self:UnregisterEvent("UNIT_MAXPOWER")
				self:UnregisterEvent("UNIT_POWER_FREQUENT")
				self:UnregisterEvent("UNIT_MAXHEALTH")
				self:UnregisterEvent("UNIT_HEALTH")
				self:UnregisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")
				self:UnregisterEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED")
				self:UnregisterEvent("INCOMING_RESURRECT_CHANGED")
				self:UnregisterEvent("RAID_TARGET_UPDATE")
				self:UnregisterEvent("PLAYER_REGEN_ENABLED")
				self:UnregisterEvent("PLAYER_REGEN_DISABLED")
				self:UnregisterEvent("PARTY_LEADER_CHANGED")
				self:UnregisterEvent("PLAYER_UPDATE_RESTING")
			elseif event == "PLAYER_ENTERING_WORLD" then
				local index = GetSpecialization()
				local id, name, description, icon, background, role = GetSpecializationInfo(index, false)
				specIcon:SetTexture(icon)
			elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
				local index = GetSpecialization()
				local id, name, description, icon, background, role = GetSpecializationInfo(index, false)
				specIcon:SetTexture(icon)
			elseif event == "GUID_SET" then
				local __0 = UnitGroupRolesAssigned(self.unit)
				UpdateRoleIcon(roleIcon, __0)
				local __1 = ClassColor(self.unit)
				local cr, cg, cb = unpack(__1)
				healthBar:SetStatusBarColor(cr, cg, cb)
				background:SetVertexColor(cr, cg, cb)
				local __2 = PowerColor(self.unit)
				local pr, pg, pb = unpack(__2)
				powerBar:SetStatusBarColor(pr, pg, pb)
				powerFont:SetTextColor(pr * 0.15, pg * 0.15, pb * 0.15)
				local __3 = UnitPowerMax(self.unit)
				local __4 = UnitPower(self.unit)
				local pp = __4 / __3
				powerFont:SetText(math.ceil(pp * 100))
				Spring:Update(powerSpring, pp)
				local __5 = UnitHealthMax(self.unit)
				healthBar:SetMinMaxValues(0, __5)
				shieldBar:SetMinMaxValues(0, __5)
				absorbBar:SetMinMaxValues(0, __5)
				local __6 = UnitHealth(self.unit)
				local __7 = UnitGetTotalAbsorbs(self.unit)
				healthSpring.absorb = __7
				Spring:Update(healthSpring, __6)
				local __8 = UnitGetTotalHealAbsorbs(self.unit)
				absorbBar:SetValue(__8)
				local __9 = UnitHasIncomingResurrection(self.unit)
				ToggleVisible(resserIcon, __9)
				local __10 = GetRaidTargetIndex(self.unit)
				UpdateRaidIcon(raidIcon, __10)
				local __11 = UnitAffectingCombat(self.unit)
				ToggleVisible(combatIcon, __11)
				local __12 = UnitInParty(self.unit)
				local __13 = UnitIsGroupLeader(self.unit)
				ToggleVisible(leaderIcon, (__12 and __13))
				local __14 = UnitIsGroupAssistant(self.unit)
				ToggleVisible(assistIcon, (__12 and __14))
				local __15 = IsResting()
				ToggleVisible(restedIcon, __15)
				Stack(healthBar, "BOTTOMLEFT", "BOTTOMLEFT", 2, 4, "LEFT", "RIGHT", 4, 0, raidIcon, leaderIcon, assistIcon, restedIcon, combatIcon)
			elseif event == "GUID_MOD" then
				local __0 = UnitGroupRolesAssigned(self.unit)
				UpdateRoleIcon(roleIcon, __0)
				local __1 = ClassColor(self.unit)
				local cr, cg, cb = unpack(__1)
				healthBar:SetStatusBarColor(cr, cg, cb)
				background:SetVertexColor(cr, cg, cb)
				local __2 = PowerColor(self.unit)
				local pr, pg, pb = unpack(__2)
				powerBar:SetStatusBarColor(pr, pg, pb)
				powerFont:SetTextColor(pr * 0.15, pg * 0.15, pb * 0.15)
				local __3 = UnitPowerMax(self.unit)
				local __4 = UnitPower(self.unit)
				local pp = __4 / __3
				powerFont:SetText(math.ceil(pp * 100))
				Spring:Update(powerSpring, pp)
				local __5 = UnitHealthMax(self.unit)
				healthBar:SetMinMaxValues(0, __5)
				shieldBar:SetMinMaxValues(0, __5)
				absorbBar:SetMinMaxValues(0, __5)
				local __6 = UnitHealth(self.unit)
				local __7 = UnitGetTotalAbsorbs(self.unit)
				healthSpring.absorb = __7
				Spring:Update(healthSpring, __6)
				local __8 = UnitGetTotalHealAbsorbs(self.unit)
				absorbBar:SetValue(__8)
				local __9 = UnitHasIncomingResurrection(self.unit)
				ToggleVisible(resserIcon, __9)
				local __10 = GetRaidTargetIndex(self.unit)
				UpdateRaidIcon(raidIcon, __10)
				local __11 = UnitAffectingCombat(self.unit)
				ToggleVisible(combatIcon, __11)
				local __12 = UnitInParty(self.unit)
				local __13 = UnitIsGroupLeader(self.unit)
				ToggleVisible(leaderIcon, (__12 and __13))
				local __14 = UnitIsGroupAssistant(self.unit)
				ToggleVisible(assistIcon, (__12 and __14))
				local __15 = IsResting()
				ToggleVisible(restedIcon, __15)
				Stack(healthBar, "BOTTOMLEFT", "BOTTOMLEFT", 2, 4, "LEFT", "RIGHT", 4, 0, raidIcon, leaderIcon, assistIcon, restedIcon, combatIcon)
			elseif event == "PLAYER_ROLES_ASSIGNED" then
				local __0 = UnitGroupRolesAssigned(self.unit)
				UpdateRoleIcon(roleIcon, __0)
			elseif event == "GROUP_ROSTER_UPDATE" then
				local __0 = ClassColor(self.unit)
				local cr, cg, cb = unpack(__0)
				healthBar:SetStatusBarColor(cr, cg, cb)
				background:SetVertexColor(cr, cg, cb)
				local __1 = UnitInParty(self.unit)
				local __2 = UnitIsGroupLeader(self.unit)
				ToggleVisible(leaderIcon, (__1 and __2))
				local __3 = UnitIsGroupAssistant(self.unit)
				ToggleVisible(assistIcon, (__1 and __3))
				local __4 = GetRaidTargetIndex(self.unit)
				Stack(healthBar, "BOTTOMLEFT", "BOTTOMLEFT", 2, 4, "LEFT", "RIGHT", 4, 0, raidIcon, leaderIcon, assistIcon, restedIcon, combatIcon)
			elseif event == "UNIT_DISPLAYPOWER" then
				local __0 = PowerColor(self.unit)
				local pr, pg, pb = unpack(__0)
				powerBar:SetStatusBarColor(pr, pg, pb)
				powerFont:SetTextColor(pr * 0.15, pg * 0.15, pb * 0.15)
			elseif event == "UNIT_POWER_UPDATE" then
				local __0 = PowerColor(self.unit)
				local pr, pg, pb = unpack(__0)
				powerBar:SetStatusBarColor(pr, pg, pb)
				powerFont:SetTextColor(pr * 0.15, pg * 0.15, pb * 0.15)
				local __1 = UnitPowerMax(self.unit)
				local __2 = UnitPower(self.unit)
				local pp = __2 / __1
				powerFont:SetText(math.ceil(pp * 100))
				Spring:Update(powerSpring, pp)
			elseif event == "UNIT_MAXPOWER" then
				local __0 = UnitPowerMax(self.unit)
				local __1 = UnitPower(self.unit)
				local pp = __1 / __0
				powerFont:SetText(math.ceil(pp * 100))
				Spring:Update(powerSpring, pp)
			elseif event == "UNIT_POWER_FREQUENT" then
				local __0 = UnitPowerMax(self.unit)
				local __1 = UnitPower(self.unit)
				local pp = __1 / __0
				powerFont:SetText(math.ceil(pp * 100))
				Spring:Update(powerSpring, pp)
			elseif event == "UNIT_MAXHEALTH" then
				local __0 = UnitHealthMax(self.unit)
				healthBar:SetMinMaxValues(0, __0)
				shieldBar:SetMinMaxValues(0, __0)
				absorbBar:SetMinMaxValues(0, __0)
			elseif event == "UNIT_HEALTH" then
				local __0 = UnitHealth(self.unit)
				local __1 = UnitGetTotalAbsorbs(self.unit)
				healthSpring.absorb = __1
				Spring:Update(healthSpring, __0)
			elseif event == "UNIT_ABSORB_AMOUNT_CHANGED" then
				local __0 = UnitHealth(self.unit)
				local __1 = UnitGetTotalAbsorbs(self.unit)
				healthSpring.absorb = __1
				Spring:Update(healthSpring, __0)
			elseif event == "UNIT_HEAL_ABSORB_AMOUNT_CHANGED" then
				local __0 = UnitGetTotalHealAbsorbs(self.unit)
				absorbBar:SetValue(__0)
			elseif event == "INCOMING_RESURRECT_CHANGED" then
				local __0 = UnitHasIncomingResurrection(self.unit)
				ToggleVisible(resserIcon, __0)
			elseif event == "RAID_TARGET_UPDATE" then
				local __0 = GetRaidTargetIndex(self.unit)
				UpdateRaidIcon(raidIcon, __0)
				local __1 = UnitIsGroupLeader(self.unit)
				local __2 = UnitIsGroupAssistant(self.unit)
				Stack(healthBar, "BOTTOMLEFT", "BOTTOMLEFT", 2, 4, "LEFT", "RIGHT", 4, 0, raidIcon, leaderIcon, assistIcon, restedIcon, combatIcon)
			elseif event == "PLAYER_REGEN_ENABLED" then
				combatIcon:Hide()
				local __0 = GetRaidTargetIndex(self.unit)
				local __1 = UnitIsGroupLeader(self.unit)
				local __2 = UnitIsGroupAssistant(self.unit)
				Stack(healthBar, "BOTTOMLEFT", "BOTTOMLEFT", 2, 4, "LEFT", "RIGHT", 4, 0, raidIcon, leaderIcon, assistIcon, restedIcon, combatIcon)
			elseif event == "PLAYER_REGEN_DISABLED" then
				combatIcon:Show()
				local __0 = GetRaidTargetIndex(self.unit)
				local __1 = UnitIsGroupLeader(self.unit)
				local __2 = UnitIsGroupAssistant(self.unit)
				Stack(healthBar, "BOTTOMLEFT", "BOTTOMLEFT", 2, 4, "LEFT", "RIGHT", 4, 0, raidIcon, leaderIcon, assistIcon, restedIcon, combatIcon)
			elseif event == "PARTY_LEADER_CHANGED" then
				local __0 = UnitInParty(self.unit)
				local __1 = UnitIsGroupLeader(self.unit)
				ToggleVisible(leaderIcon, (__0 and __1))
				local __2 = GetRaidTargetIndex(self.unit)
				local __3 = UnitIsGroupAssistant(self.unit)
				Stack(healthBar, "BOTTOMLEFT", "BOTTOMLEFT", 2, 4, "LEFT", "RIGHT", 4, 0, raidIcon, leaderIcon, assistIcon, restedIcon, combatIcon)
			elseif event == "PLAYER_UPDATE_RESTING" then
				local __0 = IsResting()
				ToggleVisible(restedIcon, __0)
			end
		end
		self:SetAttribute("unit", "player")
		self:SetPoint("RIGHT", -8, -240)
		DisableBlizzard("player")
		CastingBarFrame:SetScript("OnUpdate", nil)
		CastingBarFrame:SetScript("OnEvent", nil)
		CastingBarFrame:UnregisterAllEvents()
		CastingBarFrame:Hide()
		local castbar = CreateCastBar(self, "player", 32)
		castbar:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -16)
		castbar:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -16)
		return self
	end)()
	local cdRot = CreateCooldowns(UI, 48, SPELLS.CooldownRotation)
	cdRot:SetPoint("BOTTOMRIGHT", playerButton, "TOPRIGHT", 0, 16)
	local cdSit = CreateCooldowns(UI, 48, SPELLS.CooldownSituational)
	cdSit:SetPoint("TOPRIGHT", playerButton, "BOTTOMRIGHT", 0, -64)
	-- local cdOth = CreateCooldowns(UI, 32, SPELLS.Other)
	-- cdOth:SetPoint("TOPRIGHT", cdSit, "BOTTOMRIGHT", 0, -4)
	do
		local self = CreateFrame("button", nil, UI, "SecureActionButtonTemplate,BackdropTemplate")
		self:SetScript("OnAttributeChanged", OnAttributeChanged)
		self:RegisterForClicks("AnyUp")
		self:SetAttribute("*type1", "target")
		self:SetAttribute("*type2", "togglemenu")
		self:SetBackdrop(MEDIA:BACKDROP(true, nil, 0, -1))
		self:SetBackdropColor(0, 0, 0, 1)
		local powerBar = CreateFrame("statusbar", nil, self)
		powerBar:SetMinMaxValues(0, 1)
		powerBar:SetStatusBarTexture(MEDIA:STATUSBAR())
		powerBar:SetPoint("TOPLEFT", 0, 0)
		powerBar:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, -8)
		powerBar:SetMinMaxValues(0, 1)
		local healthBar = CreateFrame("statusbar", nil, self)
		healthBar:SetMinMaxValues(0, 1)
		healthBar:SetStatusBarTexture(MEDIA:STATUSBAR())
		healthBar:SetPoint("TOPLEFT", powerBar, "BOTTOMLEFT", 0, -1)
		healthBar:SetPoint("BOTTOMRIGHT", 0, 0)
		healthBar:SetFrameLevel(3)
		local shieldBar = CreateFrame("statusbar", nil, self)
		shieldBar:SetMinMaxValues(0, 1)
		shieldBar:SetStatusBarTexture(MEDIA:STATUSBAR())
		shieldBar:SetAllPoints(healthBar)
		shieldBar:SetStatusBarColor(0.0, 1.0, 1.0, 0.5)
		shieldBar:SetFrameLevel(2)
		local absorbBar = CreateFrame("statusbar", nil, self)
		absorbBar:SetMinMaxValues(0, 1)
		absorbBar:SetStatusBarTexture(MEDIA:STATUSBAR())
		absorbBar:SetAllPoints(healthBar)
		absorbBar:SetStatusBarColor(1.0, 0.0, 0.0, 0.5)
		absorbBar:SetFrameLevel(4)
		local background = self:CreateTexture(nil, "ARTWORK")
		background:SetPoint("TOPLEFT", healthBar, "TOPLEFT", 0, 0)
		background:SetPoint("BOTTOMRIGHT", healthBar, "BOTTOMRIGHT", 0, 0)
		background:SetTexture(MEDIA:STATUSBAR())
		background:SetAlpha(0.35)
		local overlay = healthBar:CreateTexture(nil, "ARTWORK")
		overlay:SetAllPoints()
		overlay:SetTexture([[Interface\PETBATTLES\Weather-Sunlight]])
		overlay:SetTexCoord(0.26, 1, 0, 0.7)
		overlay:SetBlendMode("ADD")
		overlay:SetAlpha(0.15)
		local textName = healthBar:CreateFontString(nil, nil, "GameFontNormal")
		textName:SetFont(MEDIA:FONT(), 20)
		textName:SetTextColor(0, 0, 0)
		textName:SetShadowColor(1, 1, 1, 0.5)
		textName:SetPoint("TOPLEFT", 4, -2)
		local textStatus = healthBar:CreateFontString(nil, nil, "GameFontNormal")
		textStatus:SetFont(MEDIA:FONT(), 16)
		textStatus:SetTextColor(0, 0, 0)
		textStatus:SetShadowColor(1, 1, 1, 0.5)
		textStatus:SetPoint("CENTER", 0, 0)
		local textLevel = healthBar:CreateFontString(nil, nil, "GameFontNormal")
		textLevel:SetFont(MEDIA:FONT(), 16)
		textLevel:SetTextColor(0, 0, 0)
		textLevel:SetShadowColor(1, 1, 1, 0.5)
		textLevel:SetPoint("BOTTOMRIGHT", -4, 4)
		local powerSpring = Spring:Create(
			function(_, percent)
				powerBar:SetValue(percent)
			end,
			180,
			30,
			0.008
		)
		local healthSpring = Spring:Create(
			function(self, health)
				healthBar:SetValue(health)
				shieldBar:SetValue(health + self.absorb)
			end,
			180,
			30,
			0.1
		)
		local questIcon = healthBar:CreateTexture(nil, "OVERLAY")
		questIcon:SetSize(32, 32)
		questIcon:SetTexture([[Interface\TargetingFrame\PortraitQuestBadge]])
		questIcon:SetPoint("TOPRIGHT", -4, 8)
		local resserIcon = healthBar:CreateTexture(nil, "OVERLAY")
		resserIcon:SetSize(32, 32)
		resserIcon:SetTexture([[Interface\RaidFrame\Raid-Icon-Rez]])
		resserIcon:SetPoint("CENTER", 0, 0)
		local roleIcon = healthBar:CreateTexture(nil, "OVERLAY")
		roleIcon:SetSize(24, 24)
		roleIcon:SetTexture([[Interface\LFGFrame\UI-LFG-ICON-PORTRAITROLES]])
		--roleIcon:SetTexture([[Interface\LFGFrame\UI-LFG-ICON-ROLES]])
		local raidIcon = healthBar:CreateTexture(nil, "OVERLAY")
		raidIcon:SetSize(24, 24)
		raidIcon:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]])
		local leaderIcon = healthBar:CreateTexture(nil, "OVERLAY")
		leaderIcon:SetSize(18, 18)
		leaderIcon:SetTexture([[Interface\GroupFrame\UI-Group-LeaderIcon]])
		local assistIcon = healthBar:CreateTexture(nil, "OVERLAY")
		assistIcon:SetSize(18, 18)
		assistIcon:SetTexture([[Interface\GroupFrame\UI-Group-AssistantIcon]])
		self.__tick = RangeChecker
		function self:handler(event, ...)
			if event == "UNIT_SET" then
				self:RegisterEvent("GROUP_ROSTER_UPDATE")
				self:RegisterEvent("PLAYER_TARGET_CHANGED")
				self:RegisterEvent("INCOMING_RESURRECT_CHANGED")
				self:RegisterEvent("PLAYER_ROLES_ASSIGNED")
				self:RegisterEvent("RAID_TARGET_UPDATE")
				self:RegisterEvent("PARTY_LEADER_CHANGED")
				self:RegisterUnitEvent("UNIT_CLASSIFICATION_CHANGED", self.unit)
				self:RegisterUnitEvent("UNIT_NAME_UPDATE", self.unit)
				self:RegisterUnitEvent("UNIT_DISPLAYPOWER", self.unit)
				self:RegisterUnitEvent("UNIT_POWER_UPDATE", self.unit)
				self:RegisterUnitEvent("UNIT_MAXPOWER", self.unit)
				self:RegisterUnitEvent("UNIT_POWER_FREQUENT", self.unit)
				self:RegisterUnitEvent("UNIT_MAXHEALTH", self.unit)
				self:RegisterUnitEvent("UNIT_HEALTH", self.unit)
				self:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", self.unit)
				self:RegisterUnitEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED", self.unit)
			elseif event == "UNIT_MOD" then
				self:RegisterUnitEvent("UNIT_CLASSIFICATION_CHANGED", self.unit)
				self:RegisterUnitEvent("UNIT_NAME_UPDATE", self.unit)
				self:RegisterUnitEvent("UNIT_DISPLAYPOWER", self.unit)
				self:RegisterUnitEvent("UNIT_POWER_UPDATE", self.unit)
				self:RegisterUnitEvent("UNIT_MAXPOWER", self.unit)
				self:RegisterUnitEvent("UNIT_POWER_FREQUENT", self.unit)
				self:RegisterUnitEvent("UNIT_MAXHEALTH", self.unit)
				self:RegisterUnitEvent("UNIT_HEALTH", self.unit)
				self:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", self.unit)
				self:RegisterUnitEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED", self.unit)
			elseif event == "UNIT_REM" then
				self:UnregisterEvent("UNIT_CLASSIFICATION_CHANGED")
				self:UnregisterEvent("UNIT_NAME_UPDATE")
				self:UnregisterEvent("GROUP_ROSTER_UPDATE")
				self:UnregisterEvent("UNIT_DISPLAYPOWER")
				self:UnregisterEvent("UNIT_POWER_UPDATE")
				self:UnregisterEvent("UNIT_MAXPOWER")
				self:UnregisterEvent("UNIT_POWER_FREQUENT")
				self:UnregisterEvent("UNIT_MAXHEALTH")
				self:UnregisterEvent("UNIT_HEALTH")
				self:UnregisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")
				self:UnregisterEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED")
				self:UnregisterEvent("PLAYER_TARGET_CHANGED")
				self:UnregisterEvent("INCOMING_RESURRECT_CHANGED")
				self:UnregisterEvent("PLAYER_ROLES_ASSIGNED")
				self:UnregisterEvent("RAID_TARGET_UPDATE")
				self:UnregisterEvent("PARTY_LEADER_CHANGED")
			elseif event == "GUID_SET" then
				local __0 = UnitClassification(self.unit)
				SetUnitClassification(textLevel, __0)
				local __1 = UnitName(self.unit)
				textName:SetText(__1)
				local __2 = ClassColor(self.unit)
				local cr, cg, cb = unpack(__2)
				healthBar:SetStatusBarColor(cr, cg, cb)
				background:SetVertexColor(cr, cg, cb)
				local __3 = PowerColor(self.unit)
				local pr, pg, pb = unpack(__3)
				powerBar:SetStatusBarColor(pr, pg, pb)
				local __4 = UnitPowerMax(self.unit)
				local __5 = UnitPower(self.unit)
				local pp = __5 / __4
				Spring:Update(powerSpring, pp)
				local __6 = UnitHealthMax(self.unit)
				healthBar:SetMinMaxValues(0, __6)
				shieldBar:SetMinMaxValues(0, __6)
				absorbBar:SetMinMaxValues(0, __6)
				local __7 = UnitHealth(self.unit)
				local __8 = UnitGetTotalAbsorbs(self.unit)
				healthSpring.absorb = __8
				Spring:Update(healthSpring, __7)
				local __9 = UnitGetTotalHealAbsorbs(self.unit)
				absorbBar:SetValue(__9)
				local __10 = UnitIsQuestBoss(self.unit)
				ToggleVisible(questIcon, __10)
				local __11 = UnitHasIncomingResurrection(self.unit)
				ToggleVisible(resserIcon, __11)
				local __12 = UnitGroupRolesAssigned(self.unit)
				UpdateRoleIcon(roleIcon, __12)
				local __13 = GetRaidTargetIndex(self.unit)
				UpdateRaidIcon(raidIcon, __13)
				local __14 = UnitInParty(self.unit)
				local __15 = UnitIsGroupLeader(self.unit)
				ToggleVisible(leaderIcon, (__14 and __15))
				local __16 = UnitIsGroupAssistant(self.unit)
				ToggleVisible(assistIcon, (__14 and __16))
				Stack(healthBar, "BOTTOMLEFT", "BOTTOMLEFT", 2, 4, "LEFT", "RIGHT", 4, 0, roleIcon, raidIcon, leaderIcon, assistIcon)
				Ticker:Add(self, true)
			elseif event == "GUID_MOD" then
				local __0 = UnitClassification(self.unit)
				SetUnitClassification(textLevel, __0)
				local __1 = UnitName(self.unit)
				textName:SetText(__1)
				local __2 = ClassColor(self.unit)
				local cr, cg, cb = unpack(__2)
				healthBar:SetStatusBarColor(cr, cg, cb)
				background:SetVertexColor(cr, cg, cb)
				local __3 = PowerColor(self.unit)
				local pr, pg, pb = unpack(__3)
				powerBar:SetStatusBarColor(pr, pg, pb)
				local __4 = UnitPowerMax(self.unit)
				local __5 = UnitPower(self.unit)
				local pp = __5 / __4
				Spring:Update(powerSpring, pp)
				local __6 = UnitHealthMax(self.unit)
				healthBar:SetMinMaxValues(0, __6)
				shieldBar:SetMinMaxValues(0, __6)
				absorbBar:SetMinMaxValues(0, __6)
				local __7 = UnitHealth(self.unit)
				local __8 = UnitGetTotalAbsorbs(self.unit)
				healthSpring.absorb = __8
				Spring:Update(healthSpring, __7)
				local __9 = UnitGetTotalHealAbsorbs(self.unit)
				absorbBar:SetValue(__9)
				local __10 = UnitIsQuestBoss(self.unit)
				ToggleVisible(questIcon, __10)
				local __11 = UnitHasIncomingResurrection(self.unit)
				ToggleVisible(resserIcon, __11)
				local __12 = UnitGroupRolesAssigned(self.unit)
				UpdateRoleIcon(roleIcon, __12)
				local __13 = GetRaidTargetIndex(self.unit)
				UpdateRaidIcon(raidIcon, __13)
				local __14 = UnitInParty(self.unit)
				local __15 = UnitIsGroupLeader(self.unit)
				ToggleVisible(leaderIcon, (__14 and __15))
				local __16 = UnitIsGroupAssistant(self.unit)
				ToggleVisible(assistIcon, (__14 and __16))
				Stack(healthBar, "BOTTOMLEFT", "BOTTOMLEFT", 2, 4, "LEFT", "RIGHT", 4, 0, roleIcon, raidIcon, leaderIcon, assistIcon)
				self:__tick()
			elseif event == "UNIT_CLASSIFICATION_CHANGED" then
				local __0 = UnitClassification(self.unit)
				SetUnitClassification(textLevel, __0)
				local __1 = UnitIsQuestBoss(self.unit)
				ToggleVisible(questIcon, __1)
			elseif event == "UNIT_NAME_UPDATE" then
				local __0 = UnitName(self.unit)
				textName:SetText(__0)
			elseif event == "GROUP_ROSTER_UPDATE" then
				local __0 = ClassColor(self.unit)
				local cr, cg, cb = unpack(__0)
				healthBar:SetStatusBarColor(cr, cg, cb)
				background:SetVertexColor(cr, cg, cb)
				local __1 = UnitInParty(self.unit)
				local __2 = UnitIsGroupLeader(self.unit)
				ToggleVisible(leaderIcon, (__1 and __2))
				local __3 = UnitIsGroupAssistant(self.unit)
				ToggleVisible(assistIcon, (__1 and __3))
				local __4 = GetRaidTargetIndex(self.unit)
				Stack(healthBar, "BOTTOMLEFT", "BOTTOMLEFT", 2, 4, "LEFT", "RIGHT", 4, 0, roleIcon, raidIcon, leaderIcon, assistIcon)
			elseif event == "UNIT_DISPLAYPOWER" then
				local __0 = PowerColor(self.unit)
				local pr, pg, pb = unpack(__0)
				powerBar:SetStatusBarColor(pr, pg, pb)
			elseif event == "UNIT_POWER_UPDATE" then
				local __0 = PowerColor(self.unit)
				local pr, pg, pb = unpack(__0)
				powerBar:SetStatusBarColor(pr, pg, pb)
				local __1 = UnitPowerMax(self.unit)
				local __2 = UnitPower(self.unit)
				local pp = __2 / __1
				Spring:Update(powerSpring, pp)
			elseif event == "UNIT_MAXPOWER" then
				local __0 = UnitPowerMax(self.unit)
				local __1 = UnitPower(self.unit)
				local pp = __1 / __0
				Spring:Update(powerSpring, pp)
			elseif event == "UNIT_POWER_FREQUENT" then
				local __0 = UnitPowerMax(self.unit)
				local __1 = UnitPower(self.unit)
				local pp = __1 / __0
				Spring:Update(powerSpring, pp)
			elseif event == "UNIT_MAXHEALTH" then
				local __0 = UnitHealthMax(self.unit)
				healthBar:SetMinMaxValues(0, __0)
				shieldBar:SetMinMaxValues(0, __0)
				absorbBar:SetMinMaxValues(0, __0)
			elseif event == "UNIT_HEALTH" then
				local __0 = UnitHealth(self.unit)
				local __1 = UnitGetTotalAbsorbs(self.unit)
				healthSpring.absorb = __1
				Spring:Update(healthSpring, __0)
			elseif event == "UNIT_ABSORB_AMOUNT_CHANGED" then
				local __0 = UnitHealth(self.unit)
				local __1 = UnitGetTotalAbsorbs(self.unit)
				healthSpring.absorb = __1
				Spring:Update(healthSpring, __0)
			elseif event == "UNIT_HEAL_ABSORB_AMOUNT_CHANGED" then
				local __0 = UnitGetTotalHealAbsorbs(self.unit)
				absorbBar:SetValue(__0)
			elseif event == "PLAYER_TARGET_CHANGED" then
				if not UnitExists(self.unit) then return end
				local max = UnitPowerMax(self.unit)
				if max == 0 then
					Spring:Stop(powerSpring, 0)
				else
					Spring:Stop(powerSpring, UnitPower(self.unit) / max)
				end
				healthSpring.absorb = UnitGetTotalAbsorbs(self.unit)
				Spring:Stop(healthSpring, UnitHealth(self.unit))
			elseif event == "INCOMING_RESURRECT_CHANGED" then
				local __0 = UnitHasIncomingResurrection(self.unit)
				ToggleVisible(resserIcon, __0)
			elseif event == "PLAYER_ROLES_ASSIGNED" then
				local __0 = UnitGroupRolesAssigned(self.unit)
				UpdateRoleIcon(roleIcon, __0)
			elseif event == "RAID_TARGET_UPDATE" then
				local __0 = GetRaidTargetIndex(self.unit)
				UpdateRaidIcon(raidIcon, __0)
				local __1 = UnitIsGroupLeader(self.unit)
				local __2 = UnitIsGroupAssistant(self.unit)
				Stack(healthBar, "BOTTOMLEFT", "BOTTOMLEFT", 2, 4, "LEFT", "RIGHT", 4, 0, roleIcon, raidIcon, leaderIcon, assistIcon)
			elseif event == "PARTY_LEADER_CHANGED" then
				local __0 = UnitInParty(self.unit)
				local __1 = UnitIsGroupLeader(self.unit)
				ToggleVisible(leaderIcon, (__0 and __1))
				local __2 = UnitIsGroupAssistant(self.unit)
				local __3 = GetRaidTargetIndex(self.unit)
				Stack(healthBar, "BOTTOMLEFT", "BOTTOMLEFT", 2, 4, "LEFT", "RIGHT", 4, 0, roleIcon, raidIcon, leaderIcon, assistIcon)
			elseif event == "GUID_REM" then
				Ticker:Remove(self)
			end
		end
		self:SetAttribute("unit", "target")
		RegisterUnitWatch(self)
		self:SetSize(376, 64)
		self:SetPoint("LEFT", playerButton, "RIGHT", 16, 0)
		DisableBlizzard("target")
		local castbar = CreateCastBar(UI, "target", 32)
		castbar:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -16)
		castbar:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -16)
	end
	do
		local self = CreateFrame("frame", "SquishPartyHeader", UI, "SecureGroupHeaderTemplate")
		self:SetAttribute("showRaid", true)
		self:SetAttribute("showParty", true)
		self:SetAttribute("showPlayer", true)
		self:SetAttribute("showSolo", true)
		self:SetAttribute("point", "RIGHT")
		self:SetAttribute("columnAnchorPoint", "BOTTOM")
		self:SetAttribute("xOffset", -2)
		self:SetAttribute("yOffset", 0)
		self:SetAttribute("groupBy", "GROUP")
		self:SetAttribute("groupingOrder", "1,2,3,4,5,6,7,8")
		self:SetAttribute("template", "SecureActionButtonTemplate,BackdropTemplate")
		self:SetAttribute("initialConfigFunction", [[
      self:SetWidth(74)
      self:SetHeight(128)
      self:GetParent():CallMethod('ConfigureButton', self:GetName())
    ]])
		local UNIT_AURA_HELPFUL = {}
		local UNIT_AURA_HARMFUL = {}
		local positive = {}
		local negative = {}
		--for id, spell in pairs(SPELLS.Positive) do
		--if spell[SPELL_SOURCE] == "UNIT_AURA_HELPFUL" then
		--UNIT_AURA_HELPFUL[id] = {}
		--UNIT_AURA_HELPFUL[id].priority = spell[SPELL_PRIORITY]
		--UNIT_AURA_HELPFUL[id].collection = positive
		--elseif spell[SPELL_SOURCE] == "UNIT_AURA_HARMFUL" then
		--UNIT_AURA_HARMFUL[id] = {}
		--UNIT_AURA_HARMFUL[id].priority = spell[SPELL_PRIORITY]
		--UNIT_AURA_HARMFUL[id].collection = positive
		--end
		--end
		--for id, spell in pairs(SPELLS.Negative) do
		--if spell[SPELL_SOURCE] == "UNIT_AURA_HARMFUL" then
		--UNIT_AURA_HARMFUL[id] = {}
		--UNIT_AURA_HARMFUL[id].priority = spell[SPELL_PRIORITY]
		--UNIT_AURA_HARMFUL[id].collection = negative
		--elseif spell[SPELL_SOURCE] == "UNIT_AURA_HELPFUL" then
		--UNIT_AURA_HELPFUL[id] = {}
		--UNIT_AURA_HELPFUL[id].priority = spell[SPELL_PRIORITY]
		--UNIT_AURA_HELPFUL[id].collection = negative
		--end
		--end
		local function UpdateUnitAuras(button)
			button.auraAttonement:Hide()
			AuraTable_Clear(positive)
			AuraTable_Clear(negative)
			for index = 1, 40 do
				local _, icon, stack, kind, duration, expiration, _, _, _, id = UnitAura(button.unit, index, "HELPFUL")
				if not id then
					break
				end
				local entry = UNIT_AURA_HELPFUL[id]
				if entry then
					AuraTable_Insert(entry.collection, entry.priority, index, icon, duration, expiration, nil, stack)
				end
				if id == button.auraAttonement.spellID then
					button.auraAttonement:Show()
					button.auraAttonement.cd:SetCooldown(expiration - duration, duration)
				end
			end
			for index = 1, 40 do
				local _, icon, count, kind, duration, expiration, _, _, _, id, _, boss = UnitAura(button.unit, index, "HARMFUL")
				if not id then
					break
				end
				local entry = UNIT_AURA_HARMFUL[id]
				if entry then
					local priority = entry.priority + (boss and 1 or 0) + (CanDispel[kind] and 1 or 0)
					AuraTable_Insert(entry.collection, priority, index, icon, duration, expiration, kind, count)
				else
					local priority = (boss and 1 or 0) + (CanDispel[kind] and 1 or 0)
					AuraTable_Insert(negative, priority, index, icon, duration, expiration, kind, count)
				end
			end
			AuraTable_Write(positive, button.unit, "HELPFUL", button[1], button[2], button[3])
			AuraTable_Write(negative, button.unit, "HARMFUL", button[4], button[5], button[6], button[7])
			button[2]:SetPoint("TOP", button, "BOTTOM", CountVisible(button[3]) * -13, -1)
			button[5]:SetPoint("BOTTOM", button, "TOP", CountVisible(button[6], button[7]) * -12.5, 1)
		end
		local OnEvent
		function self:ConfigureButton(name)
			local self = _G[name]
			self:RegisterForClicks("AnyUp")
			self:SetAttribute("*type1", "target")
			self:SetAttribute("*type2", "togglemenu")
			self:SetAttribute("toggleForVehicle", true)
			self:SetScript("OnAttributeChanged", OnAttributeChanged)
			self:SetBackdrop(MEDIA:BACKDROP(true, false, 1, 0))
			self:SetBackdropColor(0, 0, 0, 0.75)
			--self:SetBackdropBorderColor(0, 0, 0, 0.75)
			RegisterUnitWatch(self)
			self.handler = OnEvent
			self.background = self:CreateTexture(nil, "BACKGROUND", nil, -7)
			self.background:SetTexture(MEDIA:STATUSBAR())
			self.background:SetVertexColor(1, 1, 1, 0.75)
			self.background:SetPoint("TOPLEFT", -2, 2)
			self.background:SetPoint("BOTTOMRIGHT", 2, -2)
			self.background:Hide()
			self.healthBar = CreateFrame("statusbar", nil, self)
			self.healthBar:SetMinMaxValues(0, 1)
			self.healthBar:SetStatusBarTexture(MEDIA:STATUSBAR())
			self.healthBar:SetPoint("TOPLEFT", 1, -1)
			self.healthBar:SetPoint("BOTTOMRIGHT", -1, 1)
			self.healthBar:SetOrientation("VERTICAL")
			self.healthBar:SetFrameLevel(3)
			self.shieldBar = CreateFrame("statusbar", nil, self)
			self.shieldBar:SetMinMaxValues(0, 1)
			self.shieldBar:SetStatusBarTexture(MEDIA:STATUSBAR())
			self.shieldBar:SetAllPoints(self.healthBar)
			self.shieldBar:SetStatusBarColor(0.0, 1.0, 1.0, 0.75)
			self.shieldBar:SetOrientation("VERTICAL")
			self.shieldBar:SetFrameLevel(2)
			self.absorbBar = CreateFrame("statusbar", nil, self)
			self.absorbBar:SetMinMaxValues(0, 1)
			self.absorbBar:SetStatusBarTexture(MEDIA:STATUSBAR())
			self.absorbBar:SetAllPoints(self.healthBar)
			self.absorbBar:SetStatusBarColor(1.0, 0.0, 0.0, 0.5)
			self.absorbBar:SetOrientation("VERTICAL")
			self.absorbBar:SetFrameLevel(4)
			self.healthSpring = Spring:Create(
				function(spring, health)
					self.healthBar:SetValue(health)
					self.shieldBar:SetValue(health + spring.absorb)
				end,
				280,
				30,
				0.1
			)
			self.textName = self.healthBar:CreateFontString(nil, nil, "GameFontNormal")
			self.textName:SetPoint("CENTER", 0, 0)
			self.textName:SetFont(MEDIA:FONT(), 14, "OUTLINE")
			self.textStatus = self.healthBar:CreateFontString(nil, nil, "GameFontNormal")
			self.textStatus:SetFont(MEDIA:FONT(), 12)
			self.textStatus:SetPoint("BOTTOM", self, "BOTTOM", 0, 24)
			self.auraAttonement = CreateFrame("frame", nil, self, "BackdropTemplate")
			self.auraAttonement:SetSize(20, 20)
			self.auraAttonement.cd = CreateFrame("cooldown", nil, self.auraAttonement, "CooldownFrameTemplate")
			self.auraAttonement.cd:SetReverse(true)
			--local function Square(parent, id, size, r, g, b, a, point, x, y)
			--local t = {}
			--t.frame = CreateFrame("frame", nil, parent)
			--t.frame:SetBackdrop({
			--bgFile = 'Interface\Addons\Squish\media\backdrop.tga',
			--insets = { left = 0, right = 0, top = 0, bottom = 0 },
			--})
			--t.frame:SetBackdropColor(r, g, b, a)
			--t.frame:SetSize(size, size)
			--t.frame:SetPoint(point, x, y)
			--t.frame:SetFrameLevel(5)
			--t.frame:Hide()
			--t.cd = CreateFrame("cooldown", nil, t.frame, "CooldownFrameTemplate")
			--t.cd:SetReverse(true)
			--t.id = id
			--return t
			self.auraAttonement:SetPoint("TOPRIGHT", -2, -2)
			self.auraAttonement:SetBackdrop(MEDIA:BACKDROP(true, nil, 0, 0))
			self.auraAttonement:SetBackdropColor(1, 1, 0)
			self.auraAttonement.spellID = 194384
			self.resserIcon = self.healthBar:CreateTexture(nil, "OVERLAY")
			self.resserIcon:SetSize(32, 32)
			self.resserIcon:SetTexture([[Interface\RaidFrame\Raid-Icon-Rez]])
			self.resserIcon:SetPoint("CENTER", 0, 0)
			self.roleIcon = self.healthBar:CreateTexture(nil, "OVERLAY")
			self.roleIcon:SetSize(20, 20)
			self.roleIcon:SetTexture([[Interface\LFGFrame\UI-LFG-ICON-PORTRAITROLES]])
			--self.roleIcon:SetTexture([[Interface\LFGFrame\UI-LFG-ICON-ROLES]])
			self.raidIcon = self.healthBar:CreateTexture(nil, "OVERLAY")
			self.raidIcon:SetSize(22, 22)
			self.raidIcon:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]])
			self.leaderIcon = self.healthBar:CreateTexture(nil, "OVERLAY")
			self.leaderIcon:SetSize(18, 18)
			self.leaderIcon:SetTexture([[Interface\GroupFrame\UI-Group-LeaderIcon]])
			self.assistIcon = self.healthBar:CreateTexture(nil, "OVERLAY")
			self.assistIcon:SetSize(18, 18)
			self.assistIcon:SetTexture([[Interface\GroupFrame\UI-Group-AssistantIcon]])
			self.__tick = RangeChecker
			-- large buff icon
			table.insert(self, CreateAuraIcon_Bar(self, 37, 16))
			self[1]:SetPoint("BOTTOM", self, "BOTTOM", 0, 4)
			-- smaller buff icons
			table.insert(self, CreateAuraIcon_Bar(self, 25))
			table.insert(self, CreateAuraIcon_Bar(self, 25))
			Stack(self, "TOP", "BOTTOM", 0, -1, "LEFT", "RIGHT", 1, 0, self[2], self[3])
			-- large debuff icons
			table.insert(self, CreateAuraIcon_Bar(self, 72, 28, 28))
			self[4]:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 1, 26)
			self[4].priority = 5
			-- small debuff icons
			table.insert(self, CreateAuraIcon_Bar(self, 24))
			table.insert(self, CreateAuraIcon_Bar(self, 24))
			table.insert(self, CreateAuraIcon_Bar(self, 24))
			Stack(self, "BOTTOM", "TOP", -25, 1, "LEFT", "RIGHT", 1, 0, self[5], self[6], self[7])
			for i = 5, 7 do
				self[i].priority = 1
			end
		end
		function OnEvent(self, event, ...)
			if event == "UNIT_SET" then
				self:RegisterEvent("GROUP_ROSTER_UPDATE")
				self:RegisterEvent("INCOMING_RESURRECT_CHANGED")
				self:RegisterEvent("PLAYER_ROLES_ASSIGNED")
				self:RegisterEvent("RAID_TARGET_UPDATE")
				self:RegisterEvent("PARTY_LEADER_CHANGED")
				self:RegisterEvent("PLAYER_TARGET_CHANGED")
				self:RegisterUnitEvent("UNIT_MAXHEALTH", self.unit)
				self:RegisterUnitEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED", self.unit)
				self:RegisterUnitEvent("UNIT_HEALTH", self.unit)
				self:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", self.unit)
				self:RegisterUnitEvent("UNIT_NAME_UPDATE", self.unit)
				self:RegisterUnitEvent("UNIT_CONNECTION", self.unit)
				self:RegisterUnitEvent("UNIT_AURA", self.unit)
			elseif event == "UNIT_MOD" then
				self:RegisterUnitEvent("UNIT_MAXHEALTH", self.unit)
				self:RegisterUnitEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED", self.unit)
				self:RegisterUnitEvent("UNIT_HEALTH", self.unit)
				self:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", self.unit)
				self:RegisterUnitEvent("UNIT_NAME_UPDATE", self.unit)
				self:RegisterUnitEvent("UNIT_CONNECTION", self.unit)
				self:RegisterUnitEvent("UNIT_AURA", self.unit)
			elseif event == "UNIT_REM" then
				self:UnregisterEvent("GROUP_ROSTER_UPDATE")
				self:UnregisterEvent("UNIT_MAXHEALTH")
				self:UnregisterEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED")
				self:UnregisterEvent("UNIT_HEALTH")
				self:UnregisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")
				self:UnregisterEvent("UNIT_NAME_UPDATE")
				self:UnregisterEvent("UNIT_CONNECTION")
				self:UnregisterEvent("INCOMING_RESURRECT_CHANGED")
				self:UnregisterEvent("PLAYER_ROLES_ASSIGNED")
				self:UnregisterEvent("RAID_TARGET_UPDATE")
				self:UnregisterEvent("PARTY_LEADER_CHANGED")
				self:UnregisterEvent("UNIT_AURA")
				self:UnregisterEvent("PLAYER_TARGET_CHANGED")
			elseif event == "GUID_SET" then
				local __0 = ClassColor(self.unit)
				local cr, cg, cb = unpack(__0)
				self.healthBar:SetStatusBarColor(cr, cg, cb)
				local __1 = UnitHealthMax(self.unit)
				self.healthBar:SetMinMaxValues(0, __1)
				self.shieldBar:SetMinMaxValues(0, __1)
				self.absorbBar:SetMinMaxValues(0, __1)
				local __2 = UnitGetTotalHealAbsorbs(self.unit)
				self.absorbBar:SetValue(__2)
				local __3 = UnitHealth(self.unit)
				local __4 = UnitGetTotalAbsorbs(self.unit)
				self.healthSpring.absorb = __4
				Spring:Update(self.healthSpring, __3)
				local __5 = UnitName(self.unit)
				self.textName:SetText(__5:sub(1, 5))
				local __6 = UnitIsDead(self.unit)
				local __7 = UnitIsGhost(self.unit)
				local __8 = UnitIsConnected(self.unit)
				SetUnitStatus(self.textStatus, __6, __7, __8)
				local __9 = UnitHasIncomingResurrection(self.unit)
				ToggleVisible(self.resserIcon, __9)
				local __10 = UnitGroupRolesAssigned(self.unit)
				UpdateRoleIcon(self.roleIcon, __10)
				local __11 = GetRaidTargetIndex(self.unit)
				UpdateRaidIcon(self.raidIcon, __11)
				local __12 = UnitInParty(self.unit)
				local __13 = UnitIsGroupLeader(self.unit)
				ToggleVisible(self.leaderIcon, (__12 and __13))
				local __14 = UnitIsGroupAssistant(self.unit)
				ToggleVisible(self.assistIcon, (__12 and __14))
				Stack(self.healthBar, "BOTTOMLEFT", "BOTTOMLEFT", -3, -6, "BOTTOM", "TOP", 0, 0, self.roleIcon, self.raidIcon, self.leaderIcon, self.assistIcon)
				Ticker:Add(self, true)
				UpdateUnitAuras(self)
				if UnitIsUnit(self.unit, "playertarget") then
					self.background:Show()
				else
					self.background:Hide()
				end
			elseif event == "GUID_MOD" then
				local __0 = ClassColor(self.unit)
				local cr, cg, cb = unpack(__0)
				self.healthBar:SetStatusBarColor(cr, cg, cb)
				local __1 = UnitHealthMax(self.unit)
				self.healthBar:SetMinMaxValues(0, __1)
				self.shieldBar:SetMinMaxValues(0, __1)
				self.absorbBar:SetMinMaxValues(0, __1)
				local __2 = UnitGetTotalHealAbsorbs(self.unit)
				self.absorbBar:SetValue(__2)
				local __3 = UnitHealth(self.unit)
				local __4 = UnitGetTotalAbsorbs(self.unit)
				self.healthSpring.absorb = __4
				Spring:Stop(self.healthSpring, __3)
				local __5 = UnitName(self.unit)
				self.textName:SetText(__5:sub(1, 5))
				local __6 = UnitIsDead(self.unit)
				local __7 = UnitIsGhost(self.unit)
				local __8 = UnitIsConnected(self.unit)
				SetUnitStatus(self.textStatus, __6, __7, __8)
				local __9 = UnitHasIncomingResurrection(self.unit)
				ToggleVisible(self.resserIcon, __9)
				local __10 = UnitGroupRolesAssigned(self.unit)
				UpdateRoleIcon(self.roleIcon, __10)
				local __11 = GetRaidTargetIndex(self.unit)
				UpdateRaidIcon(self.raidIcon, __11)
				local __12 = UnitInParty(self.unit)
				local __13 = UnitIsGroupLeader(self.unit)
				ToggleVisible(self.leaderIcon, (__12 and __13))
				local __14 = UnitIsGroupAssistant(self.unit)
				ToggleVisible(self.assistIcon, (__12 and __14))
				Stack(self.healthBar, "BOTTOMLEFT", "BOTTOMLEFT", -3, -6, "BOTTOM", "TOP", 0, 0, self.roleIcon, self.raidIcon, self.leaderIcon, self.assistIcon)
				self:__tick()
				UpdateUnitAuras(self)
				if UnitIsUnit(self.unit, "playertarget") then
					self.background:Show()
				else
					self.background:Hide()
				end
			elseif event == "GROUP_ROSTER_UPDATE" then
				local __0 = ClassColor(self.unit)
				local cr, cg, cb = unpack(__0)
				self.healthBar:SetStatusBarColor(cr, cg, cb)
				local __1 = UnitInParty(self.unit)
				local __2 = UnitIsGroupLeader(self.unit)
				ToggleVisible(self.leaderIcon, (__1 and __2))
				local __3 = UnitIsGroupAssistant(self.unit)
				ToggleVisible(self.assistIcon, (__1 and __3))
				local __4 = GetRaidTargetIndex(self.unit)
				Stack(self.healthBar, "BOTTOMLEFT", "BOTTOMLEFT", -3, -6, "BOTTOM", "TOP", 0, 0, self.roleIcon, self.raidIcon, self.leaderIcon, self.assistIcon)
			elseif event == "UNIT_MAXHEALTH" then
				local __0 = UnitHealthMax(self.unit)
				self.healthBar:SetMinMaxValues(0, __0)
				self.shieldBar:SetMinMaxValues(0, __0)
				self.absorbBar:SetMinMaxValues(0, __0)
			elseif event == "UNIT_HEAL_ABSORB_AMOUNT_CHANGED" then
				local __0 = UnitGetTotalHealAbsorbs(self.unit)
				self.absorbBar:SetValue(__0)
			elseif event == "UNIT_HEALTH" then
				local __0 = UnitHealth(self.unit)
				local __1 = UnitGetTotalAbsorbs(self.unit)
				self.healthSpring.absorb = __1
				Spring:Update(self.healthSpring, __0)
				local __2 = UnitIsDead(self.unit)
				local __3 = UnitIsGhost(self.unit)
				local __4 = UnitIsConnected(self.unit)
				SetUnitStatus(self.textStatus, __2, __3, __4)
			elseif event == "UNIT_ABSORB_AMOUNT_CHANGED" then
				local __0 = UnitHealth(self.unit)
				local __1 = UnitGetTotalAbsorbs(self.unit)
				self.healthSpring.absorb = __1
				Spring:Update(self.healthSpring, __0)
			elseif event == "UNIT_NAME_UPDATE" then
				local __0 = UnitName(self.unit)
				self.textName:SetText(__0:sub(1, 5))
			elseif event == "UNIT_CONNECTION" then
				local __0 = UnitIsDead(self.unit)
				local __1 = UnitIsGhost(self.unit)
				local __2 = UnitIsConnected(self.unit)
				SetUnitStatus(self.textStatus, __0, __1, __2)
			elseif event == "INCOMING_RESURRECT_CHANGED" then
				local __0 = UnitHasIncomingResurrection(self.unit)
				ToggleVisible(self.resserIcon, __0)
			elseif event == "PLAYER_ROLES_ASSIGNED" then
				local __0 = UnitGroupRolesAssigned(self.unit)
				UpdateRoleIcon(self.roleIcon, __0)
			elseif event == "RAID_TARGET_UPDATE" then
				local __0 = GetRaidTargetIndex(self.unit)
				UpdateRaidIcon(self.raidIcon, __0)
				local __1 = UnitIsGroupLeader(self.unit)
				local __2 = UnitIsGroupAssistant(self.unit)
				Stack(self.healthBar, "BOTTOMLEFT", "BOTTOMLEFT", -3, -6, "BOTTOM", "TOP", 0, 0, self.roleIcon, self.raidIcon, self.leaderIcon, self.assistIcon)
			elseif event == "PARTY_LEADER_CHANGED" then
				local __0 = UnitInParty(self.unit)
				local __1 = UnitIsGroupLeader(self.unit)
				ToggleVisible(self.leaderIcon, (__0 and __1))
				local __2 = UnitIsGroupAssistant(self.unit)
				local __3 = GetRaidTargetIndex(self.unit)
				Stack(self.healthBar, "BOTTOMLEFT", "BOTTOMLEFT", -3, -6, "BOTTOM", "TOP", 0, 0, self.roleIcon, self.raidIcon, self.leaderIcon, self.assistIcon)
			elseif event == "GUID_REM" then
				Ticker:Remove(self)
			elseif event == "UNIT_AURA" then
				UpdateUnitAuras(self)
			elseif event == "PLAYER_TARGET_CHANGED" then
				if UnitIsUnit(self.unit, "playertarget") then
					self.background:Show()
				else
					self.background:Hide()
				end
			end
		end
		self:SetPoint("BOTTOMRIGHT", playerButton, "TOPRIGHT", 1, 100)
		self:Show()
	end
	HookSpellBookTooltips = nil
	ScanGameTooltips = nil
	DisableBlizzard = nil
	CreateCastBar = nil
	CreateCooldowns = nil
	CreatePlayerBuffs = nil
end)
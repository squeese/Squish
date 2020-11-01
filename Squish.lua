BINDING_HEADER_SQUISH = "Squish"
BINDING_NAME_SPELLS_TOGGLE = "Toggle Spells Panel"
local ClassColor
local PowerColor
do
	local COLOR_CLASS
	local COLOR_POWER
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
local CreateSpring
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
	local insert = table.insert
	local remove = table.remove
	local floor = math.floor
	local abs = math.abs
	local function update(s, elapsed)
		s.__update_e = s.__update_e + elapsed
		local delta = (s.__update_e - floor(s.__update_e / MPF) * MPF) / MPF
		local frames = floor(s.__update_e / MPF)
		for i = 0, frames - 1 do
			s.__update_C, s.__update_V = stepper(s.__update_C, s.__update_V, s.__update_t, s.__update_k, s.__update_b)
		end
		local c, v = stepper(s.__update_C, s.__update_V, s.__update_t, s.__update_k, s.__update_b)
		s.__update_c = s.__update_C + (c - s.__update_C) * delta
		s.__update_v = s.__update_V + (v - s.__update_V) * delta
		s.__update_e = s.__update_e - frames * MPF
	end
	local function idle(s)
		if (abs(s.__update_v) < s.__update_p and abs(s.__update_c - s.__update_t) < s.__update_p) then
			s.__update_c = s.__update_t
			s.__update_C = s.__update_t
			s.__update_v = 0
			s.__update_V = 0
			s.__update_e = 0
			return true
		end
		return false
	end
	local frame = CreateFrame("frame", nil, UIParent)
	local SPRING = {}
	SPRING.__index = SPRING
	local function OnUpdate(_, elapsed)
		local elapsedMS = elapsed * 1000
		local elapsedDT = elapsedMS / MPF
		for i = #SPRING, 1, -1 do
			local s = SPRING[i]
			if idle(s) then
				s.__active = nil
				remove(SPRING, i)
				if #SPRING == 0 then
					frame:SetScript("OnUpdate", nil)
				end
			else
				update(s, elapsedMS)
			end
			s.__update_fn(s, s.__update_c)
		end
	end
	function CreateSpring(FN, K, B, P)
		return setmetatable(
			{
				__update_fn = FN,
				__initialized = false,
				__update_p = P or 0.01,
				__update_k = K or 170,
				__update_b = B or 26
			},
			SPRING
		)
	end
	function SPRING:__call(target)
		if not self.__initialized then
			self.__initialized = true
			self.__update_c = target
			self.__update_C = target
			self.__update_v = 0
			self.__update_V = 0
			self.__update_e = 0
		end
		self.__update_t = target
		if not self.__active then
			self.__active = true
			if #SPRING == 0 then
				frame:SetScript("OnUpdate", OnUpdate)
			end
			insert(SPRING, self)
		end
	end
	function SPRING:stop(target)
		self.__update_t = target
		self.__update_c = target
		self.__update_C = target
		self.__update_v = 0
		self.__update_V = 0
		self.__update_e = 0
		if self.__active then
			self.__active = nil
			for i = 1, #SPRING do
				if self == SPRING[i] then
					remove(SPRING, i)
					break
				end
			end
			if #SPRING == 0 then
				frame:SetScript("OnUpdate", nil)
			end
		end
		self.__update_fn(self, target)
	end
end
local MEDIA = {}
do
	local bgFlat = [[Interface\Addons\Squish\media\backdrop.tga]]
	local edgeFile = [[Interface\Addons\Squish\media\edgeFile.tga]]
	local barFlat = [[Interface\Addons\Squish\media\flat.tga]]
	local barMini = [[Interface\Addons\Squish\media\minimalist.tga]]
	local vixar = [[interface\addons\squish\media\vixar.ttf]]
	function MEDIA:BACKDROP(bg, edge, edgeSize, inset)
		return {
			bgFile = bg and bgFlat,
			edgeFile = edge and edgeFile,
			edgeSize = edgeSize,
			insets = {
				left = inset,
				right = inset,
				top = inset,
				bottom = inset
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
local function OnEnter_AuraButton(self)
	if not self:IsVisible() then return end
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
	GameTooltip:SetUnitAura(self.unit, self.index, self.filter)
end
local function OnLeave_AuraButton()
	GameTooltip:Hide()
end
local OnAttributeChanged_AuraButton
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
		local insert = table.insert
		function ticker:insert(button)
			button.padd = 0
			SetDuration(button, GetTime())
			if button.active then return end
			button.active = true
			insert(self, button)
		end
		local remove = table.remove
		function ticker:remove(button)
			if not button.active then return end
			button.active = false
			for i = 1, #self do
				if button == self[i] then
					remove(self, i)
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
local function OnEvent_PlayerTarget(self, event)
	local guid = UnitGUID("playertarget")
	local header = self.header
	if guid then
		for index = 1, #header do
			if header[index].guid == guid then
				self.playerTargetAlpha(1)
				return self.playerTargetPosition(index)
			end
		end
	end
	self.playerTargetAlpha(0)
end
local function Ticker_BossTarget(self)
end
local function AuraList_Push(list, ...)
	local length = select("#", ...)
	for i = 1, length do
		list[i + list.cursor] = select(i, ...)
	end
	list.cursor = list.cursor + length
end
local OnEvent_SpellCollector
do
	--SquishData.TEST = nil
	--SquishData.SCAN = {}
	--GetInstanceInfo()
	local function GetEntry(tbl, key)
		if not tbl[key] then
			tbl[key] = {}
		end
		return tbl[key]
	end
	local function IncEntry(tbl, key)
		tbl[key] = (tbl[key] or 0) + 1
	end
	local function OnEvent_CEUF(_, event, _, sourceGUID, sourceName, sourceFlag, _, destGUID, destName, destFlag, _, spellID, spellName)
		if not spellID or not spellName then
			print("skip", event, spellID, spellName)
			return
		end
		local db = GetEntry(SquishData.SCAN, spellID)
		IncEntry(db, event)
		IncEntry(GetEntry(db, "sourceFlag"), sourceFlag)
		IncEntry(GetEntry(db, "destFlag"), destFlag)
		if sourceGUID and sourceGUID ~= " " and bit.band(sourceFlag, COMBATLOG_OBJECT_CONTROL_PLAYER) > 0 then
			local _, sourceClass = GetPlayerInfoByGUID(sourceGUID)
			if sourceClass then
				IncEntry(GetEntry(db, "sourceClass"), sourceClass)
			end
		end
		if destGUID and destGUID ~= " " and bit.band(destFlag, COMBATLOG_OBJECT_CONTROL_PLAYER) > 0 then
			local _, destFlag = GetPlayerInfoByGUID(destGUID)
			if destClass then
				IncEntry(GetEntry(db, "destClass"), destClass)
			end
		end
	end
	function OnEvent_SpellCollector(self, event, ...)
		OnEvent_CEUF(CombatLogGetCurrentEventInfo())
	end
end
local function AuraTable_Clear(tbl)
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
	local insert = table.insert
	function AuraTable_Insert(t, priority, ...)
		for i = 1, t.cursor do
			if priority > t[t[i]] then
				t.cursor = t.cursor + 1
				insert(t, i, t.offset)
				t.offset = t.offset + write(t, t.offset - 1, priority, ...)
				return
			end
		end
		t.cursor = t.cursor + 1
		t[t.cursor] = t.offset
		t.offset = t.offset + write(t, t.offset - 1, priority, ...)
	end
end
local RangeChecker = {}
do
	RangeChecker.__frame = CreateFrame("frame", nil, UIParent)
	RangeChecker.__index = RangeChecker
	setmetatable(RangeChecker, RangeChecker)
	local insert = table.insert
	local remove = table.remove
	local elapsed = 0
	local function OnUpdate(_, e)
		elapsed = elapsed + e
		if elapsed > 0.15 then
			for index = 1, #RangeChecker do
				RangeChecker:Update(RangeChecker[index])
			end
			elapsed = 0
		end
	end
	function RangeChecker:Update(button)
		if UnitIsConnected(button.unit) then
			local close, checked = UnitInRange(button.unit)
			if checked and not close then
				button:SetAlpha(0.45)
				--button.__range(button, 0.45)
			else
				button:SetAlpha(1.0)
			end
		else
			button:SetAlpha(1.0)
		end
	end
	function RangeChecker:Register(button, doUpdate)
		if #self == 0 then
			elapsed = 0
			self.__frame:SetScript("OnUpdate", OnUpdate)
		end
		for index = 1, #self do
			assert(#self[index] ~= button)
		end
		table.insert(self, button)
		if doUpdate then
			self:Update(button)
		end
	end
	function RangeChecker:Unregister(button)
		for index = 1, #self do
			if button == self[index] then
				remove(self, index)
				break
			end
		end
		for index = 1, #self do
			assert(#self[index] ~= button)
		end
		button:SetAlpha(1)
		if #self == 0 then
			self.__frame:SetScript("OnUpdate", nil)
		end
	end
end
local Ticker = {}
do
	Ticker.__frame = CreateFrame("frame", nil, UIParent)
	Ticker.__index = Ticker
	local remove = table.remove
	local insert = table.insert
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
	insert(Ticker, Ticker)
	function Ticker:__tick()
		cursor = #self
		msWait = 1.0 / cursor
	end
	function Ticker:Remove(tbl)
		for index = 1, #self do
			if tbl == self[index] then
				remove(self, index)
				break
			end
		end
		for index = 1, #self do
			assert(#self[index] ~= tbl)
		end
		if #self == 1 then
			--self.__frame:SetScript("OnUpdate", nil)
		end
	end
	function Ticker:Add(tbl, doUpdate)
		for index = 1, #self do
			assert(#self[index] ~= tbl)
		end
		if #self == 1 then
			elapsed = 0
			cursor = 2
			--self.__frame:SetScript("OnUpdate", OnUpdate_Ticker)
		end
		insert(self, tbl)
		print("added", elapsed, cursor, #self)
	end
end
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
local function CreateAuraIcon(parent, size)
	local icon = CreateFrame("frame", nil, parent, "BackdropTemplate")
	icon:SetBackdrop(MEDIA:BACKDROP(true, false, 0, 0))
	icon:SetBackdropColor(0, 0, 0, 0.75)
	icon:SetSize(size, size)
	icon.texture = icon:CreateTexture()
	icon.texture:SetPoint("TOPLEFT", 1, -1)
	icon.texture:SetPoint("BOTTOMRIGHT", -1, 1)
	icon.texture:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	icon.cd = CreateFrame("cooldown", nil, icon, "CooldownFrameTemplate")
	return icon
end
local function UpdateRoleIcon(element, role)
	if role ~= "NONE" then -- == 'TANK' or role == 'HEALER' then
		element:SetTexCoord(GetTexCoordsForRole(role))
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
local BossTarget
do
	local function OnUpdate(self, elapsed)
		self.elapsed = self.elapsed + elapsed
		if self.elapsed > 0.05 then
			local guid = UnitGUID("playertarget")
			if guid ~= self.current then
				self.current = guid
				self:handler(self.current)
			end
			self.elapsed = 0
		end
	end
	function BossTarget(parent, handler)
		local frame = CreateFrame("frame", nil, parent, "BackdropTemplate")
		frame:SetSize(parent:GetWidth(), parent:GetHeight())
		frame:SetPoint("BOTTOMRIGHT", 0, 28)
		frame:SetAlpha(0)
		frame:SetBackdrop(MEDIA:BACKDROP(true, nil, 0, 0))
		frame:SetBackdropColor(0, 0, 0, 0.5)
		frame.elapsed = 0
		frame.current = nil
		frame:SetScript("OnUpdate", OnUpdate)
		return frame
	end
end
do
	local Section_Spells = {
		title = "Spells",
		icon = 237542
	}
	do
		local function OnEnter_Row(self)
			if self.spellID then
				local r, g, b = self:GetBackdropColor()
				self:SetBackdropColor(r, g, b, 0.35)
				GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
				GameTooltip:SetSpellByID(self.spellID)
				GameTooltip:Show()
			end
		end
		local function OnLeave_Row(self)
			local r, g, b = self:GetBackdropColor()
			self:SetBackdropColor(r, g, b, 0.25)
			GameTooltip:Hide()
		end
		local function OnClick_CheckButton(button)
			local row = button:GetParent()
			SquishData.SpellsData[row.spellID][button.field] = not SquishData.SpellsData[row.spellID][button.field]
			Section_Spells.UpdateRow(row:GetParent(), row, row.spellID)
			--for i = 1, NUMROWS do
			--if self[i] == row then
			--updateData(row, CURSOR+i-1)
			--return
			--end
			--end
		end
		local info = UIDropDownMenu_CreateInfo()
		local function InitializeDropdown(self, level)
			if level == 1 then
				info.isTitle = true
				info.notCheckable = true
				info.hasArrow = false
				info.text = self.title
				UIDropDownMenu_AddButton(info)
				info.isTitle = false
				info.disabled = false
				info.text = "Source"
				info.hasArrow = true
				UIDropDownMenu_AddButton(info, 1)
			elseif level == 2 then
				info.isTitle = false
				info.hasArrow = false
				info.notCheckable = false
				info.checked = false
				info.text = "UNIT_AURA, HELPFUL"
				UIDropDownMenu_AddButton(info, 2)
				info.checked = true
				info.text = "UNIT_AURA, HARMFUL"
				UIDropDownMenu_AddButton(info, 2)
			end
		end
		local dropdown
		local function OnClick_Row(self, button)
			if button == "RightButton" then
				dropdown.title = GetSpellInfo(self.spellID)
				ToggleDropDownMenu(1, nil, dropdown, "cursor", 0, 0)
			end
		end
		function Section_Spells:SetupRows()
			dropdown = CreateFrame("frame", nil, self, "UIDropDownMenuTemplate")
			UIDropDownMenu_Initialize(dropdown, InitializeDropdown, "MENU")
			local height = self[1]:GetHeight()
			self.name = self.fontPool:Acquire()
			self.name:SetFont(MEDIA:FONT(), 18)
			self.name:SetPoint("TOPLEFT", self, "TOPLEFT", 8 + height, -12)
			self.name:SetText("Spellname")
			self.name:Show()
			self.spell = self.fontPool:Acquire()
			self.spell:SetFont(MEDIA:FONT(), 18)
			self.spell:SetPoint("TOPLEFT", self, "TOPLEFT", 200, -12)
			self.spell:SetText("SpellID")
			self.spell:Show()
			self.personal = self.fontPool:Acquire()
			self.personal:SetFont(MEDIA:FONT(), 18)
			self.personal:SetPoint("TOPLEFT", self, "TOPRIGHT", -128, -12)
			self.personal:SetText("Personal")
			self.personal:Show()
			for index, row in ipairs(self) do
				row.icon = self.texturePool:Acquire()
				row.icon:SetPoint("TOPLEFT", row, "TOPLEFT", 0, 0)
				row.icon:SetPoint("BOTTOMRIGHT", row, "TOPLEFT", row:GetHeight(), -row:GetHeight())
				row.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
				row.icon:SetParent(row)
				row.icon:Show()
				row.personal = self.checkPool:Acquire()
				row.personal:SetHitRectInsets(0, 0, 0, 0)
				row.personal:SetPoint("RIGHT", row, "RIGHT", -4 - row:GetHeight(), 0)
				row.personal:SetSize(row:GetHeight(), row:GetHeight())
				row.personal:SetScript("OnClick", OnClick_CheckButton)
				row.personal.field = "personal"
				row.personal:Show()
				row.personal:SetParent(row)
				row.spell = self.fontPool:Acquire()
				row.spell:SetFont(MEDIA:FONT(), 14)
				row.spell:SetPoint("LEFT", row.icon, "RIGHT", 8, 0)
				row.spell:SetParent(row)
				row.spell:Show()
				row.name = self.fontPool:Acquire()
				row.name:SetFont(MEDIA:FONT(), 14)
				row.name:SetPoint("LEFT", row.icon, "LEFT", 200, 0)
				row.name:SetParent(row)
				row.name:Show()
				row:SetScript("OnEnter", OnEnter_Row)
				row:SetScript("OnLeave", OnLeave_Row)
				--row:RegisterForClicks("anyup")
				row:SetScript("OnMouseUp", OnClick_Row)
				row:Show()
			end
		end
		local function comparator(a, b)
			return SquishData.SpellsData[a].class < SquishData.SpellsData[b].class
		end
		function Section_Spells:PopulateData(DATA)
			for spell, _ in pairs(SquishData.SpellsData) do
				table.insert(DATA, spell)
			end
			table.sort(DATA, comparator)
		end
		local fallbackColor = {
			r = 0,
			g = 0,
			b = 0
		}
		function Section_Spells:UpdateRow(row, spell)
			if spell then
				local name, _, icon = GetSpellInfo(spell)
				local class = SquishData.SpellsData[spell].class
				local personal = SquishData.SpellsData[spell].personal
				local color = RAID_CLASS_COLORS[class] or fallbackColor
				row.spellID = spell
				row.icon:SetTexture(icon)
				row.spell:SetText(spell)
				row.name:SetText(name)
				row.personal:SetChecked(personal)
				row:SetBackdropColor(color.r, color.g, color.b, 0.25)
				--row.personal:SetChecked(SquishData.spells[spell][FIELD_PERSONAL])
				row:Show()
			else
				row.spellID = nil
				row:Hide()
			end
		end
		function Section_Spells:CleanupRows()
			self.fontPool:Release(self.name)
			self.fontPool:Release(self.spell)
			self.fontPool:Release(self.personal)
			self.name = nil
			self.spell = nil
			self.personal = nil
			for index, row in ipairs(self) do
				self.texturePool:Release(row.icon)
				self.checkPool:Release(row.personal)
				self.fontPool:Release(row.spell)
				self.fontPool:Release(row.name)
				row.personal = nil
				row.icon = nil
				row.spell = nil
				row.name = nil
				row.spellID = nil
				row:SetScript("OnEnter", nil)
				row:SetScript("OnLeave", nil)
				row:Hide()
			end
		end
	end
	local frame = CreateFrame("frame", nil, UIParent, "BackdropTemplate")
	frame:RegisterEvent("VARIABLES_LOADED")
	frame:SetScript("OnEvent", function(self)
		if not SquishData then
			SquishData = {}
		end
		if not SquishData.SpellsData then
			SquishData.SpellsData = {}
		end
		self:UnregisterAllEvents()
		-- self:RegisterEvent("UNIT_AURA")
		-- self:RegisterEvent("UNIT_SPELLCAST_START")
		-- self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
		self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		self:SetScript("OnEvent", OnEvent_SpellCollector)
		local WIDTH = 1024
		local HEIGHT = 1025
		local NUMROWS = 32
		local ROWHEIGHT = HEIGHT / NUMROWS
		local CURSOR = 1
		local CURSOR_MAX = 1
		local DATA = {}
		local SECTION = 1
		local SECTIONS = { Section_Spells }
		--{"Spells", 237542, PrepareRows_Spells, UpdateRows_Spells},
		-- {"Scanned", 134952},
		self:SetSize(WIDTH, HEIGHT + 8 + ROWHEIGHT)
		self:SetPoint("CENTER", 0, 0)
		self:SetBackdrop(MEDIA:BACKDROP(true, false, 1, 0))
		self:SetBackdropColor(0, 0, 0, 0.7)
		self:SetBackdropBorderColor(0, 0, 0, 1)
		self:SetFrameStrata("HIGH")
		self:EnableMouseWheel(true)
		self:SetScale(0.533333333 / UIParent:GetScale())
		self:Hide()
		self.buttonPool = CreateFramePool("button", self, "UIPanelButtonTemplate")
		self.checkPool = CreateFramePool("checkbutton", self, "OptionsCheckButtonTemplate")
		self.texturePool = CreateTexturePool(self)
		self.fontPool = CreateFontStringPool(self, nil, nil, "GameFontNormal")
		for rowIndex = 1, NUMROWS do
			local row = CreateFrame("frame", nil, frame, "BackdropTemplate")
			row:SetSize(WIDTH - 32, ROWHEIGHT - 1)
			row:SetBackdrop(MEDIA:BACKDROP(true, true, 1, 0))
			row.color = rowIndex % 2 == 0 and 0.46 or 0.54
			row:SetBackdropColor(0, 0, 0, row.color)
			row:SetBackdropBorderColor(0, 0, 0, 0)
			if rowIndex == 1 then
				row:SetPoint("TOPLEFT", 4, -4 - ROWHEIGHT)
			else
				row:SetPoint("TOPLEFT", self[rowIndex - 1], "BOTTOMLEFT", 0, -1)
			end
			table.insert(self, row)
			row:Hide()
		end
		local OnMouseWheel
		local updateScroll
		local OnClick_CloseGUI
		do
			local close = CreateFrame("button", nil, self, "UIPanelButtonTemplate")
			close:SetSize(32, 32)
			close:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 2, 1)
			close:SetText("X")
			function OnClick_CloseGUI()
				SquishData.SpellsGUIOpen = false
				SECTIONS[SECTION].CleanupRows(self)
				self:Hide()
			end
			close:SetScript("OnClick", OnClick_CloseGUI)
		end
		do
			local scrollbar = CreateFrame("frame", nil, frame, "BackdropTemplate")
			scrollbar:SetBackdrop(MEDIA:BACKDROP(true, nil, 0, 0))
			scrollbar:SetBackdropColor(0.5, 0.4, 0.8, 0.3)
			scrollbar:EnableMouse(true)
			scrollbar:SetWidth(20)
			function updateScroll()
				scrollbar:SetPoint("TOPRIGHT", -4, -4 - ROWHEIGHT - (CURSOR - 1) * HEIGHT / #DATA)
				scrollbar:SetHeight(math.min(1, NUMROWS / #DATA) * HEIGHT)
			end
			scrollbar:SetScript("OnEnter", function(self)
				self:SetBackdropColor(0.5, 0.4, 0.8, 0.7)
			end)
			local function OnLeave(self)
				self:SetBackdropColor(0.5, 0.5, 0.8, 0.3)
			end
			local function OnMouseUp(self)
				self:SetScript("OnUpdate", nil)
				self:SetScript("OnMouseUp", nil)
				self:SetScript("OnLeave", OnLeave)
				OnLeave(self)
			end
			local function OnUpdate(self)
				local position = select(2, GetCursorPosition())
				local offset = position - self.start
				local delta
				if offset < 0 then
					delta = math.ceil(offset / self.height)
				else
					delta = math.floor(offset / self.height)
				end
				if delta ~= 0 then
					self.start = self.start + delta * self.height
					local sign = delta < 0 and -1 or 1
					for i = delta, sign, sign * -1 do
						OnMouseWheel(frame, sign)
					end
				end
			end
			local function OnMouseDown(self)
				self.height = (HEIGHT / #DATA) * UIParent:GetScale()
				self.start = select(2, GetCursorPosition())
				self:SetScript("OnUpdate", OnUpdate)
				self:SetScript("OnMouseUp", OnMouseUp)
				self:SetScript("OnLeave", nil)
			end
			scrollbar:SetScript("OnLeave", OnLeave)
			scrollbar:SetScript("OnMouseDown", OnMouseDown)
		end
		do
			local buttons = {}
			local function OnClick(button)
				buttons[SECTION]:SetAlpha(0.5)
				buttons[SECTION]:SetHeight(20)
				buttons[SECTION].icon:SetTexCoord(0.1, 0.9, 0.1, 0.6)
				SECTION = button.index
				SquishData.SpellsGUISection = button.index
				button:SetAlpha(1)
				button:SetHeight(32)
				button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
				for i = #DATA, 1, -1 do
					DATA[i] = nil
				end
				SECTIONS[SECTION].SetupRows(self)
				SECTIONS[SECTION].PopulateData(self, DATA)
				CURSOR = 1
				CURSOR_MAX = math.max(1, #DATA - NUMROWS + 1)
				for i = 1, NUMROWS do
					SECTIONS[SECTION].UpdateRow(self, self[i], DATA[i])
				end
				updateScroll()
			end
			local function OnEnter(self)
				self:SetAlpha(1)
			end
			local function OnLeave(self)
				if self.index == SECTION then return end
				self:SetAlpha(0.5)
			end
			for index = 1, #SECTIONS do
				local button = CreateFrame("button", nil, self, "BackdropTemplate")
				button:SetSize(32, 32)
				button:SetBackdrop(MEDIA:BACKDROP(true, nil, 0, -1))
				button:SetBackdropColor(0, 0, 0, 0.75)
				button:SetAlpha(0.5)
				button:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 1 + (index - 1) * 32, 1)
				button:SetHeight(20)
				button.icon = button:CreateTexture()
				button.icon:SetAllPoints()
				button.icon:SetTexture(SECTIONS[index].icon)
				button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.6)
				button.index = index
				button:RegisterForClicks("anyup")
				--button:SetScript("OnClick", OnClick)
				--button:SetScript("OnEnter", OnEnter)
				--button:SetScript("OnLeave", OnLeave)
				table.insert(buttons, button)
			end
			if SquishData.SpellsGUIOpen then
				self:Show()
				OnClick(buttons[SECTION])
			end
			_G[name] = {}
			_G[name].ToggleSpellsGUI = function()
				SquishData.SpellsGUIOpen = not SquishData.SpellsGUIOpen
				if SquishData.SpellsGUIOpen then
					self:Show()
					OnClick(buttons[SECTION])
				else
					OnClick_CloseGUI()
				end
			end
		end
		function OnMouseWheel(self, delta)
			if delta < 0 then -- up
				if (CURSOR - delta) > CURSOR_MAX then return end
				self[2]:SetPoint("TOPLEFT", self, "TOPLEFT", 4, -4 - ROWHEIGHT)
				self[1]:SetPoint("TOPLEFT", self[NUMROWS], "BOTTOMLEFT", 0, -1)
				SECTIONS[SECTION].UpdateRow(self, self[1], DATA[CURSOR + NUMROWS])
				--updateData(frame[1], CURSOR+NUMROWS)
				table.insert(self, self[1])
				table.remove(self, 1)
				CURSOR = CURSOR - delta
				--updateData(self[NUMROWS], CURSOR)
			else
				if (CURSOR - delta) < 1 then return end
				CURSOR = CURSOR - delta
				self[NUMROWS]:SetPoint("TOPLEFT", self, "TOPLEFT", 4, -4 - ROWHEIGHT)
				self[1]:SetPoint("TOPLEFT", self[NUMROWS], "BOTTOMLEFT", 0, -1)
				SECTIONS[SECTION].UpdateRow(self, self[NUMROWS], DATA[CURSOR])
				table.insert(self, 1, self[NUMROWS])
				table.remove(self)
			end
			updateScroll()
		end
		self:SetScript("OnMouseWheel", OnMouseWheel)
	end)
end
--[[
      row.personal = CreateFrame("checkbutton", nil, row, "OptionsCheckButtonTemplate")
      row.personal:SetHitRectInsets(0, 0, 0, 0)
      row.personal:SetScript("OnClick", OnClick)
      row.personal.field = FIELD_PERSONAL
      --row.casting = CreateFrame("checkbutton", nil, row, "OptionsCheckButtonTemplate")
      --row.casting:SetHitRectInsets(0, 0, 0, 0)
      --row.casting:SetScript("OnClick", OnClick)
      --row.warning = CreateFrame("checkbutton", nil, row, "OptionsCheckButtonTemplate")
      --row.warning:SetHitRectInsets(0, 0, 0, 0)
      --row.warning:SetScript("OnClick", OnClick)
      Stack(row, "RIGHT", "RIGHT", -32, 0, "RIGHT", "LEFT", -32, 0, row.personal)
      ]]
local UI = CreateFrame("frame", nil, UIParent, "BackdropTemplate")
UI:RegisterEvent("PLAYER_LOGIN")
UI:SetScript("OnEvent", function(self, event)
	self:SetScript("OnEvent", nil)
	self:UnregisterAllEvents()
	self:SetPoint("TOPLEFT", 0, 0)
	self:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMLEFT", 640, 0)
	self:SetBackdrop(MEDIA:BACKDROP(true, nil, 0, -1))
	self:SetBackdropColor(0, 0, 0, 0)
	self:SetBackdropBorderColor(0, 0, 0, 0)
	self:SetScale(0.533333333 / UIParent:GetScale())
	--self:SetScale(max(0.4, min(1.15, 768 / GetScreenHeight())) / UIParent:GetScale())
	--for id, spell in pairs(SquishData.SpellsData) do
	--if spell.source == "AURA_HELPFUL" then
	--spell.event = "UNIT_AURA"
	--spell.filter = "HELPFUL"
	--spell.source = nil
	--elseif spell.source == "AURA_HARMFUL" then
	--spell.event = "UNIT_AURA"
	--spell.filter = "HARMFUL"
	--spell.source = nil
	--else
	--print("??", id, spell)
	--end
	--end
	--local times = 0
	--self:RegisterUnitEvent("UNIT_AURA", "player")
	--self:SetScript("OnEvent", function()
	--times = times + 1
	--for i = 1, 40 do
	--local name = UnitAura("player", i, "HELPFUL")
	--if not name then break end
	--end
	--end)
	--C_Timer.NewTicker(1, function()
	--local usage = GetFrameCPUUsage(UI)
	--if times == 0 then return end
	--print("UI:", times, usage, usage / times)
	--end)
	local playerButton = (function()
		local self = CreateFrame("button", nil, UI, "SecureActionButtonTemplate,BackdropTemplate")
		self:SetScript("OnAttributeChanged", OnAttributeChanged)
		self:RegisterForClicks("AnyUp")
		self:SetAttribute("*type1", "target")
		self:SetAttribute("*type2", "togglemenu")
		self:SetBackdrop(MEDIA:BACKDROP(true, nil, 0, -1))
		self:SetBackdropColor(0, 0, 0, 1)
		self:SetSize(382, 64)
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
		roleIcon:SetTexture([[Interface\LFGFrame\UI-LFG-ICON-ROLES]])
		roleIcon:SetPoint("BOTTOMRIGHT", healthBar, "BOTTOMLEFT", 0, 0)
		local powerFont = healthBar:CreateFontString(nil, nil, "GameFontNormal")
		powerFont:SetFont(MEDIA:FONT(), 20)
		powerFont:SetTextColor(0, 0, 0)
		powerFont:SetShadowColor(1, 1, 1, 0.5)
		powerFont:SetPoint("TOP")
		powerFont:SetText("power")
		local powerWidth = 317
		local powerSpring = CreateSpring(
			function(_, percent)
				powerBar:SetValue(percent)
				powerFont:SetPoint("TOPRIGHT", -((1 - percent) * powerWidth) - 6, -2)
			end,
			180,
			30,
			0.008
		)
		local healthSpring = CreateSpring(
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
				self:RegisterEvent("INCOMING_RESURRECT_CHANGED")
				self:RegisterEvent("RAID_TARGET_UPDATE")
				self:RegisterEvent("PLAYER_REGEN_ENABLED")
				self:RegisterEvent("PLAYER_REGEN_DISABLED")
				self:RegisterEvent("GROUP_ROSTER_UPDATE")
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
				self:UnregisterEvent("GROUP_ROSTER_UPDATE")
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
				powerSpring(pp)
				local __5 = UnitHealthMax(self.unit)
				healthBar:SetMinMaxValues(0, __5)
				shieldBar:SetMinMaxValues(0, __5)
				absorbBar:SetMinMaxValues(0, __5)
				local __6 = UnitHealth(self.unit)
				local __7 = UnitGetTotalAbsorbs(self.unit)
				healthSpring.absorb = __7
				healthSpring(__6)
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
				powerSpring(pp)
				local __5 = UnitHealthMax(self.unit)
				healthBar:SetMinMaxValues(0, __5)
				shieldBar:SetMinMaxValues(0, __5)
				absorbBar:SetMinMaxValues(0, __5)
				local __6 = UnitHealth(self.unit)
				local __7 = UnitGetTotalAbsorbs(self.unit)
				healthSpring.absorb = __7
				healthSpring(__6)
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
				powerSpring(pp)
			elseif event == "UNIT_MAXPOWER" then
				local __0 = UnitPowerMax(self.unit)
				local __1 = UnitPower(self.unit)
				local pp = __1 / __0
				powerFont:SetText(math.ceil(pp * 100))
				powerSpring(pp)
			elseif event == "UNIT_POWER_FREQUENT" then
				local __0 = UnitPowerMax(self.unit)
				local __1 = UnitPower(self.unit)
				local pp = __1 / __0
				powerFont:SetText(math.ceil(pp * 100))
				powerSpring(pp)
			elseif event == "UNIT_MAXHEALTH" then
				local __0 = UnitHealthMax(self.unit)
				healthBar:SetMinMaxValues(0, __0)
				shieldBar:SetMinMaxValues(0, __0)
				absorbBar:SetMinMaxValues(0, __0)
			elseif event == "UNIT_HEALTH" then
				local __0 = UnitHealth(self.unit)
				local __1 = UnitGetTotalAbsorbs(self.unit)
				healthSpring.absorb = __1
				healthSpring(__0)
			elseif event == "UNIT_ABSORB_AMOUNT_CHANGED" then
				local __0 = UnitHealth(self.unit)
				local __1 = UnitGetTotalAbsorbs(self.unit)
				healthSpring.absorb = __1
				healthSpring(__0)
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
			elseif event == "GROUP_ROSTER_UPDATE" then
				local __0 = UnitInParty(self.unit)
				local __1 = UnitIsGroupLeader(self.unit)
				ToggleVisible(leaderIcon, (__0 and __1))
				local __2 = UnitIsGroupAssistant(self.unit)
				ToggleVisible(assistIcon, (__0 and __2))
				local __3 = GetRaidTargetIndex(self.unit)
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
		local powerSpring = CreateSpring(
			function(_, percent)
				powerBar:SetValue(percent)
			end,
			180,
			30,
			0.008
		)
		local healthSpring = CreateSpring(
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
		roleIcon:SetTexture([[Interface\LFGFrame\UI-LFG-ICON-ROLES]])
		local raidIcon = healthBar:CreateTexture(nil, "OVERLAY")
		raidIcon:SetSize(24, 24)
		raidIcon:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]])
		local leaderIcon = healthBar:CreateTexture(nil, "OVERLAY")
		leaderIcon:SetSize(18, 18)
		leaderIcon:SetTexture([[Interface\GroupFrame\UI-Group-LeaderIcon]])
		local assistIcon = healthBar:CreateTexture(nil, "OVERLAY")
		assistIcon:SetSize(18, 18)
		assistIcon:SetTexture([[Interface\GroupFrame\UI-Group-AssistantIcon]])
		function self:handler(event, ...)
			if event == "UNIT_SET" then
				self:RegisterEvent("PLAYER_TARGET_CHANGED")
				self:RegisterEvent("INCOMING_RESURRECT_CHANGED")
				self:RegisterEvent("PLAYER_ROLES_ASSIGNED")
				self:RegisterEvent("RAID_TARGET_UPDATE")
				self:RegisterEvent("GROUP_ROSTER_UPDATE")
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
				self:UnregisterEvent("GROUP_ROSTER_UPDATE")
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
				powerSpring(pp)
				local __6 = UnitHealthMax(self.unit)
				healthBar:SetMinMaxValues(0, __6)
				shieldBar:SetMinMaxValues(0, __6)
				absorbBar:SetMinMaxValues(0, __6)
				local __7 = UnitHealth(self.unit)
				local __8 = UnitGetTotalAbsorbs(self.unit)
				healthSpring.absorb = __8
				healthSpring(__7)
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
				RangeChecker:Register(self, true)
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
				powerSpring(pp)
				local __6 = UnitHealthMax(self.unit)
				healthBar:SetMinMaxValues(0, __6)
				shieldBar:SetMinMaxValues(0, __6)
				absorbBar:SetMinMaxValues(0, __6)
				local __7 = UnitHealth(self.unit)
				local __8 = UnitGetTotalAbsorbs(self.unit)
				healthSpring.absorb = __8
				healthSpring(__7)
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
				RangeChecker:Update(self)
			elseif event == "UNIT_CLASSIFICATION_CHANGED" then
				local __0 = UnitClassification(self.unit)
				SetUnitClassification(textLevel, __0)
				local __1 = UnitIsQuestBoss(self.unit)
				ToggleVisible(questIcon, __1)
			elseif event == "UNIT_NAME_UPDATE" then
				local __0 = UnitName(self.unit)
				textName:SetText(__0)
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
				powerSpring(pp)
			elseif event == "UNIT_MAXPOWER" then
				local __0 = UnitPowerMax(self.unit)
				local __1 = UnitPower(self.unit)
				local pp = __1 / __0
				powerSpring(pp)
			elseif event == "UNIT_POWER_FREQUENT" then
				local __0 = UnitPowerMax(self.unit)
				local __1 = UnitPower(self.unit)
				local pp = __1 / __0
				powerSpring(pp)
			elseif event == "UNIT_MAXHEALTH" then
				local __0 = UnitHealthMax(self.unit)
				healthBar:SetMinMaxValues(0, __0)
				shieldBar:SetMinMaxValues(0, __0)
				absorbBar:SetMinMaxValues(0, __0)
			elseif event == "UNIT_HEALTH" then
				local __0 = UnitHealth(self.unit)
				local __1 = UnitGetTotalAbsorbs(self.unit)
				healthSpring.absorb = __1
				healthSpring(__0)
			elseif event == "UNIT_ABSORB_AMOUNT_CHANGED" then
				local __0 = UnitHealth(self.unit)
				local __1 = UnitGetTotalAbsorbs(self.unit)
				healthSpring.absorb = __1
				healthSpring(__0)
			elseif event == "UNIT_HEAL_ABSORB_AMOUNT_CHANGED" then
				local __0 = UnitGetTotalHealAbsorbs(self.unit)
				absorbBar:SetValue(__0)
			elseif event == "PLAYER_TARGET_CHANGED" then
				if not UnitExists(self.unit) then return end
				local max = UnitPowerMax(self.unit)
				if max == 0 then
					powerSpring:stop(0)
				else
					powerSpring:stop(UnitPower(self.unit) / max)
				end
				healthSpring.absorb = UnitGetTotalAbsorbs(self.unit)
				healthSpring:stop(UnitHealth(self.unit))
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
			elseif event == "GROUP_ROSTER_UPDATE" then
				local __0 = UnitInParty(self.unit)
				local __1 = UnitIsGroupLeader(self.unit)
				ToggleVisible(leaderIcon, (__0 and __1))
				local __2 = UnitIsGroupAssistant(self.unit)
				ToggleVisible(assistIcon, (__0 and __2))
				local __3 = GetRaidTargetIndex(self.unit)
				Stack(healthBar, "BOTTOMLEFT", "BOTTOMLEFT", 2, 4, "LEFT", "RIGHT", 4, 0, roleIcon, raidIcon, leaderIcon, assistIcon)
			elseif event == "PARTY_LEADER_CHANGED" then
				local __0 = UnitInParty(self.unit)
				local __1 = UnitIsGroupLeader(self.unit)
				ToggleVisible(leaderIcon, (__0 and __1))
				local __2 = UnitIsGroupAssistant(self.unit)
				local __3 = GetRaidTargetIndex(self.unit)
				Stack(healthBar, "BOTTOMLEFT", "BOTTOMLEFT", 2, 4, "LEFT", "RIGHT", 4, 0, roleIcon, raidIcon, leaderIcon, assistIcon)
			elseif event == "GUID_REM" then
				RangeChecker:Unregister(self)
			end
		end
		self:SetAttribute("unit", "target")
		RegisterUnitWatch(self)
		self:SetSize(382, 64)
		self:SetPoint("LEFT", playerButton, "RIGHT", 16, 0)
		DisableBlizzard("target")
		local castbar = CreateCastBar(UI, "target", 32)
		castbar:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -16)
		castbar:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -16)
	end
	BuffFrame:SetScript("OnUpdate", nil)
	BuffFrame:SetScript("OnEvent", nil)
	BuffFrame:UnregisterAllEvents()
	BuffFrame:Hide()
	do
		local self = CreateFrame("frame", "Squish" .. "PlayerBuffs", UI, "SecureAuraHeaderTemplate")
		self:SetAttribute("template", "SecureActionButtonTemplate BackdropTemplate")
		self:SetAttribute("_ignore", "attributeChanges")
		self:SetAttribute("initialConfigFunction", [[
    self:SetWidth(48)
    self:SetHeight(48)
    self:SetAttribute('type', 'cancelaura')
    self:GetParent():CallMethod('configure', self:GetName())
  ]])
		self:SetAttribute("point", "TOPRIGHT")
		self:SetAttribute("unit", "player")
		self:SetAttribute("filter", "HELPFUL")
		self:SetAttribute("sortDirection", "-")
		self:SetAttribute("sortMethod", "TIME,NAME")
		self:SetAttribute("minWidth", 48)
		self:SetAttribute("minHeight", 48)
		self:SetAttribute("xOffset", -50)
		self:SetAttribute("yOffset", 0)
		function self:configure(name)
			local button = _G[name]
			button.filter = "HELPFUL"
			button.unit = "player"
			button:RegisterForClicks("RightButtonUp")
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
			button:RegisterUnitEvent("UNIT_AURA", "player")
			button:SetScript("OnAttributeChanged", OnAttributeChanged_AuraButton)
			button:SetScript("OnEnter", OnEnter_AuraButton)
			button:SetScript("OnLeave", OnLeave_AuraButton)
			button:SetScript("OnEvent", OnEvent_AuraButton)
		end
		RegisterAttributeDriver(self, "unit", "[vehicleui] vehicle; player")
		RegisterStateDriver(self, "visibility", "[petbattle] hide; show")
		self:SetPoint("TOPRIGHT", -4, -4)
	end
	do
		local self = CreateFrame("frame", "Squish" .. "PlayerDebuffs", UI, "SecureAuraHeaderTemplate")
		self:SetAttribute("template", "SecureActionButtonTemplate BackdropTemplate")
		self:SetAttribute("_ignore", "attributeChanges")
		self:SetAttribute("initialConfigFunction", [[
    self:SetWidth(64)
    self:SetHeight(64)
    
    self:GetParent():CallMethod('configure', self:GetName())
  ]])
		self:SetAttribute("point", "TOPRIGHT")
		self:SetAttribute("unit", "player")
		self:SetAttribute("filter", "HARMFUL")
		self:SetAttribute("sortDirection", "-")
		self:SetAttribute("sortMethod", "TIME,NAME")
		self:SetAttribute("minWidth", 64)
		self:SetAttribute("minHeight", 64)
		self:SetAttribute("xOffset", -66)
		self:SetAttribute("yOffset", 0)
		function self:configure(name)
			local button = _G[name]
			button.filter = "HARMFUL"
			button.unit = "player"
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
			button:RegisterUnitEvent("UNIT_AURA", "player")
			button:SetScript("OnAttributeChanged", OnAttributeChanged_AuraButton)
			button:SetScript("OnEnter", OnEnter_AuraButton)
			button:SetScript("OnLeave", OnLeave_AuraButton)
			button:SetScript("OnEvent", OnEvent_AuraButton)
		end
		RegisterAttributeDriver(self, "unit", "[vehicleui] vehicle; player")
		RegisterStateDriver(self, "visibility", "[petbattle] hide; show")
		self:SetPoint("TOPRIGHT", -4, -100)
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
      self:SetWidth(75)
      self:SetHeight(128)
      self:GetParent():CallMethod('ConfigureButton', self:GetName())
    ]])
		local AURA_HELPFUL = {}
		local AURA_HARMFUL = {}
		local negative = { index = 0 }
		local positive = { index = 0 }
		for id, spell in pairs(SquishData.SpellsData) do
			if spell.helpful then
				if spell.filter == "HELPFUL" then
					AURA_HELPFUL[id] = {}
					AURA_HELPFUL[id].icon = select(3, GetSpellInfo(id))
					AURA_HELPFUL[id].priority = spell.priority
					AURA_HELPFUL[id].collection = positive
				elseif spell.filter == "HARMFUL" then
					AURA_HARMFUL[id] = {}
					AURA_HARMFUL[id].icon = select(3, GetSpellInfo(id))
					AURA_HARMFUL[id].priority = spell.priority
					AURA_HARMFUL[id].collection = positive
				end
			end
		end
		local function UpdateUnitAuras(button)
			button.auraAttonement:Hide()
			AuraTable_Clear(positive)
			for index = 1, 40 do
				local _, icon, _, _, duration, expiration, _, _, _, id = UnitAura(button.unit, index, "HELPFUL")
				if not id then
					break
				end
				if AURA_HELPFUL[id] then
					AuraTable_Insert(positive, AURA_HELPFUL[id].priority, icon, duration, expiration)
				end
				if id == button.auraAttonement.spellID then
					button.auraAttonement:Show()
					button.auraAttonement.cd:SetCooldown(expiration - duration, duration)
				end
			end
			for index = 1, 40 do
				local _, icon, _, _, duration, expiration, _, _, _, id = UnitAura(button.unit, index, "HARMFUL")
				if not id then
					break
				end
			end
			for i = 1, 3 do
				if positive.cursor >= i then
					button[i]:Show()
					button[i].texture:SetTexture(positive[positive[i] + 1])
					button[i].cd:SetCooldown(positive[positive[i] + 3] - positive[positive[i] + 2], positive[positive[i] + 2])
				else
					button[i]:Hide()
				end
			end
		end
		--do -- boss target
		--local target = CreateFrame('frame', nil, self, "BackdropTemplate")
		--target:SetSize(75, 32)
		--target:SetPoint("BOTTOMRIGHT", 0, 0)
		--target:SetBackdrop(MEDIA:BACKDROP(true, false, 0, 0))
		--target:SetBackdropColor(0, 0, 0, 0.75)
		--target:SetFrameLevel(4)
		--target.playerTargetPosition = CreateSpring(function(_, index)
		--target:SetPoint("BOTTOMRIGHT", (index-1) * -77, 128)
		--end, 230, 24, 0.001)
		--target.playerTargetAlpha = CreateSpring(function(_, value)
		--target:SetAlpha(value)
		--end, 300, 20, 0.1)
		--target.playerTargetAlpha(0)
		--target:RegisterEvent("PLAYER_TARGET_CHANGED")
		--target.header = self
		--target:SetScript("OnEvent", OnEvent_PlayerTarget)
		--end
		local OnEvent
		function self:ConfigureButton(name)
			local self = _G[name]
			self:RegisterForClicks("AnyUp")
			self:SetAttribute("*type1", "target")
			self:SetAttribute("*type2", "togglemenu")
			self:SetAttribute("toggleForVehicle", true)
			self:SetScript("OnAttributeChanged", OnAttributeChanged)
			self:SetBackdrop(MEDIA:BACKDROP(true, false, 0, 0))
			self:SetBackdropColor(0, 0, 0, 0.75)
			RegisterUnitWatch(self)
			self.handler = OnEvent
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
			self.shieldBar:SetStatusBarColor(0.0, 1.0, 1.0, 0.5)
			self.shieldBar:SetOrientation("VERTICAL")
			self.shieldBar:SetFrameLevel(2)
			self.absorbBar = CreateFrame("statusbar", nil, self)
			self.absorbBar:SetMinMaxValues(0, 1)
			self.absorbBar:SetStatusBarTexture(MEDIA:STATUSBAR())
			self.absorbBar:SetAllPoints(self.healthBar)
			self.absorbBar:SetStatusBarColor(1.0, 0.0, 0.0, 0.5)
			self.absorbBar:SetOrientation("VERTICAL")
			self.absorbBar:SetFrameLevel(4)
			self.healthSpring = CreateSpring(
				function(spring, health)
					self.healthBar:SetValue(health)
					self.shieldBar:SetValue(health + spring.absorb)
				end,
				180,
				30,
				0.1
			)
			self.textName = self.healthBar:CreateFontString(nil, nil, "GameFontNormal")
			self.textName:SetPoint("CENTER", 0, 0)
			self.textName:SetFont(MEDIA:FONT(), 14, "OUTLINE")
			self.textStatus = self.healthBar:CreateFontString(nil, nil, "GameFontNormal")
			self.textStatus:SetFont(MEDIA:FONT(), 12)
			self.textStatus:SetPoint("TOP", self.textName, "BOTTOM", 0, -8)
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
			self.roleIcon:SetSize(22, 22)
			self.roleIcon:SetTexture([[Interface\LFGFrame\UI-LFG-ICON-ROLES]])
			self.raidIcon = self.healthBar:CreateTexture(nil, "OVERLAY")
			self.raidIcon:SetSize(22, 22)
			self.raidIcon:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]])
			self.leaderIcon = self.healthBar:CreateTexture(nil, "OVERLAY")
			self.leaderIcon:SetSize(18, 18)
			self.leaderIcon:SetTexture([[Interface\GroupFrame\UI-Group-LeaderIcon]])
			self.assistIcon = self.healthBar:CreateTexture(nil, "OVERLAY")
			self.assistIcon:SetSize(18, 18)
			self.assistIcon:SetTexture([[Interface\GroupFrame\UI-Group-AssistantIcon]])
			table.insert(self, CreateAuraIcon(self, 37))
			table.insert(self, CreateAuraIcon(self, 29))
			table.insert(self, CreateAuraIcon(self, 29))
			self[1]:SetPoint("BOTTOM", self, "BOTTOM", 0, 4)
			self[2]:SetPoint("TOPRIGHT", self, "BOTTOM", -1, -1)
			self[3]:SetPoint("TOPLEFT", self, "BOTTOM", 1, -1)
		end
		function OnEvent(self, event, ...)
			if event == "UNIT_SET" then
				self:RegisterEvent("INCOMING_RESURRECT_CHANGED")
				self:RegisterEvent("PLAYER_ROLES_ASSIGNED")
				self:RegisterEvent("RAID_TARGET_UPDATE")
				self:RegisterEvent("GROUP_ROSTER_UPDATE")
				self:RegisterEvent("PARTY_LEADER_CHANGED")
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
				self:UnregisterEvent("UNIT_MAXHEALTH")
				self:UnregisterEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED")
				self:UnregisterEvent("UNIT_HEALTH")
				self:UnregisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")
				self:UnregisterEvent("UNIT_NAME_UPDATE")
				self:UnregisterEvent("UNIT_CONNECTION")
				self:UnregisterEvent("INCOMING_RESURRECT_CHANGED")
				self:UnregisterEvent("PLAYER_ROLES_ASSIGNED")
				self:UnregisterEvent("RAID_TARGET_UPDATE")
				self:UnregisterEvent("GROUP_ROSTER_UPDATE")
				self:UnregisterEvent("PARTY_LEADER_CHANGED")
				self:UnregisterEvent("UNIT_AURA")
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
				self.healthSpring(__3)
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
				RangeChecker:Register(self, true)
				UpdateUnitAuras(self)
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
				self.healthSpring:stop(__3)
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
				RangeChecker:Update(self)
				UpdateUnitAuras(self)
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
				self.healthSpring(__0)
				local __2 = UnitIsDead(self.unit)
				local __3 = UnitIsGhost(self.unit)
				local __4 = UnitIsConnected(self.unit)
				SetUnitStatus(self.textStatus, __2, __3, __4)
			elseif event == "UNIT_ABSORB_AMOUNT_CHANGED" then
				local __0 = UnitHealth(self.unit)
				local __1 = UnitGetTotalAbsorbs(self.unit)
				self.healthSpring.absorb = __1
				self.healthSpring(__0)
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
			elseif event == "GROUP_ROSTER_UPDATE" then
				local __0 = UnitInParty(self.unit)
				local __1 = UnitIsGroupLeader(self.unit)
				ToggleVisible(self.leaderIcon, (__0 and __1))
				local __2 = UnitIsGroupAssistant(self.unit)
				ToggleVisible(self.assistIcon, (__0 and __2))
				local __3 = GetRaidTargetIndex(self.unit)
				Stack(self.healthBar, "BOTTOMLEFT", "BOTTOMLEFT", -3, -6, "BOTTOM", "TOP", 0, 0, self.roleIcon, self.raidIcon, self.leaderIcon, self.assistIcon)
			elseif event == "PARTY_LEADER_CHANGED" then
				local __0 = UnitInParty(self.unit)
				local __1 = UnitIsGroupLeader(self.unit)
				ToggleVisible(self.leaderIcon, (__0 and __1))
				local __2 = UnitIsGroupAssistant(self.unit)
				local __3 = GetRaidTargetIndex(self.unit)
				Stack(self.healthBar, "BOTTOMLEFT", "BOTTOMLEFT", -3, -6, "BOTTOM", "TOP", 0, 0, self.roleIcon, self.raidIcon, self.leaderIcon, self.assistIcon)
			elseif event == "GUID_REM" then
				RangeChecker:Unregister(self)
			elseif event == "UNIT_AURA" then
				UpdateUnitAuras(self)
			end
		end
		self:SetPoint("BOTTOMRIGHT", playerButton, "TOPRIGHT", 1, 100)
		self:Show()
	end
end)
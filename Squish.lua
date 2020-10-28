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
local SPELL_TYPES = { "Battle Res", "Tank", "Damage", "Dispel", "HardCC", "RaidCD", "SoftCC", "Healing", "Utility", "External", "Immunity", "Personal", "STHardCC", "STSoftCC", "Interrupt" }
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
local AurasFilter
do
	--local frame = CreateFrame("frame", nil, UIParent)
	--frame:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
	--frame:RegisterUnitEvent("UNIT_AURA")
	--frame:SetScript("OnEvent", function(self, event, unit, guid, spell, ...)
	--if event == "UNIT_SPELLCAST_SUCCEEDED" then
	--print("CAST", spell)
	--elseif event == "UNIT_AURA" then
	--for i = 1, 40 do
	--local name, _, _, _, _, _, source, _, _, id = UnitAura("player", i, "HELPFUL")
	--if not name then break end
	--print("AURA", name, source, id)
	--end
	--end
	--end)
end
--[[
  debuffs
  incoming spells
  buffs
  cooldowns
  UnitAura()
    name, icon, count, debuffType, duration, expirationTime, source, isStealable,
    _, spellId, _, isBossDebuff, castByPlayer, nameplateShowAll, timeMod, ...
                              spellID
  Pain Suppression            33206
  Power Word: Shield          17
  External
                    "key": "102342", "name": "|T572025:0|t |cFFFF7D0AIronbark|r",
                    "key": "116849", "name": "|T627485:0|t |cFF00FF96Life Cocoon|r",
                    "key": "1022", "name": "|T135964:0|t |cFFF58CBABlessing of Prot|r",
                    "key": "6940", "name": "|T135966:0|t |cFFF58CBABlessing of Sacr|r",
                    "key": "204018", "name": "|T135880:0|t |cFFF58CBABlessing of Spel|r",
                    "key": "633", "name": "|T135928:0|t |cFFF58CBALay on Hands|r",
                    "key": "47788", "name": "|T237542:0|t |cFFFFFFFFGuardian Spirit|r",
                    "key": "33206", "name": "|T135936:0|t |cFFFFFFFFPain Suppression|r",
                    "key": "207399", "name": "|T136080:0|t |cFF0070DEAncestral Protec|r",
                    "key": "3411", "name": "|T132365:0|t |cFFC79C6EIntervene|r",
                    "key": "102351", "name": "|T132137:0|t |cFFFF7D0ACenarion Ward|r",
                    "key": "197721","name": "|T538743:0|t |cFFFF7D0AFlourish|r",
                    "key": "319454","name": "|T135879:0|t |cFFFF7D0AHeart of the Wil|r",
                    "key": "33891","name": "|T236157:0|t |cFFFF7D0AIncarnation: Tre|r",
                    "key": "203651","name": "|T1408836:0|t |cFFFF7D0AOvergrowth|r",
                    "key": "740",
                    "name": "|T136107:0|t |cFFFF7D0ATranquility|r",
                    "key": "325197",
                    "name": "|T877514:0|t |cFF00FF96Invoke Chi-Ji, t|r",
                    "key": "322118",
                    "name": "|T574571:0|t |cFF00FF96Invoke Yu'lon, t|r",
                    "key": "115310",
                    "name": "|T1020466:0|t |cFF00FF96Revival|r",
                    "key": "216331",
                    "name": "|T589117:0|t |cFFF58CBAAvenging Crusade|r",
                    "key": "31884",
                    "name": "|T135875:0|t |cFFF58CBAAvenging Wrath|r",
                    "key": "200025",
                    "name": "|T1030094:0|t |cFFF58CBABeacon of Virtue|r",
                    "key": "105809",
                    "name": "|T571555:0|t |cFFF58CBAHoly Avenger|r",
                    "key": "200183",
                    "name": "|T1060983:0|t |cFFFFFFFFApotheosis|r",
                    "key": "64843",
                    "name": "|T237540:0|t |cFFFFFFFFDivine Hymn|r",
                    "key": "246287",
                    "name": "|T135895:0|t |cFFFFFFFFEvangelism|r",
                    "key": "265202",
                    "name": "|T458225:0|t |cFFFFFFFFHoly Word: Salva|r",
                    "key": "10060",
                    "name": "|T135939:0|t |cFFFFFFFFPower Infusion|r",
                    "key": "47536",
                    "name": "|T237548:0|t |cFFFFFFFFRapture|r",
                    "key": "109964",
                    "name": "|T538565:0|t |cFFFFFFFFSpirit Shell|r",
                    "key": "15286",
                    "name": "|T136230:0|t |cFFFFFFFFVampiric Embrace|r",
                    "key": "108281",
                    "name": "|T538564:0|t |cFF0070DEAncestral Guidan|r",
                    "key": "114052",
                    "name": "|T135791:0|t |cFF0070DEAscendance|r",
                    "key": "198838",
                    "name": "|T136098:0|t |cFF0070DEEarthen Wall Tot|r",
                    "key": "108280",
                    "name": "|T538569:0|t |cFF0070DEHealing Tide Tot|r",
                  {
                    "default": false,
                    "key": "196555",
                    "name": "|T463284:0|t |cFFA330C9Netherwalk|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "186265",
                    "name": "|T132199:0|t |cFFABD473Aspect of the Tu|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "45438",
                    "name": "|T135841:0|t |cFF40C7EBIce Block|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "642",
                    "name": "|T524354:0|t |cFFF58CBADivine Shield|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "31224",
                    "name": "|T136177:0|t |cFFFFF569Cloak of Shadows|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  }
  {
                    "default": false,
                    "key": "198589",
                    "name": "|T1305150:0|t |cFFA330C9Blur|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "48707",
                    "name": "|T136120:0|t |cFFC41F3BAnti-Magic Shell|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "48743",
                    "name": "|T136146:0|t |cFFC41F3BDeath Pact|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "48792",
                    "name": "|T237525:0|t |cFFC41F3BIcebound Fortitu|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "49039",
                    "name": "|T136187:0|t |cFFC41F3BLichborne|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "327574",
                    "name": "|T136133:0|t |cFFC41F3BSacrificial Pact|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "22812",
                    "name": "|T136097:0|t |cFFFF7D0ABarkskin|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "319454",
                    "name": "|T135879:0|t |cFFFF7D0AHeart of the Wil|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "108238",
                    "name": "|T136059:0|t |cFFFF7D0ARenewal|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "61336",
                    "name": "|T236169:0|t |cFFFF7D0ASurvival Instinc|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "109304",
                    "name": "|T461117:0|t |cFFABD473Exhilaration|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "108978",
                    "name": "|T609811:0|t |cFF40C7EBAlter Time|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "342245",
                    "name": "|T609811:0|t |cFF40C7EBAlter Time|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "235313",
                    "name": "|T132221:0|t |cFF40C7EBBlazing Barrier|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "11426",
                    "name": "|T135988:0|t |cFF40C7EBIce Barrier|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "235450",
                    "name": "|T135991:0|t |cFF40C7EBPrismatic Barrie|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "122278",
                    "name": "|T620827:0|t |cFF00FF96Dampen Harm|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "122783",
                    "name": "|T775460:0|t |cFF00FF96Diffuse Magic|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "243435",
                    "name": "|T615341:0|t |cFF00FF96Fortifying Brew|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "115203",
                    "name": "|T615341:0|t |cFF00FF96Fortifying Brew|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "122470",
                    "name": "|T651728:0|t |cFF00FF96Touch of Karma|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "498",
                    "name": "|T524353:0|t |cFFF58CBADivine Protectio|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "205191",
                    "name": "|T135986:0|t |cFFF58CBAEye for an Eye|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "184662",
                    "name": "|T236264:0|t |cFFF58CBAShield of Vengea|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "19236",
                    "name": "|T237550:0|t |cFFFFFFFFDesperate Prayer|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "47585",
                    "name": "|T237563:0|t |cFFFFFFFFDispersion|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "185311",
                    "name": "|T1373904:0|t |cFFFFF569Crimson Vial|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "Evasion/Riposte",
                    "name": "|T136205:0|t |cFFFFF569Evasion/Riposte|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "108271",
                    "name": "|T538565:0|t |cFF0070DEAstral Shift|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "108416",
                    "name": "|T538538:0|t |cFF8787EDDark Pact|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "104773",
                    "name": "|T136150:0|t |cFF8787EDUnending Resolve|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "118038",
                    "name": "|T132336:0|t |cFFC79C6EDie by the Sword|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "184364",
                    "name": "|T132345:0|t |cFFC79C6EEnraged Regenera|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "23920",
                    "name": "|T132361:0|t |cFFC79C6ESpell Reflection|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  }
                ],
  {
                    "default": false,
                    "key": "198589",
                    "name": "|T1305150:0|t |cFFA330C9Blur|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "48707",
                    "name": "|T136120:0|t |cFFC41F3BAnti-Magic Shell|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "48743",
                    "name": "|T136146:0|t |cFFC41F3BDeath Pact|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "48792",
                    "name": "|T237525:0|t |cFFC41F3BIcebound Fortitu|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "49039",
                    "name": "|T136187:0|t |cFFC41F3BLichborne|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "327574",
                    "name": "|T136133:0|t |cFFC41F3BSacrificial Pact|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "22812",
                    "name": "|T136097:0|t |cFFFF7D0ABarkskin|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "319454",
                    "name": "|T135879:0|t |cFFFF7D0AHeart of the Wil|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "108238",
                    "name": "|T136059:0|t |cFFFF7D0ARenewal|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "61336",
                    "name": "|T236169:0|t |cFFFF7D0ASurvival Instinc|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "109304",
                    "name": "|T461117:0|t |cFFABD473Exhilaration|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "108978",
                    "name": "|T609811:0|t |cFF40C7EBAlter Time|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "342245",
                    "name": "|T609811:0|t |cFF40C7EBAlter Time|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "235313",
                    "name": "|T132221:0|t |cFF40C7EBBlazing Barrier|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "11426",
                    "name": "|T135988:0|t |cFF40C7EBIce Barrier|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "235450",
                    "name": "|T135991:0|t |cFF40C7EBPrismatic Barrie|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "122278",
                    "name": "|T620827:0|t |cFF00FF96Dampen Harm|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "122783",
                    "name": "|T775460:0|t |cFF00FF96Diffuse Magic|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "243435",
                    "name": "|T615341:0|t |cFF00FF96Fortifying Brew|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "115203",
                    "name": "|T615341:0|t |cFF00FF96Fortifying Brew|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "122470",
                    "name": "|T651728:0|t |cFF00FF96Touch of Karma|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "498",
                    "name": "|T524353:0|t |cFFF58CBADivine Protectio|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "205191",
                    "name": "|T135986:0|t |cFFF58CBAEye for an Eye|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "184662",
                    "name": "|T236264:0|t |cFFF58CBAShield of Vengea|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "19236",
                    "name": "|T237550:0|t |cFFFFFFFFDesperate Prayer|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "47585",
                    "name": "|T237563:0|t |cFFFFFFFFDispersion|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "185311",
                    "name": "|T1373904:0|t |cFFFFF569Crimson Vial|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "Evasion/Riposte",
                    "name": "|T136205:0|t |cFFFFF569Evasion/Riposte|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "108271",
                    "name": "|T538565:0|t |cFF0070DEAstral Shift|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "108416",
                    "name": "|T538538:0|t |cFF8787EDDark Pact|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "104773",
                    "name": "|T136150:0|t |cFF8787EDUnending Resolve|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "118038",
                    "name": "|T132336:0|t |cFFC79C6EDie by the Sword|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "184364",
                    "name": "|T132345:0|t |cFFC79C6EEnraged Regenera|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "23920",
                    "name": "|T132361:0|t |cFFC79C6ESpell Reflection|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  }
                ],
sadf  {
                    "default": false,
                    "key": "198589",
                    "name": "|T1305150:0|t |cFFA330C9Blur|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "48707",
                    "name": "|T136120:0|t |cFFC41F3BAnti-Magic Shell|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "48743",
                    "name": "|T136146:0|t |cFFC41F3BDeath Pact|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "48792",
                    "name": "|T237525:0|t |cFFC41F3BIcebound Fortitu|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "49039",
                    "name": "|T136187:0|t |cFFC41F3BLichborne|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "327574",
                    "name": "|T136133:0|t |cFFC41F3BSacrificial Pact|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "22812",
                    "name": "|T136097:0|t |cFFFF7D0ABarkskin|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "319454",
                    "name": "|T135879:0|t |cFFFF7D0AHeart of the Wil|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "108238",
                    "name": "|T136059:0|t |cFFFF7D0ARenewal|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "61336",
                    "name": "|T236169:0|t |cFFFF7D0ASurvival Instinc|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "109304",
                    "name": "|T461117:0|t |cFFABD473Exhilaration|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "108978",
                    "name": "|T609811:0|t |cFF40C7EBAlter Time|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "342245",
                    "name": "|T609811:0|t |cFF40C7EBAlter Time|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "235313",
                    "name": "|T132221:0|t |cFF40C7EBBlazing Barrier|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "11426",
                    "name": "|T135988:0|t |cFF40C7EBIce Barrier|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "235450",
                    "name": "|T135991:0|t |cFF40C7EBPrismatic Barrie|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "122278",
                    "name": "|T620827:0|t |cFF00FF96Dampen Harm|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "122783",
                    "name": "|T775460:0|t |cFF00FF96Diffuse Magic|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "243435",
                    "name": "|T615341:0|t |cFF00FF96Fortifying Brew|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "115203",
                    "name": "|T615341:0|t |cFF00FF96Fortifying Brew|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "122470",
                    "name": "|T651728:0|t |cFF00FF96Touch of Karma|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "498",
                    "name": "|T524353:0|t |cFFF58CBADivine Protectio|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "205191",
                    "name": "|T135986:0|t |cFFF58CBAEye for an Eye|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "184662",
                    "name": "|T236264:0|t |cFFF58CBAShield of Vengea|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "19236",
                    "name": "|T237550:0|t |cFFFFFFFFDesperate Prayer|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "47585",
                    "name": "|T237563:0|t |cFFFFFFFFDispersion|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "185311",
                    "name": "|T1373904:0|t |cFFFFF569Crimson Vial|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "Evasion/Riposte",
                    "name": "|T136205:0|t |cFFFFF569Evasion/Riposte|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "108271",
                    "name": "|T538565:0|t |cFF0070DEAstral Shift|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "108416",
                    "name": "|T538538:0|t |cFF8787EDDark Pact|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "104773",
                    "name": "|T136150:0|t |cFF8787EDUnending Resolve|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "118038",
                    "name": "|T132336:0|t |cFFC79C6EDie by the Sword|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "184364",
                    "name": "|T132345:0|t |cFFC79C6EEnraged Regenera|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "23920",
                    "name": "|T132361:0|t |cFFC79C6ESpell Reflection|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  }
                ],
                  {
                    "default": false,
                    "key": "196718",
                    "name": "|T1305154:0|t |cFFA330C9Darkness|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "51052",
                    "name": "|T237510:0|t |cFFC41F3BAnti-Magic Zone|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "31821",
                    "name": "|T135872:0|t |cFFF58CBAAura Mastery|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "62618",
                    "name": "|T253400:0|t |cFFFFFFFFPower Word: Barr|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "97462",
                    "name": "|T132351:0|t |cFFC79C6ERallying Cry|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  }
   {
                    "default": false,
                    "key": "320341",
                    "name": "|T136194:0|t |cFFA330C9Bulk Extraction|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "212084",
                    "name": "|T1450143:0|t |cFFA330C9Fel Devastation|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "204021",
                    "name": "|T1344647:0|t |cFFA330C9Fiery Brand|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "187827",
                    "name": "|T1247263:0|t |cFFA330C9Metamorphosis|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "263648",
                    "name": "|T2065625:0|t |cFFA330C9Soul Barrier|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "185245",
                    "name": "|T1344654:0|t |cFFA330C9Torment|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "194844",
                    "name": "|T342917:0|t |cFFC41F3BBonestorm|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "49028",
                    "name": "|T135277:0|t |cFFC41F3BDancing Rune Wea|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "56222",
                    "name": "|T136088:0|t |cFFC41F3BDark Command|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "219809",
                    "name": "|T132151:0|t |cFFC41F3BTombstone|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "55233",
                    "name": "|T136168:0|t |cFFC41F3BVampiric Blood|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "50334",
                    "name": "|T236149:0|t |cFFFF7D0ABerserk|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "6795",
                    "name": "|T132270:0|t |cFFFF7D0AGrowl|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "102558",
                    "name": "|T571586:0|t |cFFFF7D0AIncarnation: Gua|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "204066",
                    "name": "|T136057:0|t |cFFFF7D0ALunar Beam|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "80313",
                    "name": "|T1033490:0|t |cFFFF7D0APulverize|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "115399",
                    "name": "|T629483:0|t |cFF00FF96Black Ox Brew|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "322507",
                    "name": "|T1360979:0|t |cFF00FF96Celestial Brew|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "325153",
                    "name": "|T644378:0|t |cFF00FF96Exploding Keg|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "132578",
                    "name": "|T608951:0|t |cFF00FF96Invoke Niuzao, t|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "115546",
                    "name": "|T620830:0|t |cFF00FF96Provoke|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "115176",
                    "name": "|T642417:0|t |cFF00FF96Zen Meditation|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "31850",
                    "name": "|T135870:0|t |cFFF58CBAArdent Defender|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "86659",
                    "name": "|T135919:0|t |cFFF58CBAGuardian of Anci|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "105809",
                    "name": "|T571555:0|t |cFFF58CBAHoly Avenger|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "1161",
                    "name": "|T132091:0|t |cFFC79C6EChallenging Shou|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "1160",
                    "name": "|T132366:0|t |cFFC79C6EDemoralizing Sho|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "12975",
                    "name": "|T135871:0|t |cFFC79C6ELast Stand|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "871",
                    "name": "|T132362:0|t |cFFC79C6EShield Wall|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "355",
                    "name": "|T136080:0|t |cFFC79C6ETaunt|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  }
                ],
]]
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
	local WIDTH = 1024
	local HEIGHT = 32
	local NUMROWS = 16
	local NUMCOLS = 4
	local DATA = SquishData
	local types = { "Battle Res", "Tank", "Damage", "Dispel", "HardCC", "RaidCD", "SoftCC", "Healing", "Utility", "External", "Immunity", "Personal", "STHardCC", "STSoftCC", "Interrupt" }
	-- text input
	-- order columns
	-- resize
	-- column sizes
	-- saved variables
	local frame = CreateFrame("frame", nil, UIParent, "BackdropTemplate")
	frame:SetSize(WIDTH, HEIGHT * NUMROWS + 8)
	frame:SetPoint("CENTER", 0, 0)
	frame:SetBackdrop(MEDIA:BACKDROP(true, true, 1, 0))
	frame:SetBackdropColor(0, 0, 0, 0.7)
	frame:SetBackdropBorderColor(0, 0, 0, 1)
	frame:SetFrameStrata("HIGH")
	frame:EnableMouseWheel(true)
	local edit = CreateFrame("editbox", nil, frame, "InputBoxTemplate")
	edit:SetWidth(256)
	edit:SetHeight(32)
	edit:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 8, 4)
	edit:SetAutoFocus(false)
	edit:Show()
	edit:SetFontObject("ChatFontNormal")
	edit:SetScript("OnEscapePressed", function(self)
		self:ClearFocus()
		--self:Hide()
	end)
	local bar = CreateFrame("frame", nil, frame, "BackdropTemplate")
	local height = math.min(1, NUMROWS / #DATA) * (HEIGHT * NUMROWS)
	bar.travel = (HEIGHT * NUMROWS) - height
	bar:SetSize(20, height)
	bar:SetPoint("TOPRIGHT", -4, -4)
	bar:SetBackdrop(MEDIA:BACKDROP(true, nil, 0, 0))
	bar:SetBackdropColor(0, 0, 0, 0.5)
	bar:EnableMouse(true)
	local function update(row, index)
		local spell, kind = unpack(DATA[index])
		local name, _, icon = GetSpellInfo(spell)
		row.spell = spell
		row.icon:SetTexture(icon)
		row[1]:SetText(name)
		row[2]:SetText(types[kind])
		row[3]:SetText("")
		row[4]:SetText("")
	end
	local prev
	for rowIndex = 1, NUMROWS do
		local row = CreateFrame("frame", nil, frame, "BackdropTemplate")
		row:SetSize(WIDTH - 8 - 24, HEIGHT)
		row:SetBackdrop(MEDIA:BACKDROP(true, false, 0, 0))
		if rowIndex % 2 == 0 then
			row:SetBackdropColor(0, 0, 0, 0.48)
		else
			row:SetBackdropColor(0, 0, 0, 0.52)
		end
		if rowIndex == 1 then
			row:SetPoint("TOPLEFT", 4, -4)
		else
			row:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, 0)
		end
		row.icon = row:CreateTexture()
		row.icon:SetPoint("TOPLEFT", 1, -1)
		row.icon:SetPoint("BOTTOMRIGHT", row, "TOPLEFT", HEIGHT - 2, -HEIGHT + 2)
		row.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		for colIndex = 1, NUMCOLS do
			local cell = row:CreateFontString(nil, nil, "GameFontNormal")
			cell:SetFont(MEDIA:FONT(), 10)
			cell:SetPoint("LEFT", HEIGHT + ((WIDTH - HEIGHT - (NUMCOLS + 1) * 4) / NUMCOLS) * (colIndex - 1) + (colIndex * 4), 0)
			table.insert(row, cell)
		end
		row:SetScript("OnEnter", function(self)
			if not self.spell then return end
			GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
			GameTooltip:SetSpellByID(self.spell)
			GameTooltip:Show()
		end)
		row:SetScript("OnLeave", function()
			GameTooltip:Hide()
		end)
		table.insert(frame, row)
		update(row, rowIndex)
		prev = row
	end
	local mt = getmetatable(GameTooltip).__index
	for k, v in pairs(mt) do
		if k:sub(1, 3) == "Set" then
			print(k)
		end
	end
	local index = 1
	local max = #DATA - NUMROWS + 1
	frame:SetScript("OnMouseWheel", function(self, delta)
		if delta < 0 then -- up
			if (index - delta) > max then return end
			frame[2]:SetPoint("TOPLEFT", frame, "TOPLEFT", 4, -4)
			frame[1]:SetPoint("TOPLEFT", frame[NUMROWS], "BOTTOMLEFT", 0, 0)
			update(frame[1], index + NUMROWS)
			table.insert(frame, frame[1])
			table.remove(frame, 1)
			index = index - delta
		else
			if (index - delta) < 1 then return end
			index = index - delta
			frame[NUMROWS]:SetPoint("TOPLEFT", frame, "TOPLEFT", 4, -4)
			frame[1]:SetPoint("TOPLEFT", frame[NUMROWS], "BOTTOMLEFT", 0, 0)
			update(frame[NUMROWS], index)
			table.insert(frame, 1, frame[NUMROWS])
			table.remove(frame)
		end
		bar:SetPoint("TOPRIGHT", -4, -(index - 1) / (max - 1) * bar.travel - 4)
	end)
	do
		local sy
		local si
		local ei
		local hy = (NUMROWS * HEIGHT / #DATA) * UIParent:GetScale()
		bar:SetScript("OnEnter", function(self)
			self:SetBackdropColor(0.5, 0.5, 0.5, 0.5)
		end)
		local function OnLeave(self)
			self:SetBackdropColor(0, 0, 0, 0.5)
		end
		bar:SetScript("OnLeave", OnLeave)
		local function OnUpdate(self)
			local _, my = GetCursorPosition()
			local dy = my - sy
			local n = math.floor(dy / hy)
			ei = math.max(1, math.min(max, si - n))
			for r = 1, NUMROWS do
				update(frame[r], ei + r - 1)
			end
			bar:SetPoint("TOPRIGHT", -4, -(ei - 1) / (max - 1) * bar.travel - 4)
		end
		local function OnMouseUp(self)
			index = ei
			self:SetScript("OnUpdate", nil)
			self:SetScript("OnMouseUp", nil)
			self:SetScript("OnLeave", OnLeave)
			OnLeave(self)
		end
		bar:SetScript("OnMouseDown", function(self)
			si = index
			_, sy = GetCursorPosition()
			self:SetScript("OnUpdate", OnUpdate)
			self:SetScript("OnMouseUp", OnMouseUp)
			self:SetScript("OnLeave", nil)
		end)
	end
end
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
	local function tick(self)
		local now = GetTime()
		local elapsed = now - self.time
		print("tick", self.name, elapsed)
		self.time = now
	end
	--local test1 = { name = '1', __tick = tick, time = GetTime() }
	--Ticker:Add(test1)
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
				print(index, id, name, icon, role)
				specIcon:SetTexture(icon)
			elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
				local index = GetSpecialization()
				local id, name, description, icon, background, role = GetSpecializationInfo(index, false)
				print(index, id, name, icon, role)
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
		---self:SetAttribute('groupBy', 'ASSIGNEDROLE')
		self:SetAttribute("groupBy", "GROUP")
		---self:SetAttribute('groupingOrder', 'TANK,DAMAGER,HEALER')
		self:SetAttribute("groupingOrder", "1,2,3,4,5,6,7,8")
		self:SetAttribute("template", "SecureActionButtonTemplate,BackdropTemplate")
		self:SetAttribute("initialConfigFunction", [[
      print("initialConfigFunction")
      self:SetWidth(75)
      self:SetHeight(128)
      self:GetParent():CallMethod('ConfigureButton', self:GetName())
    ]])
		do
			-- boss target
			local target = CreateFrame("frame", nil, self, "BackdropTemplate")
			target:SetSize(75, 32)
			target:SetPoint("BOTTOMRIGHT", 0, 0)
			target:SetBackdrop(MEDIA:BACKDROP(true, false, 0, 0))
			target:SetBackdropColor(0, 0, 0, 0.75)
			target:SetFrameLevel(4)
			target.playerTargetPosition = CreateSpring(
				function(_, index)
					target:SetPoint("BOTTOMRIGHT", (index - 1) * -77, 128)
				end,
				230,
				24,
				0.001
			)
			target.playerTargetAlpha = CreateSpring(
				function(_, value)
					target:SetAlpha(value)
				end,
				300,
				20,
				0.1
			)
			target.playerTargetAlpha(0)
			target:RegisterEvent("PLAYER_TARGET_CHANGED")
			target.header = self
			target:SetScript("OnEvent", OnEvent_PlayerTarget)
		end
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
			self.textName = self.healthBar:CreateFontString(nil, nil, "GameFontNormal")
			self.textName:SetPoint("CENTER", 0, 0)
			self.textName:SetFont(MEDIA:FONT(), 14, "OUTLINE")
			self.textStatus = self.healthBar:CreateFontString(nil, nil, "GameFontNormal")
			self.textStatus:SetFont(MEDIA:FONT(), 12)
			self.textStatus:SetPoint("TOP", self.textName, "BOTTOM", 0, -8)
			self.healthSpring = CreateSpring(
				function(spring, health)
					self.healthBar:SetValue(health)
					self.shieldBar:SetValue(health + spring.absorb)
				end,
				180,
				30,
				0.1
			)
			self.auraAttonement = CreateFrame("frame", nil, self, "BackdropTemplate")
			self.auraAttonement:SetSize(24, 24)
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
			-- 2 auras top
			-- 3 auras bottom
			--self.healthBar:Hide()
			--self.absorbBar:Hide()
			--self.shieldBar:Hide()
			do
				local icon = CreateFrame("frame", nil, self, "BackdropTemplate")
				icon:SetSize(75, 75)
				icon:SetPoint("BOTTOM", self, "TOP", 0, 3)
				icon:SetBackdrop(MEDIA:BACKDROP(true, false, 0, 0))
				icon:SetBackdropColor(0, 0, 0, 0.75)
				icon.texture = icon:CreateTexture()
				icon.texture:SetPoint("TOPLEFT", 1, -1)
				icon.texture:SetPoint("BOTTOMRIGHT", -1, 1)
				icon.texture:SetTexture(MEDIA:STATUSBAR())
				icon.texture:SetVertexColor(0, 0.5, 1, 0.5)
			end
			self.buffs = {}
			self.buffs.cursor = 0
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
			self.resserIcon = self.healthBar:CreateTexture(nil, "OVERLAY")
			self.resserIcon:SetSize(32, 32)
			self.resserIcon:SetTexture([[Interface\RaidFrame\Raid-Icon-Rez]])
			self.resserIcon:SetPoint("CENTER", 0, 0)
		end
		function OnEvent(self, event, ...)
			if event == "UNIT_SET" then
				self:RegisterEvent("PLAYER_ROLES_ASSIGNED")
				self:RegisterEvent("RAID_TARGET_UPDATE")
				self:RegisterEvent("GROUP_ROSTER_UPDATE")
				self:RegisterEvent("PARTY_LEADER_CHANGED")
				self:RegisterEvent("INCOMING_RESURRECT_CHANGED")
				self:RegisterUnitEvent("UNIT_HEALTH", self.unit)
				self:RegisterUnitEvent("UNIT_CONNECTION", self.unit)
				self:RegisterUnitEvent("UNIT_AURA", self.unit)
				self:RegisterUnitEvent("UNIT_NAME_UPDATE", self.unit)
				self:RegisterUnitEvent("UNIT_MAXHEALTH", self.unit)
				self:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", self.unit)
				self:RegisterUnitEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED", self.unit)
			elseif event == "UNIT_MOD" then
				self:RegisterUnitEvent("UNIT_HEALTH", self.unit)
				self:RegisterUnitEvent("UNIT_CONNECTION", self.unit)
				self:RegisterUnitEvent("UNIT_AURA", self.unit)
				self:RegisterUnitEvent("UNIT_NAME_UPDATE", self.unit)
				self:RegisterUnitEvent("UNIT_MAXHEALTH", self.unit)
				self:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", self.unit)
				self:RegisterUnitEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED", self.unit)
			elseif event == "UNIT_REM" then
				self:UnregisterEvent("UNIT_HEALTH")
				self:UnregisterEvent("UNIT_CONNECTION")
				self:UnregisterEvent("UNIT_AURA")
				self:UnregisterEvent("UNIT_NAME_UPDATE")
				self:UnregisterEvent("UNIT_MAXHEALTH")
				self:UnregisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")
				self:UnregisterEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED")
				self:UnregisterEvent("PLAYER_ROLES_ASSIGNED")
				self:UnregisterEvent("RAID_TARGET_UPDATE")
				self:UnregisterEvent("GROUP_ROSTER_UPDATE")
				self:UnregisterEvent("PARTY_LEADER_CHANGED")
				self:UnregisterEvent("INCOMING_RESURRECT_CHANGED")
			elseif event == "GUID_SET" then
				local __0 = UnitIsDead(self.unit)
				local __1 = UnitIsGhost(self.unit)
				local __2 = UnitIsConnected(self.unit)
				SetUnitStatus(self.textStatus, __0, __1, __2)
				self.auraAttonement:Hide()
				for index = 1, 40 do
					local name, icon, count, kind, duration, expiration, source, stealable, _, id = UnitAura(self.unit, index, "HELPFUL")
					if not name then
						break
					end
					AuraList_Push(self.buffs, name, icon, id)
					if id == 194384 then
						self.auraAttonement:Show()
						self.auraAttonement.cd:SetCooldown(expiration - duration, duration)
					end
				end
				self.auraAttonement:Hide()
				self.buffs.cursor = 0
				local __3 = UnitName(self.unit)
				self.textName:SetText(__3:sub(1, 5))
				local __4 = ClassColor(self.unit)
				local cr, cg, cb = unpack(__4)
				self.healthBar:SetStatusBarColor(cr, cg, cb)
				local __5 = UnitHealthMax(self.unit)
				self.healthBar:SetMinMaxValues(0, __5)
				self.shieldBar:SetMinMaxValues(0, __5)
				self.absorbBar:SetMinMaxValues(0, __5)
				local __6 = UnitHealth(self.unit)
				local __7 = UnitGetTotalAbsorbs(self.unit)
				self.healthSpring.absorb = __7
				self.healthSpring(__6)
				local __8 = UnitGetTotalHealAbsorbs(self.unit)
				self.absorbBar:SetValue(__8)
				local __9 = UnitGroupRolesAssigned(self.unit)
				UpdateRoleIcon(self.roleIcon, __9)
				local __10 = GetRaidTargetIndex(self.unit)
				UpdateRaidIcon(self.raidIcon, __10)
				local __11 = UnitInParty(self.unit)
				local __12 = UnitIsGroupLeader(self.unit)
				ToggleVisible(self.leaderIcon, (__11 and __12))
				local __13 = UnitIsGroupAssistant(self.unit)
				ToggleVisible(self.assistIcon, (__11 and __13))
				Stack(self.healthBar, "BOTTOMLEFT", "BOTTOMLEFT", -3, -6, "BOTTOM", "TOP", 0, 0, self.roleIcon, self.raidIcon, self.leaderIcon, self.assistIcon)
				local __14 = UnitHasIncomingResurrection(self.unit)
				ToggleVisible(self.resserIcon, __14)
				RangeChecker:Register(self, true)
			elseif event == "GUID_MOD" then
				local __0 = UnitIsDead(self.unit)
				local __1 = UnitIsGhost(self.unit)
				local __2 = UnitIsConnected(self.unit)
				SetUnitStatus(self.textStatus, __0, __1, __2)
				self.auraAttonement:Hide()
				for index = 1, 40 do
					local name, icon, count, kind, duration, expiration, source, stealable, _, id = UnitAura(self.unit, index, "HELPFUL")
					if not name then
						break
					end
					AuraList_Push(self.buffs, name, icon, id)
					if id == 194384 then
						self.auraAttonement:Show()
						self.auraAttonement.cd:SetCooldown(expiration - duration, duration)
					end
				end
				self.auraAttonement:Hide()
				self.buffs.cursor = 0
				local __3 = UnitName(self.unit)
				self.textName:SetText(__3:sub(1, 5))
				local __4 = ClassColor(self.unit)
				local cr, cg, cb = unpack(__4)
				self.healthBar:SetStatusBarColor(cr, cg, cb)
				local __5 = UnitHealthMax(self.unit)
				self.healthBar:SetMinMaxValues(0, __5)
				self.shieldBar:SetMinMaxValues(0, __5)
				self.absorbBar:SetMinMaxValues(0, __5)
				local __6 = UnitHealth(self.unit)
				local __7 = UnitGetTotalAbsorbs(self.unit)
				self.healthSpring.absorb = __7
				self.healthSpring:stop(__6)
				local __8 = UnitGetTotalHealAbsorbs(self.unit)
				self.absorbBar:SetValue(__8)
				local __9 = UnitGroupRolesAssigned(self.unit)
				UpdateRoleIcon(self.roleIcon, __9)
				local __10 = GetRaidTargetIndex(self.unit)
				UpdateRaidIcon(self.raidIcon, __10)
				local __11 = UnitInParty(self.unit)
				local __12 = UnitIsGroupLeader(self.unit)
				ToggleVisible(self.leaderIcon, (__11 and __12))
				local __13 = UnitIsGroupAssistant(self.unit)
				ToggleVisible(self.assistIcon, (__11 and __13))
				Stack(self.healthBar, "BOTTOMLEFT", "BOTTOMLEFT", -3, -6, "BOTTOM", "TOP", 0, 0, self.roleIcon, self.raidIcon, self.leaderIcon, self.assistIcon)
				local __14 = UnitHasIncomingResurrection(self.unit)
				ToggleVisible(self.resserIcon, __14)
				RangeChecker:Update(self)
			elseif event == "UNIT_HEALTH" then
				local __0 = UnitIsDead(self.unit)
				local __1 = UnitIsGhost(self.unit)
				local __2 = UnitIsConnected(self.unit)
				SetUnitStatus(self.textStatus, __0, __1, __2)
				local __3 = UnitHealth(self.unit)
				local __4 = UnitGetTotalAbsorbs(self.unit)
				self.healthSpring.absorb = __4
				self.healthSpring(__3)
			elseif event == "UNIT_CONNECTION" then
				local __0 = UnitIsDead(self.unit)
				local __1 = UnitIsGhost(self.unit)
				local __2 = UnitIsConnected(self.unit)
				SetUnitStatus(self.textStatus, __0, __1, __2)
			elseif event == "UNIT_AURA" then
				self.auraAttonement:Hide()
				for index = 1, 40 do
					local name, icon, count, kind, duration, expiration, source, stealable, _, id = UnitAura(self.unit, index, "HELPFUL")
					if not name then
						break
					end
					AuraList_Push(self.buffs, name, icon, id)
					if id == 194384 then
						self.auraAttonement:Show()
						self.auraAttonement.cd:SetCooldown(expiration - duration, duration)
					end
				end
				self.auraAttonement:Hide()
				self.buffs.cursor = 0
			elseif event == "UNIT_NAME_UPDATE" then
				local __0 = UnitName(self.unit)
				self.textName:SetText(__0:sub(1, 5))
			elseif event == "UNIT_MAXHEALTH" then
				local __0 = UnitHealthMax(self.unit)
				self.healthBar:SetMinMaxValues(0, __0)
				self.shieldBar:SetMinMaxValues(0, __0)
				self.absorbBar:SetMinMaxValues(0, __0)
			elseif event == "UNIT_ABSORB_AMOUNT_CHANGED" then
				local __0 = UnitHealth(self.unit)
				local __1 = UnitGetTotalAbsorbs(self.unit)
				self.healthSpring.absorb = __1
				self.healthSpring(__0)
			elseif event == "CUST_BOSS_TARGET" then
				local __0 = ...
			--print("boss target", __0, self.guid)
			elseif event == "UNIT_HEAL_ABSORB_AMOUNT_CHANGED" then
				local __0 = UnitGetTotalHealAbsorbs(self.unit)
				self.absorbBar:SetValue(__0)
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
			elseif event == "INCOMING_RESURRECT_CHANGED" then
				local __0 = UnitHasIncomingResurrection(self.unit)
				ToggleVisible(self.resserIcon, __0)
			elseif event == "GUID_REM" then
				RangeChecker:Unregister(self)
			end
		end
		self:SetPoint("BOTTOMRIGHT", playerButton, "TOPRIGHT", 1, 100)
		self:Show()
	end
end)
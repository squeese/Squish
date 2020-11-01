BINDING_HEADER_SQUISH = "Squish"
BINDING_NAME_SPELLS_TOGGLE = "Toggle Spells Panel"
local Table_Insert = table.insert
local Table_Remove = table.remove
local Math_Floor = math.floor
local Math_Abs = math.abs
local Math_Ceil = math.ceil
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
	local _, _, _, _, _, _, _, _, _, id = UnitAura(self.unit, self.index, self.filter)
	GameTooltip:AddLine("ID: " .. tostring(id), 1, 1, 1)
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
local CanDispel = {}
function CanDispel:RegisterEvents(frame)
	frame:RegisterEvent("PLAYER_ENTERING_WORLD")
	frame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
	self.RegisterEvents = nil
	return function(_, event)
		if event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_SPECIALIZATION_CHANGED" then
			local class = UnitClass("player")
			for k, _ in pairs(CanDispel) do
				CanDispel[k] = nil
			end
			if class == "Priest" then
				if IsSpellKnown(527) then
					CanDispel.Magic = true
					CanDispel.Disease = true
				else
					CanDispel.Disease = true
				end
			else
				print("unhandled dispel", class)
			end
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
local UI = CreateFrame("frame", nil, UIParent, "BackdropTemplate")
UI:RegisterEvent("PLAYER_LOGIN")
UI:SetScript("OnEvent", function(self, event)
	DisableBlizzard = nil
end)
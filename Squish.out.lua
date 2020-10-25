local AcceptInvite
do
	local frame
	function AcceptInvite(delay)
		if frame == nil then
			frame = CreateFrame("frame", nil, UIParent)
		end
		frame:RegisterEvent("PARTY_INVITE_REQUEST")
		frame:SetScript("OnEvent", function(self)
			C_Timer.After(delay or 0.01, function()
				AcceptGroup()
				StaticPopup_Hide("PARTY_INVITE")
			end)
		end)
	end
end
local ClassColor
local PowerColor
do
	local COLOR_CLASS
	local COLOR_POWER
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
	local function ClassColor(unit)
		return COLOR_CLASS[select(2, UnitClass(unit))]
	end
	local function PowerColor(unit)
		return COLOR_POWER[select(2, UnitPowerType(unit))]
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
			else
				button:SetAlpha(1.0)
			end
		else
			button:SetAlpha(1.0)
		end
	end
	function RangeChecker:Register(button)
		if #self == 0 then
			elapsed = 0
			self.__frame:SetScript("OnUpdate", OnUpdate)
		end
		table.insert(self, button)
	end
	function RangeChecker:Unregister(button)
		for index = 1, #self do
			if button == self[index] then
				remove(self, index)
				break
			end
		end
		if #self == 0 then
			self.__frame:SetScript("OnUpdate", nil)
		end
	end
end
local function ToggleVisible(frame, condition)
	if condition then
		frame:Show()
	else
		frame:Hide()
	end
end
local function CreateStack(self, P, R, X, Y, p, r, x, y)
	return function(...)
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
end
local Spring
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
	local active = {}
	local function OnUpdate(_, elapsed)
		local elapsedMS = elapsed * 1000
		local elapsedDT = elapsedMS / MPF
		for i = #active, 1, -1 do
			local s = active[i]
			if idle(s) then
				s.__active = nil
				remove(active, i)
				if #active == 0 then
					frame:SetScript("OnUpdate", nil)
				end
			else
				update(s, elapsedMS)
			end
			s.__update_F(s.__update_c)
		end
	end
	function Spring(FN, K, B, P)
		local spring
		return function(target)
			if not spring then
				spring = {}
				spring.__update_F = FN
				spring.__update_p = P or 0.01
				spring.__update_k = K or 170
				spring.__update_b = B or 26
				spring.__update_c = target
				spring.__update_C = target
				spring.__update_v = 0
				spring.__update_V = 0
				spring.__update_e = 0
			end
			spring.__update_t = target
			if not spring.__active then
				spring.__active = true
				if #active == 0 then
					frame:SetScript("OnUpdate", OnUpdate)
				end
				insert(active, spring)
			end
		end
	end
end
local MEDIA = {}
do
	local bgFlat = [[Interface\Addons\Squish\media\backdrop.tga]]
	local barFlat = [[Interface\Addons\Squish\media\flat.tga]]
	local vixar = [[interface\addons\squish\media\vixar.ttf]]
	function MEDIA:BACKDROP()
		return {
			bgFile = bgFlat,
			edgeSize = 1,
			insets = {
				left = -1,
				right = -1,
				top = -1,
				bottom = -1
			}
		}
	end
	function MEDIA:STATUSBAR()
		return barFlat
	end
	function MEDIA:FONT()
		return vixar
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
local function CreateUnitButton(parent)
	local button = CreateFrame("button", nil, parent, "SecureActionButtonTemplate,BackdropTemplate")
	button:SetScript("OnAttributeChanged", OnAttributeChanged)
	button:RegisterForClicks("AnyUp")
	button:SetAttribute("*type1", "target")
	button:SetAttribute("*type2", "togglemenu")
	button:SetBackdrop(MEDIA:BACKDROP())
	button:SetBackdropColor(0, 0, 0, 0.75)
	return button
end
local function StatusBar(parent, ...)
	local bar = CreateFrame("statusbar", nil, parent, ...)
	bar:SetMinMaxValues(0, 1)
	bar:SetStatusBarTexture(MEDIA:STATUSBAR())
	return bar
end
local function FontString(parent, size)
	local font = parent:CreateFontString(nil, nil, "GameFontNormal")
	font:SetFont(MEDIA:FONT(), size or 20)
	font:SetShadowColor(1, 1, 1, 0.5)
	return font
end
local function RoleIcon(parent, size, ...)
	local texture = parent:CreateTexture(...)
	texture:SetSize(size, size)
	texture:SetTexture([[Interface\LFGFrame\UI-LFG-ICON-ROLES]])
	return texture
end
local function RoleIconUpdate(unit, icon)
	icon:Hide()
	local role = UnitGroupRolesAssigned(unit)
	if role then -- == 'TANK' or role == 'HEALER' then
		icon:Show()
		icon:SetTexCoord(GetTexCoordsForRole(role))
	end
end
local function LeaderIcon(parent, size, ...)
	local texture = parent:CreateTexture(...)
	texture:SetSize(size, size)
	texture:SetTexture([[Interface\GroupFrame\UI-Group-LeaderIcon]])
	texture:SetTexCoord(-0.1, 1, 0, 1)
	texture:SetRotation(0.2, 0.5, 0.5)
	return texture
end
local function AssistIcon(parent, size, ...)
	local texture = parent:CreateTexture(...)
	texture:SetSize(size, size)
	texture:SetTexture([[Interface\GroupFrame\UI-Group-AssistantIcon]])
	return texture
end
local function LeadAndAssistIconUpdate(unit, leader, assist)
	leader:Hide()
	assist:Hide()
	if UnitInParty(unit) then
		if UnitIsGroupLeader(unit) then
			leader:Show()
		elseif UnitIsGroupAssistant(unit) then
			assist:Show()
		end
	end
end
local function RestedIcon(parent, size, ...)
	local texture = parent:CreateTexture(...)
	texture:SetSize(size, size)
	texture:SetTexture([[Interface\CharacterFrame\UI-StateIcon]])
	texture:SetTexCoord(0.05, .55, 0, .49)
	return texture
end
local function CombatIcon(parent, size, ...)
	local texture = parent:CreateTexture(...)
	texture:SetSize(size, size)
	texture:SetTexture([[Interface\CharacterFrame\UI-StateIcon]])
	texture:SetTexCoord(.5, 1, 0, .49)
	return texture
end
local function ResserIcon(parent, size, ...)
	local texture = parent:CreateTexture(nil, "OVERLAY")
	texture:SetSize(size, size)
	texture:SetTexture([[Interface\RaidFrame\Raid-Icon-Rez]])
	return texture
end
local CreateCastBar
do
	local function OnUpdateCasting(self, elapsed)
		self.value = self.value + elapsed
		self.bar:SetValue(self.value)
	end
	local function OnUpdateChannel(self, elapsed)
		self.value = self.value - elapsed
		self.bar:SetValue(self.value)
	end
	local function OnUpdateFade(self, elapsed)
		self.alpha = self.alpha - (elapsed * 4)
		self:SetAlpha(self.alpha)
		if self.alpha <= 0.25 then
			self:SetScript("OnUpdate", nil)
		end
	end
	local function Update(self, casting, name, _, texture, sTime, eTime, _, _, notInterruptible)
		if not name then
			return false
		end
		local curValue = GetTime() - (sTime / 1000)
		local maxValue = (eTime - sTime) / 1000
		self.bar:SetMinMaxValues(0, maxValue)
		self.bar:SetValue(casting and curValue or (maxValue - curValue))
		self.bar:SetStatusBarColor(1.0, 0.7, 0.0)
		self.icon:SetTexture(texture)
		self.text:SetText(name)
		--self:SetAlpha(1.0)
		self.interupted = nil
		if notInterruptible then
			self.shield:Show()
		else
			self.shield:Hide()
		end
		if casting then
			self.value = casting and curValue
			self:SetScript("OnUpdate", OnUpdateCasting)
		else
			self.value = maxValue - curValue
			self:SetScript("OnUpdate", OnUpdateChannel)
		end
		return true
	end
	local function OnEvent(self, event)
		if event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_DELAYED" then
			Update(self, true, UnitCastingInfo(self.unit))
			-- self.bar:SetMinMaxValues(0, 1)
			-- self.bar:SetValue(1)
			-- self.alpha = self:GetAlpha() * (self.interupted and 4.0 or 1.0)
			-- self:SetScript("OnUpdate", OnUpdateFade)
		elseif event == "UNIT_SPELLCAST_CHANNEL_START" or event == "UNIT_SPELLCAST_CHANNEL_UPDATE" then
			Update(self, false, UnitChannelInfo(self.unit))
		elseif event == "UNIT_SPELLCAST_INTERRUPTIBLE" or event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE" then
			if Update(self, true, UnitCastingInfo(self.unit)) then return end
			if Update(self, false, UnitChannelInfo(self.unit)) then return end
			--self:SetAlpha(0.25)
			self:SetScript("OnUpdate", nil)
		elseif event == "UNIT_SPELLCAST_INTERRUPTED" then
			print("2")
			self.bar:SetMinMaxValues(0, 1)
			self.bar:SetValue(1)
			self.bar:SetStatusBarColor(1.0, 0.0, 0.0)
			self.text:SetText("Interrupted")
			self.interupted = true
		elseif event == "UNIT_SPELLCAST_FAILED" then
			print("1")
			self.bar:SetMinMaxValues(0, 1)
			self.bar:SetValue(1)
			self.bar:SetStatusBarColor(1.0, 0.0, 0.0)
			self.text:SetText("Failed")
			self.interupted = true
		else
		end
	end
	local function OnAttributeChanged(self, key, val)
		if key ~= "statehidden" or val ~= self.hidden then
			-- print("changed", val)
			self.hidden = val
			if not self.hidden then
				print("show")
				-- self:SetAlpha(0)
				-- self:SetScript("OnUpdate", nil)
				--self:SetAlpha(1)
				--self:SetScript("OnEvent", OnEvent)
				--if (Update(self, true, UnitCastingInfo(self.unit))) then return end
				--if (Update(self, false, UnitChannelInfo(self.unit))) then return end
				--self:SetAlpha(0.25)
				--self:SetScript("OnUpdate", nil)
			else
				print("hide")
			end
		end
	end
	function CreateCastBar(parent, unit, height)
		local self = CreateFrame("frame", nil, parent, "SecureHandlerStateTemplate,BackdropTemplate")
		self:SetBackdrop(MEDIA:BACKDROP())
		self:SetBackdropColor(0, 0, 0, 0.75)
		self:SetHeight(height)
		--self:SetAlpha(0.25)
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
		self.text:SetText("")
		self.unit = "target"
		RegisterAttributeDriver(self, "state-visibility", "[@target,exists] show; hide")
		self:SetScript("OnAttributeChanged", OnAttributeChanged)
		return self
	end
end
local function CreatePlayerButton(parent)
	local self = CreateUnitButton(parent)
	local powerBar = StatusBar(self)
	powerBar:SetPoint("TOPLEFT", 0, 0)
	powerBar:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, -8)
	local healthBar = StatusBar(self)
	healthBar:SetPoint("TOPLEFT", powerBar, "BOTTOMLEFT", 0, -1)
	healthBar:SetPoint("BOTTOMRIGHT", 0, 0)
	healthBar:SetFrameLevel(3)
	local shieldBar = StatusBar(self)
	shieldBar:SetAllPoints(healthBar)
	shieldBar:SetStatusBarColor(0.0, 1.0, 1.0, 0.5)
	shieldBar:SetFrameLevel(2)
	local absorbBar = StatusBar(self)
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
	local powerFont = FontString(healthBar, 20)
	local healthFont = FontString(healthBar, 20)
	powerFont:SetPoint("TOP")
	healthFont:SetPoint("BOTTOM")
	local roleIcon = RoleIcon(healthBar, 48, nil, "OVERLAY")
	local leaderIcon = LeaderIcon(healthBar, 18, nil, "OVERLAY")
	local assistIcon = AssistIcon(healthBar, 18, nil, "OVERLAY")
	local restedIcon = RestedIcon(healthBar, 18, nil, "OVERLAY")
	local combatIcon = CombatIcon(healthBar, 18, nil, "OVERLAY")
	local resserIcon = ResserIcon(healthBar, 18, nil, "OVERLAY")
	local StackIcons = CreateStack(healthBar, "TOPLEFT", "TOPLEFT", 6, -4, "TOPLEFT", "TOPRIGHT", 4, 0)
	function self:handler(event, ...)
		if event == "UNIT_SET" then
			self:RegisterEvent("PLAYER_REGEN_ENABLED")
			self:RegisterEvent("PLAYER_REGEN_DISABLED")
			self:RegisterEvent("PLAYER_UPDATE_RESTING")
			self:RegisterEvent("GROUP_ROSTER_UPDATE")
			self:RegisterEvent("PLAYER_ROLES_ASSIGNED")
			self:RegisterEvent("INCOMING_RESURRECT_CHANGED")
			self:RegisterUnitEvent("UNIT_DISPLAYPOWER", self.unit)
			self:RegisterUnitEvent("UNIT_POWER_UPDATE", self.unit)
			self:RegisterUnitEvent("UNIT_MAXPOWER", self.unit)
			self:RegisterUnitEvent("UNIT_POWER_FREQUENT", self.unit)
			self:RegisterUnitEvent("UNIT_MAXHEALTH", self.unit)
			self:RegisterUnitEvent("UNIT_HEALTH", self.unit)
			self:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", self.unit)
			self:RegisterUnitEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED", self.unit)
			local __0__ = ClassColor(self.unit)
			local __1__ = PowerColor(self.unit)
			local __2__ = UnitPowerMax(self.unit)
			local __3__ = UnitPower(self.unit)
			local __4__ = UnitHealthMax(self.unit)
			local __5__ = UnitHealth(self.unit)
			local __6__ = UnitGetTotalAbsorbs(self.unit)
			local __7__ = UnitGetTotalHealAbsorbs(self.unit)
			local __8__ = UnitAffectingCombat(self.unit)
			local __9__ = IsResting()
			local __10__ = UnitIsGroupAssistant(self.unit)
			local __11__ = UnitIsGroupLeader(self.unit)
			local __12__ = UnitInParty(self.unit)
			healthBar:SetStatusBarColor(unpack(__0__))
			background:SetVertexColor(unpack(__0__))
			local r, g, b = unpack(__1__)
			powerBar:SetStatusBarColor(r, g, b)
			powerFont:SetTextColor(r * 0.15, g * 0.15, b * 0.15)
			healthFont:SetTextColor(r * 0.15, g * 0.15, b * 0.15)
			powerBar:SetMinMaxValues(0, __2__)
			powerBar:SetValue(__3__)
			powerFont:SetText(math.ceil(__3__ / __2__ * 100))
			healthBar:SetMinMaxValues(0, __4__)
			shieldBar:SetMinMaxValues(0, __4__)
			absorbBar:SetMinMaxValues(0, __4__)
			healthBar:SetValue(__5__)
			shieldBar:SetValue(__5__ + __6__)
			absorbBar:SetValue(__7__)
			ToggleVisible(combatIcon, __8__)
			ToggleVisible(restedIcon, __9__)
			ToggleVisible(leaderIcon, __12__ and __11__)
			ToggleVisible(assistIcon, __12__ and __10__)
			StackIcons(roleIcon, leaderIcon, assistIcon, restedIcon, combatIcon, resserIcon)
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
			self:UnregisterEvent("UNIT_DISPLAYPOWER")
			self:UnregisterEvent("UNIT_POWER_UPDATE")
			self:UnregisterEvent("UNIT_MAXPOWER")
			self:UnregisterEvent("UNIT_POWER_FREQUENT")
			self:UnregisterEvent("UNIT_MAXHEALTH")
			self:UnregisterEvent("UNIT_HEALTH")
			self:UnregisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")
			self:UnregisterEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED")
			self:UnregisterEvent("PLAYER_REGEN_ENABLED")
			self:UnregisterEvent("PLAYER_REGEN_DISABLED")
			self:UnregisterEvent("PLAYER_UPDATE_RESTING")
			self:UnregisterEvent("GROUP_ROSTER_UPDATE")
			self:UnregisterEvent("PLAYER_ROLES_ASSIGNED")
			self:UnregisterEvent("INCOMING_RESURRECT_CHANGED")
		elseif event == "GUID_MOD" then
			local __0__ = ClassColor(self.unit)
			local __1__ = PowerColor(self.unit)
			local __2__ = UnitPowerMax(self.unit)
			local __3__ = UnitPower(self.unit)
			local __4__ = UnitHealthMax(self.unit)
			local __5__ = UnitHealth(self.unit)
			local __6__ = UnitGetTotalAbsorbs(self.unit)
			local __7__ = UnitGetTotalHealAbsorbs(self.unit)
			local __8__ = UnitAffectingCombat(self.unit)
			local __9__ = IsResting()
			local __10__ = UnitIsGroupAssistant(self.unit)
			local __11__ = UnitIsGroupLeader(self.unit)
			local __12__ = UnitInParty(self.unit)
			healthBar:SetStatusBarColor(unpack(__0__))
			background:SetVertexColor(unpack(__0__))
			local r, g, b = unpack(__1__)
			powerBar:SetStatusBarColor(r, g, b)
			powerFont:SetTextColor(r * 0.15, g * 0.15, b * 0.15)
			healthFont:SetTextColor(r * 0.15, g * 0.15, b * 0.15)
			powerBar:SetMinMaxValues(0, __2__)
			powerBar:SetValue(__3__)
			powerFont:SetText(math.ceil(__3__ / __2__ * 100))
			healthBar:SetMinMaxValues(0, __4__)
			shieldBar:SetMinMaxValues(0, __4__)
			absorbBar:SetMinMaxValues(0, __4__)
			healthBar:SetValue(__5__)
			shieldBar:SetValue(__5__ + __6__)
			absorbBar:SetValue(__7__)
			ToggleVisible(combatIcon, __8__)
			ToggleVisible(restedIcon, __9__)
			ToggleVisible(leaderIcon, __12__ and __11__)
			ToggleVisible(assistIcon, __12__ and __10__)
			StackIcons(roleIcon, leaderIcon, assistIcon, restedIcon, combatIcon, resserIcon)
		elseif event == "UNIT_DISPLAYPOWER" then
			local __1__ = PowerColor(self.unit)
			local r, g, b = unpack(__1__)
			powerBar:SetStatusBarColor(r, g, b)
			powerFont:SetTextColor(r * 0.15, g * 0.15, b * 0.15)
			healthFont:SetTextColor(r * 0.15, g * 0.15, b * 0.15)
		elseif event == "UNIT_POWER_UPDATE" then
			local __1__ = PowerColor(self.unit)
			local __2__ = UnitPowerMax(self.unit)
			local __3__ = UnitPower(self.unit)
			local r, g, b = unpack(__1__)
			powerBar:SetStatusBarColor(r, g, b)
			powerFont:SetTextColor(r * 0.15, g * 0.15, b * 0.15)
			healthFont:SetTextColor(r * 0.15, g * 0.15, b * 0.15)
			powerBar:SetMinMaxValues(0, __2__)
			powerBar:SetValue(__3__)
			powerFont:SetText(math.ceil(__3__ / __2__ * 100))
		elseif event == "UNIT_MAXPOWER" then
			local __2__ = UnitPowerMax(self.unit)
			local __3__ = UnitPower(self.unit)
			powerBar:SetMinMaxValues(0, __2__)
			powerBar:SetValue(__3__)
			powerFont:SetText(math.ceil(__3__ / __2__ * 100))
		elseif event == "UNIT_POWER_FREQUENT" then
			local __2__ = UnitPowerMax(self.unit)
			local __3__ = UnitPower(self.unit)
			powerBar:SetValue(__3__)
			powerFont:SetText(math.ceil(__3__ / __2__ * 100))
		elseif event == "UNIT_MAXHEALTH" then
			local __4__ = UnitHealthMax(self.unit)
			local __5__ = UnitHealth(self.unit)
			local __6__ = UnitGetTotalAbsorbs(self.unit)
			healthBar:SetMinMaxValues(0, __4__)
			shieldBar:SetMinMaxValues(0, __4__)
			absorbBar:SetMinMaxValues(0, __4__)
			healthBar:SetValue(__5__)
			shieldBar:SetValue(__5__ + __6__)
		elseif event == "UNIT_HEALTH" then
			local __5__ = UnitHealth(self.unit)
			local __6__ = UnitGetTotalAbsorbs(self.unit)
			healthBar:SetValue(__5__)
			shieldBar:SetValue(__5__ + __6__)
		elseif event == "UNIT_ABSORB_AMOUNT_CHANGED" then
			local __6__ = UnitGetTotalAbsorbs(self.unit)
			local __5__ = UnitHealth(self.unit)
			shieldBar:SetValue(__5__ + __6__)
		elseif event == "UNIT_HEAL_ABSORB_AMOUNT_CHANGED" then
			local __7__ = UnitGetTotalHealAbsorbs(self.unit)
			absorbBar:SetValue(__7__)
		elseif event == "PLAYER_REGEN_ENABLED" then
			combatIcon:Hide()
			StackIcons(roleIcon, leaderIcon, assistIcon, restedIcon, combatIcon, resserIcon)
		elseif event == "PLAYER_REGEN_DISABLED" then
			combatIcon:Show()
			StackIcons(roleIcon, leaderIcon, assistIcon, restedIcon, combatIcon, resserIcon)
		elseif event == "PLAYER_UPDATE_RESTING" then
			local __9__ = IsResting()
			ToggleVisible(restedIcon, __9__)
			StackIcons(roleIcon, leaderIcon, assistIcon, restedIcon, combatIcon, resserIcon)
		elseif event == "GROUP_ROSTER_UPDATE" then
			local __10__ = UnitIsGroupAssistant(self.unit)
			local __11__ = UnitIsGroupLeader(self.unit)
			local __12__ = UnitInParty(self.unit)
			ToggleVisible(leaderIcon, __12__ and __11__)
			ToggleVisible(assistIcon, __12__ and __10__)
			StackIcons(roleIcon, leaderIcon, assistIcon, restedIcon, combatIcon, resserIcon)
		elseif event == "PLAYER_ROLES_ASSIGNED" then
			StackIcons(roleIcon, leaderIcon, assistIcon, restedIcon, combatIcon, resserIcon)
		elseif event == "INCOMING_RESURRECT_CHANGED" then
			StackIcons(roleIcon, leaderIcon, assistIcon, restedIcon, combatIcon, resserIcon)
		end
	end
	self:SetAttribute("unit", "player")
	return self
end
local UI = CreateFrame("frame", nil, UIParent, "BackdropTemplate")
UI:RegisterEvent("PLAYER_LOGIN")
UI:SetScript("OnEvent", function(self)
	self:SetScript("OnEvent", nil)
	self:UnregisterAllEvents()
	self:SetPoint("TOPLEFT", 0, 0)
	self:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMLEFT", 640, 0)
	self:SetBackdrop(MEDIA:BACKDROP())
	self:SetBackdropColor(0, 0, 0, 0.1)
	self:SetBackdropBorderColor(0, 0, 0, 0)
	-- local scale = max(0.4, min(1.15, 768 / GetScreenHeight()))
	local scale = 0.533333333
	self:SetScale(scale / UIParent:GetScale())
	local playerButton = CreatePlayerButton(self)
	playerButton:SetSize(382, 64)
	playerButton:SetPoint("RIGHT", -8, -240)
	local playerCastbar = CreateCastBar(playerButton, "player", 32)
	playerCastbar:SetPoint("TOPLEFT", playerButton, "BOTTOMLEFT", 0, -16)
	playerCastbar:SetPoint("TOPRIGHT", playerButton, "BOTTOMRIGHT", 0, -16)
	CreatePlayerButton = nil
end)
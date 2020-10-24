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

local function PPFrame(...)
	local frame = CreateFrame("frame", nil, UIParent, ...)
	frame:RegisterEvent("PLAYER_ENTERING_WORLD")
	frame:SetScript("OnEvent", function(self)
		self:SetScript("OnEvent", nil)
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		-- local scale = max(0.4, min(1.15, 768 / GetScreenHeight()))
		local scale = 0.533333333
		self:SetScale(scale / UIParent:GetScale())
	end)
	return frame
end

local ClassColor
local PowerColor
do
	function copyColors(src, dst)
		for key, value in pairs(src) do
			if not dst[key] then
				dst[key] = {
					r = value.r,
					g = value.g,
					b = value.b
				}
			end
		end
		return dst
	end
	local COLOR_POWER = copyColors(PowerBarColor, {
		MANA = {
			r = 0.31,
			g = 0.45,
			b = 0.63
		}
	})
	ClassColor = function(unit)
		return RAID_CLASS_COLORS[select(2, UnitClass(unit))]
	end
	PowerColor = function(unit)
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
			s.__update_C, s.__update_V =
				stepper(
					s.__update_C,
					s.__update_V,
					s.__update_t,
					s.__update_k,
					s.__update_b
				)
		end
		local c, v =
			stepper(
				s.__update_C,
				s.__update_V,
				s.__update_t,
				s.__update_k,
				s.__update_b
			)
		s.__update_c = s.__update_C + (c - s.__update_C) * delta
		s.__update_v = s.__update_V + (v - s.__update_V) * delta
		s.__update_e = s.__update_e - frames * MPF
	end
	local function idle(s)
		if (abs(s.__update_v) < s.__update_p and abs(
			s.__update_c - s.__update_t
		) < s.__update_p) then
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
			return UpdateGUID(self, UnitGUID("player"))
		end
		self:handler(event, ...)
	end
	local function OnEvent_Target(self, event, ...)
		if event == "PLAYER_TARGET_CHANGED" then
			assert(self.unit == "target")
			return UpdateGUID(self, UnitGUID("target"))
		end
		self:handler(event, ...)
	end
	local function OnEvent_Group(self, event, ...)
		if event == "GROUP_ROSTER_UPDATE" then
			return UpdateGUID(self, UnitGUID(self.unit))
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
			self:handler("UNIT_SET", val)
			UpdateGUID(self, UnitGUID(val))
		elseif val ~= nil then
			RemGUIDChangeEvents(self, self.unit)
			SetGUIDChangeEvents(self, val)
			self:handler("UNIT_MOD", val)
			UpdateGUID(self, UnitGUID(val))
		else
			RemGUIDChangeEvents(self, self.unit)
			self:handler("UNIT_REM")
			UpdateGUID(self, nil)
		end
		self.unit = val
	end
end
local CastBar
local CastBarTest
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
		if self.alpha <= 0 then
			self:SetScript("OnUpdate", nil)
		end
	end
	local function Update(
	self,
		casting,
		name,
		_,
		texture,
		sTime,
		eTime,
		_,
		_,
		notInterruptible
	)
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
		self:SetAlpha(1.0)
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
		if not UnitExists(self.unit) then
			self:Hide()
			self:SetAlpha(0)
			self:SetScript("OnUpdate", nil)
			return
		else
			self:Show()
		end

		if event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_DELAYED" then
			Update(self, true, UnitCastingInfo(self.unit))
		elseif event == "UNIT_SPELLCAST_CHANNEL_START" or event == "UNIT_SPELLCAST_CHANNEL_UPDATE" then
			Update(self, false, UnitChannelInfo(self.unit))
		elseif event == "PLAYER_TARGET_CHANGED" or event == "PLAYER_FOCUS_CHANGED" or event == "UNIT_SPELLCAST_INTERRUPTIBLE" or event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE" then
			if UnitExists(self.unit) then
				if Update(
					self,
					true,
					UnitCastingInfo(self.unit)
				) then return end
				if Update(
					self,
					false,
					UnitChannelInfo(self.unit)
				) then return end
			end
			self:SetAlpha(0)
			self:SetScript("OnUpdate", nil)
		elseif event == "UNIT_SPELLCAST_INTERRUPTED" then
			self.bar:SetMinMaxValues(0, 1)
			self.bar:SetValue(1)
			self.bar:SetStatusBarColor(1.0, 0.0, 0.0)
			self.text:SetText("Interrupted")
			self.interupted = true
		elseif event == "UNIT_SPELLCAST_FAILED" then
			self.bar:SetMinMaxValues(0, 1)
			self.bar:SetValue(1)
			self.bar:SetStatusBarColor(1.0, 0.0, 0.0)
			self.text:SetText("Failed")
			self.interupted = true
		else
			self.bar:SetMinMaxValues(0, 1)
			self.bar:SetValue(1)
			self.alpha = self:GetAlpha() * (self.interupted and 4.0 or 1.0)
			self:SetScript("OnUpdate", OnUpdateFade)
		end
	end

	function CastBar(parent, unit, height)
		local frame = CreateFrame("frame", nil, parent, "BackdropTemplate")
		frame:SetBackdrop({
			bgFile = [[Interface\\Addons\\Squish\\media\\backdrop.tga]],
			edgeSize = 1,
			insets = {
				left = -1,
				right = -1,
				top = -1,
				bottom = -1
			}
		})
		frame:SetBackdropColor(0, 0, 0, 0.75)
		frame:SetHeight(height)
		frame:Hide()
		frame:SetAlpha(0)
		frame.unit = unit

		frame.icon = frame:CreateTexture()
		frame.icon:SetPoint("TOPLEFT", 0, 0)
		frame.icon:SetPoint("BOTTOMRIGHT", frame, "BOTTOMLEFT", height, 0)
		frame.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

		frame.bar = CreateFrame("statusbar", nil, frame)
		frame.bar:SetPoint("TOPLEFT", height + 1, 0)
		frame.bar:SetPoint("BOTTOMRIGHT", 0, 0)
		frame.bar:SetStatusBarTexture(
			[[Interface\Addons\Squish\media\flat.tga]]
		)

		frame.shield = frame.bar:CreateTexture(nil, "OVERLAY")
		frame.shield:SetPoint(
			"CENTER",
			frame.icon,
			"CENTER",
			height * 0.55,
			-height * 0.05
		)
		frame.shield:SetSize(height * 3, height * 3)
		frame.shield:SetTexture(
			[[Interface\CastingBar\UI-CastingBar-Arena-Shield]]
		)

		frame.text = frame.bar:CreateFontString(nil, nil, "GameFontNormal")
		frame.text:SetPoint("CENTER", -(height / 2), 0)
		frame.text:SetFont(
			[[interface\addons\squish\media\vixar.ttf]],
			14,
			"OUTLINE"
		)
		frame.text:SetText("")

		if unit == "player" then
			frame:RegisterEvent("PLAYER_ENTERING_WORLD")
		elseif unit == "target" then
			frame:RegisterEvent("PLAYER_TARGET_CHANGED")
		elseif unit == "focus" then
			frame:RegisterEvent("PLAYER_FOCUS_CHANGED")
		end

		frame:RegisterUnitEvent("UNIT_SPELLCAST_START", unit)
		frame:RegisterUnitEvent("UNIT_SPELLCAST_DELAYED", unit)
		frame:RegisterUnitEvent("UNIT_SPELLCAST_STOP", unit)
		frame:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", unit)
		frame:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", unit) -- out of range, los, etc
		frame:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTIBLE", unit)
		frame:RegisterUnitEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE", unit)
		frame:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", unit)
		frame:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", unit)
		frame:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", unit)
		frame:SetScript("OnEvent", OnEvent)

		return frame
	end

	-- show    UnitExists()
	-- change  UnitIsUnit(prev, next)
	-- hide

	function CastBarTest(parent)
		--local frame = CreateFrame("frame", nil, parent, "BackdropTemplate")
		--frame.icon = frame:CreateTexture()
		--frame.icon:SetPoint("TOPLEFT", 0, 0)
		--frame.icon:SetPoint("BOTTOMRIGHT", frame, "BOTTOMLEFT", height, 0)
		--frame.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		--frame.bar = CreateFrame("statusbar", nil, frame)
		--frame.bar:SetPoint("TOPLEFT", height+1, 0)
		--frame.bar:SetPoint("BOTTOMRIGHT", 0, 0)
		--frame.bar:SetStatusBarTexture([[Interface\Addons\Squish\media\flat.tga]])
		--frame.shield = frame.bar:CreateTexture(nil, "OVERLAY")
		--frame.shield:SetPoint("CENTER", frame.icon, "CENTER", height*0.55, -height*0.05)
		--frame.shield:SetSize(height*3, height*3)
		--frame.shield:SetTexture([[Interface\CastingBar\UI-CastingBar-Arena-Shield]])
		--frame.text = frame.bar:CreateFontString(nil, nil, "GameFontNormal")
		--frame.text:SetPoint("CENTER", -(height/2), 0)
		--frame.text:SetFont([[interface\addons\squish\media\vixar.ttf]], 14, "OUTLINE")
		--frame.text:SetText("")
	end
end
AcceptInvite(1)
SetCVar("scriptErrors", 1)
SetCVar("showErrors", 1)

do
	local function CreateButton()
		local button =
			CreateFrame(
				"button",
				nil,
				UIParent,
				"SecureActionButtonTemplate,BackdropTemplate"
			)
		button:SetScript("OnAttributeChanged", OnAttributeChanged)
		button:RegisterForClicks("AnyUp")
		button:SetAttribute("*type1", "target")
		button:SetAttribute("*type2", "togglemenu")
		return button
	end

	local player = CreateButton()
	player:SetSize(64, 64)
	player:SetPoint("CENTER", -64, 0)
	player:SetBackdrop({
		bgFile = [[Interface\\Addons\\Squish\\media\\backdrop.tga]],
		edgeSize = 1,
		insets = {
			left = -1,
			right = -1,
			top = -1,
			bottom = -1
		}
	})
	player:SetBackdropColor(0, 0, 0, 0.5)
	function player:handler(event, ...)
		print("PLAYER", event, ...)
	end
	player:SetAttribute("unit", "player")

	local target = CreateButton()
	target:SetSize(64, 64)
	target:SetPoint("CENTER", 64, 0)
	target:SetBackdrop({
		bgFile = [[Interface\\Addons\\Squish\\media\\backdrop.tga]],
		edgeSize = 1,
		insets = {
			left = -1,
			right = -1,
			top = -1,
			bottom = -1
		}
	})
	target:SetBackdropColor(0, 0, 0, 0.5)
	function target:handler(event, ...)
		print("TARGET", event, ...)
	end
	target:SetAttribute("unit", "target")
	RegisterAttributeDriver(
		target,
		"state-visibility",
		"[@target,exists]show;hide"
	)

	local party =
		CreateFrame(
			"frame",
			"SquishParty",
			UIParent,
			"SecureGroupHeaderTemplate"
		)
	party:SetAttribute("showRaid", true)
	party:SetAttribute("showParty", true)
	party:SetAttribute("showPlayer", true)
	party:SetAttribute("point", "BOTTOM")
	party:SetAttribute("xOffset", 0)
	party:SetAttribute("yOffset", 4)
	party:SetAttribute("groupBy", "ASSIGNEDROLE")
	party:SetAttribute("groupingOrder", "TANK,DAMAGER,HEALER")
	party:SetAttribute(
		"template",
		"SecureActionButtonTemplate,BackdropTemplate"
	)
	party:SetAttribute(
		"initialConfigFunction",
		[[
    self:SetWidth(64)
    self:SetHeight(64)
    self:GetParent():CallMethod('ConfigureButton', self:GetName())
  ]]
	)
	function party:ConfigureButton(name)
		local button = _G[name]
		button:SetBackdrop({
			bgFile = [[Interface\\Addons\\Squish\\media\\backdrop.tga]],
			edgeSize = 1,
			insets = {
				left = -1,
				right = -1,
				top = -1,
				bottom = -1
			}
		})
		button:SetBackdropColor(0, 0, 0, 0.75)

		local name = button:CreateFontString(nil, nil, "GameFontNormal")
		name:SetPoint("CENTER", 0, 0)
		name:SetFont([[interface\addons\squish\media\vixar.ttf]], 14, "OUTLINE")
		name:SetText("hello")

		button:RegisterForClicks("AnyUp")
		button:SetAttribute("*type1", "target")
		button:SetAttribute("*type2", "togglemenu")
		button:SetAttribute("toggleForVehicle", true)
		button:SetScript("OnAttributeChanged", OnAttributeChanged)
		RegisterUnitWatch(button)
		function button:handler(event, ...)
			print("GROUP", event, ...)
			if event == "UNIT_SET" then
				name:SetText(UnitName(...))
			end
		end
	end

	party:SetPoint("CENTER", 0, 128)
	party:Show()
end

local gutter = PPFrame("BackdropTemplate")
gutter:SetPoint("TOPLEFT", 0, 0)
gutter:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMLEFT", 640, 0)
gutter:SetBackdrop({
	bgFile = [[Interface\\Addons\\Squish\\media\\backdrop.tga]],
	edgeSize = 1,
	insets = {
		left = -1,
		right = -1,
		top = -1,
		bottom = -1
	}
})
gutter:SetBackdropColor(0, 0, 0, 0.01)
gutter:SetBackdropBorderColor(0, 0, 0, 0)

local function StatusBar(parent, ...)
	local bar = CreateFrame("statusbar", nil, parent, ...)
	bar:SetMinMaxValues(0, 1)
	bar:SetStatusBarTexture([[Interface\Addons\Squish\media\flat.tga]])
	return bar
end

local function FontString(parent, size)
	local font = parent:CreateFontString(nil, nil, "GameFontNormal")
	font:SetFont([[interface\addons\squish\media\vixar.ttf]], size or 20)
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

local player = (function(parent)
	local self =
		CreateFrame(
			"button",
			nil,
			parent,
			"SecureUnitButtonTemplate,BackdropTemplate"
		)
	self.unit = "player"
	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)
	self:RegisterForClicks("AnyUp")
	self:EnableMouseWheel(true)
	self:SetAttribute("*type1", "target")
	self:SetAttribute("*type2", "togglemenu")
	self:SetAttribute("toggleForVehicle", true)
	self:SetAttribute("unit", self.unit)
	RegisterUnitWatch(self)
	self:SetPoint("RIGHT", -8, -240)
	self:SetSize(382, 64)
	self:SetBackdrop({
		bgFile = [[Interface\\Addons\\Squish\\media\\backdrop.tga]],
		edgeSize = 1,
		insets = {
			left = -1,
			right = -1,
			top = -1,
			bottom = -1
		}
	})
	self:SetBackdropColor(0, 0, 0, 0.75)

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
	background:SetTexture([[Interface\Addons\Squish\media\flat.tga]])
	background:SetAlpha(0.35)

	local overlay = healthBar:CreateTexture(nil, "ARTWORK")
	overlay:SetAllPoints()
	overlay:SetTexture([[Interface\PETBATTLES\Weather-Sunlight]])
	overlay:SetTexCoord(1, 0.26, 0, 0.7)
	overlay:SetBlendMode("ADD")
	overlay:SetAlpha(0.15)

	local powerFont = FontString(healthBar, 20)
	local healthFont = FontString(healthBar, 20)

	local roleIcon = RoleIcon(healthBar, 48, nil, "OVERLAY")
	local leaderIcon = LeaderIcon(healthBar, 18, nil, "OVERLAY")
	local assistIcon = AssistIcon(healthBar, 18, nil, "OVERLAY")
	local restedIcon = RestedIcon(healthBar, 18, nil, "OVERLAY")
	local combatIcon = CombatIcon(healthBar, 18, nil, "OVERLAY")
	local resserIcon = ResserIcon(healthBar, 18, nil, "OVERLAY")

	local castbar = CastBar(self, "player", 32)
	castbar:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -16)
	castbar:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -16)

	local powerPercent = Spring(
		function(percent)
			powerBar:SetValue(percent)
			powerFont:SetPoint("TOPRIGHT", -((1 - percent) * 382) - 6, -4)
		end,
		180,
		30,
		0.008
	)

	local healthPercent = Spring(
		function(percent)
			healthBar:SetValue(percent)
			healthFont:SetPoint("BOTTOMRIGHT", -((1 - percent) * 382) - 6, 4)
		end,
		180,
		30,
		0.004
	)
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:SetScript("OnEvent", function(self, event, unit, ...)
		if event == "PLAYER_ENTERING_WORLD" then
			self:RegisterUnitEvent("UNIT_MAXHEALTH", "player")
			self:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", "player")
			self:RegisterUnitEvent("UNIT_HEALTH", "player")
			self:RegisterUnitEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED", "player")
			self:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
			self:RegisterUnitEvent("UNIT_MAXPOWER", "player")
			self:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
			self:RegisterEvent("PLAYER_REGEN_ENABLED")
			self:RegisterEvent("PLAYER_REGEN_DISABLED")
			self:RegisterEvent("PLAYER_UPDATE_RESTING")
			self:RegisterEvent("INCOMING_RESURRECT_CHANGED")
			self:RegisterEvent("GROUP_ROSTER_UPDATE")
			self:RegisterEvent("PLAYER_ROLES_ASSIGNED")
			local CCol = ClassColor(self.unit)
			local HPMax = UnitHealthMax(self.unit)
			local HPCur = UnitHealth(self.unit)
			local SHCur = UnitGetTotalAbsorbs(self.unit)
			local ABur = UnitGetTotalHealAbsorbs(self.unit)
			local PCol = PowerColor(self.unit)
			local PWCur = UnitPower(self.unit)
			local PWMax = UnitPowerMax(self.unit)
			healthBar:SetStatusBarColor(CCol.r, CCol.g, CCol.b)
			background:SetVertexColor(CCol.r, CCol.g, CCol.b)
			shieldBar:SetMinMaxValues(0, HPMax)
			shieldBar:SetValue(HPCur + SHCur)
			absorbBar:SetMinMaxValues(0, HPMax)
			absorbBar:SetValue(ABur)
			powerBar:SetStatusBarColor(PCol.r, PCol.g, PCol.b)
			powerFont:SetTextColor(PCol.r * 0.15, PCol.g * 0.15, PCol.b * 0.15)
			healthFont:SetTextColor(PCol.r * 0.15, PCol.g * 0.15, PCol.b * 0.15)
			local percent = PWCur / PWMax
			powerFont:SetText(math.ceil(percent * 100))
			powerPercent(percent)
			local percent = HPCur / HPMax
			healthFont:SetText(math.ceil(percent * 100))
			healthPercent(percent)
			if UnitAffectingCombat(self.unit) then
				combatIcon:Show()
			else
				combatIcon:Hide()
			end
			if IsResting() then
				restedIcon:Show()
			else
				restedIcon:Hide()
			end
			if UnitHasIncomingResurrection(self.unit) then
				resserIcon:Show()
			else
				resserIcon:Hide()
			end
			LeadAndAssistIconUpdate(self.unit, leaderIcon, assistIcon)
			RoleIconUpdate(self.unit, roleIcon)
			Stack(
				healthBar,
				"TOPLEFT",
				"TOPLEFT",
				6,
				-4,
				"TOPLEFT",
				"TOPRIGHT",
				4,
				0,
				roleIcon,
				leaderIcon,
				assistIcon,
				restedIcon,
				combatIcon,
				resserIcon
			)
		elseif event == "PLAYER_REGEN_ENABLED" then
			combatIcon:Hide()
			Stack(
				healthBar,
				"TOPLEFT",
				"TOPLEFT",
				6,
				-4,
				"TOPLEFT",
				"TOPRIGHT",
				4,
				0,
				roleIcon,
				leaderIcon,
				assistIcon,
				restedIcon,
				combatIcon,
				resserIcon
			)
		elseif event == "PLAYER_REGEN_DISABLED" then
			combatIcon:Show()
			Stack(
				healthBar,
				"TOPLEFT",
				"TOPLEFT",
				6,
				-4,
				"TOPLEFT",
				"TOPRIGHT",
				4,
				0,
				roleIcon,
				leaderIcon,
				assistIcon,
				restedIcon,
				combatIcon,
				resserIcon
			)
		elseif event == "PLAYER_UPDATE_RESTING" then
			if IsResting() then
				restedIcon:Show()
			else
				restedIcon:Hide()
			end
			Stack(
				healthBar,
				"TOPLEFT",
				"TOPLEFT",
				6,
				-4,
				"TOPLEFT",
				"TOPRIGHT",
				4,
				0,
				roleIcon,
				leaderIcon,
				assistIcon,
				restedIcon,
				combatIcon,
				resserIcon
			)
		elseif event == "INCOMING_RESURRECT_CHANGED" then
			if UnitHasIncomingResurrection(self.unit) then
				resserIcon:Show()
			else
				resserIcon:Hide()
			end
			Stack(
				healthBar,
				"TOPLEFT",
				"TOPLEFT",
				6,
				-4,
				"TOPLEFT",
				"TOPRIGHT",
				4,
				0,
				roleIcon,
				leaderIcon,
				assistIcon,
				restedIcon,
				combatIcon,
				resserIcon
			)
		elseif event == "GROUP_ROSTER_UPDATE" then
			LeadAndAssistIconUpdate(self.unit, leaderIcon, assistIcon)
			Stack(
				healthBar,
				"TOPLEFT",
				"TOPLEFT",
				6,
				-4,
				"TOPLEFT",
				"TOPRIGHT",
				4,
				0,
				roleIcon,
				leaderIcon,
				assistIcon,
				restedIcon,
				combatIcon,
				resserIcon
			)
		elseif event == "PLAYER_ROLES_ASSIGNED" then
			RoleIconUpdate(self.unit, roleIcon)
			Stack(
				healthBar,
				"TOPLEFT",
				"TOPLEFT",
				6,
				-4,
				"TOPLEFT",
				"TOPRIGHT",
				4,
				0,
				roleIcon,
				leaderIcon,
				assistIcon,
				restedIcon,
				combatIcon,
				resserIcon
			)
		elseif event == "UNIT_MAXHEALTH" then
			local HPMax = UnitHealthMax(self.unit)
			local HPCur = UnitHealth(self.unit)
			shieldBar:SetMinMaxValues(0, HPMax)
			absorbBar:SetMinMaxValues(0, HPMax)
			local percent = HPCur / HPMax
			healthFont:SetText(math.ceil(percent * 100))
			healthPercent(percent)
		elseif event == "UNIT_ABSORB_AMOUNT_CHANGED" then
			local HPCur = UnitHealth(self.unit)
			local SHCur = UnitGetTotalAbsorbs(self.unit)
			shieldBar:SetValue(HPCur + SHCur)
		elseif event == "UNIT_HEALTH" then
			local HPCur = UnitHealth(self.unit)
			local SHCur = UnitGetTotalAbsorbs(self.unit)
			local HPMax = UnitHealthMax(self.unit)
			shieldBar:SetValue(HPCur + SHCur)
			local percent = HPCur / HPMax
			healthFont:SetText(math.ceil(percent * 100))
			healthPercent(percent)
		elseif event == "UNIT_HEAL_ABSORB_AMOUNT_CHANGED" then
			local ABur = UnitGetTotalHealAbsorbs(self.unit)
			absorbBar:SetValue(ABur)
		elseif event == "UNIT_POWER_UPDATE" then
			local PCol = PowerColor(self.unit)
			local PWCur = UnitPower(self.unit)
			local PWMax = UnitPowerMax(self.unit)
			powerBar:SetStatusBarColor(PCol.r, PCol.g, PCol.b)
			powerFont:SetTextColor(PCol.r * 0.15, PCol.g * 0.15, PCol.b * 0.15)
			healthFont:SetTextColor(PCol.r * 0.15, PCol.g * 0.15, PCol.b * 0.15)
			local percent = PWCur / PWMax
			powerFont:SetText(math.ceil(percent * 100))
			powerPercent(percent)
		elseif event == "UNIT_MAXPOWER" then
			local PWCur = UnitPower(self.unit)
			local PWMax = UnitPowerMax(self.unit)
			local percent = PWCur / PWMax
			powerFont:SetText(math.ceil(percent * 100))
			powerPercent(percent)
		elseif event == "UNIT_POWER_FREQUENT" then
			local PWCur = UnitPower(self.unit)
			local PWMax = UnitPowerMax(self.unit)
			local percent = PWCur / PWMax
			powerFont:SetText(math.ceil(percent * 100))
			powerPercent(percent)
		end
	end)

	return self
end)(gutter)
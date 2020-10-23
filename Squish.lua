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
				button:SetAlpha(0.25)
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
local CastBar
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
end
AcceptInvite(1)
SetCVar("scriptErrors", 1)
SetCVar("showErrors", 1)

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
gutter:SetBackdropColor(0, 0, 0, 0.1)
gutter:SetBackdropBorderColor(0, 0, 0, 0)

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
	self:SetBackdropBorderColor(0, 0, 0, 1)

	self.health = CreateFrame("statusbar", nil, self)
	self.health:SetStatusBarTexture([[Interface\Addons\Squish\media\flat.tga]])
	self.health:SetPoint("TOPLEFT", 0, 0)
	self.health:SetPoint("BOTTOMRIGHT", 0, 9)
	self.health:SetFrameLevel(3)

	self.shield = CreateFrame("statusbar", nil, self)
	self.shield:SetStatusBarTexture([[Interface\Addons\Squish\media\flat.tga]])
	self.shield:SetPoint("TOPLEFT", 0, 0)
	self.shield:SetPoint("BOTTOMRIGHT", 0, 9)
	self.shield:SetStatusBarColor(1.0, 0.7, 0.0)
	self.shield:SetFrameLevel(2)

	self.absorb = CreateFrame("statusbar", nil, self)
	self.absorb:SetStatusBarTexture([[Interface\Addons\Squish\media\flat.tga]])
	self.absorb:SetPoint("TOPLEFT", 0, 0)
	self.absorb:SetPoint("BOTTOMRIGHT", 0, 9)
	self.absorb:SetStatusBarColor(1.0, 0.0, 0.0, 0.75)
	self.absorb:SetFrameLevel(4)

	self.power = CreateFrame("statusbar", nil, self)
	self.power:SetStatusBarTexture([[Interface\Addons\Squish\media\flat.tga]])
	self.power:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, 8)
	self.power:SetPoint("BOTTOMRIGHT", 0, 0)

	local castbar = CastBar(self, "player", 32)
	castbar:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -16)
	castbar:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -16)
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:SetScript("OnEvent", function(self, event, unit, ...)
		print("TRIGGER", self.unit, "EVENT", event, unit, ...)
		if event == "PLAYER_ENTERING_WORLD" then
			self:RegisterEvent("UNIT_MAXHEALTH")
			self:RegisterEvent("UNIT_HEALTH")
			self:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")
			self:RegisterEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED")
			self:RegisterEvent("UNIT_POWER_UPDATE")
			self:RegisterEvent("UNIT_MAXPOWER")
			self:RegisterEvent("UNIT_POWER_FREQUENT")
			local colHealth = ClassColor(self.unit)
			local maxHealth = UnitHealthMax(self.unit)
			local curHealth = UnitHealth(self.unit)
			local curShield = UnitGetTotalAbsorbs(self.unit)
			local curAbsorb = UnitGetTotalHealAbsorbs(self.unit)
			local colPower = PowerColor(self.unit)
			local maxPower = UnitPowerMax(self.unit)
			local curPower = UnitPower(self.unit)
			self.health:SetStatusBarColor(colHealth.r, colHealth.g, colHealth.b)
			self.health:SetMinMaxValues(0, maxHealth)
			self.health:SetValue(curHealth)
			self.shield:SetMinMaxValues(0, maxHealth)
			self.shield:SetValue(curHealth + curShield)
			self.absorb:SetMinMaxValues(0, maxHealth)
			self.absorb:SetValue(curAbsorb)
			self.power:SetStatusBarColor(colPower.r, colPower.g, colPower.b)
			self.power:SetMinMaxValues(0, maxPower)
			self.power:SetValue(curPower)
		elseif unit ~= nil and self.unit ~= unit then
			return
		elseif event == "UNIT_MAXHEALTH" then
			local maxHealth = UnitHealthMax(self.unit)
			self.health:SetMinMaxValues(0, maxHealth)
			self.shield:SetMinMaxValues(0, maxHealth)
			self.absorb:SetMinMaxValues(0, maxHealth)
		elseif event == "UNIT_HEALTH" then
			local curHealth = UnitHealth(self.unit)
			local curShield = UnitGetTotalAbsorbs(self.unit)
			self.health:SetValue(curHealth)
			self.shield:SetValue(curHealth + curShield)
		elseif event == "UNIT_ABSORB_AMOUNT_CHANGED" then
			local curHealth = UnitHealth(self.unit)
			local curShield = UnitGetTotalAbsorbs(self.unit)
			self.shield:SetValue(curHealth + curShield)
		elseif event == "UNIT_HEAL_ABSORB_AMOUNT_CHANGED" then
			local curAbsorb = UnitGetTotalHealAbsorbs(self.unit)
			self.absorb:SetValue(curAbsorb)
		elseif event == "UNIT_POWER_UPDATE" then
			local colPower = PowerColor(self.unit)
			local maxPower = UnitPowerMax(self.unit)
			local curPower = UnitPower(self.unit)
			self.power:SetStatusBarColor(colPower.r, colPower.g, colPower.b)
			self.power:SetMinMaxValues(0, maxPower)
			self.power:SetValue(curPower)
		elseif event == "UNIT_MAXPOWER" then
			local maxPower = UnitPowerMax(self.unit)
			self.power:SetMinMaxValues(0, maxPower)
		elseif event == "UNIT_POWER_FREQUENT" then
			local curPower = UnitPower(self.unit)
			self.power:SetValue(curPower)
		end
	end)

	return self
end)(gutter)

local target = (function(parent)
	local self =
		CreateFrame(
			"button",
			nil,
			parent,
			"SecureUnitButtonTemplate,BackdropTemplate"
		)
	self.unit = "target"
	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)
	self:RegisterForClicks("AnyUp")
	self:EnableMouseWheel(true)
	self:SetAttribute("*type1", "target")
	self:SetAttribute("*type2", "togglemenu")
	self:SetAttribute("toggleForVehicle", true)
	self:SetAttribute("unit", self.unit)
	RegisterUnitWatch(self)
	self:SetPoint("LEFT", player, "RIGHT", 16, 0)
	self:SetSize(320, 64)
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
	self:SetBackdropBorderColor(0, 0, 0, 1)

	self.health = CreateFrame("statusbar", nil, self)
	self.health:SetStatusBarTexture([[Interface\Addons\Squish\media\flat.tga]])
	self.health:SetPoint("TOPLEFT", 0, 0)
	self.health:SetPoint("BOTTOMRIGHT", 0, 9)
	self.health:SetFrameLevel(3)

	self.shield = CreateFrame("statusbar", nil, self)
	self.shield:SetStatusBarTexture([[Interface\Addons\Squish\media\flat.tga]])
	self.shield:SetPoint("TOPLEFT", 0, 0)
	self.shield:SetPoint("BOTTOMRIGHT", 0, 9)
	self.shield:SetStatusBarColor(1.0, 0.7, 0.0)
	self.shield:SetFrameLevel(2)

	self.absorb = CreateFrame("statusbar", nil, self)
	self.absorb:SetStatusBarTexture([[Interface\Addons\Squish\media\flat.tga]])
	self.absorb:SetPoint("TOPLEFT", 0, 0)
	self.absorb:SetPoint("BOTTOMRIGHT", 0, 9)
	self.absorb:SetStatusBarColor(1.0, 0.0, 0.0, 0.75)
	self.absorb:SetFrameLevel(4)

	self.power = CreateFrame("statusbar", nil, self)
	self.power:SetStatusBarTexture([[Interface\Addons\Squish\media\flat.tga]])
	self.power:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, 8)
	self.power:SetPoint("BOTTOMRIGHT", 0, 0)

	self.nameString = self.health:CreateFontString(nil, nil, "GameFontNormal")
	self.nameString:SetPoint("TOPLEFT", 4, -6)
	self.nameString:SetFont(
		[[interface\addons\squish\media\vixar.ttf]],
		16,
		"OUTLINE"
	)

	self.healthString = self.health:CreateFontString(nil, nil, "GameFontNormal")
	self.healthString:SetPoint("BOTTOMLEFT", 4, 4)
	self.healthString:SetFont(
		[[interface\addons\squish\media\vixar.ttf]],
		11,
		"OUTLINE"
	)

	self.infoString = self.health:CreateFontString(nil, nil, "GameFontNormal")
	self.infoString:SetPoint("BOTTOMRIGHT", -4, 4)
	self.infoString:SetFont(
		[[interface\addons\squish\media\vixar.ttf]],
		11,
		"OUTLINE"
	)

	self.statusString = self.health:CreateFontString(nil, nil, "GameFontNormal")
	self.statusString:SetPoint("BOTTOM", 0, 4)
	self.statusString:SetFont(
		[[interface\addons\squish\media\vixar.ttf]],
		11,
		"OUTLINE"
	)
	self.statusString:SetText("Status")
	local function setStatus()
		if UnitIsDead(self.unit) then
			self.statusString:SetText("Dead")
		elseif UnitIsGhost(self.unit) then
			self.statusString:SetText("Ghost")
		elseif not UnitIsConnected(self.unit) then
			self.statusString:SetText("Offline")
		else
			self.statusString:SetText("")
		end
	end

	self.questIcon = self.health:CreateTexture(nil, "OVERLAY")
	self.questIcon:SetSize(32, 32)
	self.questIcon:SetPoint("TOPRIGHT", -4, 8)
	self.questIcon:SetTexture([[Interface\TargetingFrame\PortraitQuestBadge]])

	local castbar = CastBar(self, "target", 32)
	castbar:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -16)
	castbar:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -16)
	self:RegisterEvent("PLAYER_TARGET_CHANGED")
	self:SetScript("OnEvent", function(self, event, unit, ...)
		print("TRIGGER", self.unit, "EVENT", event, unit, ...)
		if event == "PLAYER_TARGET_CHANGED" then
			if not UnitExists("target") then
				self:UnregisterAllEvents()
				self:RegisterEvent("PLAYER_TARGET_CHANGED")
				self.__active = nil
				return
			elseif not self.__active then
				print("REGISTER", "UNIT_MAXHEALTH")
				self:RegisterEvent("UNIT_MAXHEALTH")
				print("REGISTER", "UNIT_HEALTH")
				self:RegisterEvent("UNIT_HEALTH")
				print("REGISTER", "UNIT_ABSORB_AMOUNT_CHANGED")
				self:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")
				print("REGISTER", "UNIT_HEAL_ABSORB_AMOUNT_CHANGED")
				self:RegisterEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED")
				print("REGISTER", "UNIT_POWER_UPDATE")
				self:RegisterEvent("UNIT_POWER_UPDATE")
				print("REGISTER", "UNIT_MAXPOWER")
				self:RegisterEvent("UNIT_MAXPOWER")
				print("REGISTER", "UNIT_POWER_FREQUENT")
				self:RegisterEvent("UNIT_POWER_FREQUENT")
				print("REGISTER", "UNIT_NAME_UPDATE")
				self:RegisterEvent("UNIT_NAME_UPDATE")
				print("REGISTER", "UNIT_CLASSIFICATION_CHANGED")
				self:RegisterEvent("UNIT_CLASSIFICATION_CHANGED")
				print("REGISTER", "UNIT_LEVEL")
				self:RegisterEvent("UNIT_LEVEL")
				print("REGISTER", "UNIT_CONNECTION")
				self:RegisterEvent("UNIT_CONNECTION")
				self.__active = true
			end
			local colHealth = ClassColor(self.unit)
			local maxHealth = UnitHealthMax(self.unit)
			local curHealth = UnitHealth(self.unit)
			local curShield = UnitGetTotalAbsorbs(self.unit)
			local curAbsorb = UnitGetTotalHealAbsorbs(self.unit)
			local colPower = PowerColor(self.unit)
			local maxPower = UnitPowerMax(self.unit)
			local curPower = UnitPower(self.unit)
			local name = UnitName(self.unit)
			local level = UnitLevel(self.unit)
			local status = UnitClassification(self.unit)
			local isBoss = UnitIsQuestBoss(self.unit)
			self.health:SetStatusBarColor(colHealth.r, colHealth.g, colHealth.b)
			self.health:SetMinMaxValues(0, maxHealth)
			self.health:SetValue(curHealth)
			self.shield:SetMinMaxValues(0, maxHealth)
			self.shield:SetValue(curHealth + curShield)
			self.absorb:SetMinMaxValues(0, maxHealth)
			self.absorb:SetValue(curAbsorb)
			self.power:SetStatusBarColor(colPower.r, colPower.g, colPower.b)
			self.power:SetMinMaxValues(0, maxPower)
			self.power:SetValue(curPower)
			self.nameString:SetText(name)
			self.healthString:SetText(maxHealth)
			self.infoString:SetText(level .. " " .. status)
			if isBoss then
				self.questIcon:Show()
			else
				self.questIcon:Hide()
			end
			setStatus()
			RangeChecker:Update(self)
		elseif unit ~= nil and self.unit ~= unit then
			return
		elseif event == "UNIT_MAXHEALTH" then
			local maxHealth = UnitHealthMax(self.unit)
			self.health:SetMinMaxValues(0, maxHealth)
			self.shield:SetMinMaxValues(0, maxHealth)
			self.absorb:SetMinMaxValues(0, maxHealth)
			self.healthString:SetText(maxHealth)
		elseif event == "UNIT_HEALTH" then
			local curHealth = UnitHealth(self.unit)
			local curShield = UnitGetTotalAbsorbs(self.unit)
			self.health:SetValue(curHealth)
			self.shield:SetValue(curHealth + curShield)
			setStatus()
		elseif event == "UNIT_ABSORB_AMOUNT_CHANGED" then
			local curHealth = UnitHealth(self.unit)
			local curShield = UnitGetTotalAbsorbs(self.unit)
			self.shield:SetValue(curHealth + curShield)
		elseif event == "UNIT_HEAL_ABSORB_AMOUNT_CHANGED" then
			local curAbsorb = UnitGetTotalHealAbsorbs(self.unit)
			self.absorb:SetValue(curAbsorb)
		elseif event == "UNIT_POWER_UPDATE" then
			local colPower = PowerColor(self.unit)
			local maxPower = UnitPowerMax(self.unit)
			local curPower = UnitPower(self.unit)
			self.power:SetStatusBarColor(colPower.r, colPower.g, colPower.b)
			self.power:SetMinMaxValues(0, maxPower)
			self.power:SetValue(curPower)
		elseif event == "UNIT_MAXPOWER" then
			local maxPower = UnitPowerMax(self.unit)
			self.power:SetMinMaxValues(0, maxPower)
		elseif event == "UNIT_POWER_FREQUENT" then
			local curPower = UnitPower(self.unit)
			self.power:SetValue(curPower)
		elseif event == "UNIT_NAME_UPDATE" then
			local name = UnitName(self.unit)
			self.nameString:SetText(name)
		elseif event == "UNIT_CLASSIFICATION_CHANGED" then
			local level = UnitLevel(self.unit)
			local status = UnitClassification(self.unit)
			local isBoss = UnitIsQuestBoss(self.unit)
			self.infoString:SetText(level .. " " .. status)
			if isBoss then
				self.questIcon:Show()
			else
				self.questIcon:Hide()
			end
		elseif event == "UNIT_LEVEL" then
			local level = UnitLevel(self.unit)
			local status = UnitClassification(self.unit)
			self.infoString:SetText(level .. " " .. status)
		elseif event == "UNIT_CONNECTION" then
			setStatus()
		end
	end)
	self:SetScript("OnShow", function(self, ...)
		RangeChecker:Register(self)
	end)
	self:SetScript("OnHide", function(self, ...)
		RangeChecker:Unregister(self)
	end)
	return self
end)(gutter)
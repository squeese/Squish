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
	self:SetPoint("RIGHT", -8, -240)
	self:SetSize(382, 64)

	-- HealthBar
	self.health = (function(parent)
		local bar = CreateFrame("statusbar", nil, parent)
		bar:SetStatusBarTexture([[Interface\Addons\Squish\media\flat.tga]])
		bar:SetPoint("TOPLEFT", 0, 0)
		bar:SetPoint("BOTTOMRIGHT", 0, 9)
		bar:SetFrameLevel(3)
		return bar
	end)(self)

	-- ShieldBar, behind the healthbar
	self.shield = (function(parent)
		local bar = CreateFrame("statusbar", nil, parent)
		bar:SetStatusBarTexture([[Interface\Addons\Squish\media\flat.tga]])
		bar:SetPoint("TOPLEFT", 0, 0)
		bar:SetPoint("BOTTOMRIGHT", 0, 9)
		bar:SetStatusBarColor(1.0, 0.7, 0.0)
		bar:SetFrameLevel(2)
		bar:SetMinMaxValues(0, 1)
		bar:SetValue(1)
		return bar
	end)(self)

	-- ShieldAbsorb, above the healthbar
	self.absorb = (function(parent)
		local bar = CreateFrame("statusbar", nil, parent)
		bar:SetStatusBarTexture([[Interface\Addons\Squish\media\flat.tga]])
		bar:SetPoint("TOPLEFT", 0, 0)
		bar:SetPoint("BOTTOMRIGHT", 0, 9)
		bar:SetStatusBarColor(1.0, 0.0, 0.0, 0.75)
		bar:SetFrameLevel(4)
		return bar
	end)(self)

	-- PowerBar
	self.power = (function(parent)
		local bar = CreateFrame("statusbar", nil, parent)
		bar:SetStatusBarTexture([[Interface\Addons\Squish\media\flat.tga]])
		bar:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, 8)
		bar:SetPoint("BOTTOMRIGHT", 0, 0)
		bar:SetStatusBarColor(1.0, 0.5, 0.0)
		bar:SetMinMaxValues(0, 100)
		bar:SetValue(50)
		return bar
	end)(self)
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("UNIT_MAXHEALTH")
	self:RegisterEvent("UNIT_HEALTH")
	self:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")
	self:RegisterEvent("UNIT_POWER_UPDATE")
	self:RegisterEvent("UNIT_MAXPOWER")
	self:RegisterEvent("UNIT_POWER_FREQUENT")
	self:SetScript("OnEvent", function(self, event, unit, ...)
		if event == "PLAYER_ENTERING_WORLD" then
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
			self.health:SetValue(curHealth)
		elseif event == "UNIT_ABSORB_AMOUNT_CHANGED" then
			local curHealth = UnitHealth(self.unit)
			local curShield = UnitGetTotalAbsorbs(self.unit)
			local curAbsorb = UnitGetTotalHealAbsorbs(self.unit)
			self.shield:SetValue(curHealth + curShield)
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
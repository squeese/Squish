local addon, Q = ...

local gutter = CreateFrame("frame", nil, UIParent, "BackdropTemplate")
gutter:SetPoint("TOPLEFT", 0, 0)
gutter:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMLEFT", 640, 0)
gutter:SetBackdrop(Q.BACKDROP)
gutter:SetBackdropColor(0, 0, 0, 0.1)
gutter:SetBackdropBorderColor(0, 0, 0, 0)
gutter:RegisterEvent("PLAYER_ENTERING_WORLD")
gutter:SetScript("OnEvent", function(self)
  self:UnregisterEvent("PLAYER_ENTERING_WORLD")
  self:SetScript("OnEvent", nil)
  self:SetScale(0.533333333 / UIParent:GetScale())
  SetCVar("scriptErrors", 1)
  SetCVar("showErrors", 1)
end)

local invite = CreateFrame("frame", nil, UIParent)
invite:RegisterEvent("PARTY_INVITE_REQUEST")
invite:SetScript("OnEvent", function(self)
  C_Timer.After(1, function()
    AcceptGroup()
    StaticPopup_Hide("PARTY_INVITE")
  end)
end)

local player = Q.Player(gutter, 382, 64, "RIGHT", -8, -240)
Q.DisableBlizzard("player")
CastingBarFrame:UnregisterAllEvents()
CastingBarFrame:Hide()

local target = Target(gutter, player)
-- Q.DisableBlizzard("target")

local party = Q.Party(gutter, "RIGHT", -8, 0)
--Q.DisableBlizzard("party")

--local buffs = Q.Buffs(gutter, "TOPRIGHT", -8, -8)



--[[ TODO

  target, UnitClassification -> normal, rare, elite, rareelite
  target, leader, assistant, phased
  party, custom-focus precombat, player-guid
  party, swap layouts, sorted by role vs sorted by group

--]]

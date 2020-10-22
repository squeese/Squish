local addon, Q = ...

--[[ TODO
  target, UnitClassification -> normal, rare, elite, rareelite
  target, leader, assistant, phased
  party, custom-focus precombat, player-guid
  party, swap layouts, sorted by role vs sorted by group
  SetCVar('lockActionBars', 1)

  return 
--]]

Q.AcceptInvite(1)
SetCVar("scriptErrors", 1)
SetCVar("showErrors", 1)

local gutter = Q.PPFrame("BackdropTemplate")
gutter:SetPoint("TOPLEFT", 0, 0)
gutter:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMLEFT", 640, 0)
gutter:SetBackdrop(Q.BACKDROP)
gutter:SetBackdropColor(0, 0, 0, 0.1)
gutter:SetBackdropBorderColor(0, 0, 0, 0)

--gutter:RegisterEvent("PLAYER_ENTERING_WORLD")
--gutter:SetScript("OnEvent", function(self)
  --self:UnregisterEvent("PLAYER_ENTERING_WORLD")
  --self:SetScript("OnEvent", nil)
  --local scale = max(0.4, min(1.15, 768 / GetScreenHeight()))
  ---- local scale = 0.533333333
  --print("??", scale)
  --self:SetScale(scale / UIParent:GetScale())
--end)

--local player = Q.Player(gutter, 382, 64, "RIGHT", -8, -240)
--Q.DisableBlizzard("player")
--CastingBarFrame:UnregisterAllEvents()
--CastingBarFrame:Hide()

-- local target = Target(gutter, player)
-- Q.DisableBlizzard("target")

-- local party = Q.Party(gutter, "RIGHT", -8, 0)
-- Q.DisableBlizzard("party")

-- local buffs = Q.Buffs(gutter, "TOPRIGHT", -8, -8)




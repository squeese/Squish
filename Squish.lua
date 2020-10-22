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
  frame:SetPoint("TOPLEFT", 0, 0)
  frame:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMLEFT", 640, 0)
  frame:SetBackdrop(Q.BACKDROP)
  frame:SetBackdropColor(0, 0, 0, 0.1)
  frame:SetBackdropBorderColor(0, 0, 0, 0)
  frame:RegisterEvent("PLAYER_ENTERING_WORLD")
  frame:SetScript("OnEvent", function(self)
    self:SetScript("OnEvent", nil)
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    local scale = max(0.4, min(1.15, 768 / GetScreenHeight()))
    -- local scale = 0.533333333
    print("??", scale)
    self:SetScale(scale / UIParent:GetScale())
  end)
  return frame
end
-- local addon, Q = ...
--[[ TODO
  target, UnitClassification -> normal, rare, elite, rareelite
  target, leader, assistant, phased
  party, custom-focus precombat, player-guid
  party, swap layouts, sorted by role vs sorted by group
  SetCVar('lockActionBars', 1)

  return 
--]]

AcceptInvite(1)
SetCVar("scriptErrors", 1)
SetCVar("showErrors", 1)

do
  local gutter = PPFrame("BackdropTemplate")
  gutter:SetPoint("TOPLEFT", 0, 0)
  gutter:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMLEFT", 640, 0)
  gutter:SetBackdrop({ bgFile = 'Interface\\Addons\\Squish\\media\\backdrop.tga', edgeSize = 1, insets = { left = -1, right = -1, top = -1, bottom = -1 }})
  gutter:SetBackdropColor(0, 0, 0, 0.1)
  gutter:SetBackdropBorderColor(0, 0, 0, 0)
end

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




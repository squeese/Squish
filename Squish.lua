local addon, Q = ...

-- Q.DisableBlizzard("player")
-- Q.DisableBlizzard("target")
-- Q.DisableBlizzard("party")
CastingBarFrame:UnregisterAllEvents()
CastingBarFrame:Hide()

local gutter = CreateFrame("frame", nil, UIParent)
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
end)

--gutter:RegisterAllEvents()
--gutter:SetScript("OnEvent", function(self, event)
  --if event:sub(1, 4) == "UNIT" then return end
  --if event:sub(1, 4) == "GARR" then return end
  --if event:sub(1, 4) == "VOIC" then return end
  --if event:sub(1, 4) == "UPDA" then return end
  --if event:sub(1, 4) == "ACTI" then return end
  --if event:sub(1, 4) == "COMB" then return end
  --if event:sub(1, 4) == "CURS" then return end
  --if event:sub(1, 4) == "SPEL" then return end
  --if event:sub(1, 4) == "SKIL" then return end
  --if event:sub(1, 4) == "LFG_" then return end
  --if event:sub(1, 4) == "RECE" then return end
  --if event:sub(1, 4) == "CRIT" then return end
  --if event:sub(1, 4) == "GUIL" then return end
  --if event:sub(1, 4) == "BAG_" then return end
  --if event:sub(1, 4) == "TRAC" then return end
  --if event:sub(1, 4) == "CONS" then return end
  --if event:sub(1, 3) == "BN_" then return end
  --print(event)
--end)

-- fresh login
-- ADDON_LOADED
-- VARIABLES_LOADED
-- PLAYER_LOGIN
-- PLAYER_ENTERING_WORLD
-- LOADING_SCREEN_DISABLED

-- reload
-- ADDON_LOADED
-- VARIABLES_LOADED
-- PLAYER_LOGIN
-- PLAYER_ENTERING_WORLD
-- LOADING_SCREEN_DISABLED

-- shared.lua, call to Q.ClassColor

local player = Q.Player(gutter, 382, 64, "RIGHT", -8, -240)
local target = Target(gutter, player)
local party = Q.Party(gutter, "RIGHT", -8, 0)
  -- phased
local buffs = Q.Buffs(gutter, "TOPRIGHT", -8, -8)

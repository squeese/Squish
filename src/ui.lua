${template('DEV', process.env.NODE_ENV === 'DEV')}

BINDING_HEADER_SQUISH = 'Squish'
BINDING_NAME_SPELLS_TOGGLE = 'Toggle Spells Panel'

${include("src/lua/utils.lua")}
${include("src/lua/utils.spring.lua")}
${include("src/lua/utils.blizzard.lua")}
${include("src/lua/utils.auratable.lua")}
${"" && include("src/lua/ticker.lua")}
${"" && include("src/lua/onAttributeChange.lua")}
${"" && include("src/lua/castbar.lua")}
${"" && include("src/lua/templates.lua")}
${"" && include("src/lua/spells/data.lua")}
${"" && include("src/lua/spells/positive.lua")}
${"" && include("src/lua/spells/negative.lua")}
${"" && include("src/lua/spells/cooldowns.lua")}
${"" && include("src/lua/spellsgui.lua")}
${"" && include("src/lua/cooldowns.lua")}
${"" && include("src/buffsHeader.lua")}
${"" && include("src/playerButton.lua")}
${"" && include("src/targetButton.lua")}
${"" && include("src/partyHeader.lua")}

local UI = CreateFrame("frame", nil, UIParent, "BackdropTemplate")
UI:RegisterEvent("PLAYER_LOGIN")
UI:SetScript("OnEvent", function(self, event)



  ${cleanup}
end)

--local AURA_HELPFUL = 1
--local AURA_HARMFUL = 1
--local spells = {
  ---- deathknight
  --{ spell=48743,  event=AURA_HARMFUL, class=2 },   -- Death Pact                            CHECK
  --{ spell=48707,  event=AURA_HELPFUL, class=2 },   -- Anti-Magic Shell                      CHECK
  --{ spell=55233,  event=AURA_HELPFUL, class=2 },   -- Vampiric Blood                        CHECK
  --{ spell=194679, event=AURA_HELPFUL, class=2 },   -- Rune Tap                              CHECK
  --{ spell=48792,  event=AURA_HELPFUL, class=2 },   -- Icebound Fortitude                    CHECK
  --{ spell=81256,  event=AURA_HELPFUL, class=2 },   -- Dancing Rune Weapon                   CHECK
  --{ spell=219809, event=AURA_HELPFUL, class=2 },   -- Tombstone
  ---- demonhunter
  --{ spell=187827, event=AURA_HELPFUL, class=12 },   -- Metamorphosis                        CHECK
  --{ spell=162264, event=AURA_HELPFUL, class=12 },   -- Metamorphosis                        CHECK
  --{ spell=196555, event=AURA_HELPFUL, class=12 },   -- Netherwalk                           CHECK
  --{ spell=212800, event=AURA_HELPFUL, class=12 },   -- Blur                                 CHECK
	--{ spell=203819, event=AURA_HELPFUL, class=12 },   -- Demon Spikes                         CHECK
  ---- druid
  --{ spell=22812,  event=AURA_HELPFUL, class=6 },   -- Barkskin                              CHECK
  --{ spell=61336,  event=AURA_HELPFUL, class=6 },   -- Survival Instincts                    CHECK
  --{ spell=22842,  event=AURA_HELPFUL, class=6 },   -- Frenzied Regeneration                 CHECK
  --{ spell=102342, event=AURA_HELPFUL, class=6 },   -- Ironbark                              CHECK
  --{ spell=192081, event=AURA_HELPFUL, class=6 },   -- Ironfur
	--{ spell=102558, event=AURA_HELPFUL, class=6 },   -- Incarnation: Guardian of Ursoc        CHECK
  ---- monk
  --{ spell=243435, event=AURA_HELPFUL, class=4 },   -- Fortifying Brew (Mist/Ww)             CHECK
  --{ spell=120954, event=AURA_HELPFUL, class=4 },   -- Fortifying Brew (Brewmaster)          CHECK
  --{ spell=122783, event=AURA_HELPFUL, class=4 },   -- Diffuse Magic                         CHECK
  --{ spell=116849, event=AURA_HELPFUL, class=4 },   -- Life Cocoon                           CHECK
  --{ spell=122278, event=AURA_HELPFUL, class=4 },   -- Dampen Harm                           CHECK
  --{ spell=115176, event=AURA_HELPFUL, class=4 },   -- Zen Meditation                        CHECK
  --{ spell=201325, event=AURA_HELPFUL, class=4 },   -- Zen Meditation                        CHECK
  ---- paladin
  --{ spell=1022,   event=AURA_HELPFUL, class=3 },   -- Blessing of Protection                CHECK
  --{ spell=1044,   event=AURA_HELPFUL, class=3 },   -- Blessing of Freedom                   CHECK
  --{ spell=642,    event=AURA_HELPFUL, class=3 },   -- Divine Shield                         CHECK
  --{ spell=184662, event=AURA_HELPFUL, class=3 },   -- Shield of Vengeance                   CHECK
  --{ spell=6940,   event=AURA_HELPFUL, class=3 },   -- Blessing of Sacrifice
  --{ spell=205191, event=AURA_HELPFUL, class=3 },   -- Eye for an Eye                        CHECK
  --{ spell=31850,  event=AURA_HELPFUL, class=3 },   -- Ardent Defender                       CHECK 
  --{ spell=204018, event=AURA_HELPFUL, class=3 },   -- Blessing of Spellwarding              CHECK
  --{ spell=86659,  event=AURA_HELPFUL, class=3 },   -- Guardian of Ancient Kings             CHECK
  --{ spell=498,    event=AURA_HELPFUL, class=3 },   -- Divine Protectionp                    CHECK
  ---- warrior
  --{ spell=23920,  event=AURA_HELPFUL, class=1 },   -- Spell Reflection                      CHECK
  --{ spell=97463,  event=AURA_HELPFUL, class=1 },   -- Rallying Cry                          CHECK, 97462
  --{ spell=118038, event=AURA_HELPFUL, class=1 },   -- Die by the Sword                      CHECK
  --{ spell=197690, event=AURA_HELPFUL, class=1 },   -- Defensive Stance                      CHECK
  --{ spell=12975,  event=AURA_HELPFUL, class=1 },   -- Last Stand                            CHECK
  --{ spell=871,    event=AURA_HELPFUL, class=1 },   -- Shield Wall                           CHECK
	--{ spell=190456, event=AURA_HELPFUL, class=1	},   -- Ignore Pain cant cast
	--{ spell=184364, event=AURA_HELPFUL, class=1 },   -- Enraged Regeneration CHECK
--}
--print("hello")



  --[[




        -- Hunter
        [5384] = { type = BUFF_DEFENSIVE }, -- Feign Death
        [53480] = { type = BUFF_DEFENSIVE }, -- Roar of Sacrifice (Hunter Pet Skill)
        [186265] = { type = BUFF_DEFENSIVE }, -- Aspect of the Turtle
	{186265,"HUNTER,DEF",		4,	{186265,180,	8},	nil,			nil,			nil,			},	--Aspect of the Turtle
        [199483] = { type = BUFF_DEFENSIVE }, -- Camouflage
        [209997] = { type = BUFF_DEFENSIVE }, -- Play Dead
        [272682] = { type = BUFF_DEFENSIVE }, -- Master's Call
	{781,	"HUNTER,DEF",		4,	{781,	20,	0},	nil,			nil,			nil,			},	--Disengage
	{109304,"HUNTER,DEF",		3,	{109304,120,	0},	nil,			nil,			nil,			},	--Exhilaration
	{5384,	"HUNTER,DEF",		3,	{5384,	30,	0},	nil,			nil,			nil,			},	--Feign Death
	{199483,"HUNTER,DEF",		3,	{199483,60,	0},	nil,			nil,			nil,			},	--Camouflage
	{201430,"HUNTER,DPS",		3,	nil,			{201430,120,	12},	nil,			nil,			},	--Stampede


        -- Mage
        [11426] = { type = BUFF_DEFENSIVE }, -- Ice Barrier
        [198111] = { type = BUFF_DEFENSIVE }, -- Temporal Shield
        [198064] = { type = BUFF_DEFENSIVE }, -- Prismatic Cloak
        [198065] = { type = BUFF_DEFENSIVE, parent = 198064 }, -- Prismatic Cloak
        [45438] = { type = IMMUNITY }, -- Ice Block



        -- Priest
        [33206] = { type = BUFF_DEFENSIVE }, -- Pain Suppression
        [47536] = { type = BUFF_DEFENSIVE }, -- Rapture
        [47585] = { type = BUFF_DEFENSIVE }, -- Dispersion
        [47788] = { type = BUFF_DEFENSIVE }, -- Guardian Spirit
        [81782] = { type = BUFF_DEFENSIVE }, -- Power Word: Barrier
        [271466] = { type = BUFF_DEFENSIVE, parent = 81782 }, -- Luminous Barrier (Disc Talent)
        [197268] = { type = BUFF_DEFENSIVE }, -- Ray of Hope
        [200183] = { type = BUFF_DEFENSIVE }, -- Apotheosis
        [213610] = { type = BUFF_DEFENSIVE }, -- Holy Ward
        [215769] = { type = BUFF_DEFENSIVE }, -- Spirit of Redemption
        [221660] = { type = IMMUNITY_SPELL }, -- Holy Concentration
	{47585,	"PRIEST,DEF",		4,	nil,			nil,			nil,			{47585,	120,	6},	},	--Dispersion
	{47788,	"PRIEST,DEFTAR",	2,	nil,			nil,			{47788,	180,	10},	nil,			},	--Guardian Spirit
	{2050,	"PRIEST,DEFTAR",	3,	nil,			nil,			{2050,	60,	0},	nil,			},	--Holy Word: Serenity
	{33206,	"PRIEST,DEFTAR",	2,	nil,			{33206,	180,	8},	nil,			nil,			},	--Pain Suppression

        -- Rogue
        [1966] = { type = BUFF_DEFENSIVE }, -- Feint
        [5277] = { type = BUFF_DEFENSIVE }, -- Evasion
        [199754] = { type = BUFF_DEFENSIVE }, -- Riposte
        [31224] = { type = IMMUNITY_SPELL }, -- Cloak of Shadows

        -- Shaman
        [79206] = { type = BUFF_DEFENSIVE }, -- Spiritwalker's Grace 60 * OTHER
        [108281] = { type = BUFF_DEFENSIVE }, -- Ancestral Guidance
        [98008] = { type = BUFF_DEFENSIVE }, -- Spirit Link Totem
        [108271] = { type = BUFF_DEFENSIVE }, -- Astral Shift
        [210918] = { type = BUFF_DEFENSIVE, parent = 108271 }, -- Ethereal Form
        [114050] = { type = BUFF_DEFENSIVE }, -- Ascendance (Elemental)
        [114052] = { type = BUFF_DEFENSIVE, parent = 114050 }, -- Ascendance (Restoration)
        [204293] = { type = BUFF_DEFENSIVE }, -- Spirit Link
        [260878] = { type = BUFF_DEFENSIVE }, -- Spirit Wolf
        [8178] = { type = IMMUNITY_SPELL }, -- Grounding
        [255016] = { type = IMMUNITY_SPELL, parent = 8178 }, -- Grounding
        [204336] = { type = IMMUNITY_SPELL, parent = 8178 }, -- Grounding
        [34079] = { type = IMMUNITY_SPELL, parent = 8178 }, -- Grounding

        -- Warlock
        [20707] = { type = BUFF_DEFENSIVE }, -- Soulstone
        [108416] = { type = BUFF_DEFENSIVE }, -- Dark Pact
        [104773] = { type = IMMUNITY_SPELL }, -- Unending Resolve
        [212295] = { type = IMMUNITY_SPELL }, -- Nether Ward
]]


    --local spells = {
      --{ spell=48743,  source="AURA_HARMFUL", personal=true, class="DEATHKNIGHT" },   -- Death Pact                            CHECK
      --{ spell=48707,  source="AURA_HELPFUL", personal=true, class="DEATHKNIGHT" },   -- Anti-Magic Shell                      CHECK
      --{ spell=55233,  source="AURA_HELPFUL", personal=true, class="DEATHKNIGHT" },   -- Vampiric Blood                        CHECK
      --{ spell=194679, source="AURA_HELPFUL", personal=true, class="DEATHKNIGHT" },   -- Rune Tap                              CHECK
      --{ spell=48792,  source="AURA_HELPFUL", personal=true, class="DEATHKNIGHT" },   -- Icebound Fortitude                    CHECK
      --{ spell=81256,  source="AURA_HELPFUL", personal=true, class="DEATHKNIGHT" },   -- Dancing Rune Weapon                   CHECK
      --{ spell=219809, source="AURA_HELPFUL", personal=true, class="DEATHKNIGHT" },   -- Tombstone
      --{ spell=187827, source="AURA_HELPFUL", personal=true, class="DEMONHUNTER" },   -- Metamorphosis                        CHECK
      --{ spell=162264, source="AURA_HELPFUL", personal=true, class="DEMONHUNTER" },   -- Metamorphosis                        CHECK
      --{ spell=196555, source="AURA_HELPFUL", personal=true, class="DEMONHUNTER" },   -- Netherwalk                           CHECK
      --{ spell=212800, source="AURA_HELPFUL", personal=true, class="DEMONHUNTER" },   -- Blur                                 CHECK
      --{ spell=203819, source="AURA_HELPFUL", personal=true, class="DEMONHUNTER" },   -- Demon Spikes                         CHECK
      --{ spell=22812,  source="AURA_HELPFUL", personal=true, class="DRUID" },   -- Barkskin                              CHECK
      --{ spell=61336,  source="AURA_HELPFUL", personal=true, class="DRUID" },   -- Survival Instincts                    CHECK
      --{ spell=22842,  source="AURA_HELPFUL", personal=true, class="DRUID" },   -- Frenzied Regeneration                 CHECK
      --{ spell=102342, source="AURA_HELPFUL", personal=true, class="DRUID" },   -- Ironbark                              CHECK
      --{ spell=192081, source="AURA_HELPFUL", personal=true, class="DRUID" },   -- Ironfur
      --{ spell=102558, source="AURA_HELPFUL", personal=true, class="DRUID" },   -- Incarnation: Guardian of Ursoc        CHECK
      --{ spell=243435, source="AURA_HELPFUL", personal=true, class="MONK" },   -- Fortifying Brew (Mist/Ww)             CHECK
      --{ spell=120954, source="AURA_HELPFUL", personal=true, class="MONK" },   -- Fortifying Brew (Brewmaster)          CHECK
      --{ spell=122783, source="AURA_HELPFUL", personal=true, class="MONK" },   -- Diffuse Magic                         CHECK
      --{ spell=116849, source="AURA_HELPFUL", personal=true, class="MONK" },   -- Life Cocoon                           CHECK
      --{ spell=122278, source="AURA_HELPFUL", personal=true, class="MONK" },   -- Dampen Harm                           CHECK
      --{ spell=115176, source="AURA_HELPFUL", personal=true, class="MONK" },   -- Zen Meditation                        CHECK
      --{ spell=201325, source="AURA_HELPFUL", personal=true, class="MONK" },   -- Zen Meditation                        CHECK
      --{ spell=1022,   source="AURA_HELPFUL", personal=true, class="PALADIN" },   -- Blessing of Protection                CHECK
      --{ spell=1044,   source="AURA_HELPFUL", personal=true, class="PALADIN" },   -- Blessing of Freedom                   CHECK
      --{ spell=642,    source="AURA_HELPFUL", personal=true, class="PALADIN" },   -- Divine Shield                         CHECK
      --{ spell=184662, source="AURA_HELPFUL", personal=true, class="PALADIN" },   -- Shield of Vengeance                   CHECK
      --{ spell=6940,   source="AURA_HELPFUL", personal=true, class="PALADIN" },   -- Blessing of Sacrifice
      --{ spell=205191, source="AURA_HELPFUL", personal=true, class="PALADIN" },   -- Eye for an Eye                        CHECK
      --{ spell=31850,  source="AURA_HELPFUL", personal=true, class="PALADIN" },   -- Ardent Defender                       CHECK 
      --{ spell=204018, source="AURA_HELPFUL", personal=true, class="PALADIN" },   -- Blessing of Spellwarding              CHECK
      --{ spell=86659,  source="AURA_HELPFUL", personal=true, class="PALADIN" },   -- Guardian of Ancient Kings             CHECK
      --{ spell=498,    source="AURA_HELPFUL", personal=true, class="PALADIN" },   -- Divine Protectionp                    CHECK
      --{ spell=23920,  source="AURA_HELPFUL", personal=true, class="WARRIOR" },   -- Spell Reflection                      CHECK
      --{ spell=97463,  source="AURA_HELPFUL", personal=true, class="WARRIOR" },   -- Rallying Cry                          CHECK, 97462
      --{ spell=118038, source="AURA_HELPFUL", personal=true, class="WARRIOR" },   -- Die by the Sword                      CHECK
      --{ spell=197690, source="AURA_HELPFUL", personal=true, class="WARRIOR" },   -- Defensive Stance                      CHECK
      --{ spell=12975,  source="AURA_HELPFUL", personal=true, class="WARRIOR" },   -- Last Stand                            CHECK
      --{ spell=871,    source="AURA_HELPFUL", personal=true, class="WARRIOR" },   -- Shield Wall                           CHECK
      --{ spell=190456, source="AURA_HELPFUL", personal=true, class="WARRIOR" },   -- Ignore Pain cant cast
      --{ spell=184364, source="AURA_HELPFUL", personal=true, class="WARRIOR" },   -- Enraged Regeneration CHECK
    --}
    --for _, entry in ipairs(spells) do
      --local id = entry.spell
      --SquishData.SpellsData[id] = {
        --source = entry.source,
        --personal = entry.personal,
        --class = entry.class,
      --}
    --end

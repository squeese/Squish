local function TMPGatherData()
  ${include("src/temp2.lua")}

  local SPELLS = {}
  local function Get(id)
    if not SPELLS[id] then
      local name = GetSpellInfo(id)
      SPELLS[id] = { id = id, name = name }
    end
    return SPELLS[id]
  end
  local function Set(spell, key, val)
    if spell[key] ~= nil and spell[key] ~= val then
      print("fail", key, "missmatch", spell[key], val)
      print(GetSpellInfo(spell.id))
      return
    end
    spell[key] = val
  end

  -- Weakaura..
  local stuff = WeakAurasSaved.displays["ZT - Nnoggie's Party CD Front End"].authorOptions[3].subOptions[3].subOptions
  for i = 4, #stuff do
    local section = stuff[i].name
    for _, data in ipairs(stuff[i].subOptions) do
      local id = data.key
      if type(id) == "string" then
        id = tonumber(id)
      end
      if id then
        local spell = Get(id)
        if spell.zt_type then
          spell.zt_type = spell.zt_type ..","..section
        else
          Set(spell, "zt_type", section)
        end
        --Set(spell, "zt_name", data.name)
      end
    end
  end

  do
    local BUFF_DEFENSIVE = "buffs_defensive"
    local BUFF_OFFENSIVE = "buffs_offensive"
    local BUFF_OTHER = "buffs_other"
    local INTERRUPT = "interrupts"
    local CROWD_CONTROL = "cc"
    local ROOT = "roots"
    local IMMUNITY = "immunities"
    local IMMUNITY_SPELL = "immunities_spells"
    local addon = {}
    for _, id in ipairs(WarningDebuffs) do
      local spell = Get(id)
      spell.bd_warning = true
    end
    for _, id in ipairs(PriorityDebuffs) do
      local spell = Get(id)
      spell.bd_priority = true
    end
    local function parse(class, tbl)
      for id, data in pairs(tbl) do
        local spell = Get(id)
        Set(spell, "bd_class", class)
        for k, v in pairs(data) do
          spell["bd_"..k] = v
        end
      end
    end
    parse("DEATHKNIGHT", BD_DK)
    parse("SHAMAN", BD_SHN)
    parse("MAGE", BD_MG)
    parse("HUNTER", BD_HNTR)
    parse("DRUID", BD_DRUID)
    parse("DEMONHUNTER", BD_DH)
    parse("MONK", BD_MONK)
    parse("PALADIN", BD_PAL)
    parse("PRIEST", BD_PRIES)
    parse("ROGUE", BD_RG)
    parse("WARLOCK", BD_WARL)
    parse("WARRIOR", BD_WARI)
  end



   ---QWERT
  do
    local function exx(tbl)
      for _, data in ipairs(tbl) do
        local id, type, _, a, b, c = unpack(data)
        local spell = Get(id)
        spell.er_type = type
        spell.er_spec1 = a
        spell.er_spec2 = b
        spell.er_spec3 = c
      end
    end
  
    exx({
	{107574,"WARRIOR,DPS",		3,	nil,			{107574,90,	20},	nil,			{107574,90,	20},	},	--Avatar
	{6673,	"WARRIOR",		1,	{6673,	15,	0},	nil,			nil,			nil,			},	--Battle Shout
	{18499,	"WARRIOR,DEF",		4,	{18499,	60,	6},	nil,			nil,			nil,			},	--Berserker Rage
	{227847,"WARRIOR,DPS",		3,	nil,			{227847,90,	6},	nil,			nil,			},	--Bladestorm
	{1161,	"WARRIOR,TAUNT",	5,	{1161,	240,	0},	nil,			nil,			nil,			},	--Challenging Shout
	{100,	"WARRIOR",		3,	{100,	20,	0},	nil,			nil,			nil,			},	--Charge
	{167105,"WARRIOR",		3,	nil,			{167105,90,	10},	nil,			nil,			},	--Colossus Smash
	{1160,	"WARRIOR,DEFTANK",	4,	nil,			nil,			nil,			{1160,	45,	8},	},	--Demoralizing Shout
	{118038,"WARRIOR,DEF",		4,	nil,			{118038,120,	8},	nil,			nil,			},	--Die by the Sword
	{184364,"WARRIOR,DEF",		4,	nil,			nil,			{184364,180,	8},	nil,			},	--Enraged Regeneration
	{6544,	"WARRIOR,MOVE",		4,	{52174,	45,	0},	nil,			nil,			nil,			},	--Heroic Leap
	{57755,	"WARRIOR",		3,	{57755,	6,	0},	nil,			nil,			nil,			},	--Heroic Throw
	{190456,"WARRIOR,DEF",		3,	{190456,12,	0},	nil,			nil,			{190456,1,	0},	},	--Ignore Pain
	{3411,	"WARRIOR,DEFTAR",	2,	{3411,	30,	6},	nil,			nil,			nil,			},	--Intervene
	{5246,	"WARRIOR,AOECC",	1,	{5246,	90,	8},	nil,			nil,			nil,			},	--Intimidating Shout
	{12975,	"WARRIOR,DEFTANK",	4,	nil,			nil,			nil,			{12975,	180,	15},	},	--Last Stand
	{12323,	"WARRIOR",		3,	nil,			{12323,	30,	8},	{12323,	30,	8},	nil,			},	--Piercing Howl
	{6552,	"WARRIOR,KICK",		5,	{6552,	15,	0},	nil,			nil,			nil,			},	--Pummel
	{97462,	"WARRIOR,RAID",		1,	{97462,	180,	10},	nil,			nil,			nil,			},	--Rallying Cry
	{1719,	"WARRIOR,DPS",		3,	nil,			nil,			{1719,	90,	12},	nil,			},	--Recklessness
	{64382,	"WARRIOR,UTIL",		3,	{64382,	180,	0},	nil,			nil,			nil,			},	--Shattering Throw
	{2565,	"WARRIOR",		4,	{2565,	16,	0},	nil,			nil,			nil,			},	--Shield Block
	{871,	"WARRIOR,DEFTANK",	4,	nil,			nil,			nil,			{871,	240,	8},	},	--Shield Wall
	{46968,	"WARRIOR,AOECC",	1,	nil,			nil,			nil,			{46968,	40,	2},	},	--Shockwave
	{23920,	"WARRIOR,DEFTANK",	4,	{23920,	25,	0},	nil,			nil,			nil,			},	--Spell Reflection
	{260708,"WARRIOR,DPS",		3,	nil,			{260708,45,	15},	nil,			nil,			},	--Sweeping Strikes
	{355,	"WARRIOR,TAUNT",	5,	{355,	8,	0},	nil,			nil,			nil,			},	--Taunt
	{46924,	"WARRIOR,DPS",		3,	nil,			nil,			{46924,	60,	4},	nil,			},	--Bladestorm
	{262228,"WARRIOR,DPS",		3,	nil,			{262228,60,	6},	nil,			nil,			},	--Deadly Calm
	{197690,"WARRIOR",		4,	nil,			{197690,6,	0},	nil,			nil,			},	--Defensive Stance
	{118000,"WARRIOR",		3,	nil,			nil,			{118000,30,	0},	{118000,30,	0},	},	--Dragon Roar
	{202168,"WARRIOR,DEF",		3,	{202168,30,	0},	nil,			nil,			nil,			},	--Impending Victory
	{228920,"WARRIOR,DPS",		3,	nil,			nil,			nil,			{228920,45,	0},	},	--Ravager
	{152277,"WARRIOR,DPS",		3,	nil,			{152277,45,	0},	nil,			nil,			},	--Ravager
	{280772,"WARRIOR",		3,	nil,			nil,			{280772,30,	10},	nil,			},	--Siegebreaker
	{260643,"WARRIOR",		3,	nil,			{260643,21,	0},	nil,			nil,			},	--Skullsplitter
	{107570,"WARRIOR,CC",		3,	{107570,30,	0},	nil,			nil,			nil,			},	--Storm Bolt
	{262161,"WARRIOR,DPS",		3,	nil,			{262161,45,	0},	nil,			nil,			},	--Warbreaker
	{329038,"WARRIOR,PVP",		3,	nil,			nil,			{329038,20,	0},	nil,			},	--Bloodrage
	{213871,"WARRIOR,PVP",		3,	nil,			nil,			nil,			{213871,15,	0},	},	--Bodyguard
	{199261,"WARRIOR,PVP",		3,	nil,			nil,			{199261,5,	0},	nil,			},	--Death Wish
	{236077,"WARRIOR,PVP",		3,	{236077,45,	0},	nil,			nil,			nil,			},	--Disarm
	{206572,"WARRIOR,PVP",		3,	nil,			nil,			nil,			{206572,20,	0},	},	--Dragon Charge
	{236273,"WARRIOR,PVP",		3,	nil,			{236273,60,	0},	nil,			nil,			},	--Duel
	{205800,"WARRIOR,PVP",		3,	nil,			nil,			nil,			{205800,20,	0},	},	--Oppressor
	{198817,"WARRIOR,PVP",		3,	nil,			{198817,25,	0},	nil,			nil,			},	--Sharpen Blade
	{198912,"WARRIOR,PVP",		3,	nil,			nil,			nil,			{198912,10,	0},	},	--Shield Bash
	{236320,"WARRIOR,PVP",		3,	nil,			{236320,90,	0},	nil,			nil,			},	--War Banner
	{31850,	"PALADIN,DEFTANK",	4,	nil,			nil,			{31850,	120,	8},	nil,			},	--Ardent Defender
	{31821,	"PALADIN,RAID",		1,	nil,			{31821,	180,	8},	nil,			nil,			},	--Aura Mastery
	{31935,	"PALADIN",		3,	nil,			nil,			{31935,	15,	0},	nil,			},	--Avenger's Shield
	{31884,	"PALADIN,RAID,DPS",	1,	nil,			{31884,	120,	20},	{31884,	120,	20},	{31884,	120,	20},	},	--Avenging Wrath
	{1044,	"PALADIN,DEFTAR",	2,	{1044,	25,	8},	nil,			nil,			nil,			},	--Blessing of Freedom
	{1022,	"PALADIN,DEFTAR",	2,	{1022,	300,	10},	nil,			nil,			nil,			},	--Blessing of Protection
	{6940,	"PALADIN,DEFTAR",	2,	{6940,	120,	12},	nil,			nil,			nil,			},	--Blessing of Sacrifice
	{4987,	"PALADIN,DISPEL",	5,	nil,			{4987,	8,	0},	nil,			nil,			},	--Cleanse
	{213644,"PALADIN,DISPEL",	5,	nil,			nil,			{213644,8,	0},	{213644,8,	0},	},	--Cleanse Toxins
	{26573,	"PALADIN",		3,	{26573,	9,	0},	nil,			nil,			nil,			},	--Consecration
	{498,	"PALADIN,DEF",		4,	nil,			{498,	60,	8},	nil,			nil,			},	--Divine Protection
	{642,	"PALADIN,DEF",		2,	{642,	300,	8},	nil,			nil,			nil,			},	--Divine Shield
	{190784,"PALADIN,MOVE",		4,	{190784,45,	3},	nil,			nil,			nil,			},	--Divine Steed
	{86659,	"PALADIN,DEFTANK",	4,	nil,			nil,			{86659,	300,	8},	nil,			},	--Guardian of Ancient Kings
	{853,	"PALADIN",		3,	{853,	60,	6},	nil,			nil,			nil,			},	--Hammer of Justice
	{183218,"PALADIN",		3,	nil,			nil,			nil,			{183218,30,	10},	},	--Hand of Hindrance
	{62124,	"PALADIN,TAUNT",	5,	{62124,	8,	0},	nil,			nil,			nil,			},	--Hand of Reckoning
	{20473,	"PALADIN",		3,	nil,			{20473,	7.5,	0},	nil,			nil,			},	--Holy Shock
	{633,	"PALADIN,DEFTAR",	2,	{633,	600,	0},	nil,			nil,			nil,			},	--Lay on Hands
	{96231,	"PALADIN,KICK",		5,	nil,			nil,			{96231,	15,	0},	{96231,	15,	0},	},	--Rebuke
	{184662,"PALADIN,DEF",		4,	nil,			nil,			nil,			{184662,120,	15},	},	--Shield of Vengeance
	{10326,	"PALADIN,CC",		3,	{10326,	15,	40},	nil,			nil,			nil,			},	--Turn Evil
	{255937,"PALADIN,DPS",		3,	nil,			nil,			nil,			{255937,45,	0},	},	--Wake of Ashes
	{216331,"PALADIN,RAID",		1,	nil,			{216331,120,	20},	nil,			nil,			},	--Avenging Crusader
	{200025,"PALADIN",		3,	nil,			{200025,15,	8},	nil,			nil,			},	--Beacon of Virtue
	{223306,"PALADIN",		3,	nil,			{223306,12,	5},	nil,			nil,			},	--Bestow Faith
	{204018,"PALADIN,DEFTAR",	2,	nil,			nil,			{204018,180,	10},	nil,			},	--Blessing of Spellwarding
	{115750,"PALADIN",		3,	{115750,90,	0},	nil,			nil,			nil,			},	--Blinding Light
	{231895,"PALADIN,DPS",		3,	nil,			nil,			nil,			{231895,20,	20},	},	--Crusade
	{343527,"PALADIN",		3,	nil,			nil,			nil,			{343527,60,	0},	},	--Execution Sentence
	{205191,"PALADIN",		3,	nil,			nil,			nil,			{205191,60,	10},	},	--Eye for an Eye
	{343721,"PALADIN",		3,	nil,			nil,			nil,			{343721,60,	8},	},	--Final Reckoning
	{105809,"PALADIN,HEAL,DPS",	3,	{105809,180,	20},	nil,			nil,			nil,			},	--Holy Avenger
	{114165,"PALADIN,HEAL",		3,	nil,			{114165,20,	0},	nil,			nil,			},	--Holy Prism
	{114158,"PALADIN,HEAL",		3,	nil,			{114158,60,	14},	nil,			nil,			},	--Light's Hammer
	{327193,"PALADIN",		3,	nil,			nil,			{327193,90,	0},	nil,			},	--Moment of Glory
	{20066,	"PALADIN,CC",		3,	{20066,	15,	0},	nil,			nil,			nil,			},	--Repentance
	{214202,"PALADIN,HEAL",		3,	nil,			{214202,30,	10},	nil,			nil,			},	--Rule of Law
	{152262,"PALADIN,DPS,HEAL",	3,	{152262,45,	15},	nil,			nil,			nil,			},	--Seraphim
	{210256,"PALADIN,PVP",		3,	nil,			nil,			nil,			{210256,45,	0},	},	--Blessing of Sanctuary
	{236186,"PALADIN,PVP",		3,	nil,			nil,			{236186,4,	0},	{236186,4,	0},	},	--Cleansing Light
	{210294,"PALADIN,PVP",		3,	nil,			{210294,25,	0},	nil,			nil,			},	--Divine Favor
	{228049,"PALADIN,PVP",		3,	nil,			nil,			{228049,180,	0},	nil,			},	--Guardian of the Forgotten Queen
	{207028,"PALADIN,PVP",		3,	nil,			nil,			{207028,20,	0},	nil,			},	--Inquisition
	{215652,"PALADIN,PVP",		3,	nil,			nil,			{215652,45,	0},	nil,			},	--Shield of Virtue

	{186257,"HUNTER,MOVE",		4,	{186257,180,	12},	nil,			nil,			nil,			},	--Aspect of the Cheetah
	{186289,"HUNTER",		3,	nil,			nil,			nil,			{186289,90,	15},	},	--Aspect of the Eagle
	{186265,"HUNTER,DEF",		4,	{186265,180,	8},	nil,			nil,			nil,			},	--Aspect of the Turtle
	{193530,"HUNTER,DPS",		3,	nil,			{193530,120,	20},	nil,			nil,			},	--Aspect of the Wild
	{19574,	"HUNTER,DPS",		3,	nil,			{19574,	90,	15},	nil,			nil,			},	--Bestial Wrath
	{186387,"HUNTER",		3,	nil,			nil,			{186387,30,	0},	nil,			},	--Bursting Shot
	{266779,"HUNTER,DPS",		3,	nil,			nil,			nil,			{266779,120,	20},	},	--Coordinated Assault
	{147362,"HUNTER,KICK",		3,	nil,			{147362,24,	0},	{147362,24,	0},	nil,			},	--Counter Shot
	{781,	"HUNTER,DEF",		4,	{781,	20,	0},	nil,			nil,			nil,			},	--Disengage
	{109304,"HUNTER,DEF",		3,	{109304,120,	0},	nil,			nil,			nil,			},	--Exhilaration
	{5384,	"HUNTER,DEF",		3,	{5384,	30,	0},	nil,			nil,			nil,			},	--Feign Death
	{1543,	"HUNTER",		3,	{1543,	20,	0},	nil,			nil,			nil,			},	--Flare
	{187650,"HUNTER,CC",		3,	{187650,25,	0},	nil,			nil,			nil,			},	--Freezing Trap
	{190925,"HUNTER,MOVE",		3,	nil,			nil,			nil,			{190925,20,	0},	},	--Harpoon
	{19577,	"HUNTER,CC",		3,	nil,			{19577,	60,	5},	nil,			{19577,	60,	5},	},	--Intimidation
	{34477,	"HUNTER",		3,	{34477,	30,	0},	nil,			nil,			nil,			},	--Misdirection
	{187707,"HUNTER,KICK",		3,	nil,			nil,			nil,			{187707,15,	0},	},	--Muzzle
	{257044,"HUNTER",		3,	nil,			nil,			{257044,20,	0},	nil,			},	--Rapid Fire
	{187698,"HUNTER",		3,	{187698,25,	0},	nil,			nil,			nil,			},	--Tar Trap
	{19801,	"HUNTER,UTIL",		3,	{19801,	10,	0},	nil,			nil,			nil,			},	--Tranquilizing Shot
	{288613,"HUNTER,DPS",		3,	nil,			nil,			{288613,120,	15},	nil,			},	--Trueshot
	{131894,"HUNTER",		3,	{131894,60,	15},	nil,			nil,			nil,			},	--A Murder of Crows
	{120360,"HUNTER",		3,	nil,			{120360,20,	3},	{120360,20,	3},	nil,			},	--Barrage
	{109248,"HUNTER,CC",		3,	{109248,45,	0},	nil,			nil,			nil,			},	--Binding Shot
	{321530,"HUNTER",		3,	nil,			{321530,60,	18},	nil,			nil,			},	--Bloodshed
	{199483,"HUNTER,DEF",		3,	{199483,60,	0},	nil,			nil,			nil,			},	--Camouflage
	{259391,"HUNTER",		3,	nil,			nil,			nil,			{259391,20,	0},	},	--Chakrams
	{53209,	"HUNTER",		3,	nil,			{53209,	15,	0},	nil,			nil,			},	--Chimaera Shot
	{120679,"HUNTER",		3,	nil,			{120679,20,	0},	nil,			nil,			},	--Dire Beast
	{260402,"HUNTER",		3,	nil,			nil,			{260402,60,	0},	nil,			},	--Double Tap
	{212431,"HUNTER",		3,	nil,			nil,			{212431,30,	0},	nil,			},	--Explosive Shot
	{269751,"HUNTER",		3,	nil,			nil,			nil,			{269751,30,	0},	},	--Flanking Strike
	{201430,"HUNTER,DPS",		3,	nil,			{201430,120,	12},	nil,			nil,			},	--Stampede
	{162488,"HUNTER",		3,	nil,			nil,			nil,			{162488,30,	0},	},	--Steel Trap
	{260243,"HUNTER",		3,	nil,			nil,			{260243,45,	6},	nil,			},	--Volley
	{205691,"HUNTER,PVP",		3,	nil,			{205691,120,	0},	nil,			nil,			},	--Dire Beast: Basilisk
	{208652,"HUNTER,PVP",		3,	nil,			{208652,30,	0},	nil,			nil,			},	--Dire Beast: Hawk
	{236776,"HUNTER,PVP",		3,	{236776,40,	0},	nil,			nil,			nil,			},	--Hi-Explosive Trap
	{248518,"HUNTER,PVP",		3,	nil,			{248518,45,	0},	nil,			nil,			},	--Interlope
	{212640,"HUNTER,PVP",		3,	nil,			nil,			nil,			{212640,25,	0},	},	--Mending Bandage
	{213691,"HUNTER,PVP",		3,	nil,			nil,			{213691,30,	0},	nil,			},	--Scatter Shot
	{202900,"HUNTER,PVP",		3,	{202900,24,	0},	nil,			nil,			nil,			},	--Scorpid Sting
	{203155,"HUNTER,PVP",		3,	nil,			nil,			{203155,10,	0},	nil,			},	--Sniper Shot
	{202914,"HUNTER,PVP",		3,	{202914,45,	0},	nil,			nil,			nil,			},	--Spider Sting
	{212638,"HUNTER,PVP",		3,	nil,			nil,			nil,			{212638,25,	0},	},	--Tracker's Net
	{202797,"HUNTER,PVP",		3,	{202797,30,	0},	nil,			nil,			nil,			},	--Viper Sting

	{13750,	"ROGUE,DPS",		3,	nil,			nil,			{13750,	180,	20},	nil,			},	--Adrenaline Rush
	{315341,"ROGUE",		3,	nil,			nil,			{315341,45,	0},	nil,			},	--Between the Eyes
	{13877,	"ROGUE",		3,	nil,			nil,			{13877,	30,	12},	nil,			},	--Blade Flurry
	{2094,	"ROGUE,CC",		3,	{2094,	120,	0},	nil,			nil,			nil,			},	--Blind
	{31224,	"ROGUE,DEF",		4,	{31224,	120,	5},	nil,			nil,			nil,			},	--Cloak of Shadows
	{185311,"ROGUE,DEF",		4,	{185311,30,	6},	nil,			nil,			nil,			},	--Crimson Vial
	{1725,	"ROGUE",		3,	{1725,	30,	10},	nil,			nil,			nil,			},	--Distract
	{5277,	"ROGUE,DEF",		4,	{5277,	120,	0},	nil,			nil,			nil,			},	--Evasion
	{1966,	"ROGUE,DEF",		4,	{1966,	15,	5},	nil,			nil,			nil,			},	--Feint
	{1776,	"ROGUE,CC",		3,	nil,			nil,			{1776,	15,	0},	nil,			},	--Gouge
	{195457,"ROGUE,MOVE",		3,	nil,			nil,			{195457,45,	0},	nil,			},	--Grappling Hook
	{1766,	"ROGUE,KICK",		5,	{1766,	15,	0},	nil,			nil,			nil,			},	--Kick
	{408,	"ROGUE,CC",		3,	{408,	20,	0},	nil,			nil,			nil,			},	--Kidney Shot
	{315508,"ROGUE",		3,	nil,			nil,			{315508,45,	0},	nil,			},	--Roll the Bones
	{121471,"ROGUE,DPS",		3,	nil,			nil,			nil,			{121471,180,	20},	},	--Shadow Blades
	{185313,"ROGUE,DPS",		3,	nil,			nil,			nil,			{185313,60,	8},	},	--Shadow Dance
	{36554,	"ROGUE,MOVE",		4,	nil,			{36554,	30,	2},	nil,			{36554,	30,	2},	},	--Shadowstep
	{5938,	"ROGUE",		3,	{5938,	25,	0},	nil,			nil,			nil,			},	--Shiv
	{114018,"ROGUE,UTIL",		1,	{114018,360,	15},	nil,			nil,			nil,			},	--Shroud of Concealment
	{2983,	"ROGUE,MOVE",		4,	{2983,	120,	8},	nil,			nil,			nil,			},	--Sprint
	{212283,"ROGUE,DPS",		3,	nil,			nil,			nil,			{212283,30,	10},	},	--Symbols of Death
	{57934,	"ROGUE",		3,	{57934,	30,	6},	nil,			nil,			nil,			},	--Tricks of the Trade
	{1856,	"ROGUE,DEF",		4,	{1856,	120,	3},	nil,			nil,			nil,			},	--Vanish
	{79140,	"ROGUE,DPS",		3,	nil,			{79140,	120,	20},	nil,			nil,			},	--Vendetta
	{271877,"ROGUE",		3,	nil,			nil,			{271877,45,	0},	nil,			},	--Blade Rush
	{343142,"ROGUE",		3,	nil,			nil,			{343142,90,	10},	nil,			},	--Dreadblades
	{200806,"ROGUE,DPS",		3,	nil,			{200806,45,	0},	nil,			nil,			},	--Exsanguinate
	{196937,"ROGUE",		3,	nil,			nil,			{196937,35,	0},	nil,			},	--Ghostly Strike
	{51690,	"ROGUE,DPS",		3,	nil,			nil,			{51690,	120,	0},	nil,			},	--Killing Spree
	{137619,"ROGUE,DPS",		3,	{137619,60,	0},	nil,			nil,			nil,			},	--Marked for Death
	{280719,"ROGUE",		3,	nil,			nil,			nil,			{280719,45,	0},	},	--Secret Technique
	{277925,"ROGUE",		3,	nil,			nil,			nil,			{277925,60,	4},	},	--Shuriken Tornado
	{213981,"ROGUE,PVP",		3,	nil,			nil,			nil,			{213981,60,	0},	},	--Cold Blood
	{269513,"ROGUE,PVP",		3,	{269513,30,	0},	nil,			nil,			nil,			},	--Death from Above
	{207777,"ROGUE,PVP",		3,	nil,			nil,			{207777,45,	0},	nil,			},	--Dismantle
	{206328,"ROGUE,PVP",		3,	nil,			{206328,45,	0},	nil,			nil,			},	--Neurotoxin
	{198529,"ROGUE,PVP",		3,	nil,			nil,			{198529,120,	0},	nil,			},	--Plunder Armor
	{207736,"ROGUE,PVP",		3,	nil,			nil,			nil,			{207736,120,	0},	},	--Shadowy Duel
	{212182,"ROGUE,PVP",		3,	{212182,180,	0},	nil,			nil,			nil,			},	--Smoke Bomb

	{204883,"PRIEST",		3,	nil,			nil,			{204883,15,	0},	nil,			},	--Circle of Healing
	{19236,	"PRIEST,DEF",		4,	{19236,	90,	0},	nil,			nil,			nil,			},	--Desperate Prayer
	{47585,	"PRIEST,DEF",		4,	nil,			nil,			nil,			{47585,	120,	6},	},	--Dispersion
	{64843,	"PRIEST,RAID",		1,	nil,			nil,			{64843,	180,	8},	nil,			},	--Divine Hymn
	{586,	"PRIEST,DEF",		4,	{586,	30,	10},	nil,			nil,			nil,			},	--Fade
	{47788,	"PRIEST,DEFTAR",	2,	nil,			nil,			{47788,	180,	10},	nil,			},	--Guardian Spirit
	{88625,	"PRIEST",		3,	nil,			nil,			{88625,	60,	0},	nil,			},	--Holy Word: Chastise
	{34861,	"PRIEST",		3,	nil,			nil,			{34861,	60,	0},	nil,			},	--Holy Word: Sanctify
	{2050,	"PRIEST,DEFTAR",	3,	nil,			nil,			{2050,	60,	0},	nil,			},	--Holy Word: Serenity
	{73325,	"PRIEST,UTIL",		2,	{73325,	90,	0},	nil,			nil,			nil,			},	--Leap of Faith
	{32375,	"PRIEST,DISPEL",	1,	{32375,	45,	0},	nil,			nil,			nil,			},	--Mass Dispel
	{33206,	"PRIEST,DEFTAR",	2,	nil,			{33206,	180,	8},	nil,			nil,			},	--Pain Suppression
	{10060,	"PRIEST,UTIL",		3,	{10060,	120,	20},	nil,			nil,			nil,			},	--Power Infusion
	{62618,	"PRIEST,RAID",		1,	nil,			{62618,	180,	10},	nil,			nil,			},	--Power Word: Barrier
	{194509,"PRIEST",		3,	nil,			{194509,20,	0},	nil,			nil,			},	--Power Word: Radiance
	{33076,	"PRIEST",		3,	nil,			nil,			{33076,	12,	0},	nil,			},	--Prayer of Mending
	{8122,	"PRIEST,AOECC",		3,	{8122,	60,	8},	nil,			nil,			nil,			},	--Psychic Scream
	{527,	"PRIEST,DISPEL",	5,	nil,			{527,	8,	0},	{527,	8,	0},	nil,			},	--Purify
	{213634,"PRIEST,DISPEL",	5,	nil,			nil,			nil,			{213634,8,	0},	},	--Purify Disease
	{47536,	"PRIEST,HEAL",		1,	nil,			{47536,	90,	8},	nil,			nil,			},	--Rapture
	{32379,	"PRIEST",		3,	{32379,	20,	0},	nil,			nil,			nil,			},	--Shadow Word: Death
	{34433,	"PRIEST,DPS,HEAL",	3,	nil,			{34433,	180,	15},	nil,			{34433,	180,	15},	},	--Shadowfiend
	{15487,	"PRIEST,CC,KICK",	3,	nil,			nil,			nil,			{15487,	45,	4},	},	--Silence
	{64901,	"PRIEST,HEALUTIL",	1,	nil,			nil,			{64901,	300,	5},	nil,			},	--Symbol of Hope
	{15286,	"PRIEST,RAID",		1,	nil,			nil,			nil,			{15286,	120,	15},	},	--Vampiric Embrace
	{228260,"PRIEST,DPS",		3,	nil,			nil,			nil,			{228260,90,	0},	},	--Void Eruption
	{200183,"PRIEST,HEAL",		3,	nil,			nil,			{200183,120,	20},	nil,			},	--Apotheosis
	{341374,"PRIEST",		3,	nil,			nil,			nil,			{341374,45,	0},	},	--Damnation
	{121536,"PRIEST,MOVE",		3,	nil,			{121536,20,	0},	{121536,20,	0},	nil,			},	--Angelic Feather
	{110744,"PRIEST",		3,	nil,			{110744,15,	0},	{110744,15,	0},	nil,			},	--Divine Star
	{246287,"PRIEST,HEAL",		3,	nil,			{246287,90,	0},	nil,			nil,			},	--Evangelism
	{120517,"PRIEST",		3,	nil,			{120517,40,	0},	{120517,40,	0},	nil,			},	--Halo
	{265202,"PRIEST,RAID",		1,	nil,			nil,			{265202,720,	0},	nil,			},	--Holy Word: Salvation
	{205369,"PRIEST,AOECC",		3,	nil,			nil,			nil,			{205369,30,	0},	},	--Mind Bomb
	{200174,"PRIEST",		3,	nil,			nil,			nil,			{200174,60,	15},	},	--Mindbender
	{123040,"PRIEST",		3,	nil,			{123040,60,	12},	nil,			nil,			},	--Mindbender
	{129250,"PRIEST",		3,	nil,			{129250,15,	0},	nil,			nil,			},	--Power Word: Solace
	{64044,	"PRIEST,CC",		3,	nil,			nil,			nil,			{64044,	45,	4},	},	--Psychic Horror
	{214621,"PRIEST,HEAL",		3,	nil,			{214621,24,	9},	nil,			nil,			},	--Schism
	{314867,"PRIEST",		3,	nil,			{314867,30,	9},	nil,			nil,			},	--Shadow Covenant
	{204263,"PRIEST,UTIL",		3,	nil,			{204263,45,	0},	{204263,45,	0},	nil,			},	--Shining Force
	{109964,"PRIEST,HEAL",		3,	nil,			{109964,60,	10},	nil,			nil,			},	--Spirit Shell
	{319952,"PRIEST,DPS",		3,	nil,			nil,			nil,			{319952,90,	0},	},	--Surrender to Madness
	{263165,"PRIEST",		3,	nil,			nil,			nil,			{263165,45,	4},	},	--Void Torrent
	{197862,"PRIEST,PVP",		3,	nil,			{197862,60,	0},	nil,			nil,			},	--Archangel
	{197871,"PRIEST,PVP",		3,	nil,			{197871,60,	0},	nil,			nil,			},	--Dark Archangel
	{328530,"PRIEST,PVP",		3,	nil,			nil,			{328530,60,	0},	nil,			},	--Divine Ascension
	{213602,"PRIEST,PVP",		3,	nil,			nil,			{213602,45,	0},	{213602,45,	0},	},	--Greater Fade
	{289666,"PRIEST,PVP",		3,	nil,			nil,			{289666,15,	0},	nil,			},	--Greater Heal
	{213610,"PRIEST,PVP",		3,	nil,			nil,			{213610,30,	0},	nil,			},	--Holy Ward
	{289657,"PRIEST,PVP",		3,	nil,			nil,			{289657,45,	0},	nil,			},	--Holy Word: Concentration
	{211522,"PRIEST,PVP",		3,	nil,			nil,			nil,			{211522,45,	0},	},	--Psyfiend
	{197268,"PRIEST,PVP",		3,	nil,			nil,			{197268,60,	0},	nil,			},	--Ray of Hope
	{316262,"PRIEST,PVP",		3,	{316262,90,	0},	nil,			nil,			nil,			},	--Thoughtsteal
	{108968,"PRIEST,PVP",		3,	nil,			nil,			nil,			{108968,300,	0},	},	--Void Shift

	{48707,	"DEATHKNIGHT,DEF",	4,	{48707,	60,	5},	nil,			nil,			nil,			},	--Anti-Magic Shell
	{51052,	"DEATHKNIGHT,RAID",	3,	{51052,	120,	10},	nil,			nil,			nil,			},	--Anti-Magic Zone
	{275699,"DEATHKNIGHT,DPS",	3,	nil,			nil,			nil,			{275699,90,	15},	},	--Apocalypse
	{42650,	"DEATHKNIGHT,DPS",	3,	nil,			nil,			nil,			{42650,	480,	30},	},	--Army of the Dead
	{221562,"DEATHKNIGHT,CC",	3,	nil,			{221562,45,	5},	nil,			nil,			},	--Asphyxiate
	{49028,	"DEATHKNIGHT,DEFTANK",	4,	nil,			{49028,	120,	8},	nil,			nil,			},	--Dancing Rune Weapon
	{56222,	"DEATHKNIGHT,TAUNT",	5,	{56222,	8,	0},	nil,			nil,			nil,			},	--Dark Command
	{63560,	"DEATHKNIGHT,DPS",	3,	nil,			nil,			nil,			{63560,	60,	15},	},	--Dark Transformation
	{50977,	"DEATHKNIGHT",		3,	{50977,	60,	0},	nil,			nil,			nil,			},	--Death Gate
	{49576,	"DEATHKNIGHT,UTIL",	5,	{49576,	25,	0},	nil,			nil,			nil,			},	--Death Grip
	{43265,	"DEATHKNIGHT",		3,	{43265,	30,	0},	nil,			nil,			nil,			},	--Death and Decay
	{48265,	"DEATHKNIGHT,MOVE",	4,	{48265,	45,	0},	nil,			nil,			nil,			},	--Death's Advance
	{47568,	"DEATHKNIGHT,DPS",	3,	nil,			nil,			{47568,	105,	20},	nil,			},	--Empower Rune Weapon
	{279302,"DEATHKNIGHT",		3,	nil,			nil,			{279302,180,	10},	nil,			},	--Frostwyrm's Fury
	{108199,"DEATHKNIGHT,UTIL",	1,	nil,			{108199,120,	0},	nil,			nil,			},	--Gorefiend's Grasp
	{48792,	"DEATHKNIGHT,DEFTANK,DEF",4,	{48792,	180,	8},	nil,			nil,			nil,			},	--Icebound Fortitude
	{49039,	"DEATHKNIGHT",		3,	{49039,	120,	0},	nil,			nil,			nil,			},	--Lichborne
	{47528,	"DEATHKNIGHT,KICK",	5,	{47528,	15,	0},	nil,			nil,			nil,			},	--Mind Freeze
	{51271,	"DEATHKNIGHT,DPS,DEF",	3,	nil,			nil,			{51271,	60,	12},	nil,			},	--Pillar of Frost
	{61999,	"DEATHKNIGHT,RES",	3,	{61999,	600,	0},	nil,			nil,			nil,			},	--Raise Ally
	{46585,	"DEATHKNIGHT",		3,	{46585,	120,	0},	nil,			nil,			{46585,	120,	0},	},	--Raise Dead
	{196770,"DEATHKNIGHT",		3,	nil,			nil,			{196770,20,	8},	nil,			},	--Remorseless Winter
	{194679,"DEATHKNIGHT,DEFTANK",	4,	nil,			{194679,25,	4},	nil,			nil,			},	--Rune Tap
	{327574,"DEATHKNIGHT",		3,	{327574,120,	0},	nil,			nil,			nil,			},	--Sacrificial Pact
	{55233,	"DEATHKNIGHT,DEFTANK",	3,	nil,			{55233,	90,	12},	nil,			nil,			},	--Vampiric Blood
	{108194,"DEATHKNIGHT,CC",	3,	nil,			nil,			{108194,45,	0},	{108194,45,	0},	},	--Asphyxiate
	{207167,"DEATHKNIGHT,AOECC",	3,	nil,			nil,			{207167,60,	0},	nil,			},	--Blinding Sleet
	{206931,"DEATHKNIGHT,DEFTANK",	3,	nil,			{206931,30,	0},	nil,			nil,			},	--Blooddrinker
	{194844,"DEATHKNIGHT",		3,	nil,			{194844,60,	0},	nil,			nil,			},	--Bonestorm
	{152279,"DEATHKNIGHT,DPS",	3,	nil,			nil,			{152279,120,	0},	nil,			},	--Breath of Sindragosa
	{274156,"DEATHKNIGHT",		3,	nil,			{274156,30,	0},	nil,			nil,			},	--Consumption
	{48743,	"DEATHKNIGHT,DEF",	3,	{48743,	120,	0},	nil,			nil,			nil,			},	--Death Pact
	{152280,"DEATHKNIGHT",		3,	nil,			nil,			nil,			{152280,20,	0},	},	--Defile
	{57330,	"DEATHKNIGHT",		3,	nil,			nil,			{57330,	45,	0},	nil,			},	--Horn of Winter
	{321995,"DEATHKNIGHT",		3,	nil,			nil,			{321995,45,	8},	nil,			},	--Hypothermic Presence
	{49206,	"DEATHKNIGHT,DPS",	3,	nil,			nil,			nil,			{49206,	180,	30},	},	--Summon Gargoyle
	{219809,"DEATHKNIGHT",		3,	nil,			{219809,60,	0},	nil,			nil,			},	--Tombstone
	{207289,"DEATHKNIGHT,DPS",	3,	nil,			nil,			nil,			{207289,75,	12},	},	--Unholy Assault
	{115989,"DEATHKNIGHT",		3,	nil,			nil,			nil,			{115989,45,	0},	},	--Unholy Blight
	{212552,"DEATHKNIGHT,MOVE",	3,	{212552,60,	4},	nil,			nil,			nil,			},	--Wraith Walk
	{305392,"DEATHKNIGHT,PVP",	3,	nil,			nil,			{305392,45,	0},	nil,			},	--Chill Streak
	{77606,	"DEATHKNIGHT,PVP",	3,	{77606,	20,	0},	nil,			nil,			nil,			},	--Dark Simulacrum
	{203173,"DEATHKNIGHT,PVP",	3,	nil,			{203173,30,	0},	nil,			nil,			},	--Death Chain
	{207018,"DEATHKNIGHT,PVP",	3,	nil,			{207018,20,	0},	nil,			nil,			},	--Murderous Intent
	{288853,"DEATHKNIGHT,PVP",	3,	nil,			nil,			nil,			{288853,90,	0},	},	--Raise Abomination
	{47476,	"DEATHKNIGHT,PVP",	3,	nil,			{47476,	60,	0},	nil,			nil,			},	--Strangulate
	{288977,"DEATHKNIGHT,PVP",	3,	nil,			nil,			{288977,45,	0},	{288977,45,	0},	},	--Transfusion

	{556,	"SHAMAN",		3,	{556,	600,	0},	nil,			nil,			nil,			},	--Astral Recall
	{108271,"SHAMAN,DEF",		4,	{108271,90,	12},	nil,			nil,			nil,			},	--Astral Shift
	{2825,	"SHAMAN,UTIL",		3,	{2825,	300,	40},	nil,			nil,			nil,			},	--Bloodlust
	{32182,	"SHAMAN,UTIL",		3,	{32182,	300,	40},	nil,			nil,			nil,			},	--Героизм
	{192058,"SHAMAN,AOECC",		1,	{192058,60,	2},	nil,			nil,			nil,			},	--Capacitor Totem
	{51886,	"SHAMAN,DISPEL",	5,	nil,			{51886,	8,	0},	{51886,	8,	0},	nil,			},	--Cleanse Spirit
	{198103,"SHAMAN,UTIL",		2,	{198103,300,	60},	nil,			nil,			nil,			},	--Earth Elemental
	{2484,	"SHAMAN,AOECC",		3,	{2484,	30,	20},	nil,			nil,			nil,			},	--Earthbind Totem
	{51533,	"SHAMAN,DPS",		3,	nil,			nil,			{51533,	120,	15},	nil,			},	--Feral Spirit
	{198067,"SHAMAN,DPS",		3,	nil,			{198067,150,	30},	nil,			nil,			},	--Fire Elemental
	{188389,"SHAMAN",		3,	{188389,6,	0},	nil,			nil,			nil,			},	--Flame Shock
	{73920,	"SHAMAN",		3,	nil,			nil,			nil,			{73920,	10,	0},	},	--Healing Rain
	{5394,	"SHAMAN",		3,	{5394,	30,	0},	nil,			nil,			nil,			},	--Healing Stream Totem
	{108280,"SHAMAN,RAID",		3,	nil,			nil,			nil,			{108280,180,	12},	},	--Healing Tide Totem
	{51514,	"SHAMAN,CC",		3,	{51514,	20,	0},	nil,			nil,			nil,			},	--Hex
	{16191,	"SHAMAN,HEALUTIL",	3,	nil,			nil,			nil,			{16191,	180,	8},	},	--Mana Tide Totem
	{77130,	"SHAMAN,DISPEL",	5,	nil,			nil,			nil,			{77130,	8,	0},	},	--Purify Spirit
	{20608,	"SHAMAN,RES",		2,	{21169,	1800,	0},	nil,			nil,			nil,			},	--Reincarnation
	{98008,	"SHAMAN,RAID",		1,	nil,			nil,			nil,			{98008,	180,	6},	},	--Spirit Link Totem
	{58875,	"SHAMAN,MOVE",		3,	nil,			nil,			{58875,	60,	8},	nil,			},	--Spirit Walk
	{79206,	"SHAMAN,MOVE",		3,	nil,			{79206,	120,	15},	nil,			{79206,	120,	15},	},	--Spiritwalker's Grace
	{51490,	"SHAMAN,UTIL",		3,	nil,			{51490,	45,	0},	nil,			nil,			},	--Thunderstorm
	{8143,	"SHAMAN,UTIL",		1,	{8143,	60,	10},	nil,			nil,			nil,			},	--Tremor Totem
	{57994,	"SHAMAN,KICK",		5,	{57994,	12,	0},	nil,			nil,			nil,			},	--Wind Shear
	{108281,"SHAMAN",		1,	nil,			{108281,120,	10},	nil,			nil,			},	--Ancestral Guidance
	{207399,"SHAMAN,RAID",		1,	nil,			nil,			nil,			{207399,300,	30},	},	--Ancestral Protection Totem
	{114051,"SHAMAN,DPS",		3,	nil,			nil,			{114051,180,	15},	nil,			},	--Ascendance
	{114052,"SHAMAN,HEAL",		3,	nil,			nil,			nil,			{114052,180,	15},	},	--Ascendance
	{114050,"SHAMAN,DPS",		3,	nil,			{114050,180,	15},	nil,			nil,			},	--Ascendance
	{207778,"SHAMAN",		3,	nil,			nil,			nil,			{207778,5,	0},	},	--Downpour
	{188089,"SHAMAN",		3,	nil,			nil,			{188089,20,	0},	nil,			},	--Earthen Spike
	{198838,"SHAMAN,HEAL",		3,	nil,			nil,			nil,			{198838,60,	15},	},	--Earthen Wall Totem
	{51485,	"SHAMAN,AOECC",		3,	nil,			nil,			nil,			{51485,	30,	20},	},	--Earthgrab Totem
	{320125,"SHAMAN",		3,	nil,			{320125,30,	0},	nil,			nil,			},	--Echoing Shock
	{196884,"SHAMAN",		3,	nil,			nil,			{196884,30,	0},	nil,			},	--Feral Lunge
	{333974,"SHAMAN",		3,	nil,			nil,			{333974,15,	0},	nil,			},	--Fire Nova
	{342240,"SHAMAN",		3,	nil,			nil,			{342240,15,	0},	nil,			},	--Ice Strike
	{210714,"SHAMAN",		3,	nil,			{210714,30,	0},	nil,			nil,			},	--Icefury
	{192222,"SHAMAN",		3,	nil,			{192222,60,	15},	nil,			nil,			},	--Liquid Magma Totem
	{342243,"SHAMAN",		3,	nil,			{342243,30,	0},	nil,			nil,			},	--Static Discharge
	{191634,"SHAMAN,DPS",		3,	nil,			{191634,60,	0},	nil,			nil,			},	--Stormkeeper
	{320137,"SHAMAN",		3,	nil,			nil,			{320137,60,	0},	nil,			},	--Stormkeeper
	{197214,"SHAMAN,AOECC",		3,	nil,			nil,			{197214,40,	0},	nil,			},	--Sundering
	{320746,"SHAMAN",		3,	nil,			nil,			nil,			{320746,20,	0},	},	--Surge of Earth
	{197995,"SHAMAN",		3,	nil,			nil,			nil,			{197995,20,	0},	},	--Wellspring
	{192077,"SHAMAN,RAIDSPEED",	1,	{192077,120,	15},	nil,			nil,			nil,			},	--Wind Rush Totem
	{204331,"SHAMAN,PVP",		3,	{204331,45,	0},	nil,			nil,			nil,			},	--Counterstrike Totem
	{210918,"SHAMAN,PVP",		3,	nil,			nil,			{210918,45,	0},	nil,			},	--Ethereal Form
	{204336,"SHAMAN,PVP",		3,	{204336,30,	0},	nil,			nil,			nil,			},	--Grounding Totem
	{305483,"SHAMAN,PVP",		3,	nil,			{305483,30,	0},	nil,			nil,			},	--Lightning Lasso
	{204330,"SHAMAN,PVP",		3,	{204330,40,	0},	nil,			nil,			nil,			},	--Skyfury Totem
	{204366,"SHAMAN,PVP",		3,	nil,			nil,			{204366,45,	0},	nil,			},	--Thundercharge
	{157153,"SHAMAN",		3,	nil,			nil,			nil,			{157153,30,	15},	},	--CBT
	{192249,"SHAMAN,DPS",		3,	nil,			{192249,150,	30},	nil,			nil,			},	--Storm Elemental
	{73685,	"SHAMAN",		3,	nil,			nil,			nil,			{73685,	15,	0},	},	--Unleash Life

	{108978,"MAGE,DEF",		3,	nil,			{108978,60,	10},	{108978,60,	10},	{108978,60,	10},	},	--Alter Time
	{12042,	"MAGE,DPS",		3,	nil,			{12042,	120,	15},	nil,			nil,			},	--Arcane Power
	{235313,"MAGE,DEF",		3,	nil,			nil,			{235313,25,	0},	nil,			},	--Blazing Barrier
	{1953,	"MAGE,MOVE",		4,	{1953,	15,	0},	nil,			nil,			nil,			},	--Blink
	{190356,"MAGE",			3,	nil,			nil,			nil,			{190356,8,	0},	},	--Blizzard
	{235219,"MAGE",			3,	nil,			nil,			nil,			{235219,270,	0},	},	--Cold Snap
	{190319,"MAGE,DPS",		3,	nil,			nil,			{190319,120,	12},	nil,			},	--Combustion
	{120,	"MAGE",			3,	nil,			nil,			nil,			{120,	12,	0},	},	--Cone of Cold
	{190336,"MAGE",			3,	{190336,15,	0},	nil,			nil,			nil,			},	--Conjure Refreshment
	{2139,	"MAGE,KICK",		5,	{2139,	24,	0},	nil,			nil,			nil,			},	--Counterspell
	{31661,	"MAGE",			3,	nil,			nil,			{31661,	20,	0},	nil,			},	--Dragon's Breath
	{12051,	"MAGE",			3,	nil,			{12051,	180,	6},	nil,			nil,			},	--Evocation
	{122,	"MAGE",			3,	{122,	30,	0},	nil,			nil,			nil,			},	--Frost Nova
	{84714,	"MAGE",			3,	nil,			nil,			nil,			{84714,	60,	0},	},	--Frozen Orb
	{11426,	"MAGE,DEF",		3,	nil,			nil,			nil,			{11426,	25,	0},	},	--Ice Barrier
	{45438,	"MAGE,DEF",		3,	{45438,	240,	10},	nil,			nil,			nil,			},	--Ice Block
	{12472,	"MAGE,DPS",		3,	nil,			nil,			nil,			{12472,	180,	23},	},	--Icy Veins
	{66,	"MAGE,DEF",		4,	{66,	300,	20},	{110959,120,	20},	nil,			nil,			},	--Invisibility
	{55342,	"MAGE,DEF",		3,	{55342,	120,	40},	nil,			nil,			nil,			},	--Mirror Image
	{257541,"MAGE",			3,	nil,			nil,			{257541,25,	0},	nil,			},	--Phoenix Flames
	{205025,"MAGE",			3,	nil,			{205025,60,	0},	nil,			nil,			},	--Presence of Mind
	{235450,"MAGE,DEF",		4,	nil,			{235450,25,	0},	nil,			nil,			},	--Prismatic Barrier
	{475,	"MAGE,DISPEL",		5,	{475,	8,	0},	nil,			nil,			nil,			},	--Remove Curse
	{31687,	"MAGE",			3,	nil,			nil,			nil,			{31687,	30,	0},	},	--Summon Water Elemental
	{80353,	"MAGE,UTIL",		3,	{80353,	300,	40},	nil,			nil,			nil,			},	--Time Warp
	{321507,"MAGE",			3,	nil,			{321507,45,	0},	nil,			nil,			},	--Touch of the Magi
	{153626,"MAGE",			3,	nil,			{153626,20,	0},	nil,			nil,			},	--Arcane Orb
	{157981,"MAGE",			3,	nil,			nil,			{157981,25,	0},	nil,			},	--Blast Wave
	{153595,"MAGE",			3,	nil,			nil,			nil,			{153595,30,	0},	},	--Comet Storm
	{257537,"MAGE",			3,	nil,			nil,			nil,			{257537,45,	0},	},	--Ebonbolt
	{157997,"MAGE",			3,	nil,			nil,			nil,			{157997,25,	0},	},	--Ice Nova
	{44457,	"MAGE",			3,	nil,			nil,			{44457,	12,	0},	nil,			},	--Living Bomb
	{153561,"MAGE",			3,	nil,			nil,			{153561,45,	0},	nil,			},	--Meteor
	{205021,"MAGE",			3,	nil,			nil,			nil,			{205021,75,	0},	},	--Ray of Frost
	{113724,"MAGE,AOECC",		3,	{113724,45,	0},	nil,			nil,			nil,			},	--Ring of Frost
	{116011,"MAGE,DPS",		3,	{116011,45,	15},	nil,			nil,			nil,			},	--Rune of Power
	{157980,"MAGE",			3,	nil,			{157980,25,	0},	nil,			nil,			},	--Supernova
	{203286,"MAGE,PVP",		3,	nil,			nil,			{203286,15,	0},	nil,			},	--Greater Pyroblast
	{198144,"MAGE,PVP",		3,	nil,			nil,			nil,			{198144,60,	0},	},	--Ice Form
	{198158,"MAGE,PVP",		3,	nil,			{198158,60,	0},	nil,			nil,			},	--Mass Invisibility
	{198111,"MAGE,PVP",		3,	nil,			{198111,45,	0},	nil,			nil,			},	--Temporal Shield
	{212653,"MAGE,MOVE",		4,	{212653,25,	0},	nil,			nil,			nil,			},	--Shimmer

	{104316,"WARLOCK",		3,	nil,			nil,			{104316,20,	0},	nil,			},	--Call Dreadstalkers
	{29893,	"WARLOCK",		3,	{29893,	120,	0},	nil,			nil,			nil,			},	--Create Soulwell
	{48018,	"WARLOCK",		3,	{48018,	10,	0},	nil,			nil,			nil,			},	--Demonic Circle
	{48020,	"WARLOCK",		3,	{48020,	30,	0},	nil,			nil,			nil,			},	--Demonic Circle: Teleport
	{111771,"WARLOCK",		3,	{111771,10,	0},	nil,			nil,			nil,			},	--Demonic Gateway
	{333889,"WARLOCK",		3,	{333889,180,	0},	nil,			nil,			nil,			},	--Fel Domination
	{80240,	"WARLOCK,DPS",		3,	nil,			nil,			nil,			{80240,	30,	0},	},	--Havoc
	{342601,"WARLOCK",		3,	{342601,3600,	0},	nil,			nil,			nil,			},	--Ritual of Doom
	{698,	"WARLOCK",		3,	{698,	120,	0},	nil,			nil,			nil,			},	--Ritual of Summoning
	{30283,	"WARLOCK,AOECC",	1,	{30283,	60,	3},	nil,			nil,			nil,			},	--Shadowfury
	{20707,	"WARLOCK,RES",		3,	{20707,	600,	0},	nil,			nil,			nil,			},	--Soulstone
	{205180,"WARLOCK,DPS",		3,	nil,			{205180,180,	20},	nil,			nil,			},	--Summon Darkglare
	{265187,"WARLOCK,DPS",		3,	nil,			nil,			{265187,90,	0},	nil,			},	--Summon Demonic Tyrant
	{1122,	"WARLOCK,DPS",		3,	nil,			nil,			nil,			{1122,	180,	0},	},	--Summon Infernal
	{104773,"WARLOCK,DEF",		4,	{104773,180,	8},	nil,			nil,			nil,			},	--Unending Resolve
	{267211,"WARLOCK",		3,	nil,			nil,			{267211,30,	0},	nil,			},	--Bilescourge Bombers
	{152108,"WARLOCK",		3,	nil,			nil,			nil,			{152108,30,	0},	},	--Cataclysm
	{196447,"WARLOCK",		3,	nil,			nil,			nil,			{196447,25,	0},	},	--Channel Demonfire
	{108416,"WARLOCK,DEF",		3,	{108416,60,	0},	nil,			nil,			nil,			},	--Dark Pact
	{113858,"WARLOCK,DPS",		3,	nil,			nil,			nil,			{113858,120,	0},	},	--Dark Soul: Instability
	{113860,"WARLOCK,DPS",		3,	nil,			{113860,120,	0},	nil,			nil,			},	--Dark Soul: Misery
	{267171,"WARLOCK",		3,	nil,			nil,			{267171,60,	0},	nil,			},	--Demonic Strength
	{108503,"WARLOCK",		3,	nil,			{108503,30,	0},	nil,			{108503,30,	0},	},	--Grimoire of Sacrifice
	{111898,"WARLOCK",		3,	nil,			nil,			{111898,120,	0},	nil,			},	--Grimoire: Felguard
	{48181,	"WARLOCK",		3,	nil,			{48181,	15,	0},	nil,			nil,			},	--Haunt
	{5484,	"WARLOCK,CC",		3,	{5484,	40,	0},	nil,			nil,			nil,			},	--Howl of Terror
	{6789,	"WARLOCK,CC",		3,	{6789,	45,	0},	nil,			nil,			nil,			},	--Mortal Coil
	{267217,"WARLOCK",		3,	nil,			nil,			{267217,180,	15},	nil,			},	--Nether Portal
	{205179,"WARLOCK",		3,	nil,			{205179,45,	0},	nil,			nil,			},	--Phantom Singularity
	{264130,"WARLOCK",		3,	nil,			nil,			{264130,30,	0},	nil,			},	--Power Siphon
	{6353,	"WARLOCK",		3,	nil,			nil,			nil,			{6353,	45,	0},	},	--Soul Fire
	{264057,"WARLOCK",		3,	nil,			nil,			{264057,10,	0},	nil,			},	--Soul Strike
	{264119,"WARLOCK",		3,	nil,			nil,			{264119,45,	0},	nil,			},	--Summon Vilefiend
	{278350,"WARLOCK",		3,	nil,			{278350,20,	0},	nil,			nil,			},	--Vile Taint
	{328774,"WARLOCK,PVP",		3,	{328774,45,	0},	nil,			nil,			nil,			},	--Amplify Curse
	{199954,"WARLOCK,PVP",		3,	{199954,45,	0},	nil,			nil,			nil,			},	--Bane of Fragility
	{200546,"WARLOCK,PVP",		3,	nil,			nil,			nil,			{200546,45,	0},	},	--Bane of Havoc
	{234877,"WARLOCK,PVP",		3,	nil,			{234877,30,	0},	nil,			nil,			},	--Bane of Shadows
	{212459,"WARLOCK,PVP",		3,	nil,			nil,			{212459,90,	0},	nil,			},	--Call Fel Lord
	{212619,"WARLOCK,PVP",		3,	nil,			nil,			{212619,24,	0},	nil,			},	--Call Felhunter
	{201996,"WARLOCK,PVP",		3,	nil,			nil,			{201996,90,	0},	nil,			},	--Call Observer
	{221703,"WARLOCK,PVP",		3,	{221703,60,	0},	nil,			nil,			nil,			},	--Casting Circle
	{264106,"WARLOCK,PVP",		3,	nil,			{264106,45,	0},	nil,			nil,			},	--Deathbolt
	{212295,"WARLOCK,PVP",		3,	{212295,45,	0},	nil,			nil,			nil,			},	--Nether Ward
	{344566,"WARLOCK,PVP",		3,	nil,			{344566,30,	0},	nil,			nil,			},	--Rapid Contagion
	{212623,"WARLOCK,PVP",		3,	nil,			nil,			{212623,15,	0},	nil,			},	--Singe Magic
	{212356,"WARLOCK,PVP",		3,	nil,			{212356,60,	0},	nil,			nil,			},	--Soulshatter

	{115181,"MONK",			3,	nil,			{115181,15,	0},	nil,			nil,			},	--Breath of Fire
	{322507,"MONK",			3,	nil,			{322507,60,	0},	nil,			nil,			},	--Celestial Brew
	{324312,"MONK",			3,	nil,			{324312,30,	0},	nil,			nil,			},	--Clash
	{218164,"MONK,DISPEL",		5,	{218164,8,	0},	nil,			nil,			nil,			},	--Detox
	{191837,"MONK",			3,	nil,			nil,			nil,			{191837,12,	0},	},	--Essence Font
	{322101,"MONK",			3,	{322101,15,	0},	nil,			nil,			nil,			},	--Expel Harm
	{113656,"MONK",			3,	nil,			nil,			{113656,24,	0},	nil,			},	--Fists of Fury
	{101545,"MONK,MOVE",		3,	nil,			nil,			{101545,20,	0},	nil,			},	--Flying Serpent Kick
	{115203,"MONK,DEFTANK,DEF",	4,	nil,			{115203,420,	15},	{115203,180,	15},	{115203,180,	15},	},	--Fortifying Brew
	{122281,"MONK",			3,	nil,			nil,			nil,			{122281,30,	0},	},	--Healing Elixir
	{132578,"MONK",			3,	nil,			{132578,180,	0},	nil,			nil,			},	--Invoke Niuzao, the Black Ox
	{123904,"MONK,DPS",		3,	nil,			nil,			{123904,120,	24},	nil,			},	--Invoke Xuen, the White Tiger
	{322118,"MONK,HEAL",		3,	nil,			nil,			nil,			{322118,180,	25},	},	--Invoke Yu'lon, the Jade Serpent
	{119381,"MONK,AOECC",		1,	{119381,60,	3},	nil,			nil,			nil,			},	--Leg Sweep
	{116849,"MONK,DEFTAR",		2,	nil,			nil,			nil,			{116849,120,	12},	},	--Life Cocoon
	{115078,"MONK,CC",		3,	{115078,30,	0},	nil,			nil,			nil,			},	--Paralysis
	{115546,"MONK,TAUNT",		5,	{115546,8,	0},	nil,			nil,			nil,			},	--Provoke
	{119582,"MONK",			3,	nil,			{119582,20,	0},	nil,			nil,			},	--Purifying Brew
	{115310,"MONK,RAID",		1,	nil,			nil,			nil,			{115310,180,	0},	},	--Revival
	{107428,"MONK",			3,	nil,			nil,			{107428,10,	0},	{107428,10,	0},	},	--Rising Sun Kick
	{109132,"MONK,MOVE",		3,	{107428,20,	0},	nil,			nil,			nil,			},	--Roll
	{116705,"MONK,KICK",		3,	nil,			{116705,15,	0},	{116705,15,	0},	nil,			},	--Spear Hand Strike
	{137639,"MONK,DPS",		3,	nil,			nil,			{137639,90,	15},	nil,			},	--Storm, Earth, and Fire
	{116680,"MONK",			3,	nil,			nil,			nil,			{116680,30,	0},	},	--Thunder Focus Tea
	{322109,"MONK",			3,	{322109,180,	0},	nil,			nil,			nil,			},	--Touch of Death
	{122470,"MONK,DEF",		3,	nil,			nil,			{122470,90,	10},	nil,			},	--Touch of Karma
	{101643,"MONK",			4,	{101643,10,	0},	nil,			nil,			nil,			},	--Transcendence
	{119996,"MONK,MOVE",		4,	{119996,45,	0},	nil,			nil,			nil,			},	--Transcendence: Transfer
	{115176,"MONK,DEFTANK",		4,	nil,			{115176,300,	8},	nil,			nil,			},	--Zen Meditation
	{126892,"MONK",			3,	{126892,60,	0},	nil,			nil,			nil,			},	--Zen Pilgrimage
	{115399,"MONK",			3,	nil,			{115399,120,	0},	nil,			nil,			},	--Black Ox Brew
	{123986,"MONK",			3,	{123986,30,	0},	nil,			nil,			nil,			},	--Chi Burst
	{115098,"MONK",			3,	{115098,15,	0},	nil,			nil,			nil,			},	--Chi Wave
	{122278,"MONK,DEF",		3,	{122278,120,	10},	nil,			nil,			nil,			},	--Dampen Harm
	{122783,"MONK,DEF",		4,	nil,			nil,			{122783,90,	6},	{122783,90,	6},	},	--Diffuse Magic
	{115288,"MONK",			3,	nil,			nil,			nil,			{115288,60,	5},	},	--Energizing Elixir
	{325153,"MONK",			3,	nil,			{325153,60,	0},	nil,			nil,			},	--Exploding Keg
	{261947,"MONK",			3,	nil,			nil,			nil,			{261947,30,	0},	},	--Fist of the White Tiger
	{325197,"MONK,HEAL",		3,	nil,			nil,			{325197,180,	0},	nil,			},	--Invoke Chi-Ji, the Red Crane
	{197908,"MONK,HEAL",		3,	nil,			nil,			{197908,90,	10},	nil,			},	--Mana Tea
	{116844,"MONK,UTIL",		1,	{116844,45,	5},	nil,			nil,			nil,			},	--Ring of Peace
	{152173,"MONK,DPS",		3,	nil,			nil,			nil,			{152173,90,	12},	},	--Serenity
	{198898,"MONK",			3,	nil,			nil,			{198898,30,	0},	nil,			},	--Song of Chi-Ji
	{115315,"MONK",			3,	nil,			{115315,10,	0},	nil,			nil,			},	--Summon Black Ox Statue
	{115313,"MONK",			3,	nil,			nil,			{115313,10,	0},	{115313,10,	0},	},	--Summon Jade Serpent Statue
	{116841,"MONK,UTIL,RAIDSPEED",	2,	{116841,30,	6},	nil,			nil,			nil,			},	--Tiger's Lust
	{152175,"MONK",			3,	nil,			nil,			nil,			{152175,24,	0},	},	--Whirling Dragon Punch
	{207025,"MONK,PVP",		3,	nil,			{207025,20,	0},	nil,			nil,			},	--Admonishment
	{202162,"MONK,PVP",		3,	nil,			{202162,45,	0},	nil,			nil,			},	--Avert Harm
	{202335,"MONK,PVP",		3,	nil,			{202335,45,	0},	nil,			nil,			},	--Double Barrel
	{233759,"MONK,PVP",		3,	nil,			nil,			{233759,45,	0},	{233759,45,	0},	},	--Grapple Weapon
	{202370,"MONK,PVP",		3,	nil,			{202370,30,	0},	nil,			nil,			},	--Mighty Ox Kick
	{209584,"MONK,PVP",		3,	nil,			nil,			{209584,45,	0},	nil,			},	--Zen Focus Tea
	{115008,"MONK,MOVE",		4,	{115008,20,	0},	nil,			nil,			nil,			},	--Chi Torpedo

	{22812,	"DRUID,DEFTANK,DEF",	4,	{22812,	60,	8},	nil,			nil,			nil,			nil,			},	--Barkskin
	{50334,	"DRUID,DPS",		3,	nil,			nil,			nil,			{50334,	180,	15},	nil,			},	--Berserk
	{106951,"DRUID,DPS",		3,	nil,			nil,			{106951,180,	15},	nil,			nil,			},	--Berserk
	{194223,"DRUID,DPS",		3,	nil,			{194223,180,	20},	nil,			nil,			nil,			},	--Celestial Alignment
	{1850,	"DRUID,MOVE",		4,	{1850,	120,	10},	nil,			nil,			nil,			nil,			},	--Dash
	{22842,	"DRUID,DEFTANK",	4,	{22842,	36,	3},	nil,			nil,			nil,			nil,			},	--Frenzied Regeneration
	{6795,	"DRUID,TAUNT",		5,	{6795,	8,	0},	nil,			nil,			nil,			nil,			},	--Growl
	{99,	"DRUID,CC",		3,	{99,	30,	0},	nil,			nil,			nil,			nil,			},	--Incapacitating Roar
	{29166,	"DRUID,HEALUTIL",	2,	nil,			{29166,	180,	10},	nil,			nil,			{29166,	180,	10},	},	--Innervate
	{102342,"DRUID,DEFTAR",		2,	nil,			nil,			nil,			nil,			{102342,90,	12},	},	--Ironbark
	{22570,	"DRUID",		3,	nil,			{22570,	20,	0},	{22570,	20,	0},	nil,			nil,			},	--Maim
	{88423,	"DRUID,DISPEL",		5,	nil,			nil,			nil,			nil,			{88423,	8,	0},	},	--Nature's Cure
	{132158,"DRUID",		3,	nil,			nil,			nil,			nil,			{132158,60,	0},	},	--Nature's Swiftness
	{20484,	"DRUID,RES",		1,	{20484,	600,	0},	nil,			nil,			nil,			nil,			},	--Rebirth
	{2782,	"DRUID,DISPEL",		5,	nil,			{2782,	8,	0},	{2782,	8,	0},	{2782,	8,	0},	nil,			},	--Remove Corruption
	{106839,"DRUID,KICK",		5,	nil,			nil,			{106839,15,	0},	{106839,15,	0},	nil,			},	--Skull Bash
	{78675,	"DRUID,KICK",		5,	nil,			{78675,	60,	8},	nil,			nil,			nil,			},	--Solar Beam
	{2908,	"DRUID",		5,	{2908,	10,	0},	nil,			nil,			nil,			nil,			},	--Soothe
	{106898,"DRUID,RAIDSPEED",	1,	{106898,120,	0},	nil,			nil,			nil,			nil,			},	--Stampeding Roar
	{61336,	"DRUID,DEFTANK,DEF",	3,	nil,			nil,			{61336,	180,	6},	{61336,	180,	6},	nil,			},	--Survival Instincts
	{18562,	"DRUID",		3,	nil,			nil,			nil,			nil,			{18562,	15,	0},	},	--Swiftmend
	{5217,	"DRUID,DPS",		3,	nil,			nil,			{5217,	30,	10},	nil,			nil,			},	--Tiger's Fury
	{740,	"DRUID,RAID",		1,	nil,			nil,			nil,			nil,			{740,	180,	8},	},	--Tranquility
	{132469,"DRUID,UTIL",		3,	{132469,30,	0},	nil,			nil,			nil,			nil,			},	--Typhoon
	{102793,"DRUID,UTIL",		3,	{102793,60,	10},	nil,			nil,			nil,			nil,			},	--Ursol's Vortex
	{48438,	"DRUID",		3,	nil,			nil,			nil,			nil,			{48438,	10,	0},	},	--Wild Growth
	{155835,"DRUID,DEFTANK",	3,	nil,			nil,			nil,			{155835,40,	0},	nil,			},	--Bristling Fur
	{102351,"DRUID",		3,	nil,			nil,			nil,			nil,			{102351,30,	0},	},	--Cenarion Ward
	{274837,"DRUID",		3,	nil,			nil,			{274837,45,	0},	nil,			nil,			},	--Feral Frenzy
	{197721,"DRUID,HEAL",		3,	nil,			nil,			nil,			nil,			{197721,90,	8},	},	--Flourish
	{205636,"DRUID,UTIL",		3,	nil,			{205636,60,	10},	nil,			nil,			nil,			},	--Force of Nature
	{202770,"DRUID",		3,	nil,			{202770,60,	8},	nil,			nil,			nil,			},	--Fury of Elune
	{319454,"DRUID",		3,	{319454,300,	45},	nil,			nil,			nil,			nil,			},	--Heart of the Wild
	{102560,"DRUID,DPS",		3,	nil,			{102560,180,	30},	nil,			nil,			nil,			},	--Incarnation: Chosen of Elune
	{102558,"DRUID,DEFTANK",	3,	nil,			nil,			nil,			{102558,180,	30},	nil,			},	--Incarnation: Guardian of Ursoc
	{102543,"DRUID,DPS",		3,	nil,			nil,			{102543,180,	30},	nil,			nil,			},	--Incarnation: King of the Jungle
	{33891,	"DRUID,HEAL",		3,	nil,			nil,			nil,			nil,			{33891,	180,	30},	},	--Incarnation: Tree of Life
	{102359,"DRUID,UTIL",		3,	{102359,30,	0},	nil,			nil,			nil,			nil,			},	--Mass Entanglement
	{5211,	"DRUID,CC",		3,	{5211,	60,	0},	nil,			nil,			nil,			nil,			},	--Mighty Bash
	{203651,"DRUID",		3,	nil,			nil,			nil,			nil,			{203651,60,	0},	},	--Overgrowth
	{80313,	"DRUID",		3,	nil,			nil,			nil,			{80313,	30,	0},	nil,			},	--Pulverize
	{108238,"DRUID,DEF",		3,	{108238,90,	0},	nil,			nil,			nil,			nil,			},	--Renewal
	{252216,"DRUID,MOVE",		3,	{252216,45,	5},	nil,			nil,			nil,			nil,			},	--Tiger Dash
	{202425,"DRUID",		3,	nil,			{202425,45,	0},	nil,			nil,			nil,			},	--Warrior of Elune
	{102401,"DRUID,MOVE",		3,	{102401,15,	0},	nil,			nil,			nil,			nil,			},	--Wild Charge
	{207017,"DRUID,PVP",		3,	nil,			nil,			nil,			{207017,20,	0},	nil,			},	--Alpha Challenge
	{201664,"DRUID,PVP",		3,	nil,			nil,			nil,			{201664,30,	0},	nil,			},	--Demoralizing Roar
	{209749,"DRUID,PVP",		3,	nil,			{209749,30,	0},	nil,			nil,			nil,			},	--Faerie Swarm
	{202246,"DRUID,PVP",		3,	nil,			nil,			nil,			{202246,25,	0},	nil,			},	--Overrun
	{203242,"DRUID,PVP",		3,	nil,			nil,			{203242,60,	0},	nil,			nil,			},	--Rip and Tear
	{329042,"DRUID,PVP",		3,	nil,			nil,			nil,			{329042,12,	0},	nil,			},	--Roar of the Protector
	{305497,"DRUID,PVP",		3,	nil,			{305497,45,	0},	{305497,45,	0},	nil,			{305497,45,	0},	},	--Thorns

	{188499,"DEMONHUNTER",		3,	nil,			{188499,15,	0},	nil,			},	--Blade Dance
	{198589,"DEMONHUNTER,DEF",	4,	nil,			{198589,60,	10},	nil,			},	--Blur
	{179057,"DEMONHUNTER,AOECC",	3,	nil,			{179057,60,	2},	nil,			},	--Chaos Nova
	{278326,"DEMONHUNTER",		5,	{278326,10,	0},	nil,			nil,			},	--Consume Magic
	{196718,"DEMONHUNTER,RAID",	1,	nil,			{196718,180,	8},	nil,			},	--Darkness
	{203720,"DEMONHUNTER,DEFTANK",	3,	nil,			nil,			{203720,20,	0},	},	--Demon Spikes
	{183752,"DEMONHUNTER,KICK",	5,	{183752,15,	0},	nil,			nil,			},	--Disrupt
	{198013,"DEMONHUNTER",		3,	nil,			{198013,30,	0},	nil,			},	--Eye Beam
	{212084,"DEMONHUNTER",		3,	nil,			nil,			{212084,60,	0},	},	--Fel Devastation
	{195072,"DEMONHUNTER,MOVE",	3,	nil,			{195072,10,	0},	nil,			},	--Fel Rush
	{204021,"DEMONHUNTER",		3,	nil,			nil,			{204021,60,	10},	},	--Fiery Brand
	{258920,"DEMONHUNTER",		3,	{258920,30,	0},	nil,			nil,			},	--Immolation Aura
	{217832,"DEMONHUNTER,CC",	3,	{217832,45,	0},	nil,			nil,			},	--Imprison
	{191427,"DEMONHUNTER,DPS,DEFTANK",3,	nil,			{191427,240,	30},	{187827,180,	15},	},	--Metamorphosis
	{204596,"DEMONHUNTER",		3,	nil,			nil,			{204596,30,	2},	},	--Sigil of Flame
	{207684,"DEMONHUNTER,AOECC",	1,	nil,			nil,			{207684,180,	2},	},	--Sigil of Misery
	{202137,"DEMONHUNTER,UTIL",	1,	nil,			nil,			{202137,120,	2},	},	--Sigil of Silence
	{188501,"DEMONHUNTER",		3,	{188501,60,	10},	nil,			nil,			},	--Spectral Sight
	{185123,"DEMONHUNTER",		3,	{185123,9,	0},	nil,			nil,			},	--Throw Glaive
	{185245,"DEMONHUNTER,TAUNT",	5,	{185245,8,	0},	nil,			nil,			},	--Torment
	{198793,"DEMONHUNTER",		3,	nil,			{198793,25,	0},	nil			},	--Vengeful Retreat
	{320341,"DEMONHUNTER",		3,	nil,			nil,			{320341,90,	0},	},	--Bulk Extraction
	{258860,"DEMONHUNTER",		3,	nil,			{258860,20,	0},	nil,			},	--Essence Break
	{258925,"DEMONHUNTER",		3,	nil,			{258925,60,	0},	nil,			},	--Fel Barrage
	{211881,"DEMONHUNTER,CC",	3,	nil,			{211881,30,	0},	nil,			},	--Fel Eruption
	{232893,"DEMONHUNTER",		3,	{232893,15,	0},	nil,			nil,			},	--Felblade
	{342817,"DEMONHUNTER",		3,	nil,			{342817,20,	0},	nil,			},	--Glaive Tempest
	{196555,"DEMONHUNTER,DEF",	3,	nil,			{196555,180,	5},	nil,			},	--Netherwalk
	{202138,"DEMONHUNTER,UTIL",	3,	nil,			nil,			{202138,90,	2},	},	--Sigil of Chains
	{263648,"DEMONHUNTER",		3,	nil,			nil,			{263648,30,	0},	},	--Soul Barrier
	{206649,"DEMONHUNTER,PVP",	3,	nil,			{206649,45,	0},	nil,			},	--Eye of Leotheras
	{205630,"DEMONHUNTER,PVP",	3,	nil,			nil,			{205630,60,	0},	},	--Illidan's Grasp
	{203704,"DEMONHUNTER,PVP",	3,	nil,			{203704,60,	0},	nil,			},	--Mana Break
	{235903,"DEMONHUNTER,PVP",	3,	nil,			{235903,10,	0},	nil,			},	--Mana Rift
	{206803,"DEMONHUNTER,PVP",	3,	nil,			{206803,60,	0},	nil,			},	--Rain from Above
	{205604,"DEMONHUNTER,PVP",	3,	{205604,60,	0},	nil,			nil,			},	--Reverse Magic
	{207029,"DEMONHUNTER,PVP",	3,	nil,			nil,			{207029,20,	0},	},	--Tormentor
})
end

  SquishData.TMP = SPELLS
end

local SPELLS = {}
local SPELLS_SOURCE_VALUES = {
  "UNIT_AURA_HELPFUL",
  "UNIT_AURA_HARMFUL",
}
local SPELLS_CLASS_VALUES = {}
for i = 1, #CLASS_SORT_ORDER do
  Table_Insert(SPELLS_CLASS_VALUES, CLASS_SORT_ORDER[i])
end
Table_Insert(SPELLS_CLASS_VALUES, "HOSTILE")
Table_Insert(SPELLS_CLASS_VALUES, "OTHER")
RAID_CLASS_COLORS.HOSTILE = { r = 0.7, g = 0.5, b = 0.3 }
RAID_CLASS_COLORS.OTHER = { r = 0.3, g = 0.5, b = 0.7 }

local SPELLS_STATUS_NEGATIVE_FIELD_SOURCE = 1
local SPELLS_STATUS_NEGATIVE_FIELD_PRIORITY = 2
SPELLS.StatusNegative = {
  [243237] = { 2, 5 }, -- M+ Affix Bursting
  [240559] = { 2, 5 }, -- M+ Affix Grievous Wound
  [226512] = { 2, 5 }, -- M+ Affix Sanguine
}

local SPELLS_STATUS_POSITIVE_FIELD_SOURCE = 1
local SPELLS_STATUS_POSITIVE_FIELD_PRIORITY = 2
local SPELLS_STATUS_POSITIVE_FIELD_CLASS = 3
local SPELLS_STATUS_POSITIVE_FIELD_NOTES = 4
SPELLS.StatusPositive = {
  [184364] = { 1, 1, 1,  "" }, -- WARRIOR
  [97463]  = { 1, 1, 1,  "" },
  [23920]  = { 1, 1, 1,  "" },
  [12975]  = { 1, 1, 1,  "" },
  [197690] = { 1, 1, 1,  "" },
  [118038] = { 1, 1, 1,  "" },
  [871]    = { 1, 1, 1,  "" },
  [190456] = { 1, 1, 1,  "" },
  [48792]  = { 1, 1, 2,  "" }, -- DEATHKNIGHT
  [194679] = { 1, 1, 2,  "" },
  [48743]  = { 2, 1, 2,  "" },
  [48707]  = { 1, 1, 2,  "" },
  [81256]  = { 1, 1, 2,  "" },
  [55233]  = { 1, 1, 2,  "" },
  [219809] = { 1, 1, 2,  "" },
  [6940]   = { 1, 1, 3,  "" }, -- PALADIN
  [498]    = { 1, 1, 3,  "" },
  [86659]  = { 1, 1, 3,  "" },
  [642]    = { 1, 1, 3,  "" },
  [1022]   = { 1, 1, 3,  "" },
  [1044]   = { 1, 1, 3,  "" },
  [31850]  = { 1, 1, 3,  "" },
  [204018] = { 1, 1, 3,  "" },
  [184662] = { 1, 1, 3,  "" },
  [205191] = { 1, 1, 3,  "" },
  [201325] = { 1, 1, 4,  "" }, -- MONK
  [122783] = { 1, 1, 4,  "" },
  [116849] = { 1, 1, 4,  "" },
  [122278] = { 1, 1, 4,  "" },
  [120954] = { 1, 1, 4,  "" },
  [115176] = { 1, 1, 4,  "" },
  [243435] = { 1, 1, 4,  "" },
  [192081] = { 1, 1, 7,  "" }, -- DRUID
  [22842]  = { 1, 1, 7,  "" },
  [102558] = { 1, 1, 7,  "" },
  [102342] = { 1, 1, 7,  "" },
  [61336]  = { 1, 1, 7,  "" },
  [22812]  = { 1, 1, 7,  "" },
  [187827] = { 1, 1, 12, "" }, -- DEMONHUNTER
  [196555] = { 1, 1, 12, "" },
  [203819] = { 1, 1, 12, "" },
  [162264] = { 1, 1, 12, "" },
  [212800] = { 1, 1, 12, "" },
}

SPELLS.CooldownRotation = {
  47540,                              -- penance
  8092,                               -- mind blast
  32379,                              -- shadow word: death
  129250,                             -- power word: solace
  34433,                              -- shadowfiend
  194509,                             -- power word: radiance
  { id = 128318, item = true  },      -- leveling trinket
}

SPELLS.CooldownSituational = {
  19236,                              -- desperate prayer
  8122,                               -- psychic scream
  33206,                              -- painsup
  62618,                              -- power word: barrier
  47536,                              -- rapture
}

SPELLS.CooldownOther = {
  32375,                              -- mass dispel
  586,                                -- fade
  73325,                              -- leap of faith
  605,                                -- mind control
  121536,                             -- angelic feather
  527,                                -- purify
}

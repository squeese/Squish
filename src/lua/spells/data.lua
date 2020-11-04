local SPELLS = {}

SPELLS.Negative = {
  [243237] = { "UNIT_AURA_HARMFUL", 5 }, -- M+ Affix Bursting
  [240559] = { "UNIT_AURA_HARMFUL", 5 }, -- M+ Affix Grievous Wound
  [226512] = { "UNIT_AURA_HARMFUL", 5 }, -- M+ Affix Sanguine
}



local SPELL_SOURCE = 1
local SPELL_PRIORITY = 2
local SPELL_CLASS = 3

SPELLS.Positive = {
  -- WARRIOR
  [184364] = { "UNIT_AURA_HELPFUL", 1, 1 },
  [97463]  = { "UNIT_AURA_HELPFUL", 1, 1 },
  [23920]  = { "UNIT_AURA_HELPFUL", 1, 1 },
  [12975]  = { "UNIT_AURA_HELPFUL", 1, 1 },
  [197690] = { "UNIT_AURA_HELPFUL", 1, 1 },
  [118038] = { "UNIT_AURA_HELPFUL", 1, 1 },
  [871]    = { "UNIT_AURA_HELPFUL", 1, 1 },
  [190456] = { "UNIT_AURA_HELPFUL", 1, 1 },
  -- DEATHKNIGHT
  [48792]  = { "UNIT_AURA_HELPFUL", 1, 2 },
  [194679] = { "UNIT_AURA_HELPFUL", 1, 2 },
  [48743]  = { "UNIT_AURA_HARMFUL", 1, 2 },
  [48707]  = { "UNIT_AURA_HELPFUL", 1, 2 },
  [81256]  = { "UNIT_AURA_HELPFUL", 1, 2 },
  [55233]  = { "UNIT_AURA_HELPFUL", 1, 2 },
  [219809] = { "UNIT_AURA_HELPFUL", 1, 2 },
  -- PALADIN
  [6940]   = { "UNIT_AURA_HELPFUL", 1, 3 },
  [498]    = { "UNIT_AURA_HELPFUL", 1, 3 },
  [86659]  = { "UNIT_AURA_HELPFUL", 1, 3 },
  [642]    = { "UNIT_AURA_HELPFUL", 1, 3 },
  [1022]   = { "UNIT_AURA_HELPFUL", 1, 3 },
  [1044]   = { "UNIT_AURA_HELPFUL", 1, 3 },
  [31850]  = { "UNIT_AURA_HELPFUL", 1, 3 },
  [204018] = { "UNIT_AURA_HELPFUL", 1, 3 },
  [184662] = { "UNIT_AURA_HELPFUL", 1, 3 },
  [205191] = { "UNIT_AURA_HELPFUL", 1, 3 },
  -- MONK
  [201325] = { "UNIT_AURA_HELPFUL", 1, 4 },
  [122783] = { "UNIT_AURA_HELPFUL", 1, 4 },
  [116849] = { "UNIT_AURA_HELPFUL", 1, 4 },
  [122278] = { "UNIT_AURA_HELPFUL", 1, 4 },
  [120954] = { "UNIT_AURA_HELPFUL", 1, 4 },
  [115176] = { "UNIT_AURA_HELPFUL", 1, 4 },
  [243435] = { "UNIT_AURA_HELPFUL", 1, 4 },
  -- DRUID
  [192081] = { "UNIT_AURA_HELPFUL", 1, 7 },
  [22842]  = { "UNIT_AURA_HELPFUL", 1, 7 },
  [102558] = { "UNIT_AURA_HELPFUL", 1, 7 },
  [102342] = { "UNIT_AURA_HELPFUL", 1, 7 },
  [61336]  = { "UNIT_AURA_HELPFUL", 1, 7 },
  [22812]  = { "UNIT_AURA_HELPFUL", 1, 7 },
  -- DEMONHUNTER
  [187827] = { "UNIT_AURA_HELPFUL", 1, 12 },
  [196555] = { "UNIT_AURA_HELPFUL", 1, 12 },
  [203819] = { "UNIT_AURA_HELPFUL", 1, 12 },
  [162264] = { "UNIT_AURA_HELPFUL", 1, 12 },
  [212800] = { "UNIT_AURA_HELPFUL", 1, 12 },
}

SPELLS.Rotation = {
  47540,                              -- penance
  8092,                               -- mind blast
  32379,                              -- shadow word: death
  129250,                             -- power word: solace
  34433,                              -- shadowfiend
  194509,                             -- power word: radiance
  { id = 128318, item = true  },      -- leveling trinket
}

SPELLS.Situational = {
  19236,                              -- desperate prayer
  8122,                               -- psychic scream
  33206,                              -- painsup
  62618,                              -- power word: barrier
  47536,                              -- rapture
}

SPELLS.Other = {
  32375,                              -- mass dispel
  586,                                -- fade
  73325,                              -- leap of faith
  605,                                -- mind control
  121536,                             -- angelic feather
  527,                                -- purify
}

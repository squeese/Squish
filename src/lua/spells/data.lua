local SPELL_SOURCE = 1
local SPELL_PRIORITY = 2

local SPELLS = {}

SPELLS.Negative = {
  [243237] = { "UNIT_AURA_HARMFUL", 5 }, -- M+ Affix Bursting
  [240559] = { "UNIT_AURA_HARMFUL", 5 }, -- M+ Affix Grievous Wound
  [226512] = { "UNIT_AURA_HARMFUL", 5 }, -- M+ Affix Sanguine
}

SPELLS.Positive = {
  -- DEMONHUNTER
  [187827] = { "UNIT_AURA_HELPFUL", 1 },
  [196555] = { "UNIT_AURA_HELPFUL", 1 },
  [203819] = { "UNIT_AURA_HELPFUL", 1 },
  [162264] = { "UNIT_AURA_HELPFUL", 1 },
  [212800] = { "UNIT_AURA_HELPFUL", 1 },
  -- MONK
  [201325] = { "UNIT_AURA_HELPFUL", 1 },
  [122783] = { "UNIT_AURA_HELPFUL", 1 },
  [116849] = { "UNIT_AURA_HELPFUL", 1 },
  [122278] = { "UNIT_AURA_HELPFUL", 1 },
  [120954] = { "UNIT_AURA_HELPFUL", 1 },
  [115176] = { "UNIT_AURA_HELPFUL", 1 },
  [243435] = { "UNIT_AURA_HELPFUL", 1 },
  -- DEATHKNIGHT
  [48792]  = { "UNIT_AURA_HELPFUL", 1 },
  [194679] = { "UNIT_AURA_HELPFUL", 1 },
  [48743]  = { "UNIT_AURA_HARMFUL", 1 },
  [48707]  = { "UNIT_AURA_HELPFUL", 1 },
  [81256]  = { "UNIT_AURA_HELPFUL", 1 },
  [55233]  = { "UNIT_AURA_HELPFUL", 1 },
  [219809] = { "UNIT_AURA_HELPFUL", 1 },
  -- DRUID
  [192081] = { "UNIT_AURA_HELPFUL", 1 },
  [22842]  = { "UNIT_AURA_HELPFUL", 1 },
  [102558] = { "UNIT_AURA_HELPFUL", 1 },
  [102342] = { "UNIT_AURA_HELPFUL", 1 },
  [61336]  = { "UNIT_AURA_HELPFUL", 1 },
  [22812]  = { "UNIT_AURA_HELPFUL", 1 },
  -- WARRIOR
  [184364] = { "UNIT_AURA_HELPFUL", 1 },
  [97463]  = { "UNIT_AURA_HELPFUL", 1 },
  [23920]  = { "UNIT_AURA_HELPFUL", 1 },
  [12975]  = { "UNIT_AURA_HELPFUL", 1 },
  [197690] = { "UNIT_AURA_HELPFUL", 1 },
  [118038] = { "UNIT_AURA_HELPFUL", 1 },
  [871]    = { "UNIT_AURA_HELPFUL", 1 },
  [190456] = { "UNIT_AURA_HELPFUL", 1 },
  -- PALADIN
  [6940]   = { "UNIT_AURA_HELPFUL", 1 },
  [498]    = { "UNIT_AURA_HELPFUL", 1 },
  [86659]  = { "UNIT_AURA_HELPFUL", 1 },
  [642]    = { "UNIT_AURA_HELPFUL", 1 },
  [1022]   = { "UNIT_AURA_HELPFUL", 1 },
  [1044]   = { "UNIT_AURA_HELPFUL", 1 },
  [31850]  = { "UNIT_AURA_HELPFUL", 1 },
  [204018] = { "UNIT_AURA_HELPFUL", 1 },
  [184662] = { "UNIT_AURA_HELPFUL", 1 },
  [205191] = { "UNIT_AURA_HELPFUL", 1 },
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

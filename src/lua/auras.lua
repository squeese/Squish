local AurasFilter
do
  --local frame = CreateFrame("frame", nil, UIParent)
  --frame:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
  --frame:RegisterUnitEvent("UNIT_AURA")
  --frame:SetScript("OnEvent", function(self, event, unit, guid, spell, ...)
    --if event == "UNIT_SPELLCAST_SUCCEEDED" then
      --print("CAST", spell)
    --elseif event == "UNIT_AURA" then
      --for i = 1, 40 do
        --local name, _, _, _, _, _, source, _, _, id = UnitAura("player", i, "HELPFUL")
        --if not name then break end
        --print("AURA", name, source, id)
      --end
    --end
  --end)

end

--[[

  debuffs
  incoming spells

  buffs
  cooldowns

  UnitAura()
    name, icon, count, debuffType, duration, expirationTime, source, isStealable,
    _, spellId, _, isBossDebuff, castByPlayer, nameplateShowAll, timeMod, ...

                              spellID
  Pain Suppression            33206
  Power Word: Shield          17


  External

                    "key": "102342", "name": "|T572025:0|t |cFFFF7D0AIronbark|r",

                    "key": "116849", "name": "|T627485:0|t |cFF00FF96Life Cocoon|r",

                    "key": "1022", "name": "|T135964:0|t |cFFF58CBABlessing of Prot|r",

                    "key": "6940", "name": "|T135966:0|t |cFFF58CBABlessing of Sacr|r",

                    "key": "204018", "name": "|T135880:0|t |cFFF58CBABlessing of Spel|r",

                    "key": "633", "name": "|T135928:0|t |cFFF58CBALay on Hands|r",

                    "key": "47788", "name": "|T237542:0|t |cFFFFFFFFGuardian Spirit|r",

                    "key": "33206", "name": "|T135936:0|t |cFFFFFFFFPain Suppression|r",

                    "key": "207399", "name": "|T136080:0|t |cFF0070DEAncestral Protec|r",

                    "key": "3411", "name": "|T132365:0|t |cFFC79C6EIntervene|r",

                    "key": "102351", "name": "|T132137:0|t |cFFFF7D0ACenarion Ward|r",

                    "key": "197721","name": "|T538743:0|t |cFFFF7D0AFlourish|r",

                    "key": "319454","name": "|T135879:0|t |cFFFF7D0AHeart of the Wil|r",

                    "key": "33891","name": "|T236157:0|t |cFFFF7D0AIncarnation: Tre|r",

                    "key": "203651","name": "|T1408836:0|t |cFFFF7D0AOvergrowth|r",

                    "key": "740",
                    "name": "|T136107:0|t |cFFFF7D0ATranquility|r",

                    "key": "325197",
                    "name": "|T877514:0|t |cFF00FF96Invoke Chi-Ji, t|r",

                    "key": "322118",
                    "name": "|T574571:0|t |cFF00FF96Invoke Yu'lon, t|r",

                    "key": "115310",
                    "name": "|T1020466:0|t |cFF00FF96Revival|r",

                    "key": "216331",
                    "name": "|T589117:0|t |cFFF58CBAAvenging Crusade|r",

                    "key": "31884",
                    "name": "|T135875:0|t |cFFF58CBAAvenging Wrath|r",
                    "key": "200025",

                    "name": "|T1030094:0|t |cFFF58CBABeacon of Virtue|r",

                    "key": "105809",
                    "name": "|T571555:0|t |cFFF58CBAHoly Avenger|r",

                    "key": "200183",
                    "name": "|T1060983:0|t |cFFFFFFFFApotheosis|r",

                    "key": "64843",
                    "name": "|T237540:0|t |cFFFFFFFFDivine Hymn|r",

                    "key": "246287",
                    "name": "|T135895:0|t |cFFFFFFFFEvangelism|r",

                    "key": "265202",
                    "name": "|T458225:0|t |cFFFFFFFFHoly Word: Salva|r",

                    "key": "10060",
                    "name": "|T135939:0|t |cFFFFFFFFPower Infusion|r",

                    "key": "47536",
                    "name": "|T237548:0|t |cFFFFFFFFRapture|r",
                    "key": "109964",

                    "name": "|T538565:0|t |cFFFFFFFFSpirit Shell|r",

                    "key": "15286",
                    "name": "|T136230:0|t |cFFFFFFFFVampiric Embrace|r",

                    "key": "108281",
                    "name": "|T538564:0|t |cFF0070DEAncestral Guidan|r",

                    "key": "114052",
                    "name": "|T135791:0|t |cFF0070DEAscendance|r",
                    "key": "198838",

                    "name": "|T136098:0|t |cFF0070DEEarthen Wall Tot|r",

                    "key": "108280",
                    "name": "|T538569:0|t |cFF0070DEHealing Tide Tot|r",


                  {
                    "default": false,
                    "key": "196555",
                    "name": "|T463284:0|t |cFFA330C9Netherwalk|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "186265",
                    "name": "|T132199:0|t |cFFABD473Aspect of the Tu|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "45438",
                    "name": "|T135841:0|t |cFF40C7EBIce Block|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "642",
                    "name": "|T524354:0|t |cFFF58CBADivine Shield|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "31224",
                    "name": "|T136177:0|t |cFFFFF569Cloak of Shadows|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  }

  {
                    "default": false,
                    "key": "198589",
                    "name": "|T1305150:0|t |cFFA330C9Blur|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "48707",
                    "name": "|T136120:0|t |cFFC41F3BAnti-Magic Shell|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "48743",
                    "name": "|T136146:0|t |cFFC41F3BDeath Pact|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "48792",
                    "name": "|T237525:0|t |cFFC41F3BIcebound Fortitu|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "49039",
                    "name": "|T136187:0|t |cFFC41F3BLichborne|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "327574",
                    "name": "|T136133:0|t |cFFC41F3BSacrificial Pact|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "22812",
                    "name": "|T136097:0|t |cFFFF7D0ABarkskin|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "319454",
                    "name": "|T135879:0|t |cFFFF7D0AHeart of the Wil|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "108238",
                    "name": "|T136059:0|t |cFFFF7D0ARenewal|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "61336",
                    "name": "|T236169:0|t |cFFFF7D0ASurvival Instinc|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "109304",
                    "name": "|T461117:0|t |cFFABD473Exhilaration|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "108978",
                    "name": "|T609811:0|t |cFF40C7EBAlter Time|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "342245",
                    "name": "|T609811:0|t |cFF40C7EBAlter Time|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "235313",
                    "name": "|T132221:0|t |cFF40C7EBBlazing Barrier|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "11426",
                    "name": "|T135988:0|t |cFF40C7EBIce Barrier|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "235450",
                    "name": "|T135991:0|t |cFF40C7EBPrismatic Barrie|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "122278",
                    "name": "|T620827:0|t |cFF00FF96Dampen Harm|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "122783",
                    "name": "|T775460:0|t |cFF00FF96Diffuse Magic|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "243435",
                    "name": "|T615341:0|t |cFF00FF96Fortifying Brew|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "115203",
                    "name": "|T615341:0|t |cFF00FF96Fortifying Brew|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "122470",
                    "name": "|T651728:0|t |cFF00FF96Touch of Karma|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "498",
                    "name": "|T524353:0|t |cFFF58CBADivine Protectio|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "205191",
                    "name": "|T135986:0|t |cFFF58CBAEye for an Eye|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "184662",
                    "name": "|T236264:0|t |cFFF58CBAShield of Vengea|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "19236",
                    "name": "|T237550:0|t |cFFFFFFFFDesperate Prayer|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "47585",
                    "name": "|T237563:0|t |cFFFFFFFFDispersion|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "185311",
                    "name": "|T1373904:0|t |cFFFFF569Crimson Vial|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "Evasion/Riposte",
                    "name": "|T136205:0|t |cFFFFF569Evasion/Riposte|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "108271",
                    "name": "|T538565:0|t |cFF0070DEAstral Shift|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "108416",
                    "name": "|T538538:0|t |cFF8787EDDark Pact|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "104773",
                    "name": "|T136150:0|t |cFF8787EDUnending Resolve|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "118038",
                    "name": "|T132336:0|t |cFFC79C6EDie by the Sword|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "184364",
                    "name": "|T132345:0|t |cFFC79C6EEnraged Regenera|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "23920",
                    "name": "|T132361:0|t |cFFC79C6ESpell Reflection|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  }
                ],

  {
                    "default": false,
                    "key": "198589",
                    "name": "|T1305150:0|t |cFFA330C9Blur|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "48707",
                    "name": "|T136120:0|t |cFFC41F3BAnti-Magic Shell|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "48743",
                    "name": "|T136146:0|t |cFFC41F3BDeath Pact|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "48792",
                    "name": "|T237525:0|t |cFFC41F3BIcebound Fortitu|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "49039",
                    "name": "|T136187:0|t |cFFC41F3BLichborne|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "327574",
                    "name": "|T136133:0|t |cFFC41F3BSacrificial Pact|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "22812",
                    "name": "|T136097:0|t |cFFFF7D0ABarkskin|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "319454",
                    "name": "|T135879:0|t |cFFFF7D0AHeart of the Wil|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "108238",
                    "name": "|T136059:0|t |cFFFF7D0ARenewal|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "61336",
                    "name": "|T236169:0|t |cFFFF7D0ASurvival Instinc|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "109304",
                    "name": "|T461117:0|t |cFFABD473Exhilaration|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "108978",
                    "name": "|T609811:0|t |cFF40C7EBAlter Time|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "342245",
                    "name": "|T609811:0|t |cFF40C7EBAlter Time|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "235313",
                    "name": "|T132221:0|t |cFF40C7EBBlazing Barrier|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "11426",
                    "name": "|T135988:0|t |cFF40C7EBIce Barrier|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "235450",
                    "name": "|T135991:0|t |cFF40C7EBPrismatic Barrie|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "122278",
                    "name": "|T620827:0|t |cFF00FF96Dampen Harm|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "122783",
                    "name": "|T775460:0|t |cFF00FF96Diffuse Magic|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "243435",
                    "name": "|T615341:0|t |cFF00FF96Fortifying Brew|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "115203",
                    "name": "|T615341:0|t |cFF00FF96Fortifying Brew|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "122470",
                    "name": "|T651728:0|t |cFF00FF96Touch of Karma|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "498",
                    "name": "|T524353:0|t |cFFF58CBADivine Protectio|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "205191",
                    "name": "|T135986:0|t |cFFF58CBAEye for an Eye|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "184662",
                    "name": "|T236264:0|t |cFFF58CBAShield of Vengea|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "19236",
                    "name": "|T237550:0|t |cFFFFFFFFDesperate Prayer|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "47585",
                    "name": "|T237563:0|t |cFFFFFFFFDispersion|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "185311",
                    "name": "|T1373904:0|t |cFFFFF569Crimson Vial|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "Evasion/Riposte",
                    "name": "|T136205:0|t |cFFFFF569Evasion/Riposte|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "108271",
                    "name": "|T538565:0|t |cFF0070DEAstral Shift|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "108416",
                    "name": "|T538538:0|t |cFF8787EDDark Pact|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "104773",
                    "name": "|T136150:0|t |cFF8787EDUnending Resolve|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "118038",
                    "name": "|T132336:0|t |cFFC79C6EDie by the Sword|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "184364",
                    "name": "|T132345:0|t |cFFC79C6EEnraged Regenera|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "23920",
                    "name": "|T132361:0|t |cFFC79C6ESpell Reflection|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  }
                ],




sadf  {
                    "default": false,
                    "key": "198589",
                    "name": "|T1305150:0|t |cFFA330C9Blur|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "48707",
                    "name": "|T136120:0|t |cFFC41F3BAnti-Magic Shell|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "48743",
                    "name": "|T136146:0|t |cFFC41F3BDeath Pact|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "48792",
                    "name": "|T237525:0|t |cFFC41F3BIcebound Fortitu|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "49039",
                    "name": "|T136187:0|t |cFFC41F3BLichborne|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "327574",
                    "name": "|T136133:0|t |cFFC41F3BSacrificial Pact|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "22812",
                    "name": "|T136097:0|t |cFFFF7D0ABarkskin|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "319454",
                    "name": "|T135879:0|t |cFFFF7D0AHeart of the Wil|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "108238",
                    "name": "|T136059:0|t |cFFFF7D0ARenewal|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "61336",
                    "name": "|T236169:0|t |cFFFF7D0ASurvival Instinc|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "109304",
                    "name": "|T461117:0|t |cFFABD473Exhilaration|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "108978",
                    "name": "|T609811:0|t |cFF40C7EBAlter Time|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "342245",
                    "name": "|T609811:0|t |cFF40C7EBAlter Time|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "235313",
                    "name": "|T132221:0|t |cFF40C7EBBlazing Barrier|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "11426",
                    "name": "|T135988:0|t |cFF40C7EBIce Barrier|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "235450",
                    "name": "|T135991:0|t |cFF40C7EBPrismatic Barrie|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "122278",
                    "name": "|T620827:0|t |cFF00FF96Dampen Harm|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "122783",
                    "name": "|T775460:0|t |cFF00FF96Diffuse Magic|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "243435",
                    "name": "|T615341:0|t |cFF00FF96Fortifying Brew|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "115203",
                    "name": "|T615341:0|t |cFF00FF96Fortifying Brew|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "122470",
                    "name": "|T651728:0|t |cFF00FF96Touch of Karma|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "498",
                    "name": "|T524353:0|t |cFFF58CBADivine Protectio|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "205191",
                    "name": "|T135986:0|t |cFFF58CBAEye for an Eye|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "184662",
                    "name": "|T236264:0|t |cFFF58CBAShield of Vengea|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "19236",
                    "name": "|T237550:0|t |cFFFFFFFFDesperate Prayer|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "47585",
                    "name": "|T237563:0|t |cFFFFFFFFDispersion|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "185311",
                    "name": "|T1373904:0|t |cFFFFF569Crimson Vial|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "Evasion/Riposte",
                    "name": "|T136205:0|t |cFFFFF569Evasion/Riposte|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "108271",
                    "name": "|T538565:0|t |cFF0070DEAstral Shift|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "108416",
                    "name": "|T538538:0|t |cFF8787EDDark Pact|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "104773",
                    "name": "|T136150:0|t |cFF8787EDUnending Resolve|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "118038",
                    "name": "|T132336:0|t |cFFC79C6EDie by the Sword|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "184364",
                    "name": "|T132345:0|t |cFFC79C6EEnraged Regenera|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "23920",
                    "name": "|T132361:0|t |cFFC79C6ESpell Reflection|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  }
                ],

                  {
                    "default": false,
                    "key": "196718",
                    "name": "|T1305154:0|t |cFFA330C9Darkness|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "51052",
                    "name": "|T237510:0|t |cFFC41F3BAnti-Magic Zone|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "31821",
                    "name": "|T135872:0|t |cFFF58CBAAura Mastery|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "62618",
                    "name": "|T253400:0|t |cFFFFFFFFPower Word: Barr|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "97462",
                    "name": "|T132351:0|t |cFFC79C6ERallying Cry|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  }

   {
                    "default": false,
                    "key": "320341",
                    "name": "|T136194:0|t |cFFA330C9Bulk Extraction|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "212084",
                    "name": "|T1450143:0|t |cFFA330C9Fel Devastation|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "204021",
                    "name": "|T1344647:0|t |cFFA330C9Fiery Brand|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "187827",
                    "name": "|T1247263:0|t |cFFA330C9Metamorphosis|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "263648",
                    "name": "|T2065625:0|t |cFFA330C9Soul Barrier|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "185245",
                    "name": "|T1344654:0|t |cFFA330C9Torment|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "194844",
                    "name": "|T342917:0|t |cFFC41F3BBonestorm|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "49028",
                    "name": "|T135277:0|t |cFFC41F3BDancing Rune Wea|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "56222",
                    "name": "|T136088:0|t |cFFC41F3BDark Command|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "219809",
                    "name": "|T132151:0|t |cFFC41F3BTombstone|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "55233",
                    "name": "|T136168:0|t |cFFC41F3BVampiric Blood|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "50334",
                    "name": "|T236149:0|t |cFFFF7D0ABerserk|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "6795",
                    "name": "|T132270:0|t |cFFFF7D0AGrowl|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "102558",
                    "name": "|T571586:0|t |cFFFF7D0AIncarnation: Gua|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "204066",
                    "name": "|T136057:0|t |cFFFF7D0ALunar Beam|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "80313",
                    "name": "|T1033490:0|t |cFFFF7D0APulverize|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "115399",
                    "name": "|T629483:0|t |cFF00FF96Black Ox Brew|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "322507",
                    "name": "|T1360979:0|t |cFF00FF96Celestial Brew|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "325153",
                    "name": "|T644378:0|t |cFF00FF96Exploding Keg|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "132578",
                    "name": "|T608951:0|t |cFF00FF96Invoke Niuzao, t|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "115546",
                    "name": "|T620830:0|t |cFF00FF96Provoke|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "115176",
                    "name": "|T642417:0|t |cFF00FF96Zen Meditation|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "31850",
                    "name": "|T135870:0|t |cFFF58CBAArdent Defender|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "86659",
                    "name": "|T135919:0|t |cFFF58CBAGuardian of Anci|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "105809",
                    "name": "|T571555:0|t |cFFF58CBAHoly Avenger|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "1161",
                    "name": "|T132091:0|t |cFFC79C6EChallenging Shou|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "1160",
                    "name": "|T132366:0|t |cFFC79C6EDemoralizing Sho|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "12975",
                    "name": "|T135871:0|t |cFFC79C6ELast Stand|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "871",
                    "name": "|T132362:0|t |cFFC79C6EShield Wall|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  },
                  {
                    "default": false,
                    "key": "355",
                    "name": "|T136080:0|t |cFFC79C6ETaunt|r",
                    "type": "toggle",
                    "useDesc": false,
                    "width": 0.5
                  }
                ],
]]

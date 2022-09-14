--[[
    Mod: Unreasonably Beefy Spellbook
    Author: AranaiRa
    Version: 1.0
]]--

--Alteration
require("BeefySpellbook.effects.mendEffect")

--Destruction
require("BeefySpellbook.effects.scourEffect")

--Mysticism
require("BeefySpellbook.effects.chartEffect")
require("BeefySpellbook.effects.reserveEffect")

local framework = include("OperatorJack.MagickaExpanded.magickaExpanded")

local function initialized()
    print("[BSB] Loaded")
end

event.register(tes3.event.initialized, initialized)
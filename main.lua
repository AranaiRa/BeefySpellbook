--[[
    Mod: Unreasonably Beefy Spellbook
    Author: AranaiRa
    Version: 1.0
]]--

--Alteration
require("BeefySpellbook.effects.mendEffect")

--Mysticism
require("BeefySpellbook.effects.chartEffect")

local framework = include("OperatorJack.MagickaExpanded.magickaExpanded")

local function initialized()
    print("[BSB] Loaded")
end

event.register(tes3.event.initialized, initialized)
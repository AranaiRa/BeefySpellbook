--[[
    Mod: Unreasonably Beefy Spellbook
    Author: AranaiRa
    Version: 1.0
]]--

require("BeefySpellbook.effects.mendEffect")

local framework = include("OperatorJack.MagickaExpanded.magickaExpanded")

local function initialized()
    print("[BSB] Loaded")
end

event.register(tes3.event.initialized, initialized)
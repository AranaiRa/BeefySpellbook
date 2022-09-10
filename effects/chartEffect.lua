local framework = include("OperatorJack.MagickaExpanded.magickaExpanded")
local spellIDNumber = 1302

tes3.claimSpellEffectId("chart", spellIDNumber)

--[[
    Handle the actual logic of the spell
]]--
local function onChartTick(eventParams)
    local spellMobileTarget = eventParams.effectInstance.target.mobile

    if spellMobileTarget == tes3.mobilePlayer then
        tes3.worldController.menuController.fogOfWarDisabled = true
    end

    eventParams:trigger({
        negateOnExpiry = true
    })
end

--[[
    Handle the actual logic of the spell
]]--
local function onChartRemoved(eventParams)
    local spellMobileTarget = eventParams.effectInstance.target.mobile
    if spellMobileTarget == tes3.mobilePlayer then
        tes3.worldController.menuController.fogOfWarDisabled = false
    end
end
event.register(tes3.event.magicEffectRemoved, onChartRemoved)

--[[
    Register the spell component
]]--
local function addChartEffect()
    framework.effects.mysticism.createBasicEffect({
        -- Base Information
        id = tes3.effect.chart,
        name = "Chart",
        description = "Reveals the local map for the spell's duration.",

        -- Basic dials
        baseCost = 9.8,

        -- Various flags
        allowEnchanting = true,
        allowSpellmaking = true,
        appliesOnce = true,
        canCastSelf = true,
        canCastTarget = false,
        canCastTouch = false,
        hasNoMagnitude = true,

        -- Graphics / Sounds
        --icon = "",

        -- Required callbacks
        onTick = onChartTick
    })
end
event.register(tes3.event.magicEffectsResolved, addChartEffect)

--[[
    Create actual spells that can be learned by the player
]]--
local function registerSpells()
    framework.spells.createBasicSpell({
        id = "bsb_chart_basic",
        name = "Mage Map",
        effect = tes3.effect.chart,
        range = tes3.effectRange.self,
        duration = 5})

    framework.spells.createBasicSpell({
        id = "bsb_chart_intermediate",
        name = "Sotha's Awareness",
        effect = tes3.effect.chart,
        range = tes3.effectRange.self,
        duration = 20})
        
    framework.spells.createBasicSpell({
        id = "bsb_chart_master",
        name = "Fleeting Omniscience",
        effect = tes3.effect.chart,
        range = tes3.effectRange.self,
        duration = 60})
end
event.register("MagickaExpanded:Register", registerSpells)
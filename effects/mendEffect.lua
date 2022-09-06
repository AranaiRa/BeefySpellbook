local framework = include("OperatorJack.MagickaExpanded.magickaExpanded")
local spellIDNumber = 1301

tes3.claimSpellEffectId("mend", spellIDNumber)

--[[
    Helper functions
]]--
local function getMendingEffectInStack (effects)
    for i=1,8 do
        local effect = effects[i]
        if (effect ~= nil) then
            if (effect.id == tes3.effect.mend) then
                return effect
            end
        end
    end
end

--[[
    Handle the actual logic of the spell
]]--
local function onMendingEvent(eventParams)
    --Make sure there's actually a Mend effect here, skip all the logic of the event otherwise.
    local skipEvent = true
    for _, effect in pairs(eventParams.source.effects) do
        if effect.id == tes3.effect.mend then
            skipEvent = false
            break
        end
    end
    if skipEvent then return end

    --Since the player is logically the only person who will ever cast this, we can just use the player's current tooltip target.
    local target = tes3.getPlayerTarget()
    local tes3ObjectType = target and target.object and target.object.objectType

    if not tes3ObjectType then
        return
    end

    --We only want the spell to continue if it's the right type of object
    if tes3ObjectType == tes3.objectType.armor or tes3ObjectType == tes3.objectType.weapon then
        --Load up the values relevant to our interests
        local targetCurrentCondition = target.itemData.condition
        local targetMaximumCondition = target.object.maxCondition
        local itemValue = target.object.value

        --Let's do math to figure out how much value we target for a full repair
        local cSkill = tes3.mobilePlayer.alteration.current
        local cWIL = tes3.mobilePlayer.willpower.current
        local cINT = tes3.mobilePlayer.intelligence.current
        local cMAG = framework.functions.getCalculatedMagnitudeFromEffect(getMendingEffectInStack(eventParams.source.effects))
        local valueTheshold = math.ceil(((math.min(100,cMAG) / 50.0) * (math.min(100,cMAG) / 50.0)) * (((cINT*1.25) * (cINT*1.25)) + ((cWIL*0.75) * (cWIL*0.75))))

        --Adjust the repair multiplier based on how far over the theshold the item's value actually is
        local repairMultiplier = 1.0
        if itemValue > valueTheshold     then repairMultiplier = repairMultiplier * 0.5 end
        if itemValue > valueTheshold * 2 then repairMultiplier = repairMultiplier * 0.5 end
        if itemValue > valueTheshold * 4 then repairMultiplier = repairMultiplier * 0.5 end

        --Determine the actual value to set the repair to.
        local targetConditionLimit = math.ceil(targetMaximumCondition * (math.min(100,cSkill) / 100.0))
        local newConditionRating = math.min(targetConditionLimit, math.max(1, (targetConditionLimit - targetCurrentCondition) * repairMultiplier) + targetCurrentCondition)

        --Inform the player of their results
        if targetCurrentCondition == targetMaximumCondition then
            tes3.messageBox("The "..target.object.name.."'s condition cannot be improved any further.")
        elseif newConditionRating == targetCurrentCondition then
            tes3.messageBox("Mending the "..target.object.name.." any further is beyond your ability.")
        elseif newConditionRating == targetMaximumCondition then
            tes3.messageBox("You've fully mended the "..target.object.name..".")
        elseif newConditionRating == targetConditionLimit then
            tes3.messageBox("You've mended the "..target.object.name.." to the best of your ability.")
        else
            tes3.messageBox("You've made some repairs to the "..target.object.name..", but its complexity eludes you.")
        end

        --Actually apply the change
        target.itemData.condition = newConditionRating
        tes3ui.refreshTooltip()

        --Generate a particle system because this is ~*~magical~*~
        local vfx_glow = tes3.createVisualEffect({ reference = target, lifespan = 1.2, magicEffectId = tes3.effect.mend })
        local vfx_particles = tes3.createVisualEffect({ object = "VFX_AlterationHit", reference = target, repeatCount = 1, scale = 0.0025, verticalOffset = -75 })
    end
end
event.register("spellCasted", onMendingEvent)

--[[
    Register the spell component
]]--
local function addMendEffect()
    framework.effects.alteration.createBasicEffect({
        -- Base Information
        id = tes3.effect.mend,
        name = "Mend",
        description = "Repairs a damaged object using magicka. The effect's magnitude (as well as the caster's Intelligence and, to a lesser extent, Willpower) determines how valuable of an object can be repaired. Repair effect is diminished if the target object is too valuable.\n\nRegardless of magnitude, cannot mend an object to a higher condition percentage than the caster's Alteration.",

        -- Basic dials
        baseCost = 17.2,

        -- Various flags
        allowEnchanting = false,
        allowSpellmaking = true,
        appliesOnce = true,
        canCastSelf = false,
        canCastTarget = false,
        canCastTouch = true,
        hasNoDuration = true,

        -- Graphics / Sounds
        --icon = "",

        -- Required callbacks
        onTick = function(e)
            e:trigger()
        end
    })
end
event.register("magicEffectsResolved", addMendEffect)

--[[
    Create actual spells that can be learned by the player
]]--
local function registerSpells()
    framework.spells.createBasicSpell({
        id = "bsb_mend_basic",
        name = "Darning",
        effect = tes3.effect.mend,
        range = tes3.effectRange.touch,
        min = 3,
        max = 12})

    framework.spells.createBasicSpell({
        id = "bsb_mend_intermediate",
        name = "Artisan's Touch",
        effect = tes3.effect.mend,
        range = tes3.effectRange.touch,
        min = 45,
        max = 55})

    framework.spells.createBasicSpell({
        id = "bsb_mend_master",
        name = "Forge Anew",
        effect = tes3.effect.mend,
        range = tes3.effectRange.touch,
        min = 85,
        max = 85})

    framework.spells.createBasicSpell({
        id = "bsb_mend_wild",
        name = "Wild Mending",
        effect = tes3.effect.mend,
        range = tes3.effectRange.touch,
        min = 15,
        max = 75})
end
event.register("MagickaExpanded:Register", registerSpells)
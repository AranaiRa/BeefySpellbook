local framework = include("OperatorJack.MagickaExpanded.magickaExpanded")
local spellIDNumber = 1303

tes3.claimSpellEffectId("scour", spellIDNumber)

--[[
    Helper functions
]]--
local function getScourEffectInStack (effects)
    for i=1,8 do
        local effect = effects[i]
        if (effect ~= nil) then
            if (effect.id == tes3.effect.scour) then
                return effect
            end
        end
    end
end

--[[
    Handle the actual logic of the spell
]]--
local function onScourTick(eventParams)
    local spellTarget = eventParams.effectInstance.target

    if spellTarget ~= nil then
        local commonDiseases = tes3.getSpells({ target = spellTarget, spellType = tes3.spellType.disease })
        local blightDiseases = tes3.getSpells({ target = spellTarget, spellType = tes3.spellType.blight })
        local resistCommon = tes3.getEffectMagnitude({ reference = spellTarget, effect = tes3.effect.resistCommonDisease }) - tes3.getEffectMagnitude({ reference = spellTarget, effect = tes3.effect.weaknesstoCommonDisease })
        local resistBlight = tes3.getEffectMagnitude({ reference = spellTarget, effect = tes3.effect.resistBlightDisease }) - tes3.getEffectMagnitude({ reference = spellTarget, effect = tes3.effect.weaknesstoBlightDisease })
        local cdCount = #commonDiseases
        local bdCount = #blightDiseases

        local mag = tes3.getEffectMagnitude({ reference = spellTarget, effect = tes3.effect.scour })

        local dmgCommon = (cdCount * 2) * ((100 - math.max(0,math.min(100,resistCommon))) / 100)
        local dmgBlight = (bdCount * 3) * ((100 - math.max(0,math.min(100,resistBlight))) / 100)
        local magScalar = 30 * (0.5 + (mag / 200))
        local finalDmg = (dmgCommon + dmgBlight) * magScalar

        --Remove the diseases from the victim
        for i=1, #commonDiseases do
            tes3.removeSpell({
                reference = spellTarget,
                spell = commonDiseases[i],
                updateGUI = false
            })
        end

        for i=1, #blightDiseases do
            tes3.removeSpell({
                reference = spellTarget,
                spell = blightDiseases[i],
                updateGUI = false
            })
        end

        tes3.updateMagicGUI({reference = spellTarget})

        --Damage the victim's health and fatigue
        spellTarget.mobile.health.current = spellTarget.mobile.health.current - finalDmg
        spellTarget.mobile.fatigue.current = spellTarget.mobile.fatigue.current - finalDmg

        --Inform the player of their nasty, nasty deeds
        if cdCount > 0 and bdCount > 0 then
            if cdCount > 1 and bdCount > 1 then
                tes3.messageBox("Scourged "..cdCount.." common diseases and "..bdCount.." blight diseases from "..spellTarget.baseObject.id..".")
            elseif cdCount > 1 then
                tes3.messageBox("Scourged "..cdCount.." common diseases and a blight disease from "..spellTarget.baseObject.id..".")
            elseif bdCount > 1 then
                tes3.messageBox("Scourged a common disease and "..bdCount.." blight diseases from "..spellTarget.baseObject.id..".")
            else
                tes3.messageBox("Scourged a common disease and a blight disease from "..spellTarget.baseObject.id..".")
            end
        elseif cdCount > 1 then
            tes3.messageBox("Scourged "..cdCount.." common diseases from "..spellTarget.baseObject.id..".")
        elseif cdCount > 0 then
            tes3.messageBox("Scourged a common disease from "..spellTarget.baseObject.id..".")
        elseif cdCount > 1 then
            tes3.messageBox("Scourged "..bdCount.." blight diseases from "..spellTarget.baseObject.id..".")
        elseif bdCount > 0 then
            tes3.messageBox("Scourged a blight disease from "..spellTarget.baseObject.id..".")
        end
    end

    eventParams:trigger({
        negateOnExpiry = true
    })
end

--[[
    Handle the actual logic of the spell
]]--
local function onScourRemoved(eventParams)
    
end
event.register(tes3.event.magicEffectRemoved, onScourRemoved)

--[[
    Register the spell component
]]--
local function addScourEffect()
    framework.effects.destruction.createBasicEffect({
        -- Base Information
        id = tes3.effect.scour,
        name = "Scour",
        description = "Burns away diseases afflicting the target, causing heavy damage.",

        -- Basic dials
        baseCost = 9.8,

        -- Various flags
        allowEnchanting = true,
        allowSpellmaking = true,
        appliesOnce = true,
        canCastSelf = true,
        canCastTarget = true,
        canCastTouch = true,
        hasNoDuration = true,
        

        -- Graphics / Sounds
        --icon = "",

        -- Required callbacks
        onTick = onScourTick
    })
end
event.register(tes3.event.magicEffectsResolved, addScourEffect)

--[[
    Create actual spells that can be learned by the player
]]--
local function registerSpells()
    framework.spells.createBasicSpell({
        id = "bsb_scour_basic",
        name = "Pusbloom",
        effect = tes3.effect.scour,
        range = tes3.effectRange.touch,
        min = 3,
        max = 6})

    framework.spells.createBasicSpell({
        id = "bsb_scour_intermediate",
        name = "Screaming Fever",
        effect = tes3.effect.scour,
        range = tes3.effectRange.touch,
        min = 20,
        max = 48})

    framework.spells.createBasicSpell({
        id = "bsb_scour_master",
        name = "Peryite's Embrace",
        effect = tes3.effect.scour,
        range = tes3.effectRange.target,
        min = 52,
        max = 64,
        area = 10})

    framework.spells.createBasicSpell({
        id = "bsb_scour_wild",
        name = "Rampant Illness",
        effect = tes3.effect.scour,
        range = tes3.effectRange.target,
        min = 5,
        max = 75})
end
event.register("MagickaExpanded:Register", registerSpells)
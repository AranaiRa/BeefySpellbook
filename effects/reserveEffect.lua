local framework = include("OperatorJack.MagickaExpanded.magickaExpanded")
local bsbConstants = require("BeefySpellbook.data.dataConstants")
local spellIDNumber = 1304

local itemGen = include("BeefySpellbook.items.reserveEffectGems")

--Since the player is the only person who will ever cast this, we can just squirrel this away in a script-wide variable.
local reservedMagicka = 0

tes3.claimSpellEffectId("reserve", spellIDNumber)

--[[
    Helper functions
]]--
local function getReserveEffectInStack (effects)
    for i=1,8 do
        local effect = effects[i]
        if (effect ~= nil) then
            if (effect.id == tes3.effect.reserve) then
                return effect
            end
        end
    end
end

local function getMostValuableGemInInventory (inv)
    local gemValue = 0

    for i=1,#inv do
        local thisItem = inv[i].object.id
        if thisItem == "ingred_diamond_01" then
            gemValue = math.max(gemValue, 4)
        elseif thisItem == "ingred_ruby_01" then
            gemValue = math.max(gemValue, 3)
        elseif thisItem == "ingred_emerald_01" then
            gemValue = math.max(gemValue, 2)
        elseif thisItem == "ingred_pearl_01" then
            gemValue = math.max(gemValue, 1)
        end
    end

    for i=1,#inv do
        local thisItem = inv[i].object.id
        if  (gemValue == 4 and thisItem == "ingred_diamond_01") or
            (gemValue == 3 and thisItem == "ingred_ruby_01") or
            (gemValue == 2 and thisItem == "ingred_emerald_01") or
            (gemValue == 1 and thisItem == "ingred_pearl_01") then
            return inv[i]
        end
    end

    return nil
end

local function getGemEfficiencyCoefficient (gem) 
    if gem == "ingred_diamond_01" then
        return 1.0
    elseif gem == "ingred_ruby_01" then
        return 0.9
    elseif gem == "ingred_emerald_01" then
        return 0.8
    elseif gem == "ingred_pearl_01" then
        return 0.7
    end
end

local function getFilledGemID (gem) 
    if gem == "ingred_diamond_01" then
        return "bsb_reserved_magicka_diamond"
    elseif gem == "ingred_ruby_01" then
        return "bsb_reserved_magicka_ruby"
    elseif gem == "ingred_emerald_01" then
        return "bsb_reserved_magicka_emerald"
    elseif gem == "ingred_pearl_01" then
        return "bsb_reserved_magicka_pearl"
    end
end

local function getStandardGemID (gem) 
    if gem == "bsb_reserved_magicka_diamond" then
        return "ingred_diamond_01"
    elseif gem == "bsb_reserved_magicka_ruby" then
        return "ingred_ruby_01"
    elseif gem == "bsb_reserved_magicka_emerald" then
        return "ingred_emerald_01"
    elseif gem == "bsb_reserved_magicka_pearl" then
        return "ingred_pearl_01"
    end
end

--[[
    Handle the actual logic of the spell
]]--
local function onReserveEvent(eventParams)
    --Only the player will ever reasonably cast this, so we can just grab the player ref
    local player = tes3.mobilePlayer
    local mag = framework.functions.getCalculatedMagnitudeFromEffect(getReserveEffectInStack(eventParams.source.effects))--tes3.getEffectMagnitude({ reference = player.reference, effect = tes3.effect.reserve })
    local gem = getMostValuableGemInInventory(player.inventory)
    local amount = math.round(player.magicka.current * (mag / 100))

    if gem ~= nil then
        local amountAdjusted = math.floor(amount * getGemEfficiencyCoefficient(gem.object.id))
        local newItemID = getFilledGemID(gem.object.id)

        if amount > 0 then
            tes3.removeItem({
                reference = player.reference,
                item = gem.object,
                count = 1,
                playSound = false
            })
            tes3.addItem({
                reference = player.reference,
                item = newItemID,
                count = 1,
                playSound = true
            })
            local itemData = tes3.addItemData({
                to = player.reference,
                item = newItemID
            })
            itemData.data.bsbReservedMagicka = amountAdjusted
            tes3.modStatistic({
                reference = player.reference,
                name = "magicka",
                current = (-1 * amount)
            })
            tes3.updateInventoryGUI({reference = player.reference})
            
            local message = "You sealed "..amountAdjusted.." magicka within your "..gem.object.name.."."

            if math.floor(amount) ~= amountAdjusted then
                message = message.."\n"..(math.floor(amount) - amountAdjusted).." magicka was lost in the process."
            end

            tes3.messageBox(message)
        else
            tes3.messageBox("You don't have enough magicka to instill into a jewel.")
        end
    else
        tes3.messageBox("Your inventory contains no suitable jewels.\nNo magicka was reserved.")
    end
end
event.register("spellCasted", onReserveEvent)

--[[
    Register the spell component
]]--
local function addReserveEffect()
    framework.effects.mysticism.createBasicEffect({
        -- Base Information
        id = tes3.effect.reserve,
        name = "Reserve Magicka",
        description = "Seals away a percentage of your current magicka equal ot the spell's magnitude inside of a jewel.\n\nUsing the jewel on yourself releases the magicka and returns the jewel in its mundane form.",

        -- Basic dials
        baseCost = 0,

        -- Various flags
        allowEnchanting = true,
        allowSpellmaking = true,
        appliesOnce = true,
        canCastSelf = true,
        canCastTarget = false,
        canCastTouch = false,
        hasNoDuration = true,

        -- Graphics / Sounds
        --icon = "",

        -- Required callbacks
        onTick = function(e)
            e:trigger()
        end
    })
end
event.register("magicEffectsResolved", addReserveEffect)

--[[
    Create actual spells that can be learned by the player
]]--
local function registerSpells()
    framework.spells.createBasicSpell({
        id = "bsb_reserve_basic",
        name = "Prudence",
        effect = tes3.effect.reserve,
        range = tes3.effectRange.self,
        min = 25,
        max = 25})

    framework.spells.createBasicSpell({
        id = "bsb_reserve_master",
        name = "Sotha's Contingency",
        effect = tes3.effect.reserve,
        range = tes3.effectRange.self,
        min = 70,
        max = 70})
end
event.register("MagickaExpanded:Register", registerSpells)

--debug
event.register(tes3.event.equip, function(eventParams)
    eventParams.block = true
    local thisItem = eventParams.item

    if thisItem ~= nil then
        if thisItem.id == "bsb_reserved_magicka_diamond" or
        thisItem.id == "bsb_reserved_magicka_ruby" or
        thisItem.id == "bsb_reserved_magicka_emerald" or
        thisItem.id == "bsb_reserved_magicka_pearl" then

            local magicka = eventParams.itemData.data.bsbReservedMagicka
            tes3.modStatistic({
                reference = tes3.mobilePlayer.reference,
                name = "magicka",
                current = magicka,
                limitToBase = true
            })

            local newItemID = getStandardGemID(thisItem.id)
            tes3.addItem({
                reference = tes3.mobilePlayer.reference,
                item = newItemID,
                count = 1,
                playSound = true
            })
            tes3.removeItem({
                reference = tes3.mobilePlayer.reference,
                item = thisItem.id,
                itemData = eventParams.itemData
            })

            tes3.messageBox("You drew "..magicka.." magicka from the jewel.")
        end
    end
end
)

event.register(tes3.event.initialized, function(eventParams)
    --Register items used by the spell
    local diamondWithMagicka = tes3.createObject({
        objectType = tes3.objectType.miscItem,
        id = "bsb_reserved_magicka_diamond",
        name = "Magicka-Laden Diamond",
        icon = "BeefySpellbook\\textures\\icon_effectReserveDiamond.dds",
        weight = 0.2,
        getIfExists = false
    })

    if( diamondWithMagicka ~= nil) then
        print("[BSB] Registered <"..diamondWithMagicka.id.."> item")
    else
        print("[BSB] Failed to create item")
    end

    local rubyWithMagicka = tes3.createObject({
        objectType = tes3.objectType.miscItem,
        id = "bsb_reserved_magicka_ruby",
        name = "Magicka-Laden Ruby",
        icon = "MWSE\\mods\\BeefySpellbook\\textures\\icon_effectReserveRuby",
        weight = 0.2,
        getIfExists = false
    })

    if( rubyWithMagicka ~= nil) then
        print("[BSB] Registered <"..rubyWithMagicka.id.."> item")
    else
        print("[BSB] Failed to create item")
    end

    local emeraldWithMagicka = tes3.createObject({
        objectType = tes3.objectType.miscItem,
        id = "bsb_reserved_magicka_emerald",
        name = "Magicka-Laden Emerald",
        icon = "BeefySpellbook\\textures\\icon_effectReserveEmerald.dds",
        weight = 0.2,
        getIfExists = false
    })

    if( emeraldWithMagicka ~= nil) then
        print("[BSB] Registered <"..emeraldWithMagicka.id.."> item")
    else
        print("[BSB] Failed to create item")
    end

    local pearlWithMagicka = tes3.createObject({
        objectType = tes3.objectType.miscItem,
        id = "bsb_reserved_magicka_pearl",
        name = "Magicka-Laden Pearl",
        icon = "BeefySpellbook\\textures\\icon_effectReservePearl.dds",
        weight = 0.2,
        getIfExists = false
    })

    if( pearlWithMagicka ~= nil) then
        print("[BSB] Registered <"..pearlWithMagicka.id.."> item")
    else
        print("[BSB] Failed to create item")
    end
end
)
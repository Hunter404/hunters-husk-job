local damageTable = {
    antidama1 = {
        Damage = 30,
    },
    antidama2 = {
        Damage = 20,
    },
    pomegrenadeextract = {
        Damage = 0.32,
    },
    antibloodloss1 = {
        Damage = 2.5,
    },
    antibloodloss2 = {
        Damage = 8,
    },
    deusizine = {
        Damage = 3,
    },
    liquidoxygenite = {
        Damage = 2.5,
    },
    calyxanide = {
        Damage = 40,
    },
    antipsychosis = {
        Damage = 20,
    },
    antinarc = {
        Damage = 2,
    },
    morbusineantidote = {
        Damage = 10,
    },
    cyanideantidote = {
        Damage = 10,
    },
    sufforinantidote = {
        Damage = 20,
    },
    deliriumineantidote = {
        Damage = 20,
    },
    antiparalysis = {
        Damage = 50,
    },
    opium = {
        Damage = 0.8,
    },
    antibiotics = {
        Damage = 20,
    },
}

HH.HusksAreMute = true
HH.Species = {
    Husk_player = {
        ApplyTreatmentModifier = damageTable,
        CharacterInfoValues = {
            AllowFace = true,
        }
    },
    Husk_player_chimera = {
        ApplyTreatmentModifier = damageTable,
        CanJump = true,
        JumpForce = 800,
        CharacterInfoValues = {
            AllowFace = true,
        }
    },
    Husk_player_prowler = {
        ApplyTreatmentModifier = damageTable,
        CanJump = true,
        JumpForce = 450,
        CharacterInfoValues = {
            AllowFace = true,
        }
    },
    Husk_player_exosuit = {
        ApplyTreatmentModifier = damageTable,
        CharacterInfoValues = {}
    },
}
HH.Jobs = {
    PlayerHuskJob = {
        SpeciesName = "Husk_player",
    }
}
HH.Config = {
    TransformCooldown = 5,
    JumpCooldown = 1,
}

local function TransformToFromProwler(character)

    if not character.HasTalent("prowler_transform") then
        return false
    end

    local speciesName = "Husk_player_prowler"
    if character.SpeciesName == speciesName then
        speciesName = "Husk_player"
    end

    HH:RespawnCharacter(character, speciesName)

    return true

end

function HH:HuskTransform(client)

    if HH:IsServer() then

        local character = client and client.Character or Character.Controlled

        if character == nil then
            return
        end

        if not character.IsRagdolled then
            return -- Someone is probably cheating?
        end

        if not HH:CanTransform(character) then
            HH:Message(client, "Conciousness", "I must rest before I can transform again.", ChatMessageType.Private)

            return
        end

        if not TransformToFromProwler(character) then
            return
        end

        HH:SetNextTransformAt(character, HH.Config.TransformCooldown)

    elseif CLIENT then

        local msgWriter = Networking.Start("husk_transform")
        Networking.Send(msgWriter)

    end

end

function HH:HuskJump(character)

    if HH:IsServer() then
        if
            character == nil or
            character.IsRagdolled or
            character.IsForceRagdolled or
            character.InWater or
            not character.CanInteract
        then
            return
        end
    
        local species = HH.Species[character.SpeciesName.Value]
    
        if
            character == nil or
            not species.CanJump
        then
            return
        end
    
        character.IsForceRagdolled = true
    
        Timer.Wait(function()
            if character == nil then
                return
            end

            for _, limb in pairs(character.AnimController.Limbs) do
                limb.body.ApplyForce(Vector2(0, species.JumpForce))
            end
        end, 100)
    
        Timer.Wait(function()
            if character == nil then
                return
            end

            character.IsForceRagdolled = false
        end, 400)
    else
        local msgWriter = Networking.Start("husk_jump")
        Networking.Send(msgWriter)
    
        character.IsForceRagdolled = true
    
        Timer.Wait(function() 
            if character == nil then
                return
            end
    
            character.IsForceRagdolled = false
    
        end, 500)
    end

end

function HH:HasValue(table, str)

    for _, v in pairs(table) do
        if v == str then
            return true
        end
    end

    return false

end

function HH:IsHusk(character)
    return HH.Species[character.SpeciesName.Value] ~= nil
end

function HH:StringSplit(s, sep)
    local fields = {}
    
    local sep = sep or " "
    local pattern = string.format("([^%s]+)", sep)
    string.gsub(s, pattern, function(c) fields[#fields + 1] = c end)
    
    return fields
end

local exosuit = ItemPrefab.Find(nil, "exosuit")
local clownExosuit = ItemPrefab.Find(nil, "clownexosuit")
local hhExosuitBackpack = ItemPrefab.Find(nil, "hh_exosuit_backpack")

local itemHooks = {}
itemHooks[hhExosuitBackpack.Identifier] = {
    drop = function(item, character)
        return character ~= nil -- Never allow dropping
    end,
    inventoryPutItem = function(inventory, item, character, index, removeItemBool)
        return character ~= nil and character.SpeciesName == "Husk_player_exosuit" -- Allow picking up only for exosuit
    end,
    inventoryItemSwap = function(inventory, item, character, index, swapWholeStack)
        return character ~= nil -- Never allow swapping
    end,
}
itemHooks[clownExosuit.Identifier] = {
    inventoryPutItem = function(inventory, item, character, index, swapWholeStack)
        if CLIENT and Game.IsMultiplayer then
            return false
        end

        if
            not character or
            not character.HasTalent("exosuit_transform") or
            not character.SpeciesName == "Husk_player"
        then
            return
        end

        HH:RespawnCharacter(character, "Husk_player_exosuit", function(newCharacter)
            Entity.Spawner.AddItemToSpawnQueue(hhExosuitBackpack, newCharacter.Inventory, nil, nil, function() print(":D") end, true, false, InvSlotType.Bag)
        end)

        Entity.Spawner.AddEntityToRemoveQueue(item)

    end
}
itemHooks[exosuit.Identifier] = itemHooks[clownExosuit.Identifier]

Hook.Add("item.drop", "husk_itemUnequip", function(item, character)

    local hook = itemHooks[item.Prefab.Identifier]
    if hook and hook.drop then
        return hook.drop(item, character)
    end

end)

Hook.Add("item.equip", "husk_itemEquip", function(item, character)

    local hook = itemHooks[item.Prefab.Identifier]
    if hook and hook.equip then
        return hook.equip(item, character)
    end

end)

Hook.Add("inventoryItemSwap", "husk_inventoryItemSwap", function(inventory, item, characterUser, index, swapWholeStackBool)

    local hook = itemHooks[item.Prefab.Identifier]
    if hook and hook.inventoryItemSwap then
        return hook.inventoryItemSwap(inventory, item, characterUser, index, swapWholeStackBool)
    end

end)

Hook.Add("inventoryPutItem", "husk_inventoryPutItem", function(inventory, item, characterUser, index, removeItemBool)

    local hook = itemHooks[item.Prefab.Identifier]
    if hook and hook.inventoryPutItem then
        return hook.inventoryPutItem(inventory, item, characterUser, index, removeItemBool)
    end

end)

if not HH.HuntersGeneticsBase then

    Hook.Patch(
    "Barotrauma.Character",
    "get_IsHuman",
    { },
    function(instance, ptable)

        return ptable.OriginalReturnValue or instance.Params.UseHumanAI

    end,
    Hook.HookMethodType.After)

end

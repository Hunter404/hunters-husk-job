dofile(HH.HuntersHusks.Path .. "/Lua/Scripts/utility.lua")
dofile(HH.HuntersHusks.Path .. "/Lua/Scripts/chat.lua")

Networking.Receive("husk_transform", function(_, client) HH:HuskTransform(client) end)
Networking.Receive("husk_jump", function(_, client) HH:HuskJump(client.Character) end)

Hook.Add("character.created", "husk_convertJobs", function(character)

    Timer.Wait(function()

        if
            character == nil or
            character.Info == nil or
            character.Info.Job == nil or
            character.isDead
        then
            return
        end

        local job = HH.Jobs[character.Info.Job.Prefab.Identifier.Value]

        if job == nil then
            return
        end

        if character.SpeciesName == "Human" then
            print("Respawning " .. character.Name .. " as " .. job.SpeciesName)

            HH:RespawnCharacter(character, job.SpeciesName)

            return
        elseif
            (
                character.SpeciesName == "Husk_player_chimera" or
                character.SpeciesName == "Husk_player_prowler"
            ) and character.TeamID == 3
        then
            character.TeamID = 1
        end

        -- HH:AddToCrew(character)
        HH:SetCanSpeak(character, not HH.HusksAreMute)

    end, 1000)

end)

local healBuffPrefab = AfflictionPrefab.Prefabs["HHHealBuff"]
local medicineDebuffPrefab = AfflictionPrefab.Prefabs["HHMedicineDebuff"]

local function OnApplyMedicationToHusk(item, usingCharacter, targetCharacter, limb)

    local species = HH.Species[targetCharacter.SpeciesName.Value]

    if species == nil then
        return false
    end

    local identifier = item.Prefab.Identifier.Value
    local affliction = species.ApplyTreatmentModifier[identifier]

    if affliction == nil then
        return false
    end

    local toLimb = targetCharacter.AnimController.GetLimb(LimbType.Torso)

    targetCharacter.CharacterHealth.ApplyAffliction(toLimb, medicineDebuffPrefab.Instantiate(affliction.Damage))

    Entity.Spawner.AddItemToRemoveQueue(item)

    return true

end

local function OnApplyMedicationFromHusk(item, usingCharacter, targetCharacter, limb)

    local species = HH.Species[usingCharacter.SpeciesName.Value]

    if species == nil then
        return false
    end

    if not usingCharacter.HasTalent("hh_symbiosis") then
        return false
    end

    local identifier = item.Prefab.Identifier.Value
    local affliction = species.ApplyTreatmentModifier[identifier]

    if affliction == nil then
        return false
    end

    local toLimb = targetCharacter.AnimController.GetLimb(LimbType.Torso)

    targetCharacter.CharacterHealth.ApplyAffliction(toLimb, healBuffPrefab.Instantiate(affliction.Damage / 2))

end

local function TryTransformToChimera(item, usingCharacter, targetCharacter, limb)

    local function IsDeadOrRemoved(character)
        return character == nil or character.Removed or character.IsDead
    end

    if IsDeadOrRemoved(usingCharacter) or IsDeadOrRemoved(targetCharacter) then
        return false
    end

    if targetCharacter == usingCharacter then
        return false
    end

    if not usingCharacter.HasTalent("chimera_transform") then
        return false
    end

    if item.Prefab.Identifier ~= "hh_brainslug" then
        return false
    end

    if usingCharacter.SpeciesName ~= "Husk_player" then
        return false
    end

    if targetCharacter.Vitality <= 90 then
        return false
    end

    usingCharacter.IsForceRagdolled = true
    targetCharacter.IsForceRagdolled = true

    targetCharacter.CharacterHealth.ApplyAffliction(limb, medicineDebuffPrefab.Instantiate(100))

    local shouldSpasm = true
    local direction = true

    local function Spasm()
        local function ApplyTorqueToCharacter(character, direction)
            if IsDeadOrRemoved(character) then
                return
            end

            if character == nil or character.AnimController == nil then
                return
            end

            local torso = character.AnimController.GetLimb(LimbType.Torso)

            torso.body.ApplyTorque(direction and 100 or -100)
        end

        if not shouldSpasm then
            return
        end

        ApplyTorqueToCharacter(usingCharacter, direction)
        ApplyTorqueToCharacter(targetCharacter, direction)

        direction = not direction

        Timer.Wait(Spasm, 100)
    end

    local function Transform()
        if IsDeadOrRemoved(usingCharacter) or IsDeadOrRemoved(targetCharacter) then
            if usingCharacter ~= nil then
                usingCharacter.IsForceRagdolled = false
            end

            if targetCharacter ~= nil then
                targetCharacter.IsForceRagdolled = false
            end

            return
        end

        HH:RespawnCharacter(usingCharacter, "Husk_player_chimera")

        targetCharacter.CharacterHealth.ReduceAllAfflictionsOnAllLimbs(-100) -- Make the player explode
        targetCharacter.IsForceRagdolled = false

        shouldSpasm = false

        if item ~= nil then
            Entity.Spawner.AddItemToRemoveQueue(item)
        end
    end

    Timer.Wait(Spasm, 100)
    Timer.Wait(Transform, 15000)

    return true

end

Hook.Add("item.applyTreatment", "husk_applyMedication", function(item, usingCharacter, targetCharacter, limb)

    if -- invalid use, dont do anything
        item == nil or
        usingCharacter == nil or
        targetCharacter == nil or
        targetCharacter.SpeciesName == nil or
        targetCharacter.SpeciesName.Value == nil or
        limb == nil
    then return end

    return
        OnApplyMedicationToHusk(item, usingCharacter, targetCharacter, limb) or
        OnApplyMedicationFromHusk(item, usingCharacter, targetCharacter, limb) or
        TryTransformToChimera(item, usingCharacter, targetCharacter, limb)

end)

Hook.Add("chatMessage", "husk_commands", function(message, client)

    local msgParts = HH:StringSplit(message:lower(), " ")
    local command = msgParts[1]

    if HH.ChatCommands[command] ~= nil then
        return HH.ChatCommands[msgParts[1]](msgParts, client)
    end

end)

if not HH.HuntersGeneticsBase then
    Hook.Patch(
        "Barotrauma.AIObjectiveRescueAll",
        "IsValidTarget",
        {
            "Barotrauma.Character",
            "Barotrauma.Character",
            "out System.Boolean"
        },
        function (_, ptable)
            if HH:IsHusk(ptable["target"]) then
                return false
            end

            return ptable.OriginalReturnValue
        end,
        Hook.HookMethodType.After
    )
else
    for k, _ in pairs(HH.Species) do
        HH.HuntersGeneticsBase.Character.DisableRescueForSpecies(k)
    end
end

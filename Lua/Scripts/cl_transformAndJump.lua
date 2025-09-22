local transformCounter = 0
local nextTransformAt = 0
local transformTime = 3 -- Seconds

local function CheckTransformToProwler(character, deltaTime)

    if
        not character.HasTalent("prowler_transform")
    then
        return
    end

    if
        not character.IsRagdolled or
        not PlayerInput.KeyDown(InputType.Ragdoll)
    then
        transformCounter = 0
        return
    end

    transformCounter = transformCounter + deltaTime

    if transformCounter < transformTime then
        return
    end

    if nextTransformAt > Timer.GetTime() then
        HH:Message(nil, "Conciousness", "I must rest before I can transform again.", ChatMessageType.Private)
        transformCounter = 0

        return
    end

    nextTransformAt = Timer.GetTime() + HH.Config.TransformCooldown

    HH:HuskTransform()

end

local jumpCounter = 0
local nextJumpAt = 0

function CheckHuskJump(character, deltaTime)

    if character == nil then
        return
    end

    local species = HH.Species[character.SpeciesName.Value]

    if
        character.IsRagdolled or
        character.InWater or
        character.IsClimbing or
        not character.CanInteract or
        species == nil or
        not species.CanJump
    then
        return
    end

    if not PlayerInput.KeyDown(InputType.Up) then
        jumpCounter = 0
        return
    end

    jumpCounter = jumpCounter + deltaTime

    if jumpCounter < 1 then
        return
    end

    if nextJumpAt > Timer.GetTime() then
        jumpCounter = 0

        return
    end

    nextJumpAt = Timer.GetTime() + HH.Config.JumpCooldown

    HH:HuskJump(character)

    jumpCounter = 0

end

Hook.Add("keyUpdate", "husk_keyUpdate", function(deltaTime)

    if Character.Controlled == nil then return end

    local character = Character.Controlled

    CheckTransformToProwler(character, deltaTime)
    CheckHuskJump(character, deltaTime)

end)
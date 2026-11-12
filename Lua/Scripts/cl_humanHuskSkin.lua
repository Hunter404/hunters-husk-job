-- Human_player_husk: show the vanilla husk face overlay (the <Wearable type="Husk"> in the head block,
-- Content/Characters/Human/Human_husk.png) on the head limb.
-- The game only switches it on for Husk="True" species (Character.cs: head.EnableHuskSprite = Params.Husk),
-- and Husk="True" makes the character hostile, so it is switched on here instead.
-- Purely visual and client-side, so it needs no networking. Shipped in both Hunter's Husk Job and
-- Hunter's Genetics - Husks; the hook names are shared so loading both mods doesn't run it twice.
-- The grey body tint comes from the hh_humanhusksymbiosis affliction, not from here.

local SPECIES = "Human_player_husk"
local CHECK_INTERVAL = 2 -- seconds; catches heads that are rebuilt after spawning

local function applyHuskSkin(character)
    if character == nil or character.Removed or character.SpeciesName ~= SPECIES then
        return
    end

    local animController = character.AnimController
    if animController == nil then
        return
    end

    local head = animController.GetLimb(LimbType.Head)
    if head ~= nil and not head.EnableHuskSprite then
        head.EnableHuskSprite = true
    end
end

Hook.Add("character.created", "hh_humanHuskSkin", function(character)
    -- the Character constructor sets EnableHuskSprite = Params.Husk (false) at its end, so wait a moment
    Timer.Wait(function() applyHuskSkin(character) end, 100)
end)

local nextCheckAt = 0
Hook.Add("think", "hh_humanHuskSkin", function()
    local now = Timer.GetTime()
    if now < nextCheckAt then
        return
    end
    nextCheckAt = now + CHECK_INTERVAL

    for _, character in pairs(Character.CharacterList) do
        applyHuskSkin(character)
    end
end)

-- Hireable husks at outposts (uses Hunter's Genetics - Base's hireable registry).
-- Only the base Husk_player is offered; prowler, exosuit and chimera are unlocked through the talent tree.

if not HH.RegisterHireable then
    return -- Base is too old to support hireable creatures
end

HH:RegisterHireable({
    species = "Husk_player",
    job = { "PlayerHuskJob" },
    stage = 1,
    rarity = "uncommon",
})

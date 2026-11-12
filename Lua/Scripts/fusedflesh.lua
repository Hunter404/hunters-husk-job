-- Fused flesh: a Human_player_husk with the "fusedflesh" talent who wears a diving suit (any kind, any quality)
-- in the OuterClothes slot fuses with it and is respawned as Husk_player. The suit is consumed;
-- whatever was inside it (oxygen tank etc.) is dropped first.
-- Server / singleplayer only (loaded from Autorun/init.lua).

local FROM_SPECIES = "Human_player_husk"
local TO_SPECIES = "Husk_player"
local TALENT = "fusedflesh"
local CHECK_INTERVAL = 1 -- seconds

local pending = {}

local function getWornDivingSuit(character)
    local inventory = character.Inventory
    if inventory == nil then
        return nil
    end

    local suit = inventory.GetItemInLimbSlot(InvSlotType.OuterClothes)
    if suit == nil then
        return nil
    end

    -- Every vanilla diving suit (regular, combat, abyss, respawn, broken) is tagged "deepdiving".
    -- The exosuit is excluded: it has its own path (exosuit_transform).
    if suit.HasTag("deepdiving") and not suit.HasTag("deepdivinglarge") then
        return suit
    end

    return nil
end

local function fuse(character, suit)
    pending[character.ID] = true

    if suit.OwnInventory ~= nil then
        for contained in suit.OwnInventory.AllItemsMod do
            contained.Drop(nil)
        end
    end

    local client = Game.IsMultiplayer and HH:GetCharacterClient(character) or nil
    if client ~= nil or not Game.IsMultiplayer then
        HH:Message(client, "Conciousness", "The suit's lining melts into my skin. There is no taking it off now.", ChatMessageType.Private)
    end

    HH:RespawnCharacter(character, TO_SPECIES, function(newCharacter)
        pending[character.ID] = nil
    end)

    Entity.Spawner.AddEntityToRemoveQueue(suit)
end

local nextCheckAt = 0

Hook.Add("think", "husk_fusedFlesh", function()
    local now = Timer.GetTime()
    if now < nextCheckAt then
        return
    end
    nextCheckAt = now + CHECK_INTERVAL

    for _, character in pairs(Character.CharacterList) do
        if
            character ~= nil and
            not character.Removed and
            not character.IsDead and
            not pending[character.ID] and
            character.SpeciesName == FROM_SPECIES and
            character.HasTalent(TALENT)
        then
            local suit = getWornDivingSuit(character)
            if suit ~= nil then
                fuse(character, suit)
            end
        end
    end
end)

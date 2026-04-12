HH.Players = HH.Players or {}

function HH:CanTransform(character)

    local player = HH.Players[character.ID] or {}

    if
        player == nil or
        player[character.ID] == nil or
        player[character.ID].NextTransformAt == nil
    then
        return true
    end

    return player.NextTransformAt < Timer.GetTime()
end

function HH:SetNextTransformAt(character, delay)

    local player = HH.Players[character.ID] or {}

    player.NextTransformAt = Timer.GetTime() + delay

    HH.Players[character.ID] = player

end

HH.SetCanSpeak = function(character, canSpeak)

    print(character, canSpeak)
    if character == nil then
        return
    end

    character.CanSpeak = canSpeak

end
Networking.Receive("husk_mute_state", function(msg)
    local isMute = msg.ReadBoolean()
    HH.HusksAreMute = isMute

    local character = Character.Controlled
    if character ~= nil and HH:IsHusk(character) then
        HH:Message(nil, "Server", "Husks " .. (isMute and "muted." or "unmuted."), ChatMessageType.Private)
        HH:SetCanSpeak(character, not isMute)
    end
end)

Hook.Add("character.created", "husk_setMuteState", function(character)

    Timer.Wait(function()

        if
            character == nil or
            character.Info == nil or
            character.Info.Job == nil or
            character.isDead
        then
            return
        end

        if HH:IsHusk(character) then
            HH:SetCanSpeak(character, not HH.HusksAreMute)
        end

    end, 1000)

end)
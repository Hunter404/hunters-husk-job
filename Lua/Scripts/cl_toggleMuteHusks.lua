Networking.Receive("husk_mute_state", function(msg)
    local isMute = msg.ReadBoolean()
    HH.HusksAreMute = isMute

    HH:Message(nil, "Server", "Husks " .. (isMute and "muted." or "unmuted."), ChatMessageType.Private)

    local character = Character.Controlled
    print(character, isMute)
    if character ~= nil and HH:IsHusk(character) then
        HH.SetCanSpeak(character, not isMute)
    end
end)

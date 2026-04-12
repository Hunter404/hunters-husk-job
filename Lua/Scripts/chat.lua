HH.ChatCommands = {}

HH.ChatCommands["!togglemutehusks"] = function (msgParts, client)
    if not CLIENT then -- Ignore permission in singleplayer
        if not client.CheckPermission(ClientPermissions.ConsoleCommands) then
            HH:Message(client, "Server", "You do not have permission to use this command. Permission: ConsoleCommands", ChatMessageType.Private)
            return
        end
    end

    HH.HusksAreMute = not HH.HusksAreMute

    if Game.IsMultiplayer then
        for _, c in pairs(Client.ClientList) do
            local msgWriter = Networking.Start("husk_mute_state")
            msgWriter.WriteBoolean(HH.HusksAreMute)
            Networking.Send(msgWriter, c.Connection)
        end
    else
        HH:Message(nil, "Server", "Husks " .. (HH.HusksAreMute and "muted." or "unmuted."), ChatMessageType.Private)
    end

    for _, c in pairs(Character.CharacterList) do
        if HH:IsHusk(c) then
            HH:SetCanSpeak(c, not HH.HusksAreMute)
        end
    end

    return true
end
--[[
We can't override CanClimb in any way, shape or form so ignore for now.

HH.ChatCommands["!toggleladdershusk"] = function (msgParts, client)
    if not client.CheckPermission(ClientPermissions.ConsoleCommands) then
        return
    end

    HH.husksClimbLadders = not HH.husksClimbLadders

    for _, c in pairs(Client.ClientList) do
        Game.SendDirectChatMessage(ChatMessage.Create("Server", "Husks can climb ladders: " .. (HH.husksClimbLadders and "on." or "off."), ChatMessageType.Private, nil, c, nil, nil), c)
    end

    for _, c in pairs(Character.CharacterList) do
        if HH:IsHusk(c) then
            c.Params.CanClimb = not HH.husksClimbLadders
        end
    end

    return true
end
]]
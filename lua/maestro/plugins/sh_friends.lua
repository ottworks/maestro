if SERVER then util.AddNetworkString("maestro_friends") end
local currentqueryee
maestro.command("friends", {"player:target"}, function(caller, targets)
    if #targets == 0 then
        return true, "Query matched no players."
    elseif #targets > 1 then
        return true, "Query matched more than one player."
    end
    currentqueryee = caller
    maestro.chat(caller, Color(255, 255, 255), "Connected friends of ", targets[1], ":")
    net.Start("maestro_friends")
        net.WriteEntity(targets[1])
    net.SendOmit(targets[1])
end, [[
Prints out a listing of the target's currently connected friends.]])
net.Receive("maestro_friends", function(len, ply)
    if CLIENT then
        local s = net.ReadEntity():GetFriendStatus()
        if s ~= "none" then
            net.Start("maestro_friends")
                net.WriteString(s)
            net.SendToServer()
        end
    end
    if SERVER then
        local s = net.ReadString()
        if s == "friend" or s == "blocked" or s == "requested" then
            maestro.chat(currentqueryee, "\t", ply, ": ", s)
        end
    end
end)

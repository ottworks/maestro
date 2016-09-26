maestro.command("vac", {"player:target"}, function(caller, targets)
    if #targets == 0 then
        return true, "Query matched no players."
    elseif #targets > 1 then
        return true, "Query matched more than one player."
    end
    targets[1]:Kick("You cannot connect to the selected server, because it is running in VAC (Valve Anti-Cheat) secure mode.\n\nThis Steam account has been banned from secure servers due to a cheating infraction")
    return false, "VAC banned %1"
end, [[
Kicks a player with the VAC ban message. Fun!]])

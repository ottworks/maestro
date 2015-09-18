maestro.command("vac", {"player:target"}, function(caller, targets)
    if #targets == 0 then
        return false, "Query matched no players."
    elseif #targets > 1 then
        return false, "Query matched more than one player."
    end
    targets[1]:Kick("#VAC_ConnectionRefusedDetail")
end, [[
Kicks a player with the VAC ban message. Fun!]])

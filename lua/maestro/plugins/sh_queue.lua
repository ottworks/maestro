local queue
maestro.command("queue", {"time", "command"}, function(caller, time, command)
    if not time then
        return true, "Invalid time!"
    end
    if queue then
        local id = "server"
        if caller then
            id = caller:SteamID()
        end
        queue[id] = queue[id] or {}
        local stamp = os.time() + time
        queue[id][stamp] = command
        maestro.save("queue", queue)
        return false, "queued command %2 for %1"
    else
        return true, "Queue not loaded yet! Try again later."
    end
end, [[
Queues a command to be ran at a later time.
When not run from the server console, the initiating player needs to be connected for the command to run.
(This measure is to prevent abuse such as queuing a ban on a higher rank, then disconnecting.)]])


if CLIENT then return end
maestro.load("queue", function(val)
    queue = val
end)

timer.Create("maestro_queue", 1, 0, function()
    if queue then
        for id, tab in pairs(queue) do
            for stamp, command in pairs(tab) do
                if stamp < os.time() then
                    local rank = maestro.userrank(id)
                    local split = maestro.split(command)
                    local cmd = table.remove(split, 1)
                    if id == "server" then
                        tab[stamp] = nil
                        maestro.save("queue", queue)
                        maestro.runcmd(false, cmd, split)
                    elseif player.GetBySteamID(id) then
                        tab[stamp] = nil
                        maestro.save("queue", queue)
                        if maestro.rankget(maestro.userrank(player.GetBySteamID(id))).perms[cmd] then
                            maestro.runcmd(false, cmd, split, player.GetBySteamID(id))
                        end
                    elseif maestro.userrank(id) == "root" then
                        tab[stamp] = nil
                        maestro.save("queue", queue)
                        maestro.runcmd(false, cmd, split)
                    end
                end
            end
        end
    end
end)

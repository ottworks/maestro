local gimps
local gimped = {}
maestro.command("gimp", {"player:target", "boolean:state(optional)"}, function(caller, targets, state)
    if #targets == 0 then
        return true, "Query matched no players."
    end
    if state == nil then
        for i = 1, #targets do
            local ply = targets[i]
            gimped[ply] = not gimped[ply]
        end
        return false, "toggled gimp on %1"
    else
        for i = 1, #targets do
            local ply = targets[i]
            gimped[ply] = state
        end
        if state then
            return false, "gimped %1"
        end
        return false, "ungimped %1"
    end
end)
maestro.command("gimps", {}, function(caller)
    maestro.chat(caller, "Gimps:")
    for i = 1, #gimps do
        maestro.chat(caller, i, ". ", gimps[i])
    end
end)
maestro.command("gimpadd", {"line"}, function(caller, line)
    if not line then return true, "Specify a line first!" end
    table.insert(gimps, line)
    maestro.save("gimps", gimps)
    return false, "added gimp line \"" .. line .. "\""
end)
maestro.command("gimpremove", {"number:line"}, function(caller, line)
    if gimps[line] then
        local l = gimps[line]
        table.remove(gimps, line)
        maestro.save("gimps", gimps)
        return false, "removed gimp line \"" .. l .. "\""
    end
end)
if not SERVER then return end
gimps, newfile = maestro.load("gimps")
if newfile then
    gimps = {
        "You make my software turn into hardware!",
        "Are you sitting on the F5 key? Cause your ass is refreshing.",
        "You had me at \"Hello World.\"",
        "Want to see my HARD Disk? I promise it isn't 3.5 inches and it ain't floppy.",
        "You still use Internet Explorer? You must like it nice and slow.",
        "My servers never go down... but I do!",
        "Are you a computer keyboard? Because you're my type.",
        "How about we do a little peer-to-peer saliva swapping?",
        "Mind if I run a sniffer to see if your ports are open?",
        "I was hoping you wouldn't block my pop-up.",
        "I'd switch to emacs for you.",
        "Come to my 127.0.0.1 and I’ll give you sudo access.",
        "You auto-complete me.",
        "How about we go home and you handle my exception?",
        "Hey baby, you’re hotter than magma and have more cleavage than a sheet silicate.",
        "Are you a sample of carbon? Because I’d like to date you.",
        "I wont take you for granite, baby.",
    }
    maestro.save("gimps", gimps)
end
maestro.hook("PlayerSay", "gimp", function(ply)
    if gimped[ply] then
        return table.Random(gimps) or "It's pronounced \"my strow\"."
    end
end)

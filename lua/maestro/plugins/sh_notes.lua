local notes = {}
if SERVER then
    maestro.load("notes", function(tab, newfile)
        notes = tab
    end)
end

local function donotes(caller, id, nick)
    nick = " " .. nick
    maestro.chat(caller, Color(255, 255, 255), "Notes on", maestro.blue, nick, Color(255, 255, 255), " (", maestro.blue, id, Color(255, 255, 255), "):")
    if notes[id] then
        for i = 1, #notes[id] do
            maestro.chat(caller or false, Color(255, 255, 255), "\t", i, ". ", notes[id][i])
        end
    end
end
local function noterm(id, num)
    if notes[id] then
        if notes[id][num] then
            table.remove(notes[id], num)
            if #notes[id] == 0 then
                notes[id] = nil
            end
            maestro.save("notes", notes)
            return false, "removed note %2 on %1"
        else
            return true, "No notes by this number."
        end
    end
end

maestro.command("notes", {"player:target"}, function(caller, targets)
    if #targets == 0 then
        return true, "Query matched no players."
    elseif #targets > 1 then
        return true, "Query matched more than one player."
    end
    local ply = targets[1]
    donotes(caller, ply:SteamID(), ply:Nick())
end, [[
Gets any notes that have been taken on a player.]])
maestro.command("notesid", {"steamid"}, function(caller, id)
    donotes(caller, id)
end, [[
Gets any notes that have been taken on a SteamID.]])
maestro.command("note", {"player:target", "text"}, function(caller, targets, txt)
    if #targets == 0 then
        return true, "Query matched no players."
    elseif #targets > 1 then
        return true, "Query matched more than one player."
    end
    local id = targets[1]:SteamID()
    notes[id] = notes[id] or {}
    notes[id][#notes[id] + 1] = txt
    maestro.save("notes", notes)
    return false, "took a note on %1: %2"
end, [[
Takes a note on a player.]])
maestro.command("noteid", {"steamid", "text"}, function(caller, id, txt)
    notes[id] = notes[id] or {}
    notes[id][#notes[id] + 1] = txt
    maestro.save("notes", notes)
    return false, "took a note on %1: %2"
end, [[
Takes a note on a SteamID.]])
maestro.command("noteremove", {"player:target", "number"}, function(caller, targets, num)
    if #targets == 0 then
        return true, "Query matched no players."
    elseif #targets > 1 then
        return true, "Query matched more than one player."
    end
    local id = targets[1]:SteamID()
    return noterm(id, num)
end)
maestro.command("noteremoveid", {"steamid", "number"}, function(caller, id, num)
    return noterm(id, num)
end)

maestro.hook("PlayerInitialSpawn", "notes", function(ply)
    if not notes[ply:SteamID()] then return end
    for _, ply2 in pairs(player.GetAll()) do
        local r = maestro.userrank(ply2)
        if maestro.rankgetpermcantarget(r, "notes") then
            maestro.runcmd(false, "notes", {"$" .. ply:EntIndex()}, ply2)
        end
    end
end)

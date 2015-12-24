local notes = {}

local function donotes(caller, id, nick)
    nick = " " .. nick
    maestro.chat(caller, Color(255, 255, 255), "Notes on", maestro.blue, nick, Color(255, 255, 255), " (", maestro.blue, id, Color(255, 255, 255), "):")
    local q = mysql:Select("maestro_notes")
        q:Where("steamid", id)
        q:Callback(function(res, status)
            if type(res) == "table" then
                for i = 1, #res do
                    local note = res[i]
                    maestro.chat(caller, Color(255, 255, 255), "\t", os.date("%x - ", note.when), "ID #", note.id, ", ", note.admin, " (", util.SteamIDFrom64(note.adminid), "): ", Color(255, 255, 255), note.note)
                end
            end
        end)
    q:Execute()
end
local function noterm(id, num, caller)
    local q = mysql:Select("maestro_notes")
        q:Where("steamid", id)
        q:Where("id", num)
        q:Callback(function(res, status, last)
            if last then
                local q = mysql:Delete("maestro_notes")
                    q:Where("steamid", id)
                    q:Where("id", num)
                q:Execute()
                maestro.chat(caller, Color(255, 255, 255), "Note removed.")
            else
                maestro.chat(caller, maestro.orange, "noteremove: No note for this player with this id.")
            end
        end)
    q:Execute()
end

maestro.command("notes", {"player:target"}, function(caller, targets)
    if #targets == 0 then
        return true, "Query matched no players."
    elseif #targets > 1 then
        return true, "Query matched more than one player."
    end
    local ply = targets[1]
    donotes(caller, ply:SteamID64(), ply:Nick())
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
    local id = targets[1]:SteamID64()
    local admin = caller and caller:Nick() or ""
    local adminid = caller and caller:SteamID64() or 0
    local q = mysql:Insert("maestro_notes")
        q:Insert("steamid", id)
        q:Insert("admin", admin)
        q:Insert("adminid", adminid)
        q:Insert("note", txt)
        q:Insert("when", os.time())
    q:Execute()
    return false, "took a note on %1: %2"
end, [[
Takes a note on a player.]])
maestro.command("noteid", {"steamid", "text"}, function(caller, id, txt)
    id = util.SteamIDTo64(id)
    local admin = caller and caller:Nick() or ""
    local adminid = caller and caller:SteamID64() or 0
    local q = mysql:Insert("maestro_notes")
        q:Insert("steamid", id)
        q:Insert("admin", admin)
        q:Insert("adminid", adminid)
        q:Insert("note", txt)
        q:Insert("when", os.time())
    q:Execute()
    return false, "took a note on %1: %2"
end, [[
Takes a note on a SteamID.]])
maestro.command("noteremove", {"player:target", "number:noteid"}, function(caller, targets, num)
    if #targets == 0 then
        return true, "Query matched no players."
    elseif #targets > 1 then
        return true, "Query matched more than one player."
    end
    local id = targets[1]:SteamID64()
    return noterm(id, num, caller)
end)
maestro.command("noteremoveid", {"steamid", "number:noteid"}, function(caller, id, num)
    id = util.SteamIDTo64(id)
    return noterm(id, num, caller)
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

if not SERVER then return end
local q = mysql:Create("maestro_notes")
    q:Create("id", "INT NOT NULL AUTO_INCREMENT")
    q:Create("steamid", "BIGINT NOT NULL")
    q:Create("admin", "VARCHAR(32) NOT NULL")
    q:Create("adminid", "BIGINT NOT NULL")
    q:Create("note", "VARCHAR(255) NOT NULL")
    q:Create("when", "BIGINT NOT NULL")
    q:PrimaryKey("id")
q:Execute()

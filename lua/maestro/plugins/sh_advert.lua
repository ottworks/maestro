local adverts
maestro.command("advert", {"time", "r:number", "g:number", "b:number", "text"}, function(caller, time, r, g, b, text)
    if not time then
        return true, "Invalid time!"
    end
    if adverts then
        local a = {}
        a.color = Color(r, g, b)
        a.text = text
        a.time = time
        local id = #adverts + 1
        adverts[id] = a
        maestro.save("adverts", adverts)
        timer.Create("maestro_advert_" .. text, time, 0, function()
            maestro.chat(nil, a.color, text)
        end)
        return false, "set an advert for %1 with text %5"
    else
        return true, "Adverts not loaded yet! Try again later."
    end
end, [[
Plays text back at an interval.]])
maestro.command("adverts", {}, function(caller)
    maestro.chat(caller, Color(255, 255, 255), "Adverts:")
    for i = 1, #adverts do
        maestro.chat(caller, Color(255, 255, 255), i, ". ", adverts[i].color, adverts[i].text)
    end
end, [[
Prints out a list of adverts.]])
maestro.command("advertremove", {"id:number"}, function(caller, id)
    id = tonumber(id)
    if not adverts[id] then return true, "Advert not found." end
    local a = table.remove(adverts, id)
    maestro.chat(caller, Color(255, 255, 255), "Advert removed. Note that all subsequent adverts will be shifted down, check the list before removing again.")
    timer.Remove("maestro_advert_" .. a.text)
    maestro.save("adverts", adverts)
    return false, "removed advert %1", a.text
end)

if not SERVER then return end
maestro.load("adverts", function(val)
    adverts = val or {}
    for i = 1, #adverts do
        local a = adverts[i]
        timer.Create("maestro_advert_" .. a.text, a.time, 0, function()
            maestro.chat(nil, a.color, a.text)
        end)
    end
end)

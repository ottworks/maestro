--You can delete this file with no worries if it's causing problems.
--If you're a developer, set maestro_maim to 0 instead of removing this hook, it'll save me the pain of dealing with Workshop comments if you do.

CreateConVar("maestro_maim", 1, FCVAR_ARCHIVE + FCVAR_SERVER_CAN_EXECUTE + FCVAR_REPLICATED, "Disables maiming of competing admin mods.")

local alerts = {}
local alerted = false
local delay = 30
local function alertfunc()
    for i = 1, #alerts do
        MsgC(maestro.orange, unpack(alerts[i]))
    end
    delay = delay * 2
    timer.Simple(delay, alertfunc)
end
local function alert(...)
    MsgC(maestro.orange, ...)
    alerts[#alerts + 1] = {...}
    if not alerted then
        timer.Simple(delay, alertfunc)
    end
end

local function maim(mod, id1, id2, bypass)
    if GetConVarNumber("maestro_maim") == -1 then return end
    if GetConVarNumber("maestro_maim") == 0 and not bypass then
        alert("\n\nMaestro has been maimed by ", mod, "! Set maestro_maim to -1 to disable.\n\n")
        maim("Maestro", "maestro_", "maestro_", true)
        return
    end
    for h, tab in pairs(hook.GetTable()) do
        for name in pairs(tab) do
            if string.lower(string.sub(tostring(name), 1, #id1)) == id1 then
                hook.Remove(h, name)
            end
        end
    end
    for name in pairs(net.Receivers) do
        if string.sub(name, 1, #id2) == id2 then
            net.Receivers[name] = nil
        end
    end
    if bypass then return end
    alert("\n\n", mod, " has been maimed by Maestro! Set maestro_maim to 0 to disable.\n\n")
end
hook.Add("InitPostEntity", "maestro_maim", function()
    if FAdmin then
        maim("FAdmin", "fadmin", "fadmin")
    end

    if evolve then
        maim("Evolve", "ev_", "ev_")
    end

    if ASS_VERSION then
        maim("ASSmod", "ass_", "ass_")
    end

    if ulx then
        maim("ULX", "ulx", "ulx")
        maim("UPS", "ups", "ups")
        maim("ULib", "ulib", "URPC")
    end

    if Mercury then
        maim("Mercury", "mercury", "mercury")
    end
end)

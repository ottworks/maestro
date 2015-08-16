maestro.command("play", {"sound"}, function(caller, sound)
    if not sound then
        return true, "Invalid sound."
    end
    if not file.Exists("sound/" .. sound, "GAME") then
        return true, "Sound not found."
    end
    net.Start("maestro_play")
        net.WriteString(sound)
    net.Broadcast()
end, [[
Plays a sound for everyone to hear.]])
if SERVER then
    util.AddNetworkString("maestro_play")
end
if CLIENT then
    net.Receive("maestro_play", function()
        local sound = net.ReadString()
        surface.PlaySound(sound)
    end)
end

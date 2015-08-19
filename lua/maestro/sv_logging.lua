maestro.hook("PlayerDeath", "logging", function(victime, inflictor, attacker)
    local atk = tostring(attacker)
    if IsValid(attacker) and attacker:IsPlayer() then
        atk = attacker:Nick() .. "(" .. attacker:SteamID() .. ")"
    end
    local txt = "was killed by " .. atk .. " with a(n) " .. tostring(inflictor)
    maestro.log("log_" .. os.date("%y-%m-%d"), os.date("[%H:%M] ") .. ply:Nick() .. "(" .. ply:SteamID() .. "): " .. txt)
end)

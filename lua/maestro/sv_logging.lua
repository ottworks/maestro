maestro.hook("PlayerDeath", "logging", function(victim, inflictor, attacker)
    local atk = tostring(attacker)
    if IsValid(attacker) and attacker:IsPlayer() then
        atk = attacker:Nick() .. "(" .. attacker:SteamID() .. ")"
    end
    local txt = "was killed by " .. atk .. " with a(n) " .. tostring(inflictor)
    maestro.log("log_" .. os.date("%y-%m-%d"), os.date("[%H:%M] ") .. victim:Nick() .. "(" .. victim:SteamID() .. "): " .. txt)
end)

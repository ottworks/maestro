local fmt = string.format
local function plystr(ply)
    return fmt("%s(%s)", ply:Nick(), ply:SteamID())
end
function maestro.serverlog(txt, col)
    col = col or Color(255, 255, 255)
    local final = os.date("[%H:%M] ") .. txt
    MsgC(col, final, "\n")
    for name, rank in pairs(maestro.ranks) do
        if rank.flags.echo then
            maestro.chatconsole(maestro.target("#" .. name), col, final)
        end
    end
    maestro.log("log_" .. os.date("%y-%m-%d"), final)
end
local log = maestro.serverlog


maestro.hook("PlayerDeath", "logging", function(victim, inflictor, attacker)
    local atk = tostring(attacker)
    if IsValid(attacker) and attacker:IsPlayer() then
        atk = plystr(attacker)
    end
    local txt = fmt(" was killed by %s with a(n) %s", atk, tostring(inflictor))
    log(plystr(victim) .. txt)
end)

maestro.hook("PlayerSpawnedProp", "logging", function(ply, model, ent)
    log(fmt("%s spawned prop %s", plystr(ply), model))
end)

maestro.hook("PlayerSpawnedRagdoll", "logging", function(ply, model, ent)
    log(fmt("%s spawned ragdoll %s", plystr(ply), model))
end)

maestro.hook("PlayerSpawnedEffect", "logging", function(ply, model, ent)
    log(fmt("%s spawned effect %s", plystr(ply), model))
end)

maestro.hook("PlayerSpawnedVehicle", "logging", function(ply, ent)
    log(fmt("%s spawned vehicle %s (%s)", plystr(ply), ent:GetClass(), ent:GetModel()))
end)

maestro.hook("PlayerSpawnedSENT", "logging", function(ply, ent)
    log(fmt("%s spawned SEnt %s", plystr(ply), ent:GetClass()))
end)

maestro.hook("PlayerSpawnedNPC", "logging", function(ply, ent)
    log(fmt("%s spawned NPC %s", plystr(ply), ent:GetClass()))
end)

maestro.hook("PlayerSay", "logging", function(ply, txt, team)
    log(fmt("%s%s: %s", team and "(TEAM) " or "", plystr(ply), txt))
end)

maestro.command("alias", {"player:target", "name"}, function(caller, targets, name)
    if #targets == 0 then
        return true, "Query matched no players."
    end
    if not name then
        for i = 1, #targets do
            targets[i]:SetNWBool("maestro_alias_enabled", false)
            targets[i].spawn_nick = targets[i]:Nick() --ttt workaround
        end
        if #targets > 1 then
            return false, "restored the original names of %1"
        end
        return false, "restored the original name of %1"
    end
    for i = 1, #targets do
        targets[i]:SetNWBool("maestro_alias_enabled", true)
        targets[i]:SetNWString("maestro_alias", name)
        targets[i].spawn_nick = targets[i]:Nick()
    end
    return false, "set the alias of %1 to %2"
end, [[
Sets a player's name]])
local PLAYER = FindMetaTable("Player")
PLAYER.NickOld = PLAYER.NickOld or PLAYER.Nick
function PLAYER:Nick()
    return self:GetNWBool("maestro_alias_enabled") == true and self:GetNWString("maestro_alias") or self:NickOld()
end
PLAYER.Name = PLAYER.Nick
PLAYER.GetName = PLAYER.Nick
hook.Add("DarkRPFinishedLoading", "maestro_alias", function()
    PLAYER.NickOld2 = PLAYER.Nick
    function PLAYER:Nick()
        return self:GetNWBool("maestro_alias_enabled") == true and self:GetNWString("maestro_alias") or self:NickOld2()
    end
    PLAYER.Name = PLAYER.Nick
    PLAYER.GetName = PLAYER.Nick
end)
if CLIENT then
    chat.AddTextOld = chat.AddTextOld or chat.AddText
    function chat.AddText(...)
        local args = {...}
        for k, v in ipairs(args) do
            if type(v) == "Player" then
                args[k] = v:Nick()
                table.insert(args, k, team.GetColor(v:Team()))
            end
        end
        chat.AddTextOld(unpack(args))
    end
end

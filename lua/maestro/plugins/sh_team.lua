maestro.command("team", {"player:target", "team"}, function(caller, targets, teamname)
    if #targets < 1 then
        return true, "Query matched no players."
    end
    for id, tab in pairs(team.GetAllTeams()) do
        if string.lower(tab.Name or "") == teamname:lower() then
            for i = 1, #targets do
                if DarkRP then
                    targets[i]:changeTeam(id, true)
                else
                    targets[i]:SetTeam(id)
                end
            end
            return false, "set the team of %1 to %2"
        end
    end
    return true, "Team not found: " .. teamname .. "."
end)

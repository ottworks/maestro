maestro.command("hp", {"player:target", "number"}, function(caller, targets, num)
	if #targets == 0 then
		return true, "Query matched no players."
	end
	for _, ply in pairs(targets) do
		ply:SetHealth(num)
	end
	return false, "set the hp of %% to %%"
end)
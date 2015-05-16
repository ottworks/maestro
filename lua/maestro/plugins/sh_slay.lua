maestro.command("slay", {"player:target"}, function(caller, targets)
	if #targets == 0 then
		return true, "Query matched no players."
	end
	for i = 1, #targets do
		local ply = targets[i]
		if not ply:Alive() then
			if #targets == 1 then
				return true, "Player is dead!"
			end
			continue
		end
		ply:Kill()
	end
	return false, "slayed %%"
end)
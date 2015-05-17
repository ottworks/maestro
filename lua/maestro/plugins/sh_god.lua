maestro.command("god", {"player:target(optional)", "boolean:state(optional)"}, function(caller, targets, state)
	if not targets then
		if caller:HasGodMode() then
			caller:GodDisable()
		else
			caller:GodEnable()
		end
		return false, "toggled god mode on themselves"
	end
	if #targets == 0 then
		return true, "Query matched no players."
	end
	for _, ply in pairs(targets) do
		if state == nil then
			if ply:HasGodMode() then
				ply:GodDisable()
			else
				ply:GodEnable()
			end
		elseif state then
			ply:GodEnable()
		else
			ply:GodDisable()
		end
	end
	if state == nil then
		return false, "toggled god mode on %%"
	end
	return false, "set god mode on %% to %%"
end)
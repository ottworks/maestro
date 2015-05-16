maestro.command("cvar", {"string:variable", "value"}, function(caller, var, val)
	if not var then
		return true, "Invalid cvar!"
	end
	if not val then
		return true, "Invalid value!"
	end
	local cvar = GetConVar(var)
	if cvar then
		RunConsoleCommand(var, val)
	else
		return true, "Invalid cvar!"
	end
	return false, "set cvar %% to %%"
end)
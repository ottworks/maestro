maestro.command("rcon", {"string:command"}, function(caller, ...)
	RunConsoleCommand(...)
	return false, "ran command %%"
end)
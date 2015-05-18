maestro.command("rcon", {"string:command"}, function(caller, ...)
	RunConsoleCommand(...)
	return false, "ran command %% on the server"
end)
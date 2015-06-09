maestro.command("rcon", {"string:command"}, function(caller, ...)
	RunConsoleCommand(...)
	return false, "ran command %1 %% on the server"
end, [[
Runs a console command on the server.]])
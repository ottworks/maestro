maestro.command("rcon", {"string:command"}, function(caller, ...)
	RunConsoleCommand(...)
	return false, "ran command %1 %% on the server"
end, [[
Runs a console command on the server.]])
maestro.command("lua", {"string:lua"}, function(caller, ...)
	local code = table.concat({...}, " ")
	local ran, err = pcall(CompileString(code, "maestro_lua", false))
	if err then
		return true, err .. "\nCode interpreted as:\n" .. code
	end
	return false, "ran code %% on the server"
end, [[
Runs Lua on the server.
Include your code in double quotes to prevent malformation.]])

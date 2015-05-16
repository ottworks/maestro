maestro.command("lua", {"string:lua"}, function(caller, ...)
	local code = table.concat({...}, " ")
	local ran, err = pcall(CompileString(code, "maestro_lua", false))
	if err then
		return true, err .. "\nCode interpreted as:\n" .. code
	end
	return false, "ran code \"" .. code .. "\" on the server %%"
end)
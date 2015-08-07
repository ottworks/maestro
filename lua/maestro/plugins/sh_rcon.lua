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
maestro.command("ent", {"class", "keyvalues(multiple)"}, function(caller, class, ...)
	if not caller then
		return true, "You cannot create an entity from the console!"
	elseif not class then
		return true, "Invalid class!"
	end
	local params = {...}
	local ent = ents.Create(class)
	if not IsValid(ent) then
		return true, "Invalid entity \"" .. class .. "\"."
	end
	ent:SetPos(caller:GetEyeTrace().HitPos + Vector(0, 0, 25))

	for i = 1, #params do
		if tonumber(params[i]) then
			ent:AddFlags(tonumber(params[i]))
		else
			local key, value = string.match(params[i], "([^:]+):([^:]+)")
			if not key or not value then
				ent:Remove()
				return true, "Invalid keyvalue pair \"" .. params[i] .. "\". Keyvalues are colon separated."
			end
			ent:SetKeyValue(key, value)
		end
	end

	ent:Spawn()
	ent:Activate()

	undo.Create("ms ent")
		undo.AddEntity(ent)
		undo.SetPlayer(caller)
	undo.Finish()
	if #params > 0 then
		return false, "created ent %1 with params %%"
	end
	return false, "created ent %1"
end, [[
Creates an entity and sets properties on it.
Keyvalues are formatted as such:
key:value
Flags are numbers.]])

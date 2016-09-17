local cexe = function(caller, targets, ...)
	if #targets > 1 then
		return true, "Query matched more than 1 player."
	elseif #targets < 1 then
		return true, "Query matched no players."
	end
	local ply = targets[1]
	local cmd = table.concat({...}, " ")
	ply:ConCommand(cmd)
	return false, "made %1 run command %2"
end
maestro.command("cexe", {"player:target", "string:command"}, cexe, [[
Runs a console command on the specified player.]])
maestro.command("cexec", {"player:target", "string:command"}, cexe, [[
Runs a console command on the specified player.]])

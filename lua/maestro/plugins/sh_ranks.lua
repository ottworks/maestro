maestro.command("rankadd", {"string:name", "rank:inherits", "command:multiple"}, function(caller, name, inherits, ...)
	local args = {...}
	local perms = {}
	if #args == 1 and args[1] == "*" then
		for cmd in pairs(maestro.commands) do
			perms[cmd] = true
		end
	else
		for i = 1, #args do
			perms[args[i]] = true
		end
	end
	maestro.rankadd(name, inherits, perms)
	return false, "added rank %1 (inheriting from %2) with access to command(s) %%"
end, [[
Adds a new rank to the server, inheriting from another rank, with access to the specified commands (or "*" for all commands).]])
maestro.command("rankremove", {"rank"}, function(caller, rank)
	if not rank or not maestro.rankget(rank) then
		return true, "Invalid rank!"
	end
	maestro.rankremove(rank)
	return false, "removed rank %1"
end, [[
Removes the rank from the server.]])
maestro.command("ranksetperms", {"rank", "command:multiple"}, function(caller, rank, ...)
	if not rank or not maestro.rankget(rank) then
		return true, "Invalid rank!"
	end
	local args = {...}
	local perms = {}
	for i = 1, #args do
		perms[args[i]] = true
	end
	maestro.ranksetperms(rank, perms)
	return false, "set commannd access of rank %1 to %2"
end, [[
Sets the commands available to the rank.]])
maestro.command("rankaddperms", {"rank", "command:multiple"}, function(caller, rank, ...)
	if not rank or not maestro.rankget(rank) then
		return true, "Invalid rank!"
	end
	local args = {...}
	local perms = {}
	for i = 1, #args do
		perms[args[i]] = true
	end
	maestro.rankaddperms(rank, perms)
	return false, "gave rank %1 access to command(s) %%"
end, [[
Grants the rank access to new commands.]])
maestro.command("rankremoveperms", {"rank", "command:multiple"}, function(caller, rank, ...)
	if not rank or not maestro.rankget(rank) then
		return true, "Invalid rank!"
	end
	local args = {...}
	local perms = {}
	for i = 1, #args do
		perms[args[i]] = true
	end
	maestro.rankremoveperms(rank, perms)
	return false, "revoked rank %1 access to command(s) %%"
end, [[
Explicitly revokes the commands this rank can use.
Any ranks that inherit from this one will also be unable to use the command.]])
maestro.command("rankresetperms", {"rank"}, function(caller, rank)
	if not rank or not maestro.rankget(rank) then
		return true, "Invalid rank!"
	end
	maestro.rankresetperms(rank)
	return false, "reset command access of rank %1"
end, [[
Resets a rank's permissions to only ones it inherits.]])
maestro.command("ranksetinherits", {"rank", "rank:inherits"}, function(caller, rank, inherits)
	if not rank or not maestro.rankget(rank) then
		return true, "Invalid rank!"
	end
	maestro.ranksetinherits(rank, inherits)
	return false, "set the inheritance of rank %1 to %2"
end, [[
Sets the rank this rank inherits from.]])
maestro.command("rankflag", {"rank", "flag", "boolean:admin"}, function(caller, rank, flag, bool)
	if not rank or not maestro.rankget(rank) then
		return true, "Invalid rank!"
	end
	maestro.rankflag(rank, flag, bool)
	return false, "set flag %2 of rank %1 to %3"
end, [[
Sets a flag on this rank.]])
maestro.command("ranksetcantarget", {"rank", "targetstring"}, function(caller, rank, str)
	if not rank or not maestro.rankget(rank) then
		return true, "Invalid rank!"
	end
	maestro.ranksetcantarget(rank, str)
	return false, "set the players rank %1 can target to %2"
end, [[
Sets the players this rank can target in the form of a targetstring.]])
maestro.command("rankresetcantarget", {"rank"}, function(caller, rank)
	if not rank or not maestro.rankget(rank) then
		return true, "Invalid rank!"
	end
	maestro.rankresetcantarget(rank)
	return false, "reset the players rank %1 can target"
end, [[
Resets the players this rank can target to the default value (hierarchical).]])
maestro.command("ranksetpermcantarget", {"rank", "command", "targetstring"}, function(caller, rank, cmd, str)
	if not rank or not maestro.rankget(rank) then
		return true, "Invalid rank!"
	end
	maestro.ranksetpermcantarget(rank, cmd, str)
	return false, "set the players rank %1 can target with command %2 to %3"
end, [[
Sets the players this rank can target with this command in the form of a targetstring.]])
maestro.command("rankresetpermcantarget", {"rank", "command"}, function(caller, rank, cmd)
	if not rank or not maestro.rankget(rank) then
		return true, "Invalid rank!"
	end
	maestro.rankresetpermcantarget(rank, cmd)
	return false, "reset the players rank %1 can target with %2"
end, [[
Resets the players this rank can target with this command to that of the rank's.]])
maestro.command("rankrename", {"rank:from", "to"}, function(caller, from, to)
	if not from or not maestro.rankget(from) then
		return true, "Invalid rank!"
	end
	maestro.rankrename(from, to)
	return false, "renamed rank %1 to %2"
end, [[
Renames a rank.]])
maestro.command("ranks", {}, function(caller)
	if caller then
		maestro.chat(caller, Color(255, 255, 255), "Available ranks:")
	else
		print("Available ranks:")
	end
	for rank in pairs(maestro.rankgettable()) do
		if caller then
			maestro.chat(caller, "\t", rank)
		else
			print(" ", rank)
		end
	end
end, [[
Lists all the ranks in the server.]])

maestro.command("userrank", {"player:target", "rank"}, function(caller, targets, rank)
	if #targets > 1 then
		return true, "Query matched more than 1 player."
	elseif not targets or #targets == 0 then
		return true, "Query matched no players."
	end
	if not maestro.rankget(rank) then
		return true, "Invalid rank!"
	end
	local ply = targets[1]
	maestro.userrank(ply, rank)
	return false, "set the rank of %1 to %2"
end, [[
Sets the rank of this user.]])
maestro.command("userrankid", {"steamid", "rank"}, function(caller, id, rank)
	if not maestro.rankget(rank) then
		return true, "Invalid rank!"
	end
	--TODO: check perms
	maestro.userrank(id, rank)
	return false, "set the rank of %1 to %2"
end, [[
Sets the rank of this user.]])

maestro.command("reseteverythingtodefault", {"boolean:areyousure?", "boolean:areyousureyou'resure?"}, function(caller, sure1, sure2)
	if sure1 and sure2 then
		maestro.RESETRANKS()
		maestro.RESETUSERS()
		return false, "reset EVERYTHING (yes, it was on purpose)"
	end
	if not sure1 then
		return true, "Are you sure?"
	elseif not sure2 then
		return true, "Are you sure you're sure?"
	end
	return true, "You made the right choice."
end, [[Don't press the red button.







Don't.]])

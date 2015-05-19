maestro.command("rankadd", {"string:name", "rank:inherits", "command:multiple"}, function(caller, name, inherits, ...)
	local args = {...}
	local perms = {}
	for i = 1, #args do
		perms[args[i]] = true
	end
	maestro.rankadd(name, inherits, perms)
	return false, "added rank %1 (inheriting from %2) with access to command(s) %%"
end)
maestro.command("rankremove", {"rank"}, function(caller, rank)
	if not rank or not maestro.rankget(rank) then
		return true, "Invalid rank!"
	end
	maestro.rankremove(rank)
	return false, "removed rank %1"
end)
maestro.command("rankperms", {"rank", "command:multiple"}, function(caller, rank, ...)
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
end)
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
end)
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
end)
maestro.command("rankresetperms", {"rank"}, function(caller, rank)
	if not rank or not maestro.rankget(rank) then
		return true, "Invalid rank!"
	end
	maestro.rankresetperms(rank)
	return false, "reset command access of rank %1"
end)
maestro.command("ranksetinherits", {"rank", "rank:inherits"}, function(caller, rank, inherits)
	if not rank or not maestro.rankget(rank) then
		return true, "Invalid rank!"
	end
	maestro.ranksetinherits(rank, inherits)
	return false, "set the inheritance of rank %1 to %2"
end)
maestro.command("rankflag", {"rank", "flag", "boolean:admin"}, function(caller, rank, flag, bool)
	if not rank or not maestro.rankget(rank) then
		return true, "Invalid rank!"
	end
	maestro.rankflag(rank, flag, bool)
	return false, "set flag %2 of rank %1 to %3"
end)
maestro.command("ranksetcantarget", {"rank", "targetstring"}, function(caller, rank, str)
	if not rank or not maestro.rankget(rank) then
		return true, "Invalid rank!"
	end
	maestro.ranksetcantarget(rank, str)
	return false, "set the players rank %1 can target to %2"
end)
maestro.command("rankresetcantarget", {"rank"}, function(caller, rank)
	if not rank or not maestro.rankget(rank) then
		return true, "Invalid rank!"
	end
	maestro.rankresetcantarget(rank)
	return false, "reset the players rank %1 can target"
end)
maestro.command("ranksetpermcantarget", {"rank", "command", "targetstring"}, function(caller, rank, cmd, str)
	if not rank or not maestro.rankget(rank) then
		return true, "Invalid rank!"
	end
	maestro.ranksetpermcantarget(rank, cmd, str)
	return false, "set the players rank %1 can target with command %2 to %3"
end)
maestro.command("rankresetpermcantarget", {"rank", "command"}, function(caller, rank, cmd)
	if not rank or not maestro.rankget(rank) then
		return true, "Invalid rank!"
	end
	maestro.rankresetpermcantarget(rank, cmd)
	return false, "reset the players rank %1 can target with %2"
end)
maestro.command("rankrename", {"rank:from", "to"}, function(caller, from, to)
	if not from or not maestro.rankget(from) then
		return true, "Invalid rank!"
	end
	maestro.rankrename(from, to)
	return false, "renamed rank %1 to %2"
end)

maestro.command("userrank", {"player:target", "rank"}, function(caller, targets, rank)
	if #targets > 1 then
		return true, "Query matched more than 1 player."
	elseif #targets == 0 then
		return true, "Query matched no players."
	end
	local ply = targets[1]
	maestro.userrank(ply, rank)
	return false, "set the rank of %1 to %2"
end)
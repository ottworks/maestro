maestro.command("rankadd", {"string:name", "rank:inherits", "command:multiple"}, function(caller, name, inherits, ...)
	local args = {...}
	local perms = {}
	for i = 1, #args do
		perms[args[i]] = true
	end
	maestro.rankadd(name, inherits, perms)
	return false, "added rank %% (inheriting from %%) with access to command(s) %%"
end)
maestro.command("rankremove", {"rank"}, function(caller, rank)
	if not rank or not maestro.rankget(rank) then
		return true, "Invalid rank!"
	end
	maestro.rankremove(rank)
	return false, "removed rank %%"
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
	return false, "set commannd access of rank %% to %%"
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
	return false, "gave rank %% access to command(s) %%"
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
	return false, "revoked rank %% access to command(s) %%"
end)
maestro.command("rankresetperms", {"rank"}, function(caller, rank)
	if not rank or not maestro.rankget(rank) then
		return true, "Invalid rank!"
	end
	maestro.rankresetperms(rank)
	return false, "reset command access of rank %%"
end)
maestro.command("ranksetinherits", {"rank", "rank:inherits"}, function(caller, rank, inherits)
	if not rank or not maestro.rankget(rank) then
		return true, "Invalid rank!"
	end
	maestro.ranksetinherits(rank, inherits)
	return false, "set the inheritance of rank %% to %%"
end)
maestro.command("rankadmin", {"rank", "boolean:admin"}, function(caller, rank, bool)
	if not rank or not maestro.rankget(rank) then
		return true, "Invalid rank!"
	end
	maestro.rankadmin(rank, bool)
	return false, "set the admin status of rank %% to %%"
end)
maestro.command("ranksuperadmin", {"rank", "boolean:superadmin"}, function(caller, rank, bool)
	if not rank or not maestro.rankget(rank) then
		return true, "Invalid rank!"
	end
	maestro.ranksuperadmin(rank, bool)
	return false, "set the superadmin status of rank %% to %%"
end)
maestro.command("ranksetcantarget", {"rank", "targetstring"}, function(caller, rank, str)
	if not rank or not maestro.rankget(rank) then
		return true, "Invalid rank!"
	end
	maestro.ranksetcantarget(rank, str)
	return false, "set the players rank %% can target to %%"
end)
maestro.command("rankresetcantarget", {"rank"}, function(caller, rank)
	if not rank or not maestro.rankget(rank) then
		return true, "Invalid rank!"
	end
	maestro.rankresetcantarget(rank)
	return false, "reset the players rank %% can target"
end)
maestro.command("ranksetpermcantarget", {"rank", "command", "targetstring"}, function(caller, rank, cmd, str)
	if not rank or not maestro.rankget(rank) then
		return true, "Invalid rank!"
	end
	maestro.ranksetpermcantarget(rank, cmd, str)
	return false, "set the players rank %% can access with %% to %%"
end)
maestro.command("rankresetpermcantarget", {"rank", "command"}, function(caller, rank, cmd)
	if not rank or not maestro.rankget(rank) then
		return true, "Invalid rank!"
	end
	maestro.rankresetpermcantarget(rank, cmd)
	return false, "reset the players rank %% can access with %%"
end)

maestro.command("userrank", {"player:target", "rank"}, function(caller, targets, rank)
	if #targets > 1 then
		return true, "Query matched more than 1 player."
	elseif #targets == 0 then
		return true, "Query matched no players."
	end
	local ply = targets[1]
	maestro.userrank(ply, rank)
	return false, "set the rank of %% to %%"
end)
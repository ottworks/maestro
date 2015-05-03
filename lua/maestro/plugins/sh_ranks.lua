maestro.command("rankadd", {"name", "rank", "permissions"}, function(caller, name, inherits, ...)
	local args = {...}
	local perms = {}
	for i = 1, #args do
		perms[args[i]] = true
	end
	maestro.rankadd(name, inherits, perms)
end)
maestro.command("rankremove", {"rank"}, function(caller, rank)
	if not rank or not maestro.ranks[rank] then
		return "Invalid rank!"
	end
	maestro.rankremove(rank)
end)
maestro.command("rankperms", {"rank", "permissions"}, function(caller, rank, ...)
	if not rank or not maestro.rankget(rank) then
		return "Invalid rank!"
	end
	local args = {...}
	local perms = {}
	for i = 1, #args do
		perms[args[i]] = true
	end
	maestro.ranksetperms(rank, perms)
end)
maestro.command("rankaddperms", {"rank", "permissions"}, function(caller, rank, ...)
	if not rank or not maestro.rankget(rank) then
		return "Invalid rank!"
	end
	local args = {...}
	local perms = {}
	for i = 1, #args do
		perms[args[i]] = true
	end
	maestro.rankaddperms(rank, perms)
end)
maestro.command("rankremoveperms", {"rank", "permissions"}, function(caller, rank, ...)
	if not rank or not maestro.rankget(rank) then
		return "Invalid rank!"
	end
	local args = {...}
	local perms = {}
	for i = 1, #args do
		perms[args[i]] = true
	end
	maestro.rankremoveperms(rank, perms)
end)
maestro.command("rankresetperms", {"rank"}, function(caller, rank)
	maestro.rankresetperms(rank)
end)
maestro.command("ranksetinherits", {"rank", "rank"}, function(caller, rank, inherits)
	maestro.ranksetinherits(rank, inherits)
end)

maestro.command("userrank", {"player", "rank"}, function(caller, ply, rank)
	maestro.userrank(ply, rank)
end)
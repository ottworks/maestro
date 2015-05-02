maestro.command("setrank", {"player", "rank"}, function(caller, ply, rank)
	maestro.setrank(ply, rank)
end)
maestro.command("rank", {"name", "rank", "permissions"}, function(caller, name, inherits, ...)
	local perms = {...}
	local perms2 = {}
	for i = 1, #perms do
		perms2[perms[i]] = true
	end
	maestro.rank(name, inherits, perms2)
end)
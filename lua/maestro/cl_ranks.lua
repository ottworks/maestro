maestro.ranks = {}
net.Receive("maestro_ranks", function()
	maestro.ranks = net.ReadTable()
end)

function maestro.rankget(name)
	return maestro.ranks[name] or {}
end
 maestro.ranks = {}
 net.Receive("maestro_ranks", function()
 	maestro.ranks = net.ReadTable()
 end)
 
 function maestro.rank(name)
	return maestro.ranks[name] or {}
end
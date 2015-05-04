maestro.ranks = {}
net.Receive("maestro_ranks", function()
	local ranks = net.ReadTable()
	for rank, tab in pairs(ranks) do
		if tab.inherits and tab.inherits ~= rank then
			setmetatable(tab.perms, {__index = ranks[tab.inherits].perms})
		end
	end
	maestro.ranks = ranks
end)

function maestro.rankget(name)
	return maestro.ranks[name] or {}
end
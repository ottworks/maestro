maestro.ranks = {}
net.Receive("maestro_ranks", function()
	local ranks = net.ReadMeepTable()
	for rank, r in pairs(ranks) do
		setmetatable(r.perms, {__index = function(tab, key)
			if tab ~= maestro.ranks[r.inherits].perms then
				return maestro.ranks[r.inherits].perms[key]
			end
		end})
	end
	maestro.ranks = ranks
end)

function maestro.rankget(name)
	return maestro.ranks[name] or {}
end
function maestro.rankgetcantarget(name, str)
	return maestro.ranks[name].cantarget
end
function maestro.rankgetpermcantarget(name, perm)
	return maestro.ranks[name].perms[perm]
end

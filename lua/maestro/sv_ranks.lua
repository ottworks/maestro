local ranks = {}
util.AddNetworkString("maestro_ranks")

if not file.Exists("maestro", "DATA") then
	file.CreateDir("maestro")
end
if not file.Exists("maestro/ranks.txt", "DATA") then
	file.Write("maestro/ranks.txt", "")
end
ranks = util.JSONToTable(file.Read("maestro/ranks.txt")) or {}
for rank, tab in pairs(ranks) do
	if tab.inherits and tab.inherits ~= rank then
		setmetatable(tab.perms, {__index = ranks[tab.inherits].perms})
	end
end
function maestro.saveranks()
	file.Write("maestro/ranks.txt", util.TableToJSON(ranks))
end



function maestro.rankadd(name, inherits, perms)
	perms = perms or {}
	local r = {perms = perms, inherits = inherits}
	setmetatable(r.perms, {__index = ranks[inherits].perms})
	ranks[name] = r
	maestro.saveranks()
	for _, v in pairs(player.GetAll()) do
		maestro.sendranks(v)
	end
	maestro.saveranks()
end
function maestro.rankremove(name)
	for _, v in pairs(player.GetAll()) do
		if maestro.userrank(v) == name then
			maestro.userrank(v, ranks[name].inherits)
		end
	end
	for rank, tab in pairs(ranks) do
		if tab.inherits == name then
			maestro.ranksetinherits(rank, ranks[name].inherits)
		end
	end
	ranks[name] = nil
	maestro.saveranks()
end
function maestro.rankget(name)
	return ranks[name]
end
function maestro.ranksetperms(name, perms)
	local r = maestro.rankget(name)
	r.perms = perms
	setmetatable(r.perms, {__index = maestro.rankget(r.inherits).perms})
	maestro.saveranks()
end
function maestro.rankaddperms(name, perms)
	local r = ranks[name]
	local p = r.perms
	local newperms = {}
	newperms = table.Copy(p)
	for perm in pairs(perms) do
		newperms[perm] = true
	end
	r.perms = newperms
	setmetatable(r.perms, ranks[r.inherits].perms)
	maestro.saveranks()
end
function maestro.rankremoveperms(name, perms)
	local r = ranks[name]
	local p = r.perms
	local newperms = {}
	newperms = table.Copy(p)
	for perm in pairs(perms) do
		newperms[perm] = false
	end
	r.perms = newperms
	setmetatable(r.perms, ranks[r.inherits].perms)
	maestro.saveranks()
end
function maestro.rankresetperms(name)
	ranks[name].perms = setmetatable({}, {__index = ranks[ranks[name].inherits].perms})
	maestro.saveranks()
end
function maestro.rankgetcantarget(name, str)
	return ranks[name].cantarget
end
function maestro.ranksetcantarget(name, str)
	ranks[name].cantarget = str
	maestro.saveranks()
end
function maestro.rankresetcantarget(name, str)
	ranks[name].cantarget = ""
	maestro.saveranks()
end
function maestro.getranktable()
	return ranks
end
function maestro.ranksetinherits(name, inherits)
	local r = ranks[name]
	r.inherits = inherits
	setmetatable(r.perms, {__index = ranks[inherits].perms})
	maestro.saveranks()
end



function maestro.sendranks(ply)
	net.Start("maestro_ranks")
		net.WriteTable(ranks)
	net.Send(ply)
end
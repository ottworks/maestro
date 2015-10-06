maestro.ranks = {}
util.AddNetworkString("maestro_ranks")

function maestro.saveranks()
	maestro.save("ranks", maestro.ranks)
	maestro.broadcastranks()
end



function maestro.rankadd(name, inherits, perms)
	local r = {perms = {}, inherits = inherits, cantarget = "<^", canrank = "!>^" .. name, flags = {}}
	maestro.ranks[name] = r
	setmetatable(r.perms, {__index = function(tab, key)
		if name == "root" then return true end
		if tab ~= maestro.ranks[r.inherits].perms then
			return maestro.ranks[r.inherits].perms[key]
		end
	end})
	setmetatable(r.flags, {__index = function(tab, key)
		if tab ~= maestro.ranks[r.inherits].flags then
			return maestro.ranks[r.inherits].flags[key]
		end
	end})
	if perms then
		maestro.rankaddperms(name, perms)
	end
	if inherits then
		maestro.ranksetinherits(name, inherits)
	else
		maestro.saveranks()
	end
end
function maestro.rankremove(name)
	for _, v in pairs(player.GetAll()) do
		if maestro.userrank(v) == name then
			maestro.userrank(v, maestro.ranks[name].inherits)
		end
	end
	for rank, tab in pairs(maestro.ranks) do
		if tab.inherits == name then
			maestro.ranksetinherits(rank, maestro.ranks[name].inherits)
		end
	end
	maestro.ranks[name] = nil
	maestro.saveranks()
end
function maestro.rankget(name)
	return maestro.ranks[name] or {flags = {}, perms = {}}
end
function maestro.ranksetperms(name, perms)
	local r = maestro.rankget(name)
	r.perms = perms
	maestro.ranksetinherits(name, r.inherits)
end
function maestro.rankaddperms(name, perms)
	local r = maestro.ranks[name]
	local p = r.perms
	local newperms = {}
	newperms = table.Copy(p)
	for perm in pairs(perms) do
		local t = maestro.commands[perm]
		if t and t.cantarget then
			newperms[perm] = t.cantarget
		else
			newperms[perm] = true
		end
	end
	r.perms = newperms
	maestro.ranksetinherits(name, r.inherits)
end
function maestro.rankremoveperms(name, perms)
	local r = maestro.ranks[name]
	local p = r.perms
	local newperms = {}
	newperms = table.Copy(p)
	for perm in pairs(perms) do
		newperms[perm] = false
	end
	r.perms = newperms
	maestro.ranksetinherits(name, r.inherits)
end
function maestro.rankresetperms(name)
	maestro.ranks[name].perms = {}
	maestro.ranksetinherits(name, maestro.ranks[name].inherits)
end
function maestro.rankgettable()
	print("Deprecated function: maestro.rankgettable()")
	return maestro.ranks
end
function maestro.ranksetinherits(name, inherits)
	local r = maestro.ranks[name]
	r.inherits = inherits
	maestro.saveranks()
end
function maestro.rankflag(rank, name, bool)
	if maestro.ranks[rank] then
		maestro.ranks[rank].flags[name] = bool
	end
	maestro.saveranks()
end
function maestro.rankgetcantarget(name, str)
	return maestro.ranks[name].cantarget
end
function maestro.ranksetcantarget(name, str)
	maestro.ranks[name].cantarget = str
	maestro.saveranks()
end
function maestro.rankresetcantarget(name)
	maestro.ranks[name].cantarget = "<#" .. name
	maestro.saveranks()
end
function maestro.rankgetpermcantarget(name, perm)
	local perm = maestro.ranks[name].perms[perm]
	if perm == "true" then perm = true end
	if perm == "false" then perm = false end
	return perm
end
function maestro.ranksetpermcantarget(name, perm, str)
	maestro.ranks[name].perms[perm] = str
end
function maestro.rankresetpermcantarget(name, perm)
	maestro.ranks[name].perms[perm] = true
end
function maestro.rankgetcanrank(name, str)
	return maestro.ranks[name].canrank
end
function maestro.ranksetcanrank(name, str)
	maestro.ranks[name].canrank = str
	maestro.saveranks()
end
function maestro.rankresetcanrank(name)
	maestro.ranks[name].canrank = "!>#" .. name
	maestro.saveranks()
end
function maestro.rankrename(name, to)
	maestro.ranks[to] = maestro.ranks[name]
	for _, v in pairs(player.GetAll()) do
		if maestro.userrank(v) == name then
			maestro.userrank(v, to)
		end
	end
	for rank, tab in pairs(maestro.ranks) do
		if tab.inherits == name then
			maestro.ranksetinherits(rank, to)
		end
	end
	maestro.ranks[name] = nil
	maestro.saveranks()
end
function maestro.RESETRANKS()
	maestro.ranks = {}
	maestro.rankadd("user", "user", {help = true, who = true, msg = true, menu = true, motd = true, admin = true, tutorial = true, ranks = true})
	--forgive me padre
	maestro.rankadd("admin", "user", {kick = true, slay = true, bring = true, goto = true, tp = true, send = true, votekick = true, voteban = true, ["return"] = true, jail = true, jailtp = true, ban = true, banid = true, banlog = true, banlogid = true, gag = true, mute = true, freeze = true, god = true, noclip = true, unban = true, spectate = true, notes = true, notesid = true, note = true, noteid = true, noteremove = true, noteremoveid = true})
	maestro.rankflag("admin", "admin", true)
	maestro.rankflag("admin", "echo", true)
maestro.rankadd("superadmin", "admin", {alias = true, armor = true, chatprint = true, cloak = true, fly = true, gimp = true, gimps = true, hp = true, ignite = true, map = true, play = true, ragdoll = true, scale = true, slap = true, spawn = true, strip = true, veto = true, vote = true, announce = true, blind = true, queue = true})
	maestro.rankflag("superadmin", "superadmin", true)
	maestro.rankadd("root", "superadmin", perms)
	maestro.ranksetcantarget("root", "*")
	maestro.ranksetcanrank("root", "*")
end


function maestro.sendranks(ply)
	net.Start("maestro_ranks")
		net.WriteTable(maestro.ranks)
	net.Send(ply)
end
function maestro.broadcastranks()
	net.Start("maestro_ranks")
		net.WriteTable(maestro.ranks)
	net.Broadcast()
end

maestro.load("ranks", function(val, newfile)
	maestro.ranks = val
	for rank, r in pairs(maestro.ranks) do
		setmetatable(r.perms, {__index = function(tab, key)
			if rank == "root" then return true end
			if tab ~= maestro.ranks[r.inherits].perms then
				return maestro.ranks[r.inherits].perms[key]
			end
		end})
		setmetatable(r.flags, {__index = function(tab, key)
			if tab ~= maestro.ranks[r.inherits].flags then
				return maestro.ranks[r.inherits].flags[key]
			end
		end})
	end
	if newfile then
		maestro.hook("maestro_postpluginload", "reset", function()
			maestro.RESETRANKS()
		end)
	end
end)

local ranks = {}
util.AddNetworkString("maestro_ranks")

function maestro.saveranks()
	maestro.save("ranks", ranks)
	maestro.broadcastranks()
end



function maestro.rankadd(name, inherits, perms)
	perms = perms or {}
	local r = {perms = perms, inherits = inherits, cantarget = "<#" .. name, canrank = "!>#" .. name, flags = {}}
	ranks[name] = r
	if inherits then
		maestro.ranksetinherits(name, inherits)
	else
		maestro.saveranks()
	end
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
	return ranks[name] or {flags = {}, perms = {}}
end
function maestro.ranksetperms(name, perms)
	local r = maestro.rankget(name)
	r.perms = perms
	maestro.ranksetinherits(name, r.inherits)
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
	maestro.ranksetinherits(name, r.inherits)
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
	maestro.ranksetinherits(name, r.inherits)
end
function maestro.rankresetperms(name)
	ranks[name].perms = {}
	maestro.ranksetinherits(name, ranks[name].inherits)
end
function maestro.rankgettable()
	return ranks
end
function maestro.ranksetinherits(name, inherits)
	local r = ranks[name]
	r.inherits = inherits
	maestro.saveranks()
end
function maestro.rankflag(rank, name, bool)
	if ranks[rank] then
		ranks[rank].flags[name] = bool
	end
	maestro.saveranks()
end
function maestro.rankgetcantarget(name, str)
	return ranks[name].cantarget
end
function maestro.ranksetcantarget(name, str)
	ranks[name].cantarget = str
	maestro.saveranks()
end
function maestro.rankresetcantarget(name)
	ranks[name].cantarget = "<#" .. name
	maestro.saveranks()
end
function maestro.rankgetpermcantarget(name, perm)
	local perm = ranks[name].perms[perm]
	if perm == "true" then perm = true end
	if perm == "false" then perm = false end
	return perm
end
function maestro.ranksetpermcantarget(name, perm, str)
	ranks[name].perms[perm] = str
end
function maestro.rankresetpermcantarget(name, perm)
	ranks[name].perms[perm] = true
end
function maestro.rankgetcanrank(name, str)
	return ranks[name].canrank
end
function maestro.ranksetcanrank(name, str)
	ranks[name].canrank = str
	maestro.saveranks()
end
function maestro.rankresetcanrank(name)
	ranks[name].canrank = "!>#" .. name
	maestro.saveranks()
end
function maestro.rankrename(name, to)
	ranks[to] = ranks[name]
	for _, v in pairs(player.GetAll()) do
		if maestro.userrank(v) == name then
			maestro.userrank(v, to)
		end
	end
	for rank, tab in pairs(ranks) do
		if tab.inherits == name then
			maestro.ranksetinherits(rank, to)
		end
	end
	ranks[name] = nil
	maestro.saveranks()
end
function maestro.RESETRANKS()
	ranks = {}
	maestro.rankadd("user", "user", {help = true, who = true, msg = true, menu = true, motd = true, admin = true, tutorial = true, ranks = true})
	--forgive me padre
	maestro.rankadd("admin", "user", {kick = true, slay = true, bring = true, goto = true, tp = true, send = true, votekick = true, voteban = true, ["return"] = true, jail = true, jailtp = true, ban = true, banid = true, banlog = true, banlogid = true, gag = true, mute = true, freeze = true, god = true, noclip = true, unban = true, spectate = true, notes = true, notesid = true, note = true, noteid = true, noteremove = true, noteremoveid = true})
	maestro.rankflag("admin", "admin", true)
maestro.rankadd("superadmin", "admin", {alias = true, armor = true, chatprint = true, cloak = true, fly = true, gimp = true, gimps = true, hp = true, ignite = true, map = true, play = true, ragdoll = true, scale = true, slap = true, spawn = true, strip = true, veto = true, vote = true, announce = true, blind = true, queue = true})
	maestro.rankflag("superadmin", "superadmin", true)
	if maestro.commands.kick then
		local perms = {}
		for cmd in pairs(maestro.commands) do
			perms[cmd] = true
		end
		maestro.rankadd("root", "superadmin", perms)
	else
		maestro.hook("maestro_postpluginload", "root", function()
			local perms = {}
			for cmd in pairs(maestro.commands) do
				perms[cmd] = true
			end
			maestro.rankadd("root", "superadmin", perms)
		end)
	end
end


function maestro.sendranks(ply)
	net.Start("maestro_ranks")
		net.WriteMeepTable(ranks)
	net.Send(ply)
end
function maestro.broadcastranks()
	net.Start("maestro_ranks")
		net.WriteMeepTable(ranks)
	net.Broadcast()
end

maestro.load("ranks", function(val, newfile)
	ranks = val
	for rank, r in pairs(ranks) do
		setmetatable(r.perms, {__index = function(tab, key)
			if tab ~= ranks[r.inherits].perms then
				return ranks[r.inherits].perms[key]
			end
		end})
		setmetatable(r.flags, {__index = function(tab, key)
			if tab ~= ranks[r.inherits].flags then
				return ranks[r.inherits].flags[key]
			end
		end})
	end
	if newfile then
		maestro.RESETRANKS()
	end
end)

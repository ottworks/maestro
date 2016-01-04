maestro.ranks = {}
util.AddNetworkString("maestro_ranks")

function maestro.rankadd(name, inherits, perms)
	local r = {perms = {}, inherits = inherits, cantarget = "<^", canrank = "!>^", flags = {}, color = Color(255, 255, 255)}
	maestro.ranks[name] = r
	setmetatable(r.perms, {__index = function(tab, key)
		if name == "root" then return true end
		if not maestro.ranks[r.inherits] then return end
		if tab ~= maestro.ranks[r.inherits].perms then
			return maestro.ranks[r.inherits].perms[key]
		end
	end})
	setmetatable(r.flags, {__index = function(tab, key)
		if not maestro.ranks[r.inherits] then return end
		if tab ~= maestro.ranks[r.inherits].flags then
			return maestro.ranks[r.inherits].flags[key]
		end
	end})
	if perms then
		maestro.rankaddperms(name, perms)
	end
	if inherits then
		maestro.ranksetinherits(name, inherits)
	end

	local q = mysql:Insert("maestro_ranks")
		q:Insert("rank", name)
		q:Insert("inherits", inherits)
		q:Insert("cantarget", r.cantarget)
		q:Insert("canrank", r.canrank)
		q:Insert("color", "255 255 255")
	q:Execute()

	if CAMI.GetUsergroup(name) then return end
	if name ~= "user" and name ~= "admin" and name ~= "superadmin" then
		CAMI.RegisterUsergroup({
			Name = name,
			Inherits = inherits,
		}, "maestro")
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
	maestro.broadcastranks()
	local q = mysql:Delete("maestro_ranks")
		q:Where("rank", name)
	q:Execute()
	if name ~= "user" and name ~= "admin" and name ~= "superadmin" then
		CAMI.UnregisterUsergroup(name, "maestro")
	end
end
function maestro.rankget(name)
	return maestro.ranks[name] or {flags = {}, perms = {}}
end
function maestro.ranksetperms(name, perms)
	local r = maestro.rankget(name)
	r.perms = perms
	for k, v in pairs(perms) do
		local s = mysql:Select("maestro_perms")
			s:Where("rank", name)
			s:Where("perm", perm)
			s:Callback(function(res, status, id)
				if type(res) == "table" and #res > 0 then
					local q = mysql:Update("maestro_perms")
						q:Update("value", v)
						q:Where("rank", name)
						q:Where("perm", k)
					q:Execute()
				else
					local q = mysql:Insert("maestro_perms")
						q:Insert("rank", name)
						q:Insert("perm", k)
						q:Insert("value", v)
					q:Execute()
				end
			end)
		s:Execute()
	end
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
	for k, v in pairs(newperms) do
		local s = mysql:Select("maestro_perms")
			s:Where("rank", name)
			s:Where("perm", perm)
			s:Callback(function(res, status, id)
				if type(res) == "table" and #res > 0 then
					local q = mysql:Update("maestro_perms")
						q:Update("value", true)
						q:Where("rank", name)
						q:Where("perm", k)
					q:Execute()
				else
					local q = mysql:Insert("maestro_perms")
						q:Insert("rank", name)
						q:Insert("perm", k)
						q:Insert("value", true)
					q:Execute()
				end
			end)
		s:Execute()
	end
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
	for k, v in pairs(perms) do
		local s = mysql:Select("maestro_perms")
			s:Where("rank", name)
			s:Where("perm", perm)
			s:Callback(function(res, status, id)
				if type(res) == "table" and #res > 0 then
					local q = mysql:Update("maestro_perms")
						q:Update("value", false)
						q:Where("rank", name)
						q:Where("perm", k)
					q:Execute()
				else
					local q = mysql:Insert("maestro_perms")
						q:Insert("rank", name)
						q:Insert("perm", k)
						q:Insert("value", false)
					q:Execute()
				end
			end)
		s:Execute()
	end
	maestro.ranksetinherits(name, r.inherits)
end
function maestro.rankresetperms(name)
	maestro.ranks[name].perms = {}
	local q = mysql:Delete("maestro_perms")
		q:Where("rank", name)
	q:Execute()
	maestro.ranksetinherits(name, maestro.ranks[name].inherits)
end
function maestro.rankgettable()
	print("Deprecated function: maestro.rankgettable()")
	return maestro.ranks
end
function maestro.ranksetinherits(name, inherits)
	local r = maestro.ranks[name]
	r.inherits = inherits
	local q = mysql:Update("maestro_ranks")
		q:Update("inherits", inherits)
		q:Where("rank", name)
	q:Execute()
	maestro.broadcastranks()
end
function maestro.rankflag(rank, name, bool)
	if maestro.ranks[rank] then
		maestro.ranks[rank].flags[name] = bool
		local s = mysql:Select("maestro_flags")
			s:Where("rank", name)
			s:Where("flag", name)
			s:Callback(function(res, status, id)
				if type(res) == "table" and #res > 0 then
					local q = mysql:Update("maestro_flags")
						q:Update("value", bool)
						q:Where("rank", rank)
						q:Wherew("flag", name)
					q:Execute()
				else
					local q = mysql:Insert("maestro_flags")
						q:Insert("rank", rank)
						q:Insert("flag", name)
						q:Insert("value", bool)
					q:Execute()
				end
			end)
		s:Execute()
	end
	maestro.broadcastranks()
end
function maestro.rankgetcantarget(name, str)
	return maestro.rankget(name).cantarget
end
function maestro.ranksetcantarget(name, str)
	maestro.ranks[name].cantarget = str
	local q = mysql:Update("maestro_ranks")
		q:Update("cantarget", str)
		q:Where("rank", name)
	q:Execute()
	maestro.broadcastranks()
end
function maestro.rankresetcantarget(name)
	maestro.ranks[name].cantarget = "<^"
	local q = mysql:Update("maestro_ranks")
		q:Update("cantarget", str)
		q:Where("rank", name)
	q:Execute()
	maestro.broadcastranks()
end
function maestro.rankgetpermcantarget(name, perm)
	local perm = maestro.rankget(name).perms[perm]
	if perm == "true" then perm = true end
	if perm == "false" then perm = false end
	return perm
end
function maestro.ranksetpermcantarget(name, perm, str)
	maestro.ranks[name].perms[perm] = str
	local q = mysql:Update("maestro_perms")
		q:Update("value", str)
		q:Where("rank", name)
		q:Where("perm", perm)
	q:Execute()
	maestro.broadcastranks()
end
function maestro.rankresetpermcantarget(name, perm)
	maestro.ranks[name].perms[perm] = true
	local q = mysql:Update("maestro_perms")
		q:Update("value", true)
		q:Where("rank", name)
		q:Where("perm", perm)
	q:Execute()
	maestro.broadcastranks()
end
function maestro.rankgetcanrank(name, str)
	return maestro.ranks[name].canrank
end
function maestro.ranksetcanrank(name, str)
	maestro.ranks[name].canrank = str
	local q = mysql:Update("maestro_ranks")
		q:Update("canrank", str)
		q:Where("rank", name)
	q:Execute()
	maestro.broadcastranks()
end
function maestro.rankresetcanrank(name)
	maestro.ranks[name].canrank = "!>^"
	local q = mysql:Update("maestro_ranks")
		q:Update("canrank", "!>^")
		q:Where("rank", name)
	q:Execute()
	maestro.broadcastranks()
end
function maestro.rankrename(name, to)
	maestro.ranks[to] = maestro.ranks[name]
	for _, v in pairs(player.GetAll()) do
		if maestro.userrank(v) == name then
			maestro.userrank(v, to)
		end
	end
	local q = mysql:Update("maestro_users")
		q:Update("rank", to)
		q:Where("rank", name)
	q:Execute()
	for rank, tab in pairs(maestro.ranks) do
		if tab.inherits == name then
			maestro.ranksetinherits(rank, to)
		end
	end
	maestro.ranks[name] = nil
	local q = mysql:Update("maestro_ranks")
		q:Update("inherits", to)
		q:Where("inherits", name)
	q:Execute()
	maestro.broadcastranks()
end
function maestro.rankcolor(name, r, g, b)
	if not r then return maestro.ranks[name].color end
	maestro.ranks[name].color = Color(r, g, b)
	local q = mysql:Update("maestro_ranks")
		q:Where("rank", name)
		q:Update("color", string.format("%03d %03d %03d", r, g, b))
	q:Execute()
end
function maestro.RESETRANKS()
	maestro.ranks = {}
	local q = mysql:Delete("maestro_ranks")
	q:Execute()
	local q = mysql:Delete("maestro_flags")
	q:Execute()
	local q = mysql:Delete("maestro_perms")
	q:Execute()
	maestro.rankadd("user", "user", {help = true, who = true, msg = true, menu = true, motd = true, admin = true, tutorial = true, ranks = true})
	--forgive me padre
	maestro.rankadd("admin", "user", {kick = true, slay = true, bring = true, goto = true, tp = true, send = true, votekick = true, voteban = true, ["return"] = true, jail = true, jailtp = true, ban = true, banid = true, banlog = true, banlogid = true, gag = true, mute = true, freeze = true, god = true, noclip = true, unban = true, spectate = true, notes = true, notesid = true, note = true, noteid = true, noteremove = true, noteremoveid = true, sethome = true, home = true, voteclean = true})
	maestro.rankflag("admin", "admin", true)
	maestro.rankflag("admin", "echo", true)
maestro.rankadd("superadmin", "admin", {alias = true, armor = true, chatprint = true, cloak = true, fly = true, gimp = true, gimps = true, hp = true, ignite = true, map = true, play = true, ragdoll = true, scale = true, slap = true, spawn = true, strip = true, veto = true, vote = true, announce = true, blind = true, queue = true, give = true})
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

hook.Add("CAMI.OnUsergroupRegistered", "maestro", function(name, source)
	if source ~= "maestro" then
		maestro.rankadd(name.Name)
	end
end)
hook.Add("CAMI.OnUsergroupUnregistered", "maestro", function(name, source)
	if source ~= "maestro" then
		maestro.rankremove(name.Name)
	end
end)
hook.Add("CAMI.PlayerHasAccess", "maestro", function(ply, name, callback, target, extra)

	if maestro.rankget(maestro.userrank(ply)).perms[name] ~= nil then
		if (extra and extra.IgnoreImmunity) or not target then
			callback(maestro.rankget(maestro.userrank(ply)).perms[name], "maestro")
			return true
		end
		local _, plys = maestro.target("$" .. target:EntIndex(), ply, name)
		if plys[target] then
			callback(true, "maestro")
			return true
		end
	end
end)

local function bool(str)
	if str == "true" then return true end
	if str == "false" then return false end
	if tonumber(str) == 1 then return true end
	if tonumber(str) == 0 then return false end
	return str
end
maestro.hook("DatabaseConnected", "ranks", function()
	local q = mysql:Create("maestro_ranks")
        q:Create("rank", "VARCHAR(255) NOT NULL")
        q:Create("inherits", "VARCHAR(255) NOT NULL")
        q:Create("cantarget", "VARCHAR(255) NOT NULL")
        q:Create("canrank", "VARCHAR(255) NOT NULL")
		q:Create("color", "VARCHAR(11) NOT NULL")
        q:PrimaryKey("rank")
    q:Execute()
    local q = mysql:Create("maestro_perms")
        q:Create("id", "INT NOT NULL AUTO_INCREMENT");
        q:Create("rank", "VARCHAR(255) NOT NULL")
        q:Create("perm", "VARCHAR(255) NOT NULL")
        q:Create("value", "VARCHAR(255) NOT NULL")
        q:PrimaryKey("id")
    q:Execute()
    local q = mysql:Create("maestro_flags")
        q:Create("id", "INT NOT NULL AUTO_INCREMENT");
        q:Create("rank", "VARCHAR(255) NOT NULL")
        q:Create("flag", "VARCHAR(255) NOT NULL")
        q:Create("value", "BOOLEAN NOT NULL")
        q:PrimaryKey("id")
    q:Execute()

	local q = mysql:Select("maestro_ranks")
		q:Callback(function(res, status, id)
			if type(res) == "table" and #res > 0 then
				for i = 1, #res do
					local tab = res[i]
					local name = tab.rank
					local r = {perms = {}, inherits = tab.inherits, cantarget = tab.cantarget, canrank = tab.canrank, flags = {}}
					r.color = Color(string.match(tab.color or "255 255 255", "(%d%d%d)[%s%S](%d%d%d)[%s%S](%d%d%d)"))
					setmetatable(r.perms, {__index = function(tab, key)
						if name == "root" then return true end
						if not maestro.ranks[r.inherits] then return end
						if tab ~= maestro.ranks[r.inherits].perms then
							return maestro.ranks[r.inherits].perms[key]
						end
					end})
					setmetatable(r.flags, {__index = function(tab, key)
						if not maestro.ranks[r.inherits] then return end
						if tab ~= maestro.ranks[r.inherits].flags then
							return maestro.ranks[r.inherits].flags[key]
						end
					end})
					local q = mysql:Select("maestro_perms")
						q:Where("rank", name)
						q:Callback(function(res, status, id)
							if type(res) ~= "table" then return end
							for j = 1, #res do
								local p = res[j]
								r.perms[p.perm] = bool(p.value)
							end
						end)
					q:Execute()
					local q = mysql:Select("maestro_flags")
						q:Where("rank", name)
						q:Callback(function(res, status, id)
							if type(res) ~= "table" then return end
							for j = 1, #res do
								local f = res[j]
								r.flags[f.flag] = bool(f.value)
							end
						end)
					q:Execute()
					maestro.ranks[name] = r
				end
			else
				print("No ranks found! Resetting.")
				maestro.RESETRANKS()
			end
		end)
	q:Execute()
	timer.Simple(1, function()
		for k, v in pairs(CAMI.GetUsergroups()) do
			if maestro.ranks[v.Name] then continue end
			maestro.rankadd(v.Name, v.Inherits)
		end
	end)
end)

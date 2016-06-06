local function traversedown(rank, val)
	if rank == val then
		return true
	elseif not rank then
		return false
	end
	if rank ~= "user" then
		return traversedown(maestro.rankget(rank).inherits, val)
	end
end
local function inverse(t1, t2)
	local ret = {}
	for k in pairs(t1) do
		ret[k] = true
	end
	for k in pairs(t2) do
		ret[k] = (not ret[k]) or nil
	end
	return ret
end
local function toLookup(tab)
	local ret = {}
	for k, v in pairs(tab) do
		ret[v] = true
	end
	return ret
end
local function toSequence(tab)
	local ret = {}
	for k in pairs(tab) do
		ret[#ret + 1] = k
	end
	return ret
end
local function intersect(t1, t2)
	local ret = {}
	for k in pairs(t1) do
		if t2[k] then
			ret[k] = true
		end
	end
	return ret
end
local function escape(str)
	return string.gsub(str, "([%(%)%.%%%+%-%*%?%[%^%$])", "%%%1")
end

function maestro.target(val, ply, cmd)
	if not val then return {} end
	local magic = "!*^$#<>@"
	local cursor = 1
	local s = string.sub(val, 1, 1)
	local cnot = false
	local all = false
	local self = false
	local id = false
	local group = false
	local greater = false
	local less = false
	local picker = false
	while magic:find(escape(s)) and #s > 0 do
		if s == "!" then
			cnot = not cnot
		elseif s == "*" then
			all = true
		elseif s == "^" then
			self = true
		elseif s == "$" then
			id = true
		elseif s == "#" then
			group = true
		elseif s == "<" then
			less = true
		elseif s == ">" then
			greater = true
		elseif s == "@" then
			picker = true
		end
		cursor = cursor + 1
		s = string.sub(val, cursor, cursor)
	end
	local name = string.sub(val, cursor)
	local ret = {}
	if all then
		ret = toLookup(player.GetAll())
	elseif id then
		ret[player.GetBySteamID(name) or player.GetBySteamID64(name) or player.GetByID(name)] = true
	elseif picker and ply then
		local tr = util.TraceLine{
			start = ply:GetShootPos(),
			endpos = ply:GetShootPos() + ply:EyeAngles():Forward() * 1024,
			filter = function(ent)
				return ent:GetClass() ~= "Player"
			end,
		}
		if IsValid(tr.Entity) and tr.Entity:IsPlayer() then
			ret[tr.Entity] = true
		end
	elseif less or greater then
		if self then
			name = maestro.userrank(ply)
		end
		local ranks = {}
		for rank, tab in pairs(maestro.ranks) do
			if less then
				if not traversedown(rank, name) then
					ranks[rank] = true
				end
			elseif greater then
				if traversedown(rank, name) and rank ~= name then
					ranks[rank] = true
				end
			end
		end
		for _, ply in pairs(player.GetAll()) do
			if ranks[maestro.userrank(ply)] then
				ret[ply] = true
			end
		end
	elseif group and self then
		for _, v in pairs(player.GetAll()) do
			if maestro.userrank(v) == maestro.userrank(ply) then
				ret[v] = true
			end
		end
	elseif group then
		for _, ply in pairs(player.GetAll()) do
			if maestro.userrank(ply) == name then
				ret[ply] = true
			end
		end
	elseif self then
		if IsValid(ply) then
			ret[ply] = true
		end
	else
		for _, v in pairs(player.GetAll()) do
			if v:Nick():lower():find(escape(name):lower()) then
				ret[v] = true
			end
		end
	end
	if cnot then
		ret = inverse(ret, toLookup(player.GetAll()))
	end
	if ply and cmd then
		local perm = maestro.rankgetpermcantarget(maestro.userrank(ply), cmd)
		local ct = maestro.rankgetcantarget(maestro.userrank(ply))
		if perm ~= true and perm ~= "true" then
			local tab2 = toLookup(maestro.target(perm, ply))
			tab2[ply] = true
			ret = intersect(ret, tab2)
		elseif ct then
			local tab2 = toLookup(maestro.target(ct, ply))
			tab2[ply] = true
			ret = intersect(ret, tab2)
		end
	end
	return toSequence(ret), ret
end

function maestro.targetrank(val, plyrank)
	if not val then return false end
	local magic = "!*^$#<>"
	local cursor = 1
	local s = string.sub(val, 1, 1)
	local cnot = false
	local all = false
	local self = false
	local id = false
	local group = false
	local greater = false
	local less = false
	while magic:find(escape(s)) and #s > 0 do
		if s == "!" then
			cnot = not cnot
		elseif s == "*" then
			all = true
		elseif s == "^" then
			self = true
		elseif s == "$" then
			id = true
		elseif s == "#" then
			group = true
		elseif s == "<" then
			less = true
		elseif s == ">" then
			greater = true
		end
		cursor = cursor + 1
		s = string.sub(val, cursor, cursor)
	end
	local name = string.sub(val, cursor)
	local ret = {}
	if all then
		for rank in pairs(maestro.ranks) do
			ret[rank] = true
		end
	elseif greater then
		if self then
			name = plyrank
		end
		for rank, tab in pairs(maestro.ranks) do
			if traversedown(rank, name) and rank ~= name then
				ret[rank] = true
			end
		end
	elseif less then
		if self then
			name = plyrank
		end
		for rank, tab in pairs(maestro.ranks) do
			if not traversedown(rank, name) then
				ret[rank] = true
			end
		end
	elseif self then
		if IsValid(plyrank) then
			ret[plyrank] = true
		end
	elseif group then
		ret[name] = true
	else
		ret[name] = true
	end
	if cnot then
		ret = inverse(ret, maestro.ranks)
	end
	return ret
end

function maestro.split(input, keepq)
	input = " " .. input .. " "
	local cursor = 0
	local quote = false
	local word = false
	local out = {}
	while cursor < #input do
		local a, b
		if not quote and not word then
			a, b = input:find("%s+%S", cursor)
			if a then
				cursor = a
				local t = input:sub(b, b)
				if t == "\"" or t == "”" then
					quote = b
				else
					word = b
				end
			end
		elseif quote then
			a, b = input:find("\"%s", cursor)
			if a then
				cursor = a
				if keepq then
					table.insert(out, input:sub(quote, a))
				else
					table.insert(out, input:sub(quote + 1, a - 1))
				end
				quote = false
			end
		else
			a, b = input:find("[^%s\"]%s", cursor)
			if a then
				cursor = a
				table.insert(out, input:sub(word, a))
				word = false
			end
		end
		cursor = cursor + 1
	end
	if quote or word then
		table.insert(out, input:sub(word or (quote + 1)))
	end
	if #out > 0 then
		if input:sub(-2) == "  " then
			table.insert(out, "")
		end
	end
	return out
end

function maestro.cantargetid(id1, id2, cmd)
	local r1 = maestro.userrank(id1)
	local perm = maestro.rankgetpermcantarget(r1, cmd)
	local ct = maestro.rankgetcantarget(r1)
	if type(perm) == "string" then
		ct = perm
	end
	local ranks = maestro.targetrank(ct, r1)
	return ranks[maestro.userrank(id2)]
end

local function traversedown(rank, val)
	print("traversing", rank, val)
	if rank == val then
		return true
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
local function escape(str)
	return string.gsub(str, "([%(%)%.%%%+%-%*%?%[%^%$])", "%%%1")
end
local function getByName(name)
	for _, v in pairs(player.GetAll()) do
		if v:Nick():lower():find(escape(name:lower())) then
			return v
		end
	end
end

function maestro.target(val, ply)
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
	while magic:find(escape(s)) do
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
		ret = toLookup(player.GetAll())
	elseif self then
		ret[ply] = true
	elseif id then
		ret[player.GetBySteamID(name) or player.GetBySteamID64(name) or player.GetByID(name)] = true
	elseif group then
		for _, ply in pairs(player.GetAll()) do
			if maestro.userrank(ply) == name then
				ret[ply] = true
			end
		end
	elseif greater then
		local ranks = {}
		for rank, tab in pairs(maestro.getranktable()) do
			if traversedown(rank, name) and rank ~= name then
				ranks[rank] = true
			end
		end
		for _, ply in pairs(player.GetAll()) do
			if ranks[maestro.userrank(ply)] then
				ret[ply] = true
			end
		end
	elseif less then
		local ranks = {}
		for rank, tab in pairs(maestro.getranktable()) do
			if not traversedown(rank, name) then
				ranks[rank] = true
			end
		end
		for _, ply in pairs(player.GetAll()) do
			if ranks[maestro.userrank(ply)] then
				ret[ply] = true
			end
		end
	elseif getByName(name) then
		ret[getByName(name)] = true
	end
	if cnot then
		ret = inverse(ret, player.GetAll())
	end
	return toSequence(ret)
end
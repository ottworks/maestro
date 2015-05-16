maestro.commands = maestro.commands or {}

local function command(ply, cmd, args, str)
	net.Start("maestro_cmd")
		net.WriteUInt(#args, 8)
		for i = 1, #args do
			net.WriteString(args[i])
		end
	net.SendToServer()
end
local function escape(str)
	return string.gsub(str, "([%(%)%.%%%+%-%*%?%[%^%$])", "%%%1")
end
local function autocomplete(_, str)
	str = string.sub(str, 2, -1)
	local args = maestro.split(str)
	local t = {}
	if #args == 0 then
		for k, v in pairs(maestro.commands) do
			if maestro.rankget(maestro.userrank(LocalPlayer())).perms[k] then
				table.insert(t, "ms " .. k)
			end
		end
	elseif #args == 1 then
		for k, v in pairs(maestro.commands) do
			if maestro.rankget(maestro.userrank(LocalPlayer())).perms[k] then
				if string.sub(k, 1, #args[1]):lower() == args[1]:lower() then
					table.insert(t, "ms " .. k)
				end
			end
		end
	else
		local cmd, types
		for k, v in pairs(maestro.commands) do
			if k:lower() == args[1]:lower() then
				cmd = k
				types = v
			end
		end
		local params = table.Copy(args)
		table.remove(params, 1)
		if cmd then
			local cnct = table.concat(args, " ", 2, #args - 1)
			cnct = " " .. cnct .. " "
			cnct = cnct:gsub("%s+", " ")
			local typ = string.match(types[#params] or types[#types], "[^:]+")
			if typ == "player" then
				local plys = maestro.target(params[#params], LocalPlayer(), cmd)
				for i = 1, #plys do
					table.insert(t, "ms " .. cmd .. cnct .. "\"" .. plys[i]:Nick() .. "\"")
				end
			elseif typ == "boolean" then
				table.insert(t, "ms " .. cmd .. cnct .. "true")
				table.insert(t, "ms " .. cmd .. cnct .. "false")
			elseif typ == "rank" then
				local ranks = {}
				local cr = maestro.rankget(maestro.userrank(LocalPlayer())).canrank
				if cr then
					ranks = maestro.targetrank(cr, ply)
				end
				for rank in pairs(ranks) do
					if string.sub(rank, 1, #args[#args]):lower() == args[#args]:lower() then
						table.insert(t, "ms " .. cmd .. cnct .. rank)
					end
				end
			elseif typ == "command" then
				for cmd2 in pairs(maestro.commands) do
					if string.sub(cmd2, 1, #args[#args]):lower() == args[#args]:lower() then
						table.insert(t, "ms " .. cmd .. cnct .. cmd2)
					end
				end
			elseif types[#params] then
				table.insert(t, "ms " .. cmd .. cnct .. "<" .. types[#params] .. ">")
			end
		end
	end
	table.sort(t)
	return t
end
concommand.Add("ms", command, autocomplete, nil, FCVAR_USERINFO)
net.Receive("maestro_commands", function()
	maestro.commands = net.ReadTable()
end)


function maestro.command(cmd, args)
	maestro.commands[cmd] = args
end
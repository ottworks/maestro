maestro.commands = maestro.commands or {}

local function command(ply, cmd, args, str)
	net.Start("maestro_cmd")
		net.WriteUInt(#args, 8)
		for i = 1, #args do
			net.WriteString(args[i])
		end
		net.WriteBool(false)
	net.SendToServer()
end
local function command2(ply, cmd, args, str)
	net.Start("maestro_cmd")
		net.WriteUInt(#args, 8)
		for i = 1, #args do
			net.WriteString(args[i])
		end
		net.WriteBool(true)
	net.SendToServer()
end
local function escape(str)
	return string.gsub(str, "([%(%)%.%%%+%-%*%?%[%^%$])", "%%%1")
end
local function autocomplete(base, str)
	base = base .. " "
	str = string.sub(str, 2, -1)
	local args = maestro.split(str)
	local t = {}
	if #args == 0 then
		for k, v in pairs(maestro.commands) do
			if maestro.rankget(maestro.userrank(LocalPlayer())).perms[k] then
				table.insert(t, base .. k)
			end
		end
	elseif #args == 1 then
		for k, v in pairs(maestro.commands) do
			if maestro.rankget(maestro.userrank(LocalPlayer())).perms[k] then
				if string.sub(k, 1, #args[1]):lower() == args[1]:lower() then
					table.insert(t, base .. k)
				end
			end
		end
	else
		local cmd, types
		for k, v in pairs(maestro.commands) do
			if k:lower() == args[1]:lower() then
				cmd = k
				types = v.args
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
					table.insert(t, base .. cmd .. cnct .. "\"" .. plys[i]:Nick() .. "\"")
				end
			elseif typ == "boolean" then
				local options = {"true", "false", "t", "f", "1", "0", "yes", "no"}
				for i = 1, #options do
					if string.sub(options[i], 1, #args[#args]):lower() == args[#args]:lower() then
						table.insert(t, base .. cmd .. cnct .. options[i])
					end
				end
			elseif typ == "rank" then
				local ranks = {}
				local cr = maestro.rankget(maestro.userrank(LocalPlayer())).canrank
				if cr then
					ranks = maestro.targetrank(cr, ply)
				end
				for rank in pairs(ranks) do
					if string.sub(rank, 1, #args[#args]):lower() == args[#args]:lower() then
						table.insert(t, base .. cmd .. cnct .. rank)
					end
				end
			elseif typ == "command" then
				for cmd2 in pairs(maestro.commands) do
					if string.sub(cmd2, 1, #args[#args]):lower() == args[#args]:lower() then
						table.insert(t, base .. cmd .. cnct .. cmd2)
					end
				end
			elseif typ == "sound" then
				local input = tostring(args[#args])
				input = input:gsub("\\", "/")
				input = input:gsub("%.%.", "")
				local path, name = input:match("(.*/)([^/]*)$")
				path = path or ""
				name = name or input
				local files, folders = file.Find("sound/" .. input .. "*", "GAME")
				if files and folders then
					for i = 1, #files do
						table.insert(t, base .. cmd .. cnct .. path .. files[i])
					end
					for i = 1, #folders do
						if folders[i]:sub(1, #name) == name then
							table.insert(t, base .. cmd .. cnct .. path .. folders[i])
						end
					end
				end
			elseif typ == "style" then
				local options = {"primary", "success", "info", "warning", "danger"}
				for i = 1, #options do
					if string.sub(options[i], 1, #args[#args]):lower() == args[#args]:lower() then
						table.insert(t, base .. cmd .. cnct .. options[i])
					end
				end
			elseif types[#params] then
				table.insert(t, base .. cmd .. cnct .. "<" .. types[#params] .. ">")
			end
		end
	end
	table.sort(t)
	return t
end
concommand.Add("ms", command, autocomplete, nil, FCVAR_USERINFO)
concommand.Add("mss", command2, autocomplete, nil, FCVAR_USERINFO)
net.Receive("maestro_commands", function()
	maestro.commands = net.ReadMeepTable()
end)


function maestro.command(cmd, args, func, help)
	maestro.commands[cmd] = {args = args, help = help}
end

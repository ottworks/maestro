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
	local args = string.Explode("%s+", str, true)
	local t = {}
	if #args == 1 then
		for k, v in pairs(maestro.commands) do
			if string.sub(k, 1, #args[1]):lower() == args[1]:lower() then
				table.insert(t, "ms " .. k)
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
			if types[#params] == "player" then
				for _, v in pairs(player.GetAll()) do
					if v:Nick():lower():find(escape(params[#params])) then
						table.insert(t, "ms " .. cmd .. cnct .. "\"" .. v:Nick() .. "\"")
					end
				end
			elseif types[#params] then
				table.insert(t, "ms " .. cmd .. cnct .. "<" .. types[#params] .. ">")
			end
		end
	end
	return t
end
concommand.Add("ms", command, autocomplete, nil, FCVAR_USERINFO)
net.Receive("maestro_commands", function()
	maestro.commands = net.ReadTable()
end)


function maestro.command(cmd, args)
	maestro.commands[cmd] = args
end
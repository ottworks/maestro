maestro.commands = maestro.commands or {}

local function command(ply, cmd, args, str)
	net.Start("maestro_cmd")
		net.WriteUInt(#args, 8)
		for i = 1, #args do
			net.WriteString(args[i])
		end
	net.SendToServer()
end
local function autocomplete(_, args)
	args = string.sub(args, 2, -1)
	args = string.lower(args)
	args = string.Explode("%s", args, true)
	PrintTable(args)
	local t = {}
	if #args == 1 then
		for k, v in pairs(maestro.commands) do
			if string.sub(k, 1, #args[1]):lower() == args[1] then
				table.insert(t, "ms " .. k)
			end
		end
	else
		local cmd, types
		for k, v in pairs(maestro.commands) do
			if k:lower() == args[1] then
				cmd = k
				types = v
			end
		end
		if cmd then
			if types[#args - 1] == "player" then
				for _, v in pairs(player.GetAll()) do
					if v:Nick():lower():find(args[#args]) then
						table.insert(t, "ms " .. cmd .. " \"" .. v:Nick() .. "\"")
					end
				end
			elseif types[#args - 1] then
				table.insert(t, "ms " .. cmd .. " <" .. types[#args - 1] .. ">")
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
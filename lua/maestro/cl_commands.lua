maestro.commands = {}
local function command(ply, cmd, args, str)
	net.Start("maestro_cmd")
		net.WriteUInt(#args, 8)
		for i = 1, #args do
			net.WriteString(args[i])
		end
	net.SendToServer()
end
local function autocomplete(cmd, args)
	args = string.lower(args)
	local t = {}
	for k, v in pairs(maestro.commands) do
		if string.sub(k, 1, #args):lower() == args then
			table.insert(t, "ms " .. k)
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
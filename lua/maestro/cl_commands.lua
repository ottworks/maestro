maestro.commands = maestro.commands or {}
maestro.commandaliases = maestro.commandaliases or {}

local function command(ply, cmd, args2, str)
	local args = maestro.split(str)
	net.Start("maestro_cmd")
		net.WriteUInt(#args, 8)
		for i = 1, #args do
			net.WriteString(args[i])
		end
		net.WriteBool(false)
	net.SendToServer()
end
local function command2(ply, cmd, args2, str)
	local args = maestro.split(str)
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

concommand.Add("ms", command, maestro.autocomplete, nil, FCVAR_USERINFO)
concommand.Add("mss", command2, maestro.autocomplete, nil, FCVAR_USERINFO)
net.Receive("maestro_commands", function()
	maestro.commands = net.ReadTable()
end)


function maestro.command(cmd, args, func, help)
	for name, tab in pairs(maestro.commands) do
		if tab.serversidecallback == func and name ~= cmd then
			maestro.commandaliases[cmd] = name
			return
		end
	end
	maestro.commands[cmd] = {args = args, help = help, serversidecallback = func}
end

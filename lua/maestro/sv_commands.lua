maestro.commands = maestro.commands or {}

util.AddNetworkString("maestro_commands")
util.AddNetworkString("maestro_cmd")
function maestro.sendcommands(ply)
	net.Start("maestro_commands")
		net.WriteTable(maestro.commands)
	net.Send(ply)
end

player.GetBySteamID = player.GetBySteamID or function()
	return false
end
player.GetBySteamID64 = player.GetBySteamID64 or function()
	return false
end

local function convertTo(val, t, ply, cmd)
	if t == "player" then
		return maestro.target(val, ply, cmd)
	elseif t == "number" then
		return tonumber(val)
	elseif t == "boolean" then
		return val == "true"
	end
	return val
end

local function runcmd(cmd, args, ply)
	for i = 1, #args do
		args[i] = convertTo(args[i], string.match(maestro.commands[cmd].args[i] or "", "[^:]+"), ply, cmd)
	end
	local ret = maestro.commands[cmd].callback(ply, unpack(args))
	if ret and IsValid(ply) then
		ply:ChatPrint(cmd .. ": " .. ret)
	elseif ret then
		print(cmd .. ": " .. ret)
	end
end

net.Receive("maestro_cmd", function(len, ply)
	local num = net.ReadUInt(8)
	local cmd = string.lower(net.ReadString())
	if maestro.commands[cmd] then
		if maestro.rankget(maestro.userrank(ply)).perms[cmd] then
			local args = {}
			for i = 1, num - 1 do
				args[i] = net.ReadString()
			end
			runcmd(cmd, args, ply)
		else
			ply:ChatPrint(cmd .. ": Insufficient permissions!")
		end
	else
		ply:ChatPrint("Unrecognized command: " .. cmd)
	end
end)

function maestro.command(cmd, args, callback)
	for k, arg in pairs(args) do
		args[k] = string.gsub(arg, "%s", "_")
	end
	maestro.commands[cmd] = {args = args, callback = callback}
end

concommand.Add("ms", function(ply, cmd, args, str)
	local cmd = args[1]
	table.remove(args, 1)
	runcmd(cmd, args)
end)
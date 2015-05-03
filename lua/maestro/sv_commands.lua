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

local function convertTo(val, t, ply)
	if t == "player" then
		return maestro.target(val, ply)
	elseif t == "number" then
		return tonumber(val)
	end
	return val
end

local function runcmd(cmd, args, ply)
	for i = 1, #args do
		args[i] = convertTo(args[i], maestro.commands[cmd].args[i], ply)
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
	end
end)

function maestro.command(cmd, args, callback)
	maestro.commands[cmd] = {args = args, callback = callback}
end

concommand.Add("ms", function(ply, cmd, args, str)
	local cmd = args[1]
	table.remove(args, 1)
	runcmd(cmd, args)
end)
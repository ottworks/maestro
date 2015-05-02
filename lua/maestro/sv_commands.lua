maestro.commands = maestro.commands or {}

util.AddNetworkString("maestro_commands")
util.AddNetworkString("maestro_cmd")
function maestro.sendcommands(ply)
	net.Start("maestro_commands")
		net.WriteTable(maestro.commands)
	net.Send(ply)
end

local function getByName(name)
	for _, v in pairs(player.GetAll()) do
		if v:Nick():lower():find(name:lower()) then
			return v
		end
	end
end

local function convertTo(val, t)
	if t == "player" then
		return (player.GetBySteamID and player.GetBySteamID(val)) or getByName(val)
	elseif t == "number" then
		return tonumber(val)
	end
	return val
end

local function runcmd(cmd, args, ply)
	for i = 1, #args do
		args[i] = convertTo(args[i], maestro.commands[cmd].args[i])
	end
	local ret = maestro.commands[cmd].callback(ply, unpack(args))
	if ret and IsValid(ply) then
		ply:ChatPrint("ms " .. cmd .. ": " .. ret)
	end
end

net.Receive("maestro_cmd", function(len, ply)
	local num = net.ReadUInt(8)
	local cmd = net.ReadString()
	if maestro.commands[cmd] then
		if maestro.rank(maestro.getrank(ply)).perms[cmd] then
			local args = {}
			for i = 1, num - 1 do
				args[i] = net.ReadString()
			end
			runcmd(cmd, args, ply)
		else
			ply:ChatPrint("ms " .. cmd .. ": Insufficient permissions!")
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
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
	local err, msg = maestro.commands[cmd].callback(ply, unpack(args))
	if err and IsValid(ply) then
		maestro.chat(ply, Color(255, 154, 27),  cmd .. ": " .. msg)
	elseif err then
		MsgC(Color(255, 154, 27), cmd .. ": " .. msg .. "\n")
	elseif msg then
		local t = string.Explode("%%", msg .. " ")
		local ret = {ply or "(Console)", " "}
		for i = 1, #t do
			if i ~= 1 then
				local a = args[i - 1]
				if a then
					if type(a) == "table" then
						table.insert(ret, a[1])
						for i = 2, #a do
							table.insert(ret, ", ")
							table.insert(ret, a[i])
						end
					else
						table.insert(ret, Color(78, 196, 255))
						table.insert(ret, tostring(a))
					end
				end
			end
			table.insert(ret, Color(255, 255, 255))
			table.insert(ret, t[i])
		end
		if #args > #t - 1 then
			table.remove(ret, #ret)
			for i = #t, #args do
				table.insert(ret, Color(255, 255, 255))
				table.insert(ret, ", ")
				table.insert(ret, Color(78, 196, 255))
				table.insert(ret, args[i])
			end
		end
		maestro.chat(ply, unpack(ret))
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
			maestro.chat(ply, Color(255, 154, 27),  cmd .. ": Insufficient permissions!")
		end
	else
		maestro.chat(ply, Color(255, 154, 27), "Unrecognized command: " .. cmd)
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

hook.Add("PlayerSay", "maestro_command", function(ply, txt)
	if txt:sub(1, 1) == "!" then
		txt = txt:sub(2)
		local args = maestro.split(txt)
		local cmd = args[1]
		table.remove(args, 1)
		if maestro.commands[cmd] then
			if maestro.rankget(maestro.userrank(ply)).perms[cmd] then
				runcmd(cmd, args, ply)
			else
				ply:ChatPrint(cmd .. ": Insufficient permissions!")
			end
		else
			ply:ChatPrint("Unrecognized command: " .. cmd)
		end
	end
end)
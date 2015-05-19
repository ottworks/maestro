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
	elseif t == "rank" then
		if not ply then return val end
		local cr = maestro.rankget(maestro.userrank(ply)).canrank
		if cr then
			local ranks = maestro.targetrank(cr, ply)
			if ranks[val] then
				return val
			end
			return false, true
		else
			return val
		end
	elseif t == "number" then
		return tonumber(val)
	elseif t == "boolean" then
		return val == "true"
	elseif t == "time" then
		return maestro.toseconds(val)
	end
	return val
end

local function handleError(ply, cmd, msg)
	if IsValid(ply) then
		maestro.chat(ply, Color(255, 154, 27),  cmd .. ": " .. msg)
	else
		MsgC(Color(255, 154, 27), cmd .. ": " .. msg .. "\n")
	end
end

local function handleMultiple(a, ret, cmd, num)
	local arg = maestro.commands[cmd].args[num] or maestro.commands[cmd].args[#maestro.commands[cmd].args]
	if type(a) == "table" then
		for j = 1, #a do
			if j == 1 then
				table.insert(ret, a[j])
			elseif j == #a then
				if #a > 2 then
					table.insert(ret, ", and ")
				else
					table.insert(ret, " and ")
				end
				table.insert(ret, a[j])
			else
				table.insert(ret, ", ")
				table.insert(ret, a[j])
			end
		end
	elseif string.gmatch(arg, "[^:]+") == "time" then
		table.insert(ret, Color(78, 196, 255))
		table.insert(ret, maestro.time(a))
	else
		table.insert(ret, Color(78, 196, 255))
		table.insert(ret, tostring(a))
	end
end

local function runcmd(cmd, args, ply)
	if not maestro.commands[cmd] then
		print("Invalid command!")
		return
	end
	for i = 1, #args do
		local err
		args[i], err = convertTo(args[i], string.match(maestro.commands[cmd].args[i] or "", "[^:]+"), ply, cmd)
		if err then
			handleError(ply, cmd, "You can't target this rank!")
			return
		end
	end
	local err, msg = maestro.commands[cmd].callback(ply, unpack(args))
	if err then
		handleError(ply, cmd, msg)
	elseif msg then
		local t = string.Explode("%%[%d%%]", msg, true)
		local ret = {ply or "(Console)", " "}
		local i = 1
		local max = 1
		for m in string.gmatch(msg, "%%%d") do --tally up
			local num = tonumber(m:sub(2, 2))
			max = math.max(max, num)
		end
		max = max + 1
		for m in string.gmatch(msg, "%%[%d%%]") do
			local num = tonumber(m:sub(2, 2))
			table.insert(ret, Color(255, 255, 255))
			table.insert(ret, t[i])
			if num then --normal argument
				local a = args[num]				
				handleMultiple(a, ret, cmd, num)
			else --it's a vararg
				table.insert(ret, Color(255, 154, 27))
				table.insert(ret, "[")
				for i = max, #args do
					local a = args[i]
					table.insert(ret, Color(255, 255, 255))
					if i ~= max and i == #args then
						if i - max > 2 then
							table.insert(ret, ", and ")
						else
							table.insert(ret, " and ")
						end
					elseif i ~= max then
						table.insert(ret, ", ")
					end
					handleMultiple(a, ret, cmd, num)
				end
				table.insert(ret, Color(255, 154, 27))
				table.insert(ret, "]")
			end
			i = i + 1
		end
		if #t[#t] ~= 0 then
			table.insert(ret, Color(255, 255, 255))
			table.insert(ret, t[#t])
		end
		
		maestro.chat(nil, unpack(ret))
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
		cmd = string.lower(cmd)
		if maestro.commands[cmd] then
			if maestro.rankget(maestro.userrank(ply)).perms[cmd] then
				runcmd(cmd, args, ply)
			else
				ply:ChatPrint(cmd .. ": Insufficient permissions!")
			end
			return false
		end
	end
end)
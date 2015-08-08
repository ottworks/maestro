local function toSequence(tab)
	local ret = {}
	for k in pairs(tab) do
		ret[#ret + 1] = k
	end
	return ret
end
maestro.command("help", {"command:optional"}, function(caller, cmd)
	if cmd and not maestro.commands[cmd] then
		return true, "Invalid command!"
	end
	if caller then
		caller:SendLua("maestro.help(" .. (cmd and "\"" .. cmd .. "\"" or "") .. ")")
	else
		return maestro.help(cmd)
	end
end, [[
Displays this menu.]])
function maestro.help(cmd)
	if cmd then
		local col = maestro.blue
		if LocalPlayer and not maestro.rankget(maestro.userrank(LocalPlayer())).perms[cmd] then
			col = maestro.orange
		end
		local args = maestro.commands[cmd].args
		local ret = {Color(255, 255, 255)}
		for j = 1, #args do
			table.insert(ret, Color(255, 255, 255))
			table.insert(ret, " <")
			table.insert(ret, maestro.blue)
			local t = args[j]:match("%w+")
			table.insert(ret, t)
			table.insert(ret, Color(255, 255, 255))
			if args[j]:find(":") then
				table.insert(ret, args[j]:match(":.+"))
			end
			table.insert(ret, ">")
		end
		table.insert(ret, "\n")
		MsgC(Color(255, 255, 255), "ms ", col, cmd, Color(255, 255, 255), unpack(ret))
		if maestro.commands[cmd].help then
			for w in string.gmatch(maestro.commands[cmd].help, "[^\n]+") do
				MsgC("\t", Color(255, 255, 255), w, "\n")
			end
		end
	else
		MsgC(Color(255, 255, 255), "Available commands:\n")
		local names = toSequence(maestro.commands)
		table.sort(names)
		for i = 1, #names do
			local col = maestro.blue
			if LocalPlayer and not maestro.rankget(maestro.userrank(LocalPlayer())).perms[names[i]] then
				col = maestro.orange
			end
			local args = maestro.commands[names[i]].args
			local ret = {Color(255, 255, 255)}
			for j = 1, #args do
				table.insert(ret, Color(255, 255, 255))
				table.insert(ret, " <")
				table.insert(ret, maestro.blue)
				local t = args[j]:match("%w+")
				table.insert(ret, t)
				table.insert(ret, Color(255, 255, 255))
				if args[j]:find(":") then
					table.insert(ret, args[j]:match(":.+"))
				end
				table.insert(ret, ">")
			end
			table.insert(ret, "\n")
			MsgC(Color(255, 255, 255), "\tms ", col, names[i], Color(255, 255, 255), string.rep(" ", 26 - #names[i]), unpack(ret))
		end
	end
end

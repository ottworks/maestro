local function toSequence(tab)
	local ret = {}
	for k in pairs(tab) do
		ret[#ret + 1] = k
	end
	return ret
end
maestro.command("help", {"boolean:showall"}, function(caller, showall)
	if caller then
		caller:SendLua("maestro.help(" .. (showall and "true" or "false") .. ")")
	else
		maestro.help(showall)
	end
end)
--Orange Color(255, 154, 27)
--Blue Color(78, 196, 255)
function maestro.help(showall)
	if showall then
		MsgC(Color(255, 255, 255), "All commands:\n")
	else
		MsgC(Color(255, 255, 255), "Available commands:\n")
	end
	local names = toSequence(maestro.commands)
	table.sort(names)
	for i = 1, #names do
		if not showall and LocalPlayer and not maestro.rankget(maestro.userrank(LocalPlayer())).perms[names[i]] then continue end
		local args = maestro.commands[names[i]].args
		if CLIENT then args = maestro.commands[names[i]] end
		local ret = {Color(255, 255, 255)}
		for j = 1, #args do
			table.insert(ret, Color(255, 255, 255))
			table.insert(ret, " <")
			table.insert(ret, Color(78, 196, 255))
			local t = args[j]:match("%w+")
			table.insert(ret, t)
			table.insert(ret, Color(255, 255, 255))
			if args[j]:find(":") then
				table.insert(ret, args[j]:match(":.+"))
			end
			table.insert(ret, ">")
		end
		table.insert(ret, "\n")
		MsgC(Color(255, 255, 255), "\tms ", Color(255, 154, 27), names[i], Color(255, 255, 255), string.rep(" ", 26 - #names[i]), unpack(ret))
	end
end
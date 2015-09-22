maestro.command("msg", {"player:target", "message"}, function(caller, targets, msg)
	if #targets < 1 then
		return true, "Query matched no players."
	end
	targets[#targets + 1] = caller
	local lookup = {}
	for k, v in pairs(targets) do
		lookup[v] = true
	end
	targets = {}
	for k in pairs(lookup) do
		targets[#targets + 1] = k
	end
	table.sort(targets, function(a, b)
		return a:Nick() < b:Nick()
	end)
	local ret = {Color(255, 255, 255), caller, " to "}
	for j = 1, #targets do
		if targets[j] == caller and #targets > 1 then continue end
		if j == 1 then
			table.insert(ret, targets[j])
		elseif j == #targets then
			if #targets > 2 then
				table.insert(ret, ", and ")
			else
				table.insert(ret, " and ")
			end
			table.insert(ret, targets[j])
		else
			table.insert(ret, ", ")
			table.insert(ret, targets[j])
		end
	end
	table.insert(ret, ": ")
	table.insert(ret, msg)
	maestro.chat(targets, unpack(ret))
end, [[
Sends a message to the targetted players.]], "*")
maestro.command("chatprint", {"text"}, function(caller, text)
	if not text then
		return true, "Invalid text."
	end
	maestro.chat(nil, text)
	return false, "chatprinted %1"
end, [[
Prints a message to everyone's chat.]])
maestro.command("admin", {"text"}, function(caller, text)
	local plys = {caller}
	for _, ply in pairs(player.GetAll()) do
		local flags = maestro.rankget(maestro.userrank(ply)).flags
		if flags.admin or flags.superadmin then
			plys[#plys + 1] = ply
		end
	end
	maestro.chat(plys, caller, Color(255, 255, 255), " to ", Color(0, 255, 0), "admins", Color(255, 255, 255), ": ", text)
end, [[
Sends a message to any people in ranks flagged as admin.]])
maestro.hook("PlayerSay", "admin", function(ply, text)
	if string.sub(text, 1, 1) == "@" then
		maestro.runcmd(false, "admin", {string.sub(text, 2)}, ply)
		return ""
	end
end)

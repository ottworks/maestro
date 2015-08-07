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
Sends a message to the targetted players.]])

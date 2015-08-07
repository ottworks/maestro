maestro.command("hp", {"player:target", "number"}, function(caller, targets, num)
	if not targets or #targets == 0 then
		return true, "Query matched no players."
	end
	for _, ply in pairs(targets) do
		ply:SetHealth(num)
	end
	return false, "set the hp of %1 to %2"
end, [[
Sets the health of the targeted player(s).]])

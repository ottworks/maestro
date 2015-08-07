maestro.command("armor", {"player:target", "number"}, function(caller, targets, num)
	if #targets == 0 then
		return true, "Query matched no players."
	end
	for _, ply in pairs(targets) do
		ply:SetArmor(num)
	end
	return false, "set the armor of %1 to %2"
end, [[
Sets the armor of the targeted player(s).]])

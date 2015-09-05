maestro.command("exit", {"player:target"}, function(caller, targets)
	if #targets == 0 then
		return true, "Query matched no players."
	end
	for i = 1, #targets do
		local ply = targets[i]
		if not IsValid( ply:GetVehicle() ) then
			if #targets == 1 then
				return true, "Player is not in vehicle!"
			end
			continue
		end
	ply:ExitVehicle()
	end
	return false, "exited %1"
end, [[
Force a player out of their vehicle - grand theft auto style.]])

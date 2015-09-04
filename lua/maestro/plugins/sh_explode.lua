maestro.command("explode", {"player:target"}, function(caller, targets)
	if #targets == 0 then
		return true, "Query matched no players."
	end
	for i = 1, #targets do
		local ply = targets[i]
		if not ply:Alive() then
			if #targets == 1 then
				return true, "Player is dead!"
			end
			continue
		end
//death code
	local boom = ents.Create("env_explosion")
	boom:SetPos(ply:GetPos() )
	boom:Spawn()
	boom:SetKeyValue("iMagnitude", "100")
	boom:Fire("Explode")
	ply:Kill()
	end
	return false, "exploded %1"
end, [[
Slays a player.]])

local maestro_trainfuck_models = {}
maestro_trainfuck_models[1] = "models/props_trainstation/train001.mdl"
maestro_trainfuck_models[2] = "models/props_trainstation/train002.mdl"
maestro_trainfuck_models[3] = "models/props_trainstation/train003.mdl"
local maestro_cartoss_models = {}
maestro_cartoss_models[1] = "models/props_vehicles/car002a_physics.mdl"
maestro_cartoss_models[2] = "models/props_vehicles/car003a_physics.mdl"
maestro_cartoss_models[3] = "models/props_vehicles/car004a_physics.mdl"
maestro_cartoss_models[4] = "models/props_vehicles/car005a_physics.mdl"
maestro_cartoss_models[5] = "models/props_vehicles/van001a_physics.mdl"
maestro_cartoss_models[6] = "models/props_vehicles/truck003a.mdl"
maestro_cartoss_models[7] = "models/props_vehicles/car003b_physics.mdl"

maestro.command("trainfuck", {"player:target"}, function(caller, targets)
	if #targets == 0 then return true, "Query matched no players." end
	
	for i = 1, #targets do
		local ply = targets[i]
		
		if not ply:Alive() then
			if #targets == 1 then return true, "Player is dead!" end
			continue
		end
		
		local trainPos, trainDirection = ply:GetPos() + ply:GetForward() * 1000 + Vector(0, 0, 125), ply:GetForward() * -1
		local trainModel = maestro_trainfuck_models[math.random(1, #maestro_trainfuck_models)]
		local train = ents.Create("prop_physics")
		train:SetModel(trainModel)
		train:SetAngles(trainDirection:Angle() + Angle(0, 270, 0))
		train:SetPos(trainPos)
		train:Spawn()
		train:Activate()
		train:EmitSound("ambient/alarms/train_horn2.wav", 100, 100)
		local phys = train:GetPhysicsObject()
		phys:SetVelocity(trainDirection * 100000)
		
		timer.Simple(3, function()
			train:Remove()
		end)
	end
	
	return false, "trainfucked %1"
end, [[
Throws a train at the target.]])

maestro.command("cartoss", {"player:target"}, function(caller, targets)
	if #targets == 0 then return true, "Query matched no players." end
	
	for i = 1, #targets do
		local ply = targets[i]
		
		if not ply:Alive() then
			if #targets == 1 then return true, "Player is dead!" end
			continue
		end
		
		local carPos, carDirection = ply:GetPos() + ply:GetForward() * 1000 + Vector(0, 0, 75), ply:GetForward() * -1
		local carModel = maestro_cartoss_models[math.random(1, #maestro_cartoss_models)]
		local car = ents.Create("prop_physics")
		car:SetModel(carModel)
		car:SetAngles(carDirection:Angle() + Angle(0, 270, 0))
		car:SetPos(carPos)
		car:Spawn()
		car:Activate()
		local phys = car:GetPhysicsObject()
		phys:SetVelocity(carDirection * 100000)
		
		timer.Simple(3, function()
			car:Remove()
		end)
	end
	
	return false, "cartossed %1"
end, [[
Throws a car at the target.]])
--Plugin by FluffyXVI
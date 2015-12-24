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

		local trainPos, trainDirection = ply:GetPos() + ply:GetForward() * 2000 + Vector(0, 0, 100), ply:GetForward() * -1
		local trainModel = maestro_trainfuck_models[math.random(1, #maestro_trainfuck_models)]
		local train = ents.Create("prop_physics")
		train:SetModel(trainModel)
		train:SetAngles(trainDirection:Angle() + Angle(0, 270, 0))
		train:SetPos(trainPos)
		train:Spawn()
		train:Activate()
		targets[i]:EmitSound("ambient/alarms/train_horn2.wav", 511, 100)
		local obj = train:GetPhysicsObject()
		if IsValid(obj) then
			obj:EnableGravity(false)
			obj:EnableCollisions(false)
			obj:SetVelocity(trainDirection * 100000)
		end
		timer.Simple(0.6, function()
			local dmg = DamageInfo()
			dmg:AddDamage(2^31 -1)
			dmg:SetDamageForce(trainDirection * 500000)
			dmg:SetInflictor(train)
			dmg:SetAttacker(train)
			targets[i]:TakeDamageInfo(dmg)
			timer.Simple(0, function()
				if targets[i]:Alive() then
					targets[i]:Kill()
				end
			end)
		end)

		timer.Simple(3, function()
			train:Remove()
		end)
	end

	return false, "trainfucked %1"
end, [[
Throws a train at the target.]])

maestro.command("cartoss", {}, function(ply)
	local carPos, carDirection = ply:GetShootPos(), ply:EyeAngles():Forward()
	local carModel = maestro_cartoss_models[math.random(1, #maestro_cartoss_models)]
	local car = ents.Create("prop_physics")
	car:SetModel(carModel)
	car:SetAngles(carDirection:Angle())
	car:SetPos(carPos)
	car:Spawn()
	car:Activate()
	car:SetOwner(ply)
	car:SetMaxHealth(2^31 - 1) --don't ask
	local phys = car:GetPhysicsObject()
	phys:SetVelocity(carDirection * 10000)

	timer.Simple(3, function()
		car:Remove()
	end)

	return false, "threw a car"
end, [[
Throws a car.]])
--Plugin originally by FluffyXVI

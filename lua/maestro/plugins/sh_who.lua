maestro.command("who", {}, function(caller)
	if IsValid(caller) then
		net.Start("maestro_printranks")
		net.Send(caller)
	else
		for _, v in pairs(player.GetAll()) do
			print(v:Nick() .. string.rep(" ", 40 - #v:Nick()) .. maestro.userrank(v))
		end
	end
end, [[
Lists the players on the server and their ranks.]])
if SERVER then
	util.AddNetworkString("maestro_printranks")
end
if CLIENT then
	net.Receive("maestro_printranks", function()
		for _, v in pairs(player.GetAll()) do
			print(v:Nick() .. string.rep(" ", 40 - #v:Nick()) .. v:GetUserGroup())
		end
	end)
end

if SERVER then
	util.AddNetworkString("maestro_chat")
	function maestro.chat(ply, ...)
		net.Start("maestro_chat")
			net.WriteTable({...})
		if ply then
			net.Send(ply)
		else
			net.Broadcast()
		end
	end
end
if CLIENT then
	net.Receive("maestro_chat", function()
		local args = net.ReadTable()
		chat.AddText(unpack(args))
	end)
end
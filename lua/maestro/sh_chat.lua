if SERVER then
	util.AddNetworkString("maestro_chat")
	function maestro.chat(ply, ...)
		MsgC(...)
		MsgC("\n")
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
		for k, v in pairs(args) do
			if type(v) ~= "table" and type(v) ~= "Player" then
				args[k] = tostring(v)
			end
		end
		chat.AddText(unpack(args))
	end)
end
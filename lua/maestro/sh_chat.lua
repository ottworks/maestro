local function ts(i)
	if type(i) == "Player" then
		return i:Nick() .. "(" .. i:SteamID() .. ")"
	end
	return tostring(i)
end
if SERVER then
	util.AddNetworkString("maestro_chat")
	function maestro.chat(ply, ...)
		if not ply then
			MsgC(...)
			MsgC("\n")
			local txt = ""
			for _, i in ipairs{...} do
				if type(i) ~= "table" then
					txt = txt .. (ts(i) or "")
				end
			end
			maestro.log("log_" .. os.date("%y-%m-%d"), os.date("[%H:%M] ") .. txt)
		end
		if ply ~= false then
			net.Start("maestro_chat")
				net.WriteTable({...})
			if ply then
				net.Send(ply)
			else
				net.Broadcast()
			end
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

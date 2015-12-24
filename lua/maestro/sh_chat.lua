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
		end
		if ply ~= false and ply ~= NULL then
			net.Start("maestro_chat")
				net.WriteBool(true)
				net.WriteTable({...})
			if ply then
				net.Send(ply)
			else
				net.Broadcast()
				local txt = ""
				for _, i in ipairs{...} do
					if type(i) ~= "table" then
						txt = txt .. (ts(i) or "")
					end
				end
				maestro.serverlog(txt)
			end
		end
	end
	function maestro.chatconsole(ply, ...)
		if not ply then
			MsgC(...)
			MsgC("\n")
		end
		if ply ~= false and ply ~= NULL then
			net.Start("maestro_chat")
				net.WriteBool(false)
				net.WriteTable({...})
			if ply then
				net.Send(ply)
			else
				net.Broadcast()
				local txt = ""
				for _, i in ipairs{...} do
					if type(i) ~= "table" then
						txt = txt .. (ts(i) or "")
					end
				end
				maestro.serverlog(txt)
			end
		end
	end
end
if CLIENT then
	net.Receive("maestro_chat", function()
		local msgtype = net.ReadBool()
		local args = net.ReadTable()
		for k, v in pairs(args) do
			if type(v) ~= "table" and type(v) ~= "Player" then
				args[k] = tostring(v)
			end
		end
		if msgtype then
			chat.AddText(unpack(args))
		else
			MsgC(unpack(args))
			MsgC("\n")
		end
	end)
end

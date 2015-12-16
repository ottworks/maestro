--[[
    Note: This is chat autocomplete. Console autocomplete is in cl_commands.lua
	Originally contributed by Fluffy (http://facepunch.com/member.php?u=646169)
-]]
if CLIENT then
	function draw.AAText(text, font, x, y, color, align)
		draw.SimpleText(text, font, x+1, y+1, Color(0, 0, 0, math.min(color.a, 120)), align)
		draw.SimpleText(text, font, x+2, y+2, Color(0, 0, 0, math.min(color.a, 50)), align)
		draw.SimpleText(text, font, x, y, color, align)
	end
end
local ma = { }
ma.sug = { }
ma.c = false
function ma:DrawSuggestions()
	if chat ~= nil and self.c and CLIENT then
		local cx, cy = chat.GetChatBoxPos()
		local sw, sh = ScrW(), ScrH()
		cx = cx + sw * .08
		cy = cy + sh / 4 + 4
		surface.SetFont('ChatFont')
		for _, v in ipairs(self.sug) do
			local tx, ty = surface.GetTextSize(v)
			draw.AAText(v, "ChatFont", cx, cy, Color(255, 255, 255, 255))
			cy = cy + ty
		end
	end
end
function ma:GetSugCmds(message)
	if string.Left(message, 1) == "!" then
		local cmd = string.sub(message, 2, (string.find(message, " ") or (#message + 1)) - 1)
		self.sug = { }
		for k, v in pairs(maestro.commands) do
			if v and string.sub(k, 0, #cmd) == string.lower(cmd) and #self.sug < 4 then
				local a = table.concat(v.args, "> <")
				if a == "" then
					table.insert(self.sug, { command = "!" .. k })
				else
					table.insert(self.sug, { command = "!" .. k .. " <" .. a .. ">" })
				end
			end
		end
		table.SortByMember(self.sug, "command", function(a, b) return a < b end)
	else
		self.sug = {}
	end
end
function ma:Autocomplete(s)
	if string.match(s, "^!") and #self.sug > 0 then
		return self.sug[1]
	end
end
function ma:ChatOpen(t)
	self.c = true
end
function ma:ChatClose()
	self.c = false
end
local function escape(str)
	return string.gsub(str, "([%(%)%.%%%+%-%*%?%[%^%$])", "%%%1")
end
local function autocomplete(str)
	local base = "!"
	str = string.sub(str, 2, -1)
	local args = maestro.split(str, true)
	local t = {}
	if #args == 0 then
		for k, v in pairs(maestro.commands) do
			if maestro.rankget(maestro.userrank(LocalPlayer())).perms[k] then
				table.insert(t, base .. k)
			end
		end
	elseif #args == 1 then
		for k, v in pairs(maestro.commands) do
			if maestro.rankget(maestro.userrank(LocalPlayer())).perms[k] then
				if string.sub(k, 1, #args[1]):lower() == args[1]:lower() then
					table.insert(t, base .. k)
				end
			end
		end
	else
		local cmd, types
		for k, v in pairs(maestro.commands) do
			if k:lower() == args[1]:lower() then
				cmd = k
				types = v.args
			end
		end
		local params = table.Copy(args)
		table.remove(params, 1)
		if cmd then
			local cnct = table.concat(args, " ", 2, #args - 1)
			cnct = " " .. cnct .. " "
			cnct = cnct:gsub("%s+", " ")
			local typ = string.match(types[#params] or types[#types], "[^:]+")
			if typ == "player" then
				local plys = maestro.target(params[#params], LocalPlayer(), cmd)
				for i = 1, #plys do
					table.insert(t, base .. cmd .. cnct .. "\"" .. plys[i]:Nick() .. "\"")
				end
			elseif typ == "boolean" then
				local options = {"true", "false", "t", "f", "1", "0", "yes", "no"}
				for i = 1, #options do
					if string.sub(options[i], 1, #args[#args]):lower() == args[#args]:lower() then
						table.insert(t, base .. cmd .. cnct .. options[i])
					end
				end
			elseif typ == "rank" then
				local ranks = {}
				local cr = maestro.rankget(maestro.userrank(LocalPlayer())).canrank
				if cr then
					ranks = maestro.targetrank(cr, maestro.userrank(LocalPlayer()))
				end
				for rank in pairs(ranks) do
					if string.sub(rank, 1, #args[#args]):lower() == args[#args]:lower() then
						table.insert(t, base .. cmd .. cnct .. rank)
					end
				end
			elseif typ == "command" then
				for cmd2 in pairs(maestro.commands) do
					if string.sub(cmd2, 1, #args[#args]):lower() == args[#args]:lower() then
						table.insert(t, base .. cmd .. cnct .. cmd2)
					end
				end
			elseif typ == "sound" then
				local input = tostring(args[#args])
				input = input:gsub("\\", "/")
				input = input:gsub("%.%.", "")
				local path, name = input:match("(.*/)([^/]*)$")
				path = path or ""
				name = name or input
				local files, folders = file.Find("sound/" .. input .. "*", "GAME")
				if files and folders then
					for i = 1, #files do
						table.insert(t, base .. cmd .. cnct .. path .. files[i])
					end
					for i = 1, #folders do
						if folders[i]:sub(1, #name) == name then
							table.insert(t, base .. cmd .. cnct .. path .. folders[i])
						end
					end
				end
			elseif typ == "style" then
				local options = {"primary", "success", "info", "warning", "danger"}
				for i = 1, #options do
					if string.sub(options[i], 1, #args[#args]):lower() == args[#args]:lower() then
						table.insert(t, base .. cmd .. cnct .. options[i])
					end
				end
			elseif typ == "team" then
				for id, tab in pairs(team.GetAllTeams()) do
					if string.sub(tab.Name or "", 1, #args[#args]):lower() == args[#args]:lower() then
						table.insert(t, base .. cmd .. cnct .. tab.Name)
					end
				end
			elseif types[#params] then
				table.insert(t, base .. cmd .. cnct .. "<" .. types[#params] .. ">")
			end
		end
	end
	table.sort(t)
	ma.sug = t
end
maestro.hook("HUDPaint", "cmdsuggest", function() ma:DrawSuggestions() end)
maestro.hook("ChatTextChanged", "findsuggest", autocomplete)
maestro.hook("StartChat", "plopenchat", function(t) ma:ChatOpen(t) end)
maestro.hook("FinishChat", "plclosechat", function() ma:ChatClose() end)
maestro.hook("OnChatTab", "autocomplete", function(s) return ma:Autocomplete(s) end)

--[[
    Note: This is chat autocomplete. Console autocomplete is in cl_commands.lua
	If this breaks yell at http://facepunch.com/member.php?u=646169
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
			local tx, ty = surface.GetTextSize(v.command)
			draw.AAText(v.command, "ChatFont", cx, cy, Color(255, 255, 255, 255))
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
	if string.match(s, "^[!][^ ]*$") and #self.sug > 0 then
		return self.sug[1].command
	end
end
function ma:ChatOpen(t)
	self.c = true
end
function ma:ChatClose()
	self.c = false
end
maestro.hook("HUDPaint", "cmdsuggest", function() ma:DrawSuggestions() end)
maestro.hook("ChatTextChanged", "findsuggest", function(msg) ma:GetSugCmds(msg) end)
maestro.hook("StartChat", "plopenchat", function(t) ma:ChatOpen(t) end)
maestro.hook("FinishChat", "plclosechat", function() ma:ChatClose() end)
maestro.hook("OnChatTab", "autocomplete", function(s) ma:Autocomplete(s) end)

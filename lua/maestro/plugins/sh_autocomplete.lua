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
			draw.AAText("!" .. string.sub(v, 3), "ChatFont", cx, cy, Color(255, 255, 255, 255))
			cy = cy + ty
		end
	end
end
function ma:Autocomplete(s)
	if string.match(s, "^!") and #self.sug > 0 then
		return "!" .. string.sub(self.sug[1], 3)
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
	ma.sug = maestro.autocomplete("!", str)
end
maestro.hook("HUDPaint", "cmdsuggest", function() ma:DrawSuggestions() end)
maestro.hook("ChatTextChanged", "findsuggest", autocomplete)
maestro.hook("StartChat", "plopenchat", function(t) ma:ChatOpen(t) end)
maestro.hook("FinishChat", "plclosechat", function() ma:ChatClose() end)
maestro.hook("OnChatTab", "autocomplete", function(s) return ma:Autocomplete(s) end)

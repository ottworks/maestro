maestro = {}

print("\201\205\205\205\205\205\205\205\205\205\205\205\205\205\205\205\205\205\205\205\205\205\205\205\205\205\205\205\205\205\205\205\205\205\205\187")
print("\186 Maestro v0.01                    \186") 
print("\186     (it's pronounced \"my strow\") \186")
print("\186 (c) 2015 Ott(STEAM_0:0:36527860) \186")
print("\199\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\182")
local files, folders = file.Find("maestro/*", "LUA")
table.sort(files, function(a, b)
	local suba = string.sub(a, 1, 3)
	local subb = string.sub(b, 1, 3)
	if table.HasValue({"sv_", "sh_", "cl_"}, suba) and table.HasValue({"sv_", "sh_", "cl_"}, subb) then
		return string.sub(a, 4) < string.sub(b, 4)
	end
	return a < b
end) 
for k, v in pairs(files) do
	print("\199\196" .. v .. string.rep(" ", 33 - #v) .. "\186")
	if string.sub(v, 1, 3) == "cl_" then
		if SERVER then
			AddCSLuaFile("maestro/" .. v)
		end
		if CLIENT then
			include("maestro/" .. v)
		end
	elseif string.sub(v, 1, 3) == "sh_" then
		if SERVER then
			AddCSLuaFile("maestro/" .. v)
		end
		include("maestro/" .. v)
	elseif string.sub(v, 1, 3) == "sv_" then
		if SERVER then
			include("maestro/" .. v)
		end
	end
end
print("\199\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\196\182")
local files, folders = file.Find("maestro/plugins/*", "LUA")
table.sort(files, function(a, b)
	local suba = string.sub(a, 1, 3)
	local subb = string.sub(b, 1, 3)
	if table.HasValue({"sv_", "sh_", "cl_"}, suba) and table.HasValue({"sv_", "sh_", "cl_"}, subb) then
		return string.sub(a, 4) < string.sub(b, 4)
	end
	return a < b
end)
for k, v in pairs(files) do
	print("\199\196" .. v .. string.rep(" ", 33 - #v) .. "\186")
	if string.sub(v, 1, 3) == "cl_" then
		if SERVER then
			AddCSLuaFile("maestro/plugins/" .. v)
		end
		if CLIENT then
			include("maestro/plugins/" .. v)
		end
	elseif string.sub(v, 1, 3) == "sh_" then
		if SERVER then
			AddCSLuaFile("maestro/plugins/" .. v)
		end
		include("maestro/plugins/" .. v)
	elseif string.sub(v, 1, 3) == "sv_" then
		if SERVER then
			include("maestro/plugins/" .. v)
		end
	end
end
print("\200\205\205\205\205\205\205\205\205\205\205\205\205\205\205\205\205\205\205\205\205\205\205\205\205\205\205\205\205\205\205\205\205\205\205\188")
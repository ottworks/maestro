maestro.ranks = {}
util.AddNetworkString("maestro_ranks")

if not file.Exists("maestro", "DATA") then
	file.CreateDir("maestro")
end
if not file.Exists("maestro/ranks.txt", "DATA") then
	file.Write("maestro/ranks.txt", "")
end
maestro.ranks = util.JSONToTable(file.Read("maestro/ranks.txt")) or {}

function maestro.saveranks()
	file.Write("maestro/ranks.txt", util.TableToJSON(maestro.ranks))
end

function maestro.rank(name, inherits, perms)
	if inherits then
		local r = {perms = perms, inherits = inherits}
		setmetatable(r, {__index = maestro.ranks[inherits]})
		maestro.ranks[name] = r
		maestro.saveranks()
		for _, v in pairs(player.GetAll()) do
			maestro.sendranks(v)
		end
	else
		return maestro.ranks[name] or {perms = {}, inherits = "user"}
	end
end

function maestro.sendranks(ply)
	net.Start("maestro_ranks")
		net.WriteTable(maestro.ranks)
	net.Send(ply)
end
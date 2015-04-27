maestro.ranks = {}

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

function maestro.rank(name, perms)
	if perms then
		maestro.ranks[name] = perms
		maestro.saveranks()
	else
		return maestro.ranks[name] or {}
	end
end
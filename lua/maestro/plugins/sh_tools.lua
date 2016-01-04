maestro.command("toolrestrict", {"rank", "tool:optional"}, function(caller, rank, tool)
    if not tool then
        if IsValid(caller) and type(caller) == "Player" then
            tool = caller:GetTool().Mode
        else
            return true, "You need to be ingame to use the current tool."
        end
    end
    local r = maestro.ranks[rank]
    r.tools = r.tools or {}
    setmetatable(r.tools, {__index = function(tab, key)
        if rank == "root" then return true end
        if not maestro.ranks[r.inherits] then return end
        if tab ~= maestro.ranks[r.inherits].tools then
            return maestro.ranks[r.inherits].tools[key]
        end
    end})
    r.tools[tool] = false
    maestro.broadcastranks()
    local q = mysql:Delete("maestro_tools")
        q:Where("rank", rank)
        q:Where("tool", tool)
    q:Execute()
    local q = mysql:Insert("maestro_tools")
        q:Insert("rank", rank)
        q:Insert("tool", tool)
        q:Insert("value", false)
    q:Execute()
    return false, "restricted tool %2 from rank %1", false, tool
end, [[
Restricts a tool from a rank. Ranks that inherit from this one will also be restricted. Use toolallow to correct for this.
]])
maestro.command("toolallow", {"rank", "tool:optional"}, function(caller, rank, tool)
    if not tool then
        if IsValid(caller) and type(caller) == "Player" then
            tool = caller:GetTool().Mode
        else
            return true, "You need to be ingame to use the current tool."
        end
    end
    local r = maestro.ranks[rank]
    r.tools = r.tools or {}
    setmetatable(r.tools, {__index = function(tab, key)
        if rank == "root" then return true end
        if not maestro.ranks[r.inherits] then return end
        if tab ~= maestro.ranks[r.inherits].tools then
            return maestro.ranks[r.inherits].tools[key]
        end
    end})
    r.tools[tool] = true
    maestro.broadcastranks()
    local q = mysql:Delete("maestro_tools")
        q:Where("rank", rank)
        q:Where("tool", tool)
    q:Execute()
    local q = mysql:Insert("maestro_tools")
        q:Insert("rank", rank)
        q:Insert("tool", tool)
        q:Insert("value", true)
    q:Execute()
    return false, "granted tool %2 to rank %1", false, tool
end, [[
Explicitly allows a rank to use a tool.
]])
maestro.command("toolreset", {"rank", "tool:optional"}, function(caller, rank, tool)
    if not tool then
        if IsValid(caller) and type(caller) == "Player" then
            tool = caller:GetTool().Mode
        else
            return true, "You need to be ingame to use the current tool."
        end
    end
    local r = maestro.ranks[rank]
    r.tools = r.tools or {}
    setmetatable(r.tools, {__index = function(tab, key)
        if rank == "root" then return true end
        if not maestro.ranks[r.inherits] then return end
        if tab ~= maestro.ranks[r.inherits].tools then
            return maestro.ranks[r.inherits].tools[key]
        end
    end})
    r.tools[tool] = nil
    maestro.broadcastranks()
    local q = mysql:Delete("maestro_tools")
        q:Where("rank", rank)
        q:Where("tool", tool)
    q:Execute()
    return false, "reset rank %1's allowance of tool %2", false, tool
end, [[
Removes the restriction status from a rank's tool. The rank's tool availibility will be determined by inheritance.
]])

maestro.hook("CanTool", "tools", function(ply, tr, tool)
    if maestro.rankget(maestro.userrank(ply)).tools and maestro.rankget(maestro.userrank(ply)).tools[tool] == false then
        maestro.chat(ply, maestro.orange, "This tool is restricted from your rank!")
        return false
    end
end)

if not SERVER then return end
for rank, r in pairs(maestro.ranks) do
    r.tools = r.tools or {}
    setmetatable(r.tools, {__index = function(tab, key)
        if rank == "root" then return true end
        if not maestro.ranks[r.inherits] then return end
        if tab ~= maestro.ranks[r.inherits].tools then
            return maestro.ranks[r.inherits].tools[key]
        end
    end})
end
local q = mysql:Create("maestro_tools")
    q:Create("rank", "VARCHAR(255) NOT NULL")
    q:Create("tool", "VARCHAR(255) NOT NULL")
    q:Create("value", "BOOLEAN NOT NULL")
q:Execute()
local function bool(str)
	if str == "true" then return true end
	if str == "false" then return false end
	if tonumber(str) == 1 then return true end
	if tonumber(str) == 0 then return false end
	return str
end
local q = mysql:Select("maestro_tools")
    q:Callback(function(res, status)
        if type(res) == "table" and #res > 0 then
            for i = 1, #res do
                local item = res[i]
                local r = maestro.ranks[item.rank]
                r.tools[item.tool] = bool(item.value)
            end
        end
    end)
q:Execute()

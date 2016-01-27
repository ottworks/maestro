maestro.command("itemrestrict", {"rank", "item:optional"}, function(caller, rank, item)
    if not item then
        if IsValid(caller) and type(caller) == "Player" then
            if caller:GetActiveWeapon():GetClass() == "gmod_tool" then
                item = caller:GetTool().Mode
            else
                item = caller:GetActiveWeapon():GetClass()
            end
        else
            return true, "You need to be ingame to use the current item."
        end
    end
    local r = maestro.ranks[rank]
    r.items = r.items or {}
    setmetatable(r.items, {__index = function(tab, key)
        if rank == "root" then return true end
        if not maestro.ranks[r.inherits] then return end
        if tab ~= maestro.ranks[r.inherits].items then
            return maestro.ranks[r.inherits].items[key]
        end
    end})
    r.items[item] = false
    maestro.broadcastranks()
    local q = mysql:Delete(maestro.config.tables.items)
        q:Where("rank", rank)
        q:Where("item", item)
    q:Execute()
    local q = mysql:Insert(maestro.config.tables.items)
        q:Insert("rank", rank)
        q:Insert("item", item)
        q:Insert("value", false)
    q:Execute()
    return false, "restricted item %2 from rank %1", false, item
end, [[
Restricts a item from a rank. Ranks that inherit from this one will also be restricted. Use itemallow to correct for this.
]])
maestro.command("itemallow", {"rank", "item:optional"}, function(caller, rank, item)
    if not item then
        if IsValid(caller) and type(caller) == "Player" then
            if caller:GetActiveWeapon():GetClass() == "gmod_tool" then
                item = caller:GetTool().Mode
            else
                item = caller:GetActiveWeapon():GetClass()
            end
        else
            return true, "You need to be ingame to use the current item."
        end
    end
    local r = maestro.ranks[rank]
    r.items = r.items or {}
    setmetatable(r.items, {__index = function(tab, key)
        if rank == "root" then return true end
        if not maestro.ranks[r.inherits] then return end
        if tab ~= maestro.ranks[r.inherits].items then
            return maestro.ranks[r.inherits].items[key]
        end
    end})
    r.items[item] = true
    maestro.broadcastranks()
    local q = mysql:Delete(maestro.config.tables.items)
        q:Where("rank", rank)
        q:Where("item", item)
    q:Execute()
    local q = mysql:Insert(maestro.config.tables.items)
        q:Insert("rank", rank)
        q:Insert("item", item)
        q:Insert("value", true)
    q:Execute()
    return false, "granted item %2 to rank %1", false, item
end, [[
Explicitly allows a rank to use a item.
]])
maestro.command("itemreset", {"rank", "item:optional"}, function(caller, rank, item)
    if not item then
        if IsValid(caller) and type(caller) == "Player" then
            if caller:GetActiveWeapon():GetClass() == "gmod_tool" then
                item = caller:GetTool().Mode
            else
                item = caller:GetActiveWeapon():GetClass()
            end
        else
            return true, "You need to be ingame to use the current item."
        end
    end
    local r = maestro.ranks[rank]
    r.items = r.items or {}
    setmetatable(r.items, {__index = function(tab, key)
        if rank == "root" then return true end
        if not maestro.ranks[r.inherits] then return end
        if tab ~= maestro.ranks[r.inherits].items then
            return maestro.ranks[r.inherits].items[key]
        end
    end})
    r.items[item] = nil
    maestro.broadcastranks()
    local q = mysql:Delete(maestro.config.tables.items)
        q:Where("rank", rank)
        q:Where("item", item)
    q:Execute()
    return false, "reset rank %1's allowance of item %2", false, item
end, [[
Removes the restriction status from a rank's item. The rank's item availibility will be determined by inheritance.
]])

maestro.hook("CanTool", "items", function(ply, tr, item)
    if maestro.rankget(maestro.userrank(ply)).items and maestro.rankget(maestro.userrank(ply)).items[item] == false then
        maestro.chat(ply, maestro.orange, "This tool is restricted from your rank!")
        return false
    end
end)
maestro.hook("PlayerCanPickupWeapon", "items", function(ply, item)
    if maestro.rankget(maestro.userrank(ply)).items and maestro.rankget(maestro.userrank(ply)).items[item:GetClass()] == false then
        maestro.chat(ply, maestro.orange, "This weapon is restricted from your rank!")
        return false
    end
end)
maestro.hook("PlayerCanPickupItem", "items", function(ply, item)
    if maestro.rankget(maestro.userrank(ply)).items and maestro.rankget(maestro.userrank(ply)).items[item:GetClass()] == false then
        maestro.chat(ply, maestro.orange, "This item is restricted from your rank!")
        return false
    end
end)

if not SERVER then return end
for rank, r in pairs(maestro.ranks) do
    r.items = r.items or {}
    setmetatable(r.items, {__index = function(tab, key)
        if rank == "root" then return true end
        if not maestro.ranks[r.inherits] then return end
        if tab ~= maestro.ranks[r.inherits].items then
            return maestro.ranks[r.inherits].items[key]
        end
    end})
end
local q = mysql:Create(maestro.config.tables.items)
    q:Create("rank", "VARCHAR(255) NOT NULL")
    q:Create("item", "VARCHAR(255) NOT NULL")
    q:Create("value", "BOOLEAN NOT NULL")
q:Execute()
local function bool(str)
	if str == "true" then return true end
	if str == "false" then return false end
	if tonumber(str) == 1 then return true end
	if tonumber(str) == 0 then return false end
	return str
end
local q = mysql:Select(maestro.config.tables.items)
    q:Callback(function(res, status)
        if type(res) == "table" and #res > 0 then
            for i = 1, #res do
                local item = res[i]
                local r = maestro.ranks[item.rank]
                if r then
                    r.items = r.items or {}
                    r.items[item.item] = bool(item.value)
                end
            end
        end
    end)
q:Execute()

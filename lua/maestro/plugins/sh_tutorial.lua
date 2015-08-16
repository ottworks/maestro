local tutorial = {}
maestro.command("tutorial", {"number:page(optional)"}, function(caller, page)
    page = page or 0
    if not tutorial[page] then
        return true, "Invalid page."
    end
    if not caller then
        MsgC(Color(255, 255, 255), tutorial[page])
    else
        maestro.chat(caller, Color(255, 255, 255), "Page ", page, " of the tutorial has been printed to your console.")
        net.Start("maestro_tutorial")
            net.WriteUInt(page or 0, 8)
        net.Send(caller)
    end
end, [[
Displays the tutorial.]])
if SERVER then util.AddNetworkString("maestro_tutorial") end
net.Receive("maestro_tutorial", function()
    local page = net.ReadUInt(8)
    MsgC(Color(255, 255, 255), tutorial[page])
end)
tutorial[0] = [[
Table of contents:
    1. Introduction
    2. Getting Started
    3. Adding a Rank/Introduction to Inheritance
    4. Flags
]]
tutorial[1] = [[
    Hi, thanks for using maesto. In this tutorial, we're going to go over the
basics of getting a server up and running. Please note that maestro is NOT
compatible with FAdmin (or ULX). If you're running DarkRP, you'll need to remove
it by browsing to darkrp/gamemode/modules and deleting the "fadmin" folder. You
can view the availalbe commands and specific command help by using the console
command "ms help" or the chat command "!help" at any time. View the next page
with "ms tutorial 2".
]]
tutorial[2] = [[
    If you run "ms ranks", you'll see that there's a few ranks already: User,
admin, superadmin, and root. In the server console, add yourself to root:

    ms adduser <yournamehere> root

    Now, you can do everything from the ingame console or chat commands. We'll
be using the ingame console because it has autocomplete. The server is pretty
much ready now as the default ranks are preconfigured as such: User gets basic
stuff like motd and help, admin gets just administration tools (no fun allowed),
superadmin gets all the fun stuff but no rank configuration, and root gets
everything. The map voting features are not allowed for anyone by default, as
some servers might be messed up if users could change the map.
    Using team chat for !chat commands will run the command as silent. A command
ran silently is only visible to your rank and above. You can also use the
console command "mss" instead of "ms" to run commands silently from the console.
]]
tutorial[3] = [[
    Say you wanted to add a moderator rank that had access to kick, but not ban.
You can do such by adding a rank and changing the inheritance of admin:

    ms rankadd moderator user kick freeze goto
    ms ranksetinherits admin moderator

    The first command adds a rank called moderator that has all the permissions
user has, plus kick, freeze, and goto. The second gives admin all permissions
moderator has instead of user.
]]
tutorial[4] = [[
    What if something in your gamemode requires a person to be "admin", but you
want your moderators to have access to it as well? Garry's Mod has a limited
ranking system by default, consisting of just admin and superadmin. To make GMod
recognize maestro ranks as admin and superadmin, we have flags:

    ms rankflag moderator admin

    This command tells the game that the rank "moderator" should be considered
admin. Here's a list of the current valid flags:
    admin: Marks a rank as admin.
    superadmin: Marks a rank as superadmin.
    anonymous: Hides a rank (people in this rank will appear as users).
]]

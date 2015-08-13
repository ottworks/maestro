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
    2. Adding a rank / Inheritance
    3. Adding an owner rank
    4. Adding a rank inbetween / Inheritance pt. 2
    5. Flags
]]
tutorial[1] = [[
    Hi, thanks for using maesto. Maestro was designed to be flexibile, and that
means no default ranks. In this tutorial, we're going to go over the basics of
getting a server up and running. Please note that maestro is NOT compatible with
FAdmin (or ULX). If you're running DarkRP, you'll need to remove it by browsing
to darkrp/gamemode/modules and deleting the "fadmin" folder. You can view the
availalbe commands and specific command help by using the console command "ms
help" or the chat command "!help" at any time. From now on we'll be running
commands from the server console with "ms <command>". View the next page with
"ms tutorial 2".
]]
tutorial[2] = [[
    If you run "ms ranks", you'll see that there's one rank: user. Let's add
another one:

    ms rankadd admin user kick ban

    This will add a rank called admin that inherits from user and has access to
the kick and ban commands. A rank (rank 1) that inherits from another rank
(rank 2) will have all the permissions that rank 2 has (and ever will have) and
rank 2 will not be able to target rank 1 by default.
]]
tutorial[3] = [[
    Typing commands into the server console sucks, so let's add an owner rank
with access to everything:

    ms rankadd owner admin *

    When adding new ranks, writing a star (*) instead of permissions will give the
rank access to all current commands. Add yourself to this rank:

    ms userrank <yournamehere> owner

    You can switch away from the server console and use either console (ms) or
chat (!) commands now. I'll be using console because you're already reading this
tutorial in the console.
]]
tutorial[4] = [[
    How about a superadmin rank?

    ms rankadd superadmin admin slap scale

    Okay, that's nice, but now we've run into an issue: Owner and superadmin
both inherit from admin. They are equal owner can't target superadmin. We can
fix the heirarchy by setting owner's inheriting rank:

    ms ranksetinherits owner superadmin

    Order restored.
]]
tutorial[5] = [[
    "But now, addons think that my admins and superadmins aren't admins or
superadmins!" We can fix that with flags. The 'admin' and 'superadmin' flags
tell the rest of GMod which ranks are admins and superadmins. Flags with be
inherited by ranks just as permissions are. Add some now to your ranks:

    ms rankflag admin admin
    ms rankflag superadmin superadmin

    Now, admin, superadmin, and owner will all be recognized as admins, and
superadmin and owner will be recognized as superadmins.
]]

maestro.command("decals", {}, function(caller)
		for _, ply in pairs( player.GetAll() ) do
			ply:ConCommand( "r_cleardecals" )
		end
    return false, "cleaned up the decals"
end, [[
Clears the decals.]])

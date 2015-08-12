if SERVER then
    CreateConVar("maestro_motd", "", FCVAR_SERVER_CAN_EXECUTE + FCVAR_ARCHIVE, "MOTD URL.")
    util.AddNetworkString("maestro_motd")
    maestro.hook("PlayerInitialSpawn", "maestro_motd", function(ply)
        ply:ConCommand("ms motd")
    end)
end
maestro.command("motd", {}, function(caller)
    local motd = GetConVarString("maestro_motd")
    if #motd < 4 then
        return true, "This server has not set up their MOTD yet!"
    end
    net.Start("maestro_motd")
        net.WriteString(motd)
    net.Send(caller)
end, [[
Opens the MOTD.
]])
maestro.command("motdset", {"url"}, function(caller, ...)
    local url = table.concat({...})
    if url == "" then
        RunConsoleCommand("maestro_motd", "")
        return false, "reset the MOTD"
    end
    local inv = url:match("[^%w%-%._~:/%?#%[%]@%!%$&'%(%)%*%+=%%]")
    if inv then
        return true, "Invalid URL! (illegal character: " .. inv .. ")"
    end
    RunConsoleCommand("maestro_motd", url)
    return false, "set the MOTD to %1"
end)
if CLIENT then
    net.Receive("maestro_motd", function()
        local url = net.ReadString()
        if not url:find("https?://") then
            url = "http://" .. url
        end
        if maestro_motd then maestro_motd:Remove() end
        maestro_motd = vgui.Create("DHTML")
        maestro_motd:SetSize(ScrW(), ScrH())
        maestro_motd:Center()
        maestro_motd:MakePopup()
        maestro_motd:SetScrollbars(false)
    	maestro_motd:SetVerticalScrollbarEnabled(false)
        maestro_motd:SetAllowLua(true)
        maestro_motd:SetHTML([[
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="utf-8">
	<title>Bootstrap 3</title>
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<meta name="description" content="">
	<meta name="author" content="">

	<!--link rel="stylesheet/less" href="less/bootstrap.less" type="text/css" /-->
	<!--link rel="stylesheet/less" href="less/responsive.less" type="text/css" /-->
	<!--script src="js/less-1.3.3.min.js"></script-->
	<!--append ‘#!watch’ to the browser URL, then refresh the page. -->

	<link rel="stylesheet" href=" https://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/css/bootstrap.min.css">


	<!-- Latest compiled and minified JavaScript -->
	<script src=" https://ajax.googleapis.com/ajax/libs/jquery/1.11.2/jquery.min.js"></script>
	<script src=" https://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/js/bootstrap.min.js"></script>
    <script>
        function resizeIframe(obj) {
            obj.style.height = obj.contentWindow.document.body.scrollHeight + 'px';
        }
    </script>
    <style>
        body {
            background-color: transparent;
        }
        ::-webkit-scrollbar {
			display: none;
		}
    </style>
</head>

<body>
<button onclick="console.log('maestro_close')">Close MOTD</button>
<div class="container-fluid">
    <!-- Modal -->
    <div class="modal fade" id="myModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h4 class="modal-title" id="myModalLabel">Message Of The Day</h4>
          </div>
          <div class="modal-body">
              <iframe src="]] .. url .. [[" frameborder="0" allowtransparency="true" width="100%" height="100%" ></iframe>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-default" data-dismiss="modal" onclick="console.log('maestro_close')">Close</button>
          </div>
        </div>
        <!-- /.modal-content -->
      </div>
      <!-- /.modal-dialog -->
    </div>
    <!-- /.modal -->
</div>
<script>
    $('#myModal').modal('show');
</script>
</body>
</html>
]])
        function maestro_motd:ConsoleMessage(msg)
            if msg == "maestro_close" then
                self:Remove()
            end
        end
    end)
end

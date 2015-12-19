local function escape(str)
	str = str:gsub("<", "&lt;")
	str = str:gsub(">", "&gt;")
	return str:gsub("(['\"])", "\\%1")
end
maestro.command("announce", {"text", "title:optional", "style:optional"}, function(caller, text, title, style)
    net.Start("maestro_announce")
        net.WriteString(text)
        net.WriteString(style or "primary")
        net.WriteString(title or "Attention!")
    net.Broadcast()
    if title then
        if style then
            return false, "made an announcement with text %1, title %2, and style %3"
        end
        return false, "made an announcement with text %1 and title %2"
    end
    return false, "made an announcement with text %1"
end, [[
Broadcasts a message on everybody's screen. Possible values for style:
	primary
	success
	info
	warning
	danger]])
if SERVER then
    util.AddNetworkString("maestro_announce")
end
function maestro.announce(text, title, style)
	title = title or "Announcement"
	text = text or ""
	style = style or "primary"
	if SERVER then
		net.Start("maestro_announce")
			net.WriteString(text)
			net.WriteString(style)
			net.WriteString(title)
		net.Broadcast()
	end
	if CLIENT then
		maestro_announce:Call([[
	document.getElementById("panel-title").innerHTML = "]] .. title .. [[";
	document.getElementById("panel-body").innerHTML = "]] .. text .. [[";
	document.getElementById("panel").className = "panel panel-]] .. style .. [[";
	]])
	    maestro_announce:MoveTo(ScrW()/2 - 320, 20, 1, 0, 0.1, function()
	        timer.Simple(5, function()
	            maestro_announce:MoveTo(ScrW()/2 - 320, -180, 1, 0, 2)
	        end)
	    end)
	end
end
if not CLIENT then return end
net.Receive("maestro_announce", function()
    local text = escape(net.ReadString())
    local style = escape(net.ReadString())
    local title = escape(net.ReadString())
    maestro.announce(text, title, style)
end)
if maestro_announce then
    maestro_announce:Remove()
end
timer.Create("maestro_announce", 1, 0, function()
	maestro_announce = vgui.Create("DHTML")
	if not maestro_announce then
		return
	else
		timer.Remove("maestro_announce")
	end
	maestro_announce:SetSize(640, 180)
	maestro_announce:SetPos(ScrW()/2 - 320, -180)
	maestro_announce:SetHTML([[
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

	<style>
		.noselect {
			-webkit-touch-callout: none;
			-webkit-user-select: none;
			-khtml-user-select: none;
			-moz-user-select: none;
			-ms-user-select: none;
			user-select: none;
			cursor:default;
		}
		.form-control-inline {
			min-width: 0;
			width: auto;
			display: inline;
		}
		.affix {
			width: 809px;
		}
		body {
			background-color: transparent;
		}
		.nopad {
			padding-bottom: 0px;
		}
	</style>
</head>
<body>
	<div class="container">
		<div class="row clearfix">
            <div class="col-md-12">
                <div class="panel panel-primary" id="panel">
                    <div class="panel-heading">
                        <h3 class="panel-title" id="panel-title">
                            Panel title
                        </h3>
                    </div>
                    <div class="panel-body" id="panel-body">
                        Panel content
                    </div>
                </div>
            </div>
		</div>
	</div>
</body>
]])
end)

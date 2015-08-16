if SERVER then
	util.AddNetworkString("maestro_menu")
end
maestro.command("menu", {}, function(caller)
	if not caller then return true, "You can't open the menu from the server console!" end
	net.Start("maestro_menu")
	net.Send(caller)
end, [[
Opens a menu for running commands.]])

if not CLIENT then return end
local function populatecommands()
	local ret = ""
	local cmds = {}
	for cmd in pairs(maestro.commands) do
		cmds[#cmds + 1] = cmd
	end
	table.sort(cmds)
	for i = 1, #cmds do
		local cmd = cmds[i]
		if maestro.rankget(maestro.userrank(LocalPlayer())).perms[cmd] then
			ret = ret .. [[
<li><a onclick="resetPills(); this.parentNode.className = 'active'; console.log('RUNLUA: maestromenuupdate(\']] .. cmd .. [[\')');">]]..cmd..'</a></li>\n'
		else
			ret = ret .. [[
<li class="disabled"><a>]]..cmd..'</a></li>\n'
		end
	end
	return ret
end
local function escape(str)
	str = str:gsub("<", "&lt;")
	str = str:gsub(">", "&gt;")
	return str:gsub("(['\"])", "\\%1")
end
local curcmd = ""
function maestromenuupdate(cmd)
	curcmd = cmd
	maestro_menu:Call([[
document.getElementById("commandname").innerHTML = "]] .. cmd .. [[";]])
	maestro_menu:Call([[
document.getElementById("commandhelp").innerHTML = "]] .. maestro.commands[cmd].help:gsub("\n", "<br>") .. [[";]])
	local function args(t)
		local ret = ""
		for i = 1, #t do
			ret = ret .. " &lt;" .. t[i] .. "&gt;"
		end
		return ret
	end
	maestro_menu:Call([[
document.getElementById("commandsyntax").innerHTML = "ms ]] .. cmd .. args(maestro.commands[cmd].args) .. [[";]])
	maestro_menu:Call([[
document.getElementById("commandform").innerHTML = "";]])
	for i = 1, #maestro.commands[cmd].args do
		local arg = maestro.commands[cmd].args[i]
		local type, desc = arg:match("^%w+"), arg:match(":(%w+)")
		local code = [[
<input type="text" class="form-control form-control-inline" placeholder="]] .. type .. (desc and ":" .. desc or "") .. [[" id="cmdarg_]] .. i .. [["></input>]]
		if type == "player" then
			local function plys()
				local ret = ""
				for k, ply in pairs(player.GetAll()) do
					ret = ret .. [[<li><a href="#" onclick="this.parentNode.parentNode.parentNode.children[0].innerHTML = \']] .. escape(ply:Nick()) .. [[ \' + caret(); this.parentNode.parentNode.parentNode.children[0].value = \'$]] .. ply:EntIndex() .. [[\'; return false;">]] .. escape(ply:Nick()) .. [[</a></li>]]
				end
				return ret
			end
			code = [[
<div class="btn-group">\
	<button class="btn btn-default btn-sm dropdown-toggle" type="button" data-toggle="dropdown" aria-expanded="false" id="cmdarg_]] .. i .. [[">\
		Select Player <span class="caret"></span>\
	</button>\
	<ul class="dropdown-menu" role="menu">]] .. plys() .. [[</ul>\
</div>]]
		end
		maestro_menu:Call([[ $("#commandform").append(']] .. code .. [[');]])
	end
	maestro_menu:Call([[
$("#commandform").append('<button type="submit" class="btn btn-default form-control-inline" onclick="runCommand(]] .. #maestro.commands[cmd].args .. [[);">\
	Submit\
</button>');]])
end
local submitargs = {}
function maestromenustart()
	submitargs = {}
end
function maestromenuadd(a)
	if a == "MAESTRO_NOVALUE" then
		a = nil
	end
	submitargs[#submitargs + 1] = a
end
function maestromenuend()
	RunConsoleCommand("ms", curcmd, unpack(submitargs))
end

net.Receive("maestro_menu", function()
	if maestro_menu then maestro_menu:Remove() end
	maestro_menu = vgui.Create("DHTML")
	maestro_menu:SetSize(1024, 576)
	maestro_menu:Center()
	maestro_menu:MakePopup()
	maestro_menu:SetAllowLua(true)
	maestro_menu:SetScrollbars(false)
	maestro_menu:SetVerticalScrollbarEnabled(false)
	maestro_menu:SetHTML([[
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
		function resetPills() {
			var a = document.getElementById("commandpills").children;
			for (var i = 0; i < a.length; i++) {
				if (a[i].classList.contains("active")) {
					a[i].classList.remove("active");
				}
			}
		}
		function toTop() {
			$("html, body").animate({
				scrollTop: 0
			}, 600);
		}
		function caret() {
			return '<span class="caret"></span>'
		}
		function runCommand(num) {
			console.log("RUNLUA: maestromenustart()");
			for (i = 1; i <= num; i++) {
				var argval = document.getElementById("cmdarg_" + i).arg_value
				var val = document.getElementById("cmdarg_" + i).value
				if (argval) {
					console.log("RUNLUA: maestromenuadd('" + argval + "')");
				} else if (val) {
					console.log("RUNLUA: maestromenuadd('" + val + "')");
				} else {
					console.log("RUNLUA: maestromenuadd('MAESTRO_NOVALUE')");
				}
			}
			console.log("RUNLUA: maestromenuend()");
		}
	</script>

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
		::-webkit-scrollbar {
			display: none;
		}
	</style>
</head>

<body>
<div class="container">
	<div class="row clearfix noselect">
		<div class="col-md-12 column">
			<nav class="navbar navbar-default navbar-fixed-top" role="navigation">
				<div align="right">
					<button type="button" class="close" aria-label="Close" align="right" onclick="console.log('RUNLUA: maestro_menu:Remove()');">
						<span aria-hidden="true">&times;&nbsp;</span>
					</button>
				</div>
				<div class="navbar-header">
					<a class="navbar-brand">maestro</a>
				</div>
			</nav>
			<h3>
				h3. Lorem ipsum dolor sit amet.
			</h3>
		</div>
	</div>
	<div class="row clearfix">
		<div class="col-xs-2 column noselect">
			<ul class="nav nav-pills nav-stacked" id="commandpills">
				]] .. populatecommands() .. [[
			</ul>
		</div>
		<div class="col-xs-10 column">
			<div data-spy="affix" id="affix">
				<div class="panel panel-primary">
					<div class="panel-heading">
						<h3 class="panel-title" id="commandname">&nbsp;</h3>
					</div>
					<div class="panel-body">
						<div class="highlight">
							<pre><code class="language-html" data-lang="html" id="commandsyntax"> </code></pre>
						</div>
						<dl>
							<span id="commandhelp">

							</span>
						</dl>
						<div class="well noselect">
							<div class="controls" id="commandform">

							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>
</body>
</html>
]])
end)

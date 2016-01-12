local votes = {}
local voteid = 0
maestro.command("vote", {"title", "options:multiple"}, function(caller, title, ...)
	local args = {...}
	maestro.vote(title, args, function(option, voted, total)
		if option then
			maestro.chat(nil, Color(255, 255, 255), "Option \"", option, "\" has won. (", voted, "/", total, ")")
		else
			maestro.chat(nil, Color(255, 255, 255), "No options have won.")
		end
	end)
	return false, "started a vote \"%1\""
end, [[
Starts a vote with the given options.]])
maestro.command("votekick", {"player:target", "reason"}, function(caller, targets, reason)
	if #targets < 1 then
		return true, "Query matched no players."
	elseif #targets > 1 then
		return true, "Query matched multiple players."
	end
	if reason then
		reason = "\"" .. reason .. "\""
	end
	maestro.vote("Kick " .. targets[1]:Nick() .. " for " .. (reason or "no reason") .. "?", {"Yes, kick this player.", "No, do not kick this player."}, function(option, voted, total)
		if option then
			maestro.chat(nil, Color(255, 255, 255), "Option \"", option, "\" has won. (", voted, "/", total, ")")
			if option == "Yes, kick this player." then
				maestro.chat(nil, Color(255, 255, 255), "Player ", targets[1], " will be kicked.")
				targets[1]:Kick("You have been voted off")
			else
				maestro.chat(nil, Color(255, 255, 255), "No action will be taken.")
			end
		else
			maestro.chat(nil, Color(255, 255, 255), "No options have won.")
		end
	end)
	if reason then
		return false, "started a votekick against %1 for \"%2\""
	end
	return false, "started a votekick against %1"
end, [[
Starts a vote to kick the target for an optional reason.]])
maestro.command("voteban", {"player:target", "time", "reason"}, function(caller, targets, time, reason)
	if #targets < 1 then
		return true, "Query matched no players."
	elseif #targets > 1 then
		return true, "Query matched multiple players."
	end
	if reason then
		reason = "\"" .. reason .. "\""
	end
	maestro.vote("Ban " .. targets[1]:Nick() .. " for " .. maestro.time(time) .. "? (" .. (reason or "no reason") .. ")", {"Yes, ban this player.", "No, do not ban this player."}, function(option, voted, total)
		if option then
			maestro.chat(nil, Color(255, 255, 255), "Option \"", option, "\" has won. (", voted, "/", total, ")")
			if option == "Yes, ban this player." then
				maestro.chat(nil, Color(255, 255, 255), "Player ", targets[1], " will be banned.")
				maestro.ban(targets[1], time, "Voted: " .. (reason or "no reason"))
			else
				maestro.chat(nil, Color(255, 255, 255), "No action will be taken.")
			end
		else
			maestro.chat(nil, Color(255, 255, 255), "No options have won.")
		end
	end)
	if reason then
		return false, "started a voteban against %1 for %2 (\"%3\")"
	end
	return false, "started a voteban against %1 for %2"
end, [[
Starts a vote to ban the target for the specified time and an optional reason.]])
maestro.command("voteclean", {}, function(caller)
	maestro.vote("Clean up the map?", {"Yes", "No"}, function(option, voted, total)
		if option and option == "Yes" then
			maestro.chat(nil, Color(255, 255, 255), "The map will be cleaned in 30 seconds. (", voted, "/", total, ")")
			maestro.announce("The map will be cleaned up in 30 seconds.", "Map Clean Up", "warning")
			timer.Simple(15, function()
				maestro.chat(nil, Color(255, 255, 255), "The map will be cleaned in 15 seconds.")
				timer.Simple(10, function()
					maestro.chat(nil, Color(255, 255, 255), "The map will be cleaned in 5 seconds.")
					for i = 1, 4 do
						timer.Simple(i, function()
							maestro.chat(nil, Color(255, 255, 255), "The map will be cleaned in ", 5 - i, " seconds.")
						end)
						timer.Simple(5, function()
							game.CleanUpMap()
						end)
					end
				end)
			end)
		else
			maestro.chat(nil, Color(255, 255, 255), "The map will not be cleaned.")
		end
	end)
	return false, "started a vote to clean the map"
end, [[
Starts a vote to clean the map.]])
maestro.command("veto", {}, function(caller)
	if not votes[caller] or not votes[caller][1] then
		return true, "You have no active vote!"
	end
	local id = votes[caller][1]
	for _, ply in pairs(player.GetAll()) do
		if votes[ply][1] == id then
			table.remove(votes[ply], 1)
		end
	end
	net.Start("maestro_voteover")
		net.WriteUInt(id, 16)
		net.WriteUInt(0, 4)
	net.Broadcast()
	votes[id].callback()
	timer.Remove("maestro_vote_" .. id)
	return false, "vetoed the vote \"" .. votes[id].title .. "\""
end, [[
Stops the current vote.]])




if SERVER then
	function maestro.vote(title, args, callback, targets)
		targets = targets or player.GetAll()
		voteid = voteid + 1
		local id = voteid
		net.Start("maestro_votenew")
			net.WriteString(title)
			net.WriteUInt(math.min(#args, 9), 4)
			for i = 1, math.min(#args, 9) do
				net.WriteString(args[i])
			end
		net.Send(targets)
		
		for _, ply in pairs(targets) do
			votes[ply] = votes[ply] or {}
			table.insert(votes[ply], id)
			timer.Simple(60, function()
				if votes[ply][1] == id then
					table.remove(votes[ply], 1)
				end
			end)
		end
		votes[id] = {unpack(args)}
		votes[id].title = title
		votes[id].results = {}
		votes[id].callback = callback
		votes[id].targets = targets
		for i = 1, #args do
			votes[id].results[i] = 0
		end
		timer.Create("maestro_vote_" .. id, 60, 1, function()
			if votes[id] then
				local plys = #targets
				local max = 0
				local winner
				for i = 1, #votes[id].results do
					if votes[id].results[i] > max then
						max = votes[id].results[i]
						if max / plys > 0.5 then
							winner = i
						end
					end
				end
				if winner then
					local option = votes[id][winner]
					callback(option, max, plys)
					net.Start("maestro_voteover")
						net.WriteUInt(id, 16)
						net.WriteUInt(winner, 4)
					net.Send(targets)
				else
					callback()
				end
			end
		end)
	end
	util.AddNetworkString("maestro_votenew")
	util.AddNetworkString("maestro_votecast")
	util.AddNetworkString("maestro_voteover")
	net.Receive("maestro_votecast", function(len, ply)
		local num = net.ReadUInt(4)
		if votes[ply] and votes[ply][1] then
			local id = votes[ply][1]
			if num == 0 or not votes[id][num] then
				table.remove(votes[ply], 1)
			elseif not votes[id][ply] then
				votes[id].results[num] = votes[id].results[num] + 1
				votes[id][ply] = true
				net.Start("maestro_votecast")
					net.WriteUInt(id, 16)
					net.WriteUInt(num, 4)
				net.Send(votes[id].targets)
				table.remove(votes[ply], 1)
			end
		end
	end)
end

if not CLIENT then return end
if maestro_votepanel then
	maestro_votepanel:Remove()
end
local function escape(str)
	str = str:gsub("<", "&lt;")
	str = str:gsub(">", "&gt;")
	return str:gsub("(['\"])", "\\%1")
end
local function nextvote()
	for i = 1, #votes do
		if not votes[i].done then
			return votes[i], i
		end
	end
end
local function addvote(title, ...)
	voteid = voteid + 1
	local id = voteid
	table.insert(votes, {id = id, done = false})
	local args = {...}
	local function options()
		local ret = ""
		for i = 1, #args do
			ret = ret .. [[
			<li class="list-group-item" id="listitem_]] .. id .. [[_]] .. i .. [[">\
				<span class="badge" id="badge_]] .. id .. [[_]] .. i .. [[">0</span>\
				]] .. i .. ". " .. escape(args[i]) .. [[\
			</li>\
			]]
		end
		return ret
	end
	maestro_votepanel:Call([[
$("#voterow").append('\
<div class="col-xs-3 column id="column_]] .. id .. [[">\
	<div class="panel panel-primary" id="panel_]] .. id .. [[">\
		<div class="panel-heading">\
			<h3 class="panel-title">]] .. escape(title) .. [[</h3>\
		</div>\
		<div class="panel-body nopad">\
			<ul class="list-group">\
				]] .. options() .. [[
				<li class="list-group-item">\
					0. Dismiss\
				</li>\
			</ul>\
			<div class="progress">\
				<div class="progress-bar progress-bar-striped active" role="progressbar" aria-valuenow="45" aria-valuemin="0" aria-valuemax="100" style="width: 0%" id="progressbar_]] .. id .. [[">\
				</div>\
			</div>\
		</div>\
	</div>\
</div>');
setInterval(function() {
	var bar = document.getElementById("progressbar_]] .. id .. [[");
	if (bar) {
		bar.style.width = (Number(bar.style.width.substring(0, bar.style.width.length - 1)) + (1 / (20 * 58)) * 100) + "%";
	}
}, 50);
]])
	timer.Simple(63, function()
		if votes[1] and votes[1].id == id then
			maestro_votepanel:Call([[
var a = document.getElementById("voterow");
a.removeChild(a.childNodes[1]);
]])
			table.remove(votes, 1)
		end
	end)
end
maestro.hook("PlayerBindPress", "maestro_voting", function(plu, bind, pressed)
	if not pressed then return end
	if bind:sub(1, 4) == "slot" then
		local num = tonumber(bind:sub(5))
		if num and nextvote() then
			net.Start("maestro_votecast")
				net.WriteUInt(num, 4)
			net.SendToServer()
			if num ~= 0 then
				maestro_votepanel:Call([[
var a = document.getElementById("listitem_]] .. nextvote().id .. [[_]] .. num .. [[");
a.className = "list-group-item list-group-item-warning";
]])
				nextvote().done = true
			else
				local vote, i = nextvote()
				table.remove(votes, i)
				maestro_votepanel:Call([[
var a = document.getElementById("voterow");
a.removeChild(a.childNodes[]] .. i .. [[]);
]])
			end
			return true
		end
	end
end)
net.Receive("maestro_votenew", function()
	local title = net.ReadString()
	local count = net.ReadUInt(4)
	local args = {}
	for i = 1, count do
		args[i] = net.ReadString()
	end
	addvote(title, unpack(args))
end)
net.Receive("maestro_votecast", function()
	local id = net.ReadUInt(16)
	local num = net.ReadUInt(4)
	maestro_votepanel:Call([[
var badge = document.getElementById("badge_]] .. id .. [[_]] .. num .. [[");
badge.innerHTML = Number(badge.innerHTML) + 1;
]])
end)
net.Receive("maestro_voteover", function()
	local id = net.ReadUInt(16)
	local num = net.ReadUInt(4)
	if num ~= 0 then
		maestro_votepanel:Call([[
var voted = document.getElementsByClassName("list-group-item-warning")[0]
if (voted && voted.id != "listitem_]] .. id .. [[_]] .. num .. [[")
{
	voted.className = "list-group-item list-group-item-danger";
}
var win = document.getElementById("listitem_]] .. id .. [[_]] .. num .. [[");
win.className = "list-group-item list-group-item-success";
]])
	else
		local pos
		for i = 1, #votes do
			if votes[i].id == id then
				pos = i
				table.remove(votes, i)
				break
			end
		end
		if pos then
			maestro_votepanel:Call([[
var a = document.getElementById("voterow");
a.removeChild(a.childNodes[]] .. pos .. [[]);
]])
		end
	end
end)
timer.Create("maestro_voting", 1, 0, function()
	maestro_votepanel = vgui.Create("DHTML")
	if not maestro_votepanel then
		return
	else
		timer.Remove("maestro_voting")
	end
	maestro_votepanel:SetSize(1280, 720)
	maestro_votepanel:SetPos(0, ScrH() * 0.3)
	maestro_votepanel:SetAllowLua(true)
	maestro_votepanel:SetHTML([[
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
		function toTop() {
			$("html, body").animate({
				scrollTop: 0
			}, 600);
		}
		function caret() {
			return '<span class="caret"></span>'
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
		body {
			background-color: transparent;
		}
		.nopad {
			padding-bottom: 0px;
		}
	</style>
</head>
<body class="noselect">
	<div class="container">
		<div class="row clearfix" id="voterow">
		</div>
	</div>
</body>
]])
end)

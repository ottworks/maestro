TIME_SECOND = 1
TIME_MINUTE = TIME_SECOND * 60
TIME_HOUR = TIME_MINUTE * 60
TIME_DAY = TIME_HOUR * 24
TIME_WEEK = TIME_DAY * 7
TIME_FORTNIGHT = TIME_WEEK * 2
TIME_MONTH = TIME_DAY * (365.2425/12)
TIME_QUARTER = TIME_MONTH * 3
TIME_YEAR = TIME_DAY * 365.2425
TIME_DECADE = TIME_YEAR * 10
TIME_CENTURY = TIME_DECADE * 10
TIME_MILLENNIUM = TIME_CENTURY * 10
TIME_AGE = TIME_YEAR * 1000000
TIME_EPOCH = TIME_AGE * 10
TIME_ERA = TIME_EPOCH * 10
TIME_AEON = TIME_ERA * 10

local function plural(a, n)
	if n == 1 then
		return a
	end
	if a == "century" then
		return "centuries"
	elseif a == "millennium" then
		return "millennia"
	end
	return a .. "s"
end

function maestro.toseconds(str)
	str = tostring(str)
	local cursor = 1
	local num
	local total = 0
	while true do
		local s1, s2 = string.find(str, "%d+", cursor)
		local u1, u2 = string.find(str, "%a+", cursor)
		if s1 and ((u1 and s1 < u1) or not u1) then
			num = str:sub(s1, s2)
			cursor = s2
		elseif u1 and ((s1 and u1 < s1) or not s1) then
			if u1 ~= u2 and not num then
				error("invalid string")
			end
			local u = str:sub(u1, u2)
			if u == "s" then
				total = total + num
			elseif u == "m" then
				total = total + num * TIME_MINUTE
			elseif u == "h" then
				total = total + num * TIME_HOUR
			elseif u == "d" then
				total = total + num * TIME_DAY
			elseif u == "w" then
				total = total + num * TIME_WEEK
			elseif u == "f" then
				total = total + num * TIME_FORTNIGHT
			elseif u == "M" then
				total = total + num * TIME_MONTH
			elseif u == "q" then
				total = total + num * TIME_QUARTER
			elseif u == "y" then
				total = total + num * TIME_YEAR
			elseif u == "D" then
				total = total + num * TIME_DECADE
			elseif u == "c" then
				total = total + num * TIME_CENTURY
			elseif u == "a" then
				total = total + num * TIME_AGE
			elseif u == "e" then
				total = total + num * TIME_EPOCH
			elseif u == "E" then
				total = total + num * TIME_ERA
			elseif u == "A" then
				total = total + num * TIME_AEON
			end
			num = nil
			cursor = u2
		end
		cursor = cursor + 1
		if cursor > #str then
			break
		end
	end
	if num then
		total = total + num
	end
	return total
end

function maestro.time(num, limit)
	if not tonumber(num) then error("invalid time") end
	if num == 0 then
		return "all of time"
	end
	local ret = {}
	while not limit or limit > 0 do
		if num >= TIME_AEON then
			local c = math.floor(num / TIME_AEON)
			ret[#ret + 1] = c .. " " .. plural("aeon", c)
			num = num - TIME_AEON * c
		elseif num >= TIME_ERA then
			local c = math.floor(num / TIME_ERA)
			ret[#ret + 1] = c .. " " .. plural("era", c)
			num = num - TIME_ERA * c
		elseif num >= TIME_EPOCH then
			local c = math.floor(num / TIME_EPOCH)
			ret[#ret + 1] = c .. " " .. plural("epoch", c)
			num = num - TIME_EPOCH * c
		elseif num >= TIME_AGE then
			local c = math.floor(num / TIME_AGE)
			ret[#ret + 1] = c .. " " .. plural("age", c)
			num = num - TIME_AGE * c
		elseif num >= TIME_MILLENNIUM then
			local c = math.floor(num / TIME_MILLENNIUM)
			ret[#ret + 1] = c .. " " .. plural("millennium", c)
			num = num - TIME_MILLENNIUM * c
		elseif num >= TIME_CENTURY then
			local c = math.floor(num / TIME_CENTURY)
			ret[#ret + 1] = c .. " " .. plural("century", c)
			num = num - TIME_CENTURY * c
		elseif num >= TIME_DECADE then
			local c = math.floor(num / TIME_DECADE)
			ret[#ret + 1] = c .. " " .. plural("decade", c)
			num = num - TIME_DECADE * c
		elseif num >= TIME_YEAR then
			local c = math.floor(num / TIME_YEAR)
			ret[#ret + 1] = c .. " " .. plural("year", c)
			num = num - TIME_YEAR * c
		elseif num >= TIME_MONTH then
			local c = math.floor(num / TIME_MONTH)
			ret[#ret + 1] = c .. " " .. plural("month", c)
			num = num - TIME_MONTH * c
		elseif num >= TIME_WEEK then
			local c = math.floor(num / TIME_WEEK)
			ret[#ret + 1] = c .. " " .. plural("week", c)
			num = num - TIME_WEEK * c
		elseif num >= TIME_DAY then
			local c = math.floor(num / TIME_DAY)
			ret[#ret + 1] = c .. " " .. plural("day", c)
			num = num - TIME_DAY * c
		elseif num >= TIME_HOUR then
			local c = math.floor(num / TIME_HOUR)
			ret[#ret + 1] = c .. " " .. plural("hour", c)
			num = num - TIME_HOUR * c
		elseif num >= TIME_MINUTE then
			local c = math.floor(num / TIME_MINUTE)
			ret[#ret + 1] = c .. " " .. plural("minute", c)
			num = num - TIME_MINUTE * c
		elseif num >= TIME_SECOND then
			local c = math.floor(num / TIME_SECOND)
			ret[#ret + 1] = c .. " " .. plural("second", c)
			num = num - TIME_SECOND * c
		else
			break
		end
		if limit then
			limit = limit - 1
		end
	end
	local str = ""
	for i = 1, #ret do
		if i == 1 then
			str = str .. ret[i]
		elseif i == #ret then
			str = str .. " and " .. ret[i]
		else
			str = str .. ", " .. ret[i]
		end
	end
	return str
end
local main = {}

function main.setup()
	os.execute("stty raw -echo min 0 time 0")
	io.write("\27[2J\27[?25l")
end

function main.exit()
	os.execute("stty sane")
	io.write("\27[?25h\27[2J\27[H\27[0;37m")
	io.flush()
end

function main.getTerminalSize()
	local handle = io.popen("stty size 2>/dev/null")
	if not handle then return 80, 24 end

	local result = handle:read("*a")
	handle:close()

	local height, width = result:match("(%d+)%s+(%d+)")

    if height and width then return tonumber(width), tonumber(height)
	else return 80, 24 end
end

function main.clearScreen()
    io.write("\27[2J") -- Clears screen
    io.flush()
end

function main.fg256(n)
    return "\27[38;5;" .. n .. "m"
end

function main.bg256(n)
    return "\27[48;5;" .. n .. "m"
end

local colors = {
	black  = "\27[0;30m",
	red    = "\27[0;31m",
	green  = "\27[0;32m",
	yellow = "\27[0;33m",
	blue   = "\27[0;34m",
	purple = "\27[0;35m",
	cyan   = "\27[0;36m",
	white  = "\27[0;37m",
    boldblack  = "\27[1;30m",
    boldred    = "\27[1;31m",
    boldgreen  = "\27[1;32m",
    boldyellow = "\27[1;33m",
    boldblue   = "\27[1;34m",
    boldpurple = "\27[1;35m",
    boldcyan   = "\27[1;36m",
    boldwhite  = "\27[1;37m"	
}

function main.draw(x, y, symbol, color_name)
    local color = colors[color_name] or ""
    io.write(string.format("\27[%d;%dH%s%s\27[0m", y, x, color, symbol))
end

function main.render(screen, offx, offy)
    offx, offy = offx or 0, offy or 0
    for _, tile in ipairs(screen) do
        main.draw(tile.x + offx, tile.y + offy, tile.symbol, tile.color)
    end
    io.flush()
end

return(main)

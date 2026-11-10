-- test.lua
local main = require("main")
local input = require("input")

main.setup()
local x, y = 10, 10
local screen = {}

local ok, err = pcall(function()
    while true do
    	local screen = {}

        local a = input.getAction()

        if a == "ctrl_c" or a == "q" then break end

		local screen = {
			x = x,
			y = y,
			symbol = "@",
			color = "red"
		}
		
        if a then 
            if a == "arrow_up"    then y = y - 1 end
            if a == "arrow_down"  then y = y + 1 end
            if a == "arrow_left"  then x = x - 1 end
            if a == "arrow_right" then x = x + 1 end

        end
        
        main.render(screen, 0, 0)
        io.flush()
    end
end)

main.exit()
if not ok then print(err) end

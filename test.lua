-- test.lua
local main = require("main")
local input = require("input")
local render = require("LDM")

main.setup()
render.init()


local x, y = 10, 10

local world = {
	terrain={},
	buildings={},
	item={},
	occupant={}
} 

local player = {x = 0, y = 0}

world.terrain[10] = {}
world.terrain[10][10] = { symbol = ".", color = "green" }
		
local ok, err = pcall(function()
    while true do
    	local screen = {}

        local a = input.getAction()

        if a == "ctrl_c" or a == "q" then break end
		
        if a then 
            if a == "arrow_up"    then y = y - 1 end
            if a == "arrow_down"  then y = y + 1 end
            if a == "arrow_left"  then x = x - 1 end
            if a == "arrow_right" then x = x + 1 end
		end        

        render.present(world, x, y)
        io.flush()
    end
end)

main.exit()

if not ok then print(err) end

-- renderer.lua
local main = require("main")

local renderer = {}

-- Buffers and viewport state
local front_buffer = {}
local back_buffer = {}
local term_w, term_h = 80, 24

function renderer.init()
    term_w, term_h = main.getTerminalSize()
    -- Initialize buffers with empty state
    for y = 1, term_h do
        front_buffer[y] = {}
        back_buffer[y] = {}
        for x = 1, term_w do
            front_buffer[y][x] = { symbol = " ", color = "black" }
            back_buffer[y][x] = { symbol = " ", color = "black" }
        end
    end
end

-- Clear the back buffer before drawing the new frame
function renderer.clear()
    for y = 1, term_h do
        for x = 1, term_w do
            back_buffer[y][x] = { symbol = " ", color = "black" }
        end
    end
end

-- Set a tile in the back buffer (world coords translated to screen coords via camera)
function renderer.draw_tile(screen_x, screen_y, symbol, color)
    if screen_x >= 1 and screen_x <= term_w and screen_y >= 1 and screen_y <= term_h then
        back_buffer[screen_y][screen_x] = { symbol = symbol, color = color }
    end
end

-- Main render pipeline: Compasses world layers, applies camera, and delta-blits to terminal
function renderer.present(world, camera_x, camera_y)
    term_w, term_h = main.getTerminalSize()
    
    -- 1. Clear back buffer
    renderer.clear()

    -- 2. Composite layers onto back buffer relative to camera offset
    local half_w = math.floor(term_w / 2)
    local half_h = math.floor(term_h / 2)

    for sy = 1, term_h do
        for sx = 1, term_w do
            -- Map screen coordinates to world coordinates
            local wx = camera_x + sx - half_w
            local wy = camera_y + sy - half_h

            -- Check bounds of world
            if wx >= 1 and wx <= world.width and wy >= 1 and wy <= world.height then
                -- Layer priority: Terrain -> Buildings -> Items -> Entities (Pawns)
                local tile = world.terrain[wy] and world.terrain[wy][wx]
                local bldg = world.buildings[wy] and world.buildings[wy][wx]
                local item = world.items and world.items[wy] and world.items[wy][wx]
                local pawn = world.occupant[wy] and world.occupant[wy][wx]

                if pawn then
                    renderer.draw_tile(sx, sy, pawn.symbol, pawn.color)
                elseif item then
                    renderer.draw_tile(sx, sy, item.symbol, item.color)
                elseif bldg then
                    renderer.draw_tile(sx, sy, bldg.symbol, bldg.color)
                elseif tile then
                    renderer.draw_tile(sx, sy, tile.symbol, tile.color)
                end
            end
        end
    end

    -- 3. Delta Blit: Compare back_buffer to front_buffer and output ANSI diffs
    for y = 1, term_h do
        for x = 1, term_w do
            local back = back_buffer[y][x]
            local front = front_buffer[y][x]

            -- Only write to the terminal if this specific cell changed
            if back.symbol ~= front.symbol or back.color ~= front.color then
                -- Move cursor to (y, x) and draw symbol with color
                -- Note: main.draw expects (x, y, symbol, color)
                main.draw(x, y, back.symbol, back.color)
                
                -- Update front buffer state
                front_buffer[y][x] = { symbol = back.symbol, color = back.color }
            end
        end
    end

    io.flush()
end

return renderer

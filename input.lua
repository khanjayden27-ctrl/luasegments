local input = {}

local tty
local function openTty()
    tty = assert(io.open("/dev/tty", "rb"))
    tty:setvbuf("no")
end
openTty()

-- Returns a byte, or nil if nothing arrived within ~0.1s
local function getChar()
    local c = tty:read(1)
    if not c then        -- glibc EOF is sticky, so reopen after a timeout
        tty:close()
        openTty()
    end
    return c
end

function input.init()
    -- no line buffering, no echo, no signal keys, 0.1s read timeout
    os.execute("stty -icanon -echo -isig min 0 time 1")
    openTty()
end

function input.shutdown()
    if tty then tty:close() end
    os.execute("stty sane")
end

local letters = {
    A = "arrow_up", B = "arrow_down", C = "arrow_right", D = "arrow_left",
    H = "home", F = "end",
}
local tildes = {
    ["1"] = "home", ["3"] = "delete", ["4"] = "end",
    ["5"] = "page_up", ["6"] = "page_down",
}
local simple = {
    ["\r"] = "enter", ["\n"] = "enter", ["\127"] = "backspace",
    ["\8"] = "backspace", ["\9"] = "tab", ["\3"] = "ctrl_c",
}

-- Returns an action name, or nil if no key was pressed (idle tick)
function input.getAction()
    local c = getChar()
    if not c then return nil end

    if c ~= "\27" then
        return simple[c] or c
    end

    local n = getChar()
    if not n then return "escape" end          -- bare Esc

    if n == "[" then
        local params = ""
        local final
        repeat                                  -- consume the whole sequence
            final = getChar()
            if not final then return "escape" end
            local b = final:byte()
            if b < 0x40 then params = params .. final end
        until final:byte() >= 0x40
        if final == "~" then
            return tildes[params:match("^%d+")] or "unknown"
        end
        return letters[final] or "unknown"      -- ignores modifiers like 1;5
    elseif n == "O" then
        local final = getChar()
        return letters[final or ""] or "unknown"
    end

    return "alt_" .. n
end

return input

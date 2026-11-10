local function wsaction(action, range, i)
    return function()
        local activews = hl.get_active_workspace()
        if not activews or not activews.id or activews.id < 1 then
            return
        end

        local id = activews.id
        local s = (i - 1) * 10 + (id % 10)
        local t = math.floor((id - 1) / 10) * 10 + i
        local z = (range == "group") and s or t

        if action == "move" then
            return hl.dispatch(hl.dsp.window.move({ workspace = z }))
        end
        return hl.dispatch(hl.dsp.focus({ workspace = z }))
    end
end

local function resize_by_screen(x, y)
    local screen = hl.get_active_monitor()
    if not screen or type(screen.width) ~= "number" or type(screen.height) ~= "number" then
        return nil
    end
    if x == 0 and y == 0 then
        return nil
    end

    local scale = (type(screen.scale) == "number" and screen.scale > 0) and screen.scale or 1
    local width = math.floor(screen.width / scale)
    local height = math.floor(screen.height / scale)
    local w = (type(x) == "number" and x > 0) and math.floor(width * x / 100) or width
    local h = (type(y) == "number" and y > 0) and math.floor(height * y / 100) or height

    return { x = w, y = h, relative = false }
end

local function resize_active_window(x, y)
    local win = hl.get_active_window()
    if not win or not win.size
        or type(win.size.x) ~= "number"
        or type(win.size.y) ~= "number" then
        return nil
    end

    local w = math.floor(win.size.x * (x / 100))
    local h = math.floor(win.size.y * (y / 100))
    if w == 0 and h == 0 then
        return nil
    end
    return { x = w, y = h, relative = true }
end

local function resizer(window, pattern, x_percent, y_percent, actions, exact)
    if not window or not window.title or not pattern then
        return
    end
    local plain = exact and true or false
    if not string.find(window.title, pattern, 1, plain) then
        return
    end

    local disp = (type(actions) == "table") and actions or { actions }
    for _, action in ipairs(disp) do
        hl.dispatch(action)
    end

    local size = resize_by_screen(x_percent, y_percent)
    if size then
        hl.dispatch(hl.dsp.window.resize(size))
    end
    hl.dispatch(hl.dsp.window.set_prop({ prop = "keep_aspect_ratio", value = "true" }))
end

local function move_actions(win)
    local screen = hl.get_active_monitor()
    if not screen
        or type(screen.width) ~= "number"
        or type(screen.height) ~= "number" then
        return nil
    end
    if not win or not win.size
        or type(win.size.x) ~= "number"
        or type(win.size.y) ~= "number"
        or win.size.x <= 0
        or win.size.y <= 0 then
        return nil
    end

    local scale = (type(screen.scale) == "number" and screen.scale > 0) and screen.scale or 1
    local monitor_width = screen.width / scale
    local monitor_height = screen.height / scale
    local scale_factor = (monitor_height / 4) / win.size.y
    local target_width = win.size.x * scale_factor
    local target_height = win.size.y * scale_factor
    local x_resize = math.floor(math.max(200, target_width))
    local y_resize = math.floor(math.max(150, target_height))
    local offset = math.min(monitor_width, monitor_height) * 0.03
    local move_x = math.floor((screen.x or 0) + monitor_width - x_resize - offset)
    local move_y = math.floor((screen.y or 0) + monitor_height - y_resize - offset)

    return {
        hl.dsp.window.resize({ x = x_resize, y = y_resize, window = win }),
        hl.dsp.window.move({ x = move_x, y = move_y, relative = false, window = win }),
    }
end

return {
    resizer = resizer,
    resize_by_screen = resize_by_screen,
    resize_active_window = resize_active_window,
    wsaction = wsaction,
    move_actions = move_actions,
}

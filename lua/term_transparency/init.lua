local M = {}
local private = {}

-- check if the state file exists
M.opts = {
    -- filepath to save transparency state
    transparency_state_file = vim.fn.expand("~") .. "/.local/state/term/transparency.txt",

    -- terminal emulators settings
    term = {
        -- wezterm is the only terminal supported as of now
        wezterm = {
            enabled = true,
            transparency_toggle_file = "", -- filepath to wezterm toggle script
        },
    },

    -- notification settings
    notifications = {
        enabled = true,
    },

    -- callback function to be triggered when transparency changes
    on_transparency_change = function() end,
}

-- toggle transparency
M.toggle_transparency = function()
    private.change_transparency(not vim.g.is_transparent)
end

-- used for easy access of callback
M.on_transparency_change = function() end

-- setup
M.setup = function(opts)
    -- merge user opts with default opts
    if opts then
        M.opts = vim.tbl_deep_extend("force", M.opts, opts)
    end

    -- init plugin
    private.init()
end

private.init = function()
    -- create transparency_state_file if it doesn't exists
    if private.check_if_file_exists() == false then
        private.create_transparency_state_file()
    end

    -- set vim.g.is_transparent
    vim.g.is_transparent = private.get_transparency_file_state()

    -- start watching state file changes
    private.watch_transparency_file()

    -- set easy access for callback
    M.on_transparency_change = M.opts.on_transparency_change

    -- initialize transparency depended plugins
    M.on_transparency_change()

    -- create autocmd to stop watching at VimLeave
    vim.api.nvim_create_autocmd("VimLeave", {
        callback = function()
            private.w.stop()
            private.w:close()
        end,
    })
end

-- check if the transparency_state_file exists
private.check_if_file_exists = function()
    private.filepath = vim.fn.fnamemodify(M.opts.transparency_state_file, ":h")
    private.filename = vim.fn.fnamemodify(M.opts.transparency_state_file, ":t")

    local file = io.open(M.opts.transparency_state_file, "r")

    if file == nil then
        return false
    end

    file:close()
    return true
end

-- create transparency_state_file and set initial value
private.create_transparency_state_file = function()
    vim.fn.system(string.format("mkdir -p %s", private.filepath))

    local file = io.open(M.opts.transparency_state_file, "w")

    if file == nil then
        return
    end

    file:write("false")
    file:close()
end

-- get current transparency_state_file value
private.get_transparency_file_state = function()
    local file = io.open(M.opts.transparency_state_file, "r")

    if file == nil then
        return false
    end

    local value = file:read("*a")
    value = value:gsub("\n", "")
    file:close()

    return value == "true"
end

-- change transparency of nvim and the terminal emulator
private.change_transparency = function(transparency)
    local file = io.open(M.opts.transparency_state_file, "w")

    if file == nil then
        return
    end

    if M.opts.term.wezterm.enabled then
        local wezterm_toggle_cmd = M.opts.term.wezterm.transparency_toggle_file .. " " .. tostring(transparency)

        vim.fn.system("sh " .. wezterm_toggle_cmd)
    end

    file:write(tostring(transparency))
    file:close()
end

-- filepath watcher
private.w = vim.uv.new_fs_event()

-- start watching transparency state file changes
private.watch_transparency_file = function()
    if private.w == nil then
        return
    end

    private.w:start(
        private.filepath,
        {},
        vim.schedule_wrap(function(error, filename, events)
            private.on_change(error, filename, events)
        end)
    )
end

-- on transparency file state changed
private.on_change = function(error, filename, events)
    if error then
        if M.opts.notifications.enabled then
            vim.notify(string.format("term-transparency\n Error: %s", error), vim.log.levels.ERROR)
        end

        return
    end

    if filename == private.filename and (events.change == true or events.rename == true) then
        local current_file_state = private.get_transparency_file_state()

        if current_file_state == vim.g.is_transparent then
            return
        end

        private.sync_state(current_file_state)
    end
end

-- sync file transparency state with terminal transparency state
private.sync_state = function(transparency)
    vim.g.is_transparent = transparency

    M.on_transparency_change()

    if M.opts.notifications.enabled then
        vim.notify(
            string.format(
                "term-transparency\n Terminal mode: %s",
                transparency and "transparent" or "normal",
                vim.log.levels.INFO
            )
        )
    end
end

return M

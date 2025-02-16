local M = {}
local private = {}

-- check if the state file exists
M.opts = {
    transparency_value = 0.80,

    -- terminal emulators settings
    term = {
        kitty = {
            enabled = false,
            socket = "/tmp/kitty.sock", -- socket that kitty listens to
        },

        wezterm = {
            enabled = false,
        },
    },

    -- notification settings
    notifications = {
        enabled = true,
    },

    -- callback function to be triggered when transparency changes
    on_transparency_change = function() end,
}

-- setup
M.setup = function(opts)
    if opts then
        M.opts = vim.tbl_deep_extend("force", M.opts, opts)
    end

    private.init()
end

private.transparency_state_file = vim.fn.expand("~") .. "/.local/state/term/transparency.txt"

private.init = function()
    private.plugin_dir = debug.getinfo(1, "S").source:sub(2):match("(.-)/lua/")

    if private.check_if_file_exists() == false then
        private.create_transparency_state_file()
    end

    if M.opts.term.kitty.enabled then
        private.kitty = {}
        private.kitty.script_file =
            vim.fn.fnamemodify(private.plugin_dir .. "/scripts/toggle_kitty_transparency.sh", ":p")

        private.kitty.socket_dir = vim.fn.fnamemodify(M.opts.term.kitty.socket, ":h")
        private.kitty.socket_file = vim.fn.fnamemodify(M.opts.term.kitty.socket, ":t")
    end

    if M.opts.term.wezterm.enabled then
        private.wezterm = {}
        private.wezterm.script_file =
            vim.fn.fnamemodify(private.plugin_dir .. "/scripts/toggle_wezterm_transparency.sh", ":p")
    end

    private.check_nvim_version()

    vim.g.is_transparent = private.get_transparency_file_state()

    private.watch_transparency_file()

    M.opts.on_transparency_change()

    vim.api.nvim_create_user_command("ToggleTermTransparency", function()
        private.toggle_transparency()
    end, { desc = "Toggle Terminal Transparency" })

    vim.api.nvim_create_autocmd("VimLeave", {
        callback = function()
            if private.w:is_active() then
                private.w:stop()
                private.w:close()
            end
        end,
    })
end

private.check_if_file_exists = function()
    private.filepath = vim.fn.fnamemodify(private.transparency_state_file, ":h")
    private.filename = vim.fn.fnamemodify(private.transparency_state_file, ":t")

    local file = io.open(private.transparency_state_file, "r")

    if file == nil then
        return false
    end

    file:close()

    return true
end

private.create_transparency_state_file = function()
    vim.fn.system(string.format("mkdir -p %s", private.filepath))

    local file = io.open(private.transparency_state_file, "w")

    if file == nil then
        return
    end

    file:write("false")
    file:close()
end

private.check_nvim_version = function()
    local version = vim.api.nvim_exec2("version", { output = true })
    local version_number = string.match(version.output, "NVIM v([0-9]+.[0-9]+)")

    if tonumber(version_number) > 1 then
        private.w = vim.uv.new_fs_event()
    elseif tonumber(string.match(version_number, "0.([0-9]+)")) >= 10 then
        private.w = vim.uv.new_fs_event()
    else
        private.w = vim.loop.new_fs_event()
    end
end

private.get_transparency_file_state = function()
    local file = io.open(private.transparency_state_file, "r")

    if file == nil then
        return false
    end

    local value = file:read("*a")
    value = value:gsub("\n", "")
    file:close()

    return value == "true"
end

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

private.on_change = function(error, filename, events)
    if error then
        if M.opts.notifications.enabled then
            vim.notify(string.format("term-transparency.nvim\nError: %s", error), vim.log.levels.ERROR)
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

private.toggle_transparency = function()
    local file = io.open(private.transparency_state_file, "w")

    if file == nil then
        return
    end

    file:write(tostring(not vim.g.is_transparent))
    file:close()
end

private.sync_state = function(transparency)
    vim.g.is_transparent = transparency

    local transparency_value = transparency and tostring(M.opts.transparency_value) or "1"

    if M.opts.term.kitty.enabled then
        local kitty_toggle_cmd = private.kitty.script_file
            .. " "
            .. private.kitty.socket_file
            .. " "
            .. private.kitty.socket_dir
            .. " "
            .. transparency_value

        vim.fn.system("sh " .. kitty_toggle_cmd)
    end

    if M.opts.term.wezterm.enabled then
        local wezterm_toggle_cmd = private.wezterm.script_file .. " " .. transparency_value

        vim.fn.system("sh " .. wezterm_toggle_cmd)
    end

    M.opts.on_transparency_change()

    if M.opts.notifications.enabled then
        vim.notify(
            string.format(
                "term-transparency.nvim\nTerminal mode: %s",
                transparency and "transparent" or "normal",
                vim.log.levels.INFO
            )
        )
    end
end

return M

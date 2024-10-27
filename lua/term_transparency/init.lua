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

    -- setup autocmd to set transparency mode when the neovim instance gains focus
    want_autocmd = false,

    -- callback function to be triggered when transparency changes
    on_transparency_change = function() end,
}

-- check if the transparency_state_file exists
private.check_if_file_exists = function()
    local file = io.open(M.opts.transparency_state_file, "r")

    if file then
        file:close()
        return true
    else
        return false
    end
end

-- create transparency_state_file and set initial value
private.create_transparency_state_file = function()
    local dirpath = vim.fn.fnamemodify(M.opts.transparency_state_file, ":h")
    vim.fn.system(string.format("mkdir -p %s", dirpath))

    local file = io.open(M.opts.transparency_state_file, "w")
    if file then
        file:write("false")
        file:close()
    end
end

-- get current transparency file state
private.get_transparency_file_state = function()
    local file = io.open(M.opts.transparency_state_file, "r")

    if file then
        local value = file:read("*a")
        value = value:gsub("\n", "")
        file:close()

        return value == "true"
    else
        return false
    end
end

-- change transparency of nvim and the terminal emulator the user want affected
private.change_transparency = function()
    local file = io.open(M.opts.transparency_state_file, "w")

    if file then
        if M.opts.term.wezterm.enabled then
            local wezterm_toggle_cmd = M.opts.term.wezterm.transparency_toggle_file
                .. " "
                .. tostring(vim.g.is_transparent)

            vim.fn.system("sh " .. wezterm_toggle_cmd)
        end

        file:write(tostring(vim.g.is_transparent))
        file:close()

        if M.opts.notifications.enabled then
            vim.notify(
                string.format(
                    "terminal mode: %s",
                    vim.g.is_transparent and "transparent" or "normal",
                    vim.log.levels.INFO
                )
            )
        end

        local toggle_cmd =
            "nvim --server /tmp/nvim.pipe --remote-send \":lua require('term_transparency').on_transparency_change()<CR>\""
        vim.fn.system(toggle_cmd)
    end
end

-- toggle transparency
M.toggle_transparency = function()
    local current_file_state = private.get_transparency_file_state()
    vim.g.is_transparent = not current_file_state

    private.change_transparency()
end

-- set transparency file state to is_transparent global variable
M.sync_state = function()
    local current_file_state = private.get_transparency_file_state()
    vim.g.is_transparent = current_file_state
end

-- used for easy access of callback
M.on_transparency_change = function() end

M.setup = function(opts)
    -- merge user opts with default opts
    if opts then
        M.opts = vim.tbl_deep_extend("force", M.opts, opts)
    end

    -- create transparency_state_file if it doesn't exists
    if private.check_if_file_exists() == false then
        private.create_transparency_state_file()
    end

    -- create autocmd to sync transparency on focus gained
    if M.opts.want_autocmd then
        vim.api.nvim_create_autocmd("FocusGained", {
            callback = function()
                M.opts.on_transparency_change()
            end,
        })
    end

    -- set easy access for callback
    M.on_transparency_change = M.opts.on_transparency_change

    -- initialize transparency depended plugins
    M.on_transparency_change()
end

return M

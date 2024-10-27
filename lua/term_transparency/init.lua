local M = {}

M.opts = {
	transparency_state_file = vim.fn.expand("~") .. "/.local/state/term/transparency.txt",
	term = {
		wezterm = {
			enabled = true,
			transparency_toggle_file = "",
		},
	},
	want_autocmd = false,
	on_transparency_change = function() end,
}

M.toggle_transparency = function()
	local current_file_state = M.get_file_transparency_state()
	vim.g.is_transparent = not current_file_state

	M.change_transparency()
end

M.get_file_transparency_state = function()
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

M.change_transparency = function()
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

		local toggle_cmd =
			"nvim --server /tmp/nvim.pipe --remote-send \"<CMD>lua require('term_transparency').opts.on_transparency_change()<CR>\""
		vim.fn.system(toggle_cmd)
	end
end

M.sync_state = function()
	local current_file_state = M.get_file_transparency_state()
	vim.g.is_transparent = current_file_state

	vim.notify(string.format("Transparency: %s", tostring(vim.g.is_transparent)), vim.log.levels.INFO)
end

M.setup = function(opts)
	if opts then
		M.opts = vim.tbl_deep_extend("force", M.opts, opts)
	end

	if M.opts.want_autocmd then
		vim.api.nvim_create_autocmd("FocusGained", {
			callback = function()
				M.opts.on_transparency_change()
			end,
		})
	end

	M.opts.on_transparency_change()
end

return M

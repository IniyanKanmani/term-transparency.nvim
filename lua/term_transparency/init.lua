local M = {}

M.opts = {
	transparency_state_file = vim.fn.expand("~") .. "/.local/state/term/transparency.txt",
	term = {
		wezterm = {
			enabled = true,
			transparency_toggle_file = "",
		},
	},
}

M.toggle_transparency = function()
	vim.g.is_transparent = not vim.g.is_transparent
end

M.set_is_transparent = function(value)
	value = tostring(value)

	if value == "true" then
		vim.g.is_transparent = true
	elseif value == "false" then
		vim.g.is_transparent = false
	end
end

M.read_transparency_file = function()
	local file = io.open(M.opts.transparency_state_file, "r")

	if file then
		local value = file:read("*a")
		value = value:gsub("\n", "") -- Remove any trailing newline characters

		M.set_is_transparent(value) -- Set transparency based on file content
		file:close()
	else
		M.set_is_transparent("false") -- Default to 'false' if the file doesn't exist
		M.write_transparency_file() -- Write default transparency value
	end
end

M.write_transparency_file = function()
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

		-- Exp: running server command
		local toggle_cmd = string.format(
			'nvim --server /tmp/nvim.pipe --remote-send "<CMD>lua ExecuteOnTransparencyChange("%s")<CR>" 2>/dev/null',
			tostring(vim.g.is_transparent)
		)

		-- local toggle_cmd = 'nvim --server /tmp/nvim.pipe --remote-send ":lua ExecuteOnTransparencyChange()<CR>"'
		-- local toggle_cmd = "sh /Users/apple/.config/nvim/sh/toggle_transparency.sh"
		vim.fn.system(toggle_cmd)
	end
end

M.setup = function(opts)
	if opts then
		M.opts = vim.tbl_deep_extend("force", M.opts, opts)
	end

	-- vim.notify(vim.inspect(opts), vim.log.levels.INFO)

	M.read_transparency_file()
end

return M

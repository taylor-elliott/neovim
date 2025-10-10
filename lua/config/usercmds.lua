local h = require("utils.helper")

local usercmd = vim.api.nvim_create_user_command

usercmd("LeetClean", function()
	local bufnr = vim.api.nvim_get_current_buf()
	local lines = vim.api.nvim_buf_getlines(bufnr, 0, -1, false)
	local cleaned = {}

	for _, line in ipairs(lines) do
		if not line:match("^# %@leet") then
			table.insert(cleaned, line)
		end
	end

	-- Trim leading empty lines
	while #cleaned > 0 and cleaned[1]:match("^%s*$") do
		table.remove(cleaned, 1)
	end

	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, cleaned)
end, {})

usercmd("LeetTest", function()
	local slug = vim.fn.expand("%:r")
	vim.cmd("tabnew " .. slug .. ".in")
end, {})

usercmd("Reload", h.reload_command, {
	nargs = "?",
	complete = h.reload_completion,
})

usercmd("ReloadModule", h.reload_command, {
	nargs = "?",
	complete = h.reload_completion,
})

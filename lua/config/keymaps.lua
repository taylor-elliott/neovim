local extract = require("utils.extract")
local reload = require("utils.reload")

local g = vim.g
local map = vim.keymap.set
local buf = vim.lsp.buf
local dia = vim.diagnostic

g.mapleader = " "
g.maplocalleader = " "

map({ "n", "i", "v" }, "<Up>", "<nop>", { noremap = true, silent = true })
map({ "n", "i", "v" }, "<Down>", "<nop>", { noremap = true, silent = true })
map({ "n", "i", "v" }, "<Left>", "<nop>", { noremap = true, silent = true })
map({ "n", "i", "v" }, "<Right>", "<nop>", { noremap = true, silent = true })

map({ "n", "i", "v" }, "<C-s>", "<Esc>:update<CR>a", { silent = true })

map("n", "H", "^", { desc = "Go to beginning of line" })
map("n", "L", "$", { desc = "Go to end of line" })
map("v", "H", "0", { desc = "Go to beginning of line" })
map("v", "L", "$", { desc = "Go to end of line" })

map("i", "<C-h>", "<C-o>h", { noremap = true, silent = true }) -- Move left
map("i", "<C-j>", "<C-o>j", { noremap = true, silent = true }) -- Move down
map("i", "<C-k>", "<C-o>k", { noremap = true, silent = true }) -- Move up
map("i", "<C-l>", "<C-o>l", { noremap = true, silent = true }) -- Move right
vim.api.nvim_set_keymap("n", "<bs>", [[ciw]], { noremap = true })

map("i", "jj", "<Esc>")

map("n", "Q", function()
	if vim.bo.modified then
		vim.cmd("write")
		print("✓ Saved!")
	else
		print("No changes")
	end
end, { desc = "Smart save current file" })
-- map("n", "<CR>", "O<Esc>", { desc = "Insert newline " })
map("n", "<CR>", "i<CR><Esc>", { desc = "Insert mode CR then back to normal" })

map("n", "<BS>", "kJ", { desc = "Join with previous line like backspace" })
map("n", "`", function()
	local is_diag_open = false

	-- Check if a quickfix, Trouble, or diagnostic window is open
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		local ft = vim.bo[buf].filetype

		if ft == "qf" or ft == "Trouble" or ft == "diagnostic" then
			is_diag_open = true
			break
		end
	end

	-- If in netrw and diagnostics list is NOT open, close the netrw buffer
	local ft = vim.bo.filetype
	if ft == "netrw" or ft == "" then
		vim.cmd("Ex")
	elseif not is_diag_open then
		vim.cmd("bd")
	else
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-w>w", true, false, true), "n", false)
	end
end, { noremap = true, silent = true, desc = "Smart window switch or close netrw if diagnostics not open" })

-- Resize window using <ctrl> arrow keys
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

-- Move Lines
-- map("n", "K", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move Line Up" })
-- map("n", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
-- map("n", "K", ":m '<-2<CR>gv=gv", { desc = "Move Selection Up" })
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move Selection Up" })

vim.api.nvim_set_keymap("n", "<leader>tf", "<Plug>PlenaryTestFile", { noremap = false, silent = false })

map("n", "<Leader><CR>", function()
	require("telescope.builtin").buffers({
		sort_mru = true,
		ignore_current_buffer = true,
		previewer = true,
	})
end, { noremap = true, silent = true })

map("n", "J", "mzJ`z")
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", function()
	local success, _ = pcall(vim.cmd, "normal! nzzzv")
	if not success then
		vim.notify("Pattern not found", vim.log.levels.WARN)
	end
end, { desc = "Repeat search and center" })
map("n", "N", "Nzzzv")
map("n", "=ap", "ma=ap'a")

map("x", "<leader>p", [["_dP]], { desc = "paste without overwriting what you copied" })

map(
	{ "n", "v" },
	"<leader>y",
	[["+y]],
	{ desc = "In both normal and visual mode, yank (copy) to the system clipboard (+ register)" }
)
map("n", "<leader>Y", [["+Y]], {
	desc = "Yanks (copies) from the current line to the end of line to system clipboard (just like Y but to + register).",
})
map("i", "<C-y>", "<C-r>0", { desc = "Paste last yanked text in insert mode" })
map("i", "<C-p>", "<C-r>1", { desc = "Paste last deleted text in insert mode" })
map(
	{ "n", "v" },
	"<leader>d",
	'"_d',
	{ desc = "Deletes text into the black hole register, so it doesn't overwrite your clipboard" }
)

map("i", "<F9>", function()
	-- Show notification
	vim.notify("Pasting from clipboard", vim.log.levels.INFO, { title = "Insert Mode Paste" })

	-- Paste from system clipboard
	local keys = vim.api.nvim_replace_termcodes("<C-r>+", true, false, true)
	vim.api.nvim_feedkeys(keys, "i", false)
end, { desc = "Paste from clipboard with notification" })

map("n", "<leader>P", '"+p', { desc = "Paste from system clipboard" })

-- map("n", "Q", "<nop>")

map("n", "<C-k>", "<cmd>cnext<CR>zz")
map("n", "<C-j>", "<cmd>cprev<CR>zz")
map("n", "<leader>k", "<cmd>lnext<CR>zz")
map("n", "<leader>j", "<cmd>lprev<CR>zz")

map("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

map("v", "<leader>mv", extract.create_component, { desc = "Extract selection to src/components/{Name}.tsx" })
map("v", "<leader>mb", extract.set_barrel, { desc = "Extract component {Name}.tsx and update barrel index.ts" })

-- map("n", "<leader>xx", function()
-- 	local diagnostics = vim.diagnostic.get(0)
-- 	if vim.tbl_isempty(diagnostics) then
-- 		return
-- 	end
--
-- 	local lines = {}
-- 	for _, d in ipairs(diagnostics) do
-- 		local msg = string.format("%s:%d:%d: %s", vim.fn.bufname(d.bufnr), d.lnum + 1, d.col + 1, d.message)
-- 		table.insert(lines, msg)
-- 	end
--
-- 	vim.lsp.util.open_floating_preview(lines, "plaintext", { border = "rounded" })
-- end, { desc = "Show All Diagnostics (Float)" })

map("n", "<leader>xl", dia.setloclist, { desc = "Diagnostic Location List" })
map("n", "<leader>xq", dia.setqflist, { desc = "Diagnostic Quickfix List" })

map({ "n", "x" }, "<leader>cp", ":CommentYankPaste<CR>", { desc = "Comment Yank Paste" })

map("n", "<leader>ca", buf.code_action, {
	desc = "LSP Code Actions",
})

map("n", "=", function()
	vim.cmd("!npm run build ")
end, { desc = "Build current TypeScript file" })

-- map("n", "0", function()
--     vim.cmd("!node ./dist/index.js\n\n")
-- end, { desc = "Compile the current TypeScript file" })
-- Create the user command that calls ReloadModule with an argument
vim.api.nvim_create_user_command("ReloadModule", function(opts)
	reload.ReloadModule(opts.args)
end, {
	nargs = 1,
	complete = function(ArgLead)
		local modules = { "keymaps", "options", "autocmds" }
		local matches = {}
		for _, mod in ipairs(modules) do
			if mod:match("^" .. ArgLead) then
				table.insert(matches, mod)
			end
		end
		return matches
	end,
})

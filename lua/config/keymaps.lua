local extract = require("utils.extract")
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

map("i", "jj", "<Esc>")
map("n", "Q", function()
	if vim.bo.modified then
		vim.cmd("write")
		print("✓ Saved!")
	else
		print("No changes")
	end
end, { desc = "Smart save current file" })
map("n", "<CR>", "o<Esc>", { desc = "Insert newline " })
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
map("n", "J", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move Line Down" })
map("n", "K", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move Line Up" })
map("i", "J", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Line Down" })
map("i", "K", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Line Up" })
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
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")
map("n", "=ap", "ma=ap'a")

map("x", "<leader>p", [["_dP]])

map({ "n", "v" }, "<leader>y", [["+y]])
map("n", "<leader>Y", [["+Y]])

map({ "n", "v" }, "<leader>d", '"_d')

-- map("n", "Q", "<nop>")
map("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")
map("n", "<M-h>", "<cmd>silent !tmux-sessionizer -s 0 --vsplit<CR>")
map("n", "<M-H>", "<cmd>silent !tmux neww tmux-sessionizer -s 0<CR>")

map("n", "<C-k>", "<cmd>cnext<CR>zz")
map("n", "<C-j>", "<cmd>cprev<CR>zz")
map("n", "<leader>k", "<cmd>lnext<CR>zz")
map("n", "<leader>j", "<cmd>lprev<CR>zz")

map("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
-- map("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

map("n", "<leader>ee", "oif err != nil {<CR>}<Esc>Oreturn err<Esc>")

map("n", "<leader>ea", 'oassert.NoError(err, "")<Esc>F";a')

map("n", "<leader>ef", 'oif err != nil {<CR>}<Esc>Olog.Fatalf("error: %s\\n", err.Error())<Esc>jj')

map("n", "<leader>el", 'oif err != nil {<CR>}<Esc>O.logger.Error("error", "error", err)<Esc>F.;i')

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

map("i", "<C-k>", buf.signature_help, { desc = "Signature Help" })

map("n", "<leader>ca", buf.code_action, {
	desc = "LSP Code Actions",
})

map("n", "=", function()
	vim.cmd("w") -- Save file
	vim.cmd("!ts-node %")
end, { desc = "Run current TypeScript file" })

map("n", "-", function()
	vim.cmd("w") -- Save file
	vim.cmd("!tsc %")
end, { desc = "Compile the current TypeScript file" })

map("n", "0", function()
	vim.cmd("!node %")
end, { desc = "Run compiled ts file" })

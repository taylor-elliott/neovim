local api = vim.api
local lsp = vim.lsp
local map = vim.keymap.set
local augroup = vim.api.nvim_create_augroup
local autocmd = api.nvim_create_autocmd
local yank_group = augroup("HighlightYank", {})
local MyGroup = augroup("nvim-te", {})

local group = vim.api.nvim_create_augroup("AutoFormatOnInsertLeave", { clear = true })

vim.api.nvim_create_autocmd("InsertLeave", {
	group = group,
	pattern = "*",
	callback = function()
		if vim.bo.buftype ~= "" then
			return
		end
		if vim.fn.bufname() == "" then
			return
		end

		local ft = vim.bo.filetype
		if ft == "text" or ft == "markdown" then
			return
		end

		local clients = vim.lsp.get_active_clients({ bufnr = 0 })
		if #clients == 0 then
			return
		end

		vim.lsp.buf.format({ async = false })
		vim.cmd("silent! write")
	end,
})

autocmd("TextYankPost", {
	group = yank_group,
	pattern = "*",
	callback = function()
		vim.highlight.on_yank({
			higroup = "IncSearch",
			timeout = 40,
		})
	end,
})

autocmd({ "BufWritePre" }, {
	group = MyGroup,
	pattern = "*",
	command = [[%s/\s\+$//e]],
})

autocmd("LspAttach", {
	group = MyGroup,
	callback = function(args)
		local client = lsp.get_client_by_id(args.data.client_id)

		if
			type(lsp.inlay_hint) == "function"
			and client
			and client.server_capabilities
			and client.server_capabilities.inlayHintProvider
		then
			lsp.inlay_hint(args.buf, true)
		end

		local opts = { buffer = args.buf }
		map("n", "gd", function()
			lsp.buf.definition()
		end, opts)
		map("n", "K", function()
			lsp.buf.hover()
		end, opts)
		map("n", "<leader>vws", function()
			lsp.buf.workspace_symbol()
		end, opts)
		map("n", "<leader>vd", function()
			vim.diagnostic.open_float()
		end, opts)
		map("n", "<leader>vca", function()
			lsp.buf.code_action()
		end, opts)
		map("n", "<leader>vrr", function()
			lsp.buf.references()
		end, opts)
		map("n", "<leader>vrn", function()
			lsp.buf.rename()
		end, opts)
	end,
})

autocmd("BufWritePre", {
	pattern = { "*.ts", "*.tsx", "*.js", "*.jsx" },
	callback = function()
		lsp.buf.code_action({
			context = { only = { "source.organizeImports" }, diagnostics = {} },
			apply = true,
		})
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "netrw",
	callback = function()
		-- Remove conflicting mapping for gh in netrw buffer
		vim.api.nvim_buf_del_keymap(0, "n", "gh")
		-- Set gh to toggle hidden files
		vim.api.nvim_buf_set_keymap(0, "n", "gh", "<Plug>NetrwHideToggle", {})
	end,
})
vim.g.vsnip_snippet_dir = vim.fn.stdpath("config") .. "/snippets/"
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3
vim.g.netrw_sort_sequence = [[[\/]$,\.bak$,\.o$,\.h$,\.info$,\.swp$,\.obj$,.git$,\.DS_Store$]]
vim.g.netrw_list_hide = [[\(^\|\s\s\)\zs\.\S\+]]
vim.g.netrw_hide = 1
vim.g.netrw_browse_split = 0
vim.g.netrw_winsize = 25

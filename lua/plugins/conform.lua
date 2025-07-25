return {
	"stevearc/conform.nvim",
	opts = {
		format_on_save = {
			timeout_ms = 1000,
			lsp_fallback = true, -- fallback to vim.lsp.buf.format
		},

		formatters_by_ft = {
			lua = { "stylua" },
			typescript = { "prettierd" },
			typescriptreact = { "prettierd" },
			javascript = { "prettierd" },
			javascriptreact = { "prettierd" },
			json = { "prettierd", "prettier" },
			html = { "prettierd", "prettier" },
			css = { "prettierd", "prettier" },
			yaml = { "prettierd", "prettier" },
		},
	},
	config = function(_, opts)
		require("conform").setup(opts)

		-- Manual format keybinding
		vim.keymap.set("n", "<leader>f", function()
			require("conform").format({ async = true })
		end, { desc = "Format buffer" })

		vim.api.nvim_create_augroup("ConformFormat", { clear = true })

		vim.api.nvim_create_autocmd("BufWritePre", {
			group = "ConformFormat",
			callback = function(event)
				require("conform").format({ bufnr = event.buf, async = false, silent = true })
			end,
		})
	end,
}

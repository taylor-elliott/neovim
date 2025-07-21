return {
	"nvim-telescope/telescope.nvim",

	tag = "0.1.5",

	dependencies = {
		"nvim-lua/plenary.nvim",
	},

	config = function()
		require("telescope").setup({})
		local builtin = require("telescope.builtin")

		vim.keymap.set("n", "<leader><leader>", builtin.find_files, {})

		vim.keymap.set("n", "<leader>xx", function()
			vim.diagnostic.setqflist()
			-- builtin.quickfix()
		end, { desc = "Show Diagnostics via quickfix + Telescope" })
		vim.keymap.set("n", "<leader>xc", function()
			vim.cmd("cclose")
		end, { desc = "Close quickfix window" })

		vim.keymap.set("n", "<leader>ff", builtin.git_files, {})

		vim.keymap.set("n", "<leader>fs", function()
			local word = vim.fn.expand("<cword>")
			builtin.grep_string({ search = word })
		end)

		vim.keymap.set("n", "<leader>fg", function()
			builtin.grep_string({ search = vim.fn.input("Grep > ") })
		end)

		vim.keymap.set("n", "<leader>fh", builtin.help_tags, {})

		vim.api.nvim_create_autocmd("FileType", {
			pattern = "qf",
			callback = function()
				vim.keymap.set("n", "<CR>", function()
					vim.cmd('exe "cc " .. line(".")')
				end, { buffer = 0, noremap = true, silent = true })
			end,
		})
	end,
}

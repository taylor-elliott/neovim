return {
	"crispgm/telescope-heading.nvim",
	dependencies = { "nvim-telescope/telescope.nvim" },
	config = function()
		require("telescope").load_extension("heading")
		vim.keymap.set("n", "<leader>mh", function()
			require("telescope").extensions.heading.heading()
		end, { desc = "Markdown Headings" })
	end,
}

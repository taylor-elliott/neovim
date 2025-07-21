return {
	"theprimeagen/harpoon",
	branch = "harpoon2",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local harpoon = require("harpoon")
		harpoon:setup()

		local harpoon_extensions = require("harpoon.extensions")
		harpoon:extend(harpoon_extensions.builtins.highlight_current_file())
	end,
	keys = {
		{
			"<leader>A",
			function()
				require("harpoon"):list():prepend()
			end,
			desc = "harpoon file",
		},

		{
			"<leader>a",
			function()
				require("harpoon"):list():add()
			end,
			desc = "harpoon file",
		},
		{
			"<F5>",
			function()
				local harpoon = require("harpoon")
				harpoon.ui:toggle_quick_menu(harpoon:list())
			end,
			desc = "harpoon quick menu",
		},
		{
			"<F1>",
			function()
				require("harpoon"):list():select(1)
			end,
			desc = "harpoon to file 1",
		},
		{
			"<F2>",
			function()
				require("harpoon"):list():select(2)
			end,
			desc = "harpoon to file 2",
		},
		{
			"<F3>",
			function()
				require("harpoon"):list():select(3)
			end,
			desc = "harpoon to file 3",
		},
		{
			"<F4>",
			function()
				require("harpoon"):list():select(4)
			end,
			desc = "harpoon to file 4",
		},
		{
			"<leader>1",
			function()
				require("harpoon"):list():replace_at(1)
			end,
			desc = "harpoon to file 1",
		},
		{
			"<leader>2",
			function()
				require("harpoon"):list():replace_at(2)
			end,
			desc = "harpoon to file 2",
		},
		{
			"<leader>3",
			function()
				require("harpoon"):list():repalce_at(3)
			end,
			desc = "harpoon to file 3",
		},
		{
			"<leader>4",
			function()
				require("harpoon"):list():replace_at(4)
			end,
			desc = "harpoon to file 4",
		},
	},
}

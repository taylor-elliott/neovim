return {
	{
		"L3MON4D3/LuaSnip",
		dependencies = {
			"rafamadriz/friendly-snippets", -- tons of ready-to-use snippets
		},
		config = function()
			local ls = require("luasnip")
		end,
	},
}

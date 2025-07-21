return {
	"nvim-treesitter/nvim-treesitter",
	ensure_installed = {
		"c",
		"lua",
		"vim",
		"vimdoc",
		"query",
		"markdown",
		"markdown_inline",
		"javascript",
		"typescript",
	},
	sync_install = false,
	auto_install = true,
	ignore_install = {},
	highlight = {
		enable = true,
		disable = { "c", "rust" },
		additional_vim_regex_highlighting = false,
	},
}

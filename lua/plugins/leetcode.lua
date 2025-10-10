return {
	"kawre/leetcode.nvim",
	build = ":TSUpdate html",
	dependencies = {
		"nvim-telescope/telescope.nvim",
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
	},
	opts = {
		lang = "python3",
		picker = { provider = "telescope" },
		description = {
			position = "left",
			width = "25%",
			show_stats = true,
		},
		theme = {
		},
		injector = {
			["python3"] = {
				imports = function()
					return { "" }
				end,
				header = {},
				template = {},

				before = { "import unittest", "" },
				after = {
					"class TestSolution(unittest.TestCase):",
					"\tdef test_example(self):",
					"\t\tself.assertEqual(1, 1)",
					"",
					'if __name__ == "__main__":',
					"\tunittest.main()"
				},
			},

			["c"] = {
				imports = function()
					return { "#include <string.h>" }
				end,
				after = "int main() {}",
			},
		},
	},
}

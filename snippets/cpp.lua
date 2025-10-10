local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node

-- Function to return uppercase filename without path or extension
local function guard_name()
	return vim.fn.expand("%:t:r"):upper() .. "_H"
end

return {
	s("abcdef", {
		t("#ifndef "),
		f(guard_name, {}),
		t({ "", "#define " }),
		f(guard_name, {}),
		t({ "", "", "" }),
		i(0),
		t({ "", "", "#endif /* " }),
		f(guard_name, {}),
		t(" */"),
	}),
}

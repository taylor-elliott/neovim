local ls = require("luasnip")
local fmt = require("luasnip.extras.fmt").fmt
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local rep = require("luasnip.extras").rep
return {
	s("con", {
		t("console.log("),
		i(1, "msg"),
		t(")"),
	}),
	s("imp", {
		t("import { "),
		i(1, "name"),
		t(" } from '"),
		i(2, "module"),
		t("';"),
	}),
	s("fun", {
		t("function "),
		i(1, "name"),
		t("("),
		i(2),
		t({ ") {", "\t" }),
		i(0),
		t({ "", "}" }),
	}),
	s(
		"const ",
		fmt("const {} = ({}) => {{\n  {}\n}};", {
			i(1, "name"),
			i(2),
			i(3, "// body"),
		})
	),
	s(
		"binarysearch",
		fmt(
			[[
const {} = ({}:{}, {}:{}) => {{
  let left = 0;
  let right = {}.length - 1;

  while (left <= right) {{
    const mid = Math.floor((left + right) / 2);

    if ({}[mid] === {}) return mid;
    else if ({}[mid] < {}) {{
      left = mid + 1;
    }} else {{
      right = mid - 1;
    }}
  }}

  return -1;
}};
]],
			{
				i(1, "binarySearch"),
				i(2, "arr"),
				i(3, "any"),
				i(4, "target"),
				i(5, "any"),
				rep(2),
				rep(2),
				rep(4),
				rep(2),
				rep(4),
			}
		)
	),
	-- Interface
	s(
		"interface",
		fmt("interface {} {{\n  {}: {};\n}}", {
			i(1, "Name"),
			i(2, "prop"),
			i(3, "type"),
		})
	),

	-- Async function with try/catch
	s(
		"afun",
		fmt(
			[[
async function {}({}) {{
  try {{
    {}
  }} catch (err) {{
    console.error(err);
  }}
}}]],
			{
				i(1, "fetchData"),
				i(2),
				i(3, "// code"),
			}
		)
	),
	s(
		"constinterface",
		fmt(
			[[
interface {} {{
  {}: {};
}}

const {} = ({}) => {{
  {}
}};
  ]],
			{
				i(1, "Props"),
				i(2, "value"),
				i(3, "string"),
				i(4, "foo"),
				i(5),
				i(6, "// foo body"),
			}
		)
	),
}

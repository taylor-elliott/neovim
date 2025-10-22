local ls = require("luasnip")
local fmt = require("luasnip.extras.fmt").fmt
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local rep = require("luasnip.extras").rep

return {
    s(
        "map",
        fmt(
            [[
const {} = {}.map(({}, index) => {{
  return (
    <>
      {}
    </>
  );
}});
]],
            {
                i(1, "mappedList"),
                i(2, "listName"),
                i(3, "item"),
                i(4, "// JSX or expression"),
            }
        )
    ),
    s(
        "list",
        fmt(
            [[
const {} = [{}];
]],
            {
                i(1, "list"),
                i(2),
            }
        )
    ),

    s(
        "div",
        fmt(
            [[
<div className="{}">
    {}
</div>
]],
            {
                i(1, ""),
                i(2),
            }
        )
    ),
    s(
        "rfc",
        fmt(
            [[

interface {}Props {{
  {}
}}

const {} = (props: {}Props) => {{
  {}  -- destructuring line or empty
  return (
    <div>
      {}
    </div>
  );
}};
]],
            {
                i(1, "Component"),
                i(2, "// props"),
                rep(1),
                rep(1),
                i(3, ""), -- destructuring left empty by default
                i(4, "// JSX"),
            }
        )
    ),
    s("console", {
        t("console.log("),
        i(1),
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
        "_const_",
        fmt("const {} = () => {{\n\treturn <div>{}</div>;\n}};\n\nexport default {};", {
            i(1),
            rep(1),
            rep(1),
        })
    ),
    s(
        "const",
        fmt("const {} = ({}) => {{\n  {}\n}}", {
            i(1, "fn"),
            i(2, "props"),
            i(3),
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
    s(
        "cond",
        fmt("{{ {1} && <{2} /> }}", {
            i(1, "name"),
            i(2, "Component"),
        })
    ),
    s(
        "cond_exp",
        fmt("{{ {1} && (\n  <{2} />\n) }}", {
            i(1, "name"),
            i(2, "Component"),
        })
    ),
    s(
        "cond_imp_map",
        fmt("{{ {1}.map(({2}) => (\n  <li key={{ {2}.id }}>{2}.{3}</li>\n)) }}", {
            i(1, "items"),
            i(2, "item"),
            i(3, "name"),
        })
    ),
    s(
        "type",
        fmt("type {} = {{\n  {}: {};\n}}", {
            i(1, "name"),
            i(2, "prop"),
            i(3, "type"),
        })
    ),
    s(
        "interface",
        fmt("interface {} {{\n  {}: {};\n}}", {
            i(1, "Name"),
            i(2, "prop"),
            i(3, "type"),
        })
    ),

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
        "cfninterface",
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

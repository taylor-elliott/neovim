local ls = require("luasnip")
local fmt = require("luasnip.extras.fmt").fmt
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
    s("std", fmt(
        "${} = \\sqrt{{\\frac{{({} - \\bar{{{}}})^2}}{{{} - 1}}}}",
        {
            i(1, "s"),
            i(2, "x_i"),
            i(3, "x"),
            i(4, "n")
        }
    )),
}

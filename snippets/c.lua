local ls = require("luasnip")
local fmt = require("luasnip.extras.fmt").fmt
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local rep = require("luasnip.extras").rep

local function guard_name()
    return vim.fn.expand("%:t:r"):upper() .. "_H"
end

return {
    s("printf", {
        t('printf("'),
        i(1),
        t(" = %"),
        i(2),
        t('\\n", '),
        i(3),
        t(");"),
    }),
    s("guard", {
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

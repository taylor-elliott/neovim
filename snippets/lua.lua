local ls = require("luasnip")
local fmt = require("luasnip.extras.fmt").fmt
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local rep = require("luasnip.extras").rep


ls.add_snippets("lua", {
    s("map", {
        t('map("'), i(1, "n"), t('", "'), i(2, "x"), t('", "'), i(3, "x"), t('")')
    })
})

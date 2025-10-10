local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node

local function now()
    return os.date("%Y-%m-%d %H:%M")
end

return {
    s("header_3", {
        t("|  "),
        i(1, "X"),
        t(" | "),
        i(2, "X"),
        t(" | "),
        i(3, "X"),
        t(" |"),
        t({ "", "| :--- | :--- | :--- |" }),
    }),
    s("sumfull", {
        t({
            " 𝑛 ",
            " ∑",
            "𝑖＝𝟷"
        })
    }),
    s("divide", {
        t({ "    ", "       " }), i(1, "a"), t({ "", "" }),
        i(2, "b"), t(" = ⎯⎯⎯⎯⎯⎯ "),
        t(""),
        t({ "    ", "       " }), i(3, "c"), t({ "", "" }),
    }),

    s("header_3_time", {
        t("|  "),
        i(1, "X"),
        t(" | "),
        i(2, "X"),
        t(" | TIME |"),
        t({ "", "| :--- | :--- | :--- |" }),
    }),
    s("header_2", {
        t("| "),
        i(1, "X"),
        t(" | "),
        i(2, "X"),
        t(" |"),
        t({ "", "| :--- | :--- |" }),
    }),
    s("row_2", {
        t("|  "),
        i(1, " "),
        t(" | "),
        i(2, " "),
        t(" |"),
    }),
    s("row_3", {
        t("|  "),
        i(1, " "),
        t(" | "),
        i(2, " "),
        t(" |"),
        i(3, " "),
        t(" |"),
    }),
    s("row_3_blank", {
        t("| | |   |"),
    }),
    s("row_3_empty", {
        t("|||   |"),
    }),
    s("row_2_empty", {
        t("| |   |"),
    }),
    s("row_3_time", {
        t("|  "),
        i(1, " "),
        t(" | "),
        i(2, "X"),
        t(" |"),
        f(function()
            return { now() }
        end, {}),
        t(" | "),
    }),
    s("todo", {
        t("- [ ] "),
        i(1, "Task Name"),
    }),
}

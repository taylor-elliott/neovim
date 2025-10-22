local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local l = require("luasnip.extras").lambda
local rep = require("luasnip.extras").rep
local p = require("luasnip.extras").partial
local m = require("luasnip.extras").match
local n = require("luasnip.extras").nonempty
local dl = require("luasnip.extras").dynamic_lambda
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local types = require("luasnip.util.types")
local conds = require("luasnip.extras.expand_conditions")

local function now()
    return os.date("%Y-%m-%d %H:%M")
end

return {
    s(
        "lua",
        fmt(
            [[
    ``` lua

    {1}

    ```
    ]],
            {
                i(1),
            }
        )
    ),
    s(
        "sql",
        fmt(
            [[
    ``` sql

    {1}

    ```
    ]],
            {
                i(1),
            }
        )
    ),
    s(
        "python",
        fmt(
            [[
    ``` python

    {1}

    ```
    ]],
            {
                i(1),
            }
        )
    ),
    s(
        "vim",
        fmt(
            [[
    ``` vim

    {1}

    ```
    ]],
            {
                i(1),
            }
        )
    ),
    s(
        "shell",
        fmt(
            [[
    ``` bash

    {1}

    ```
    ]],
            {
                i(1),
            }
        )
    ),
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
            "𝑖＝𝟷",
        }),
    }),
    s("divide", {
        t({ "    ", "       " }),
        i(1, "a"),
        t({ "", "" }),
        i(2, "b"),
        t(" = ⎯⎯⎯⎯⎯⎯ "),
        t(""),
        t({ "    ", "       " }),
        i(3, "c"),
        t({ "", "" }),
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
    s("testnote", {
        t({
            "#### DEFINITION",
            "- ",
        }),
        i(1, "Definition goes here..."),
    }),
    s("note", {
        t({ "# " }),
        t({ "" }),
        i(1, "Topic"),

        t({ "", "## " }),
        t({ "" }),
        i(2, "Subtopic"),

        t({ "", "### " }),
        t({ "" }),
        i(3, "Key Idea"),

        t({ "", "#### INFO", "- TODO: DEF, OPERATIONS, EXAMPLES, ETC " }),

        t({ "", "##### EXTRA", "" }),
        t("- TODO: EXTRA DETAILS, LINKS, REFERENCES, ETC"),
    }),
}

--
-- # Topic / Subject Area
-- ## Subtopic / Module
-- ###  Concept / Key Idea
-- #### Details / Notes / Code Examples
-- ##### COMMENTS
--
-- # 📂 DATA STRUCTURES
-- ## 📂 SUBTOPIC / MODULE
-- - HOW TO USE THIS LEVEL: Break down the major topic into subtopics or modules covered in class.
-- - Arrays and Strings
-- - Linked Lists
-- - Trees and Graphs
-- - Sorting Algorithms
-- ### 📂 CONCEPT / KEY IDEA
-- - HOW TO USE THIS LEVEL: Use this for specific concepts or important ideas within a subtopic.
-- - Binary Search Tree (BST)
-- - Depth-First Search (DFS)
-- - Graph Representations (Adjacency List / Matrix)
-- #### 📂 DETAILS / NOTES / CODE EXAMPLES
-- - HOW TO USE THIS LEVEL: Use this for definitions, pseudocode, syntax, examples, or anything detailed.
-- - [Definition]: A binary tree where left < root < right
-- - [Operations]: Insert, Delete, Search
-- - [Example]:
-- ```python
--
-- class Node:
--     def __init__(self, val):
--         self.left = None
--         self.right = None
--         self.val = val
--
-- ```
-- ##### COMMENTS
-- - HOW TO USE THIS:
--     - Referencing material
--     - Clarifying edge cases
--     - Follow-ups or TODOs
--
--

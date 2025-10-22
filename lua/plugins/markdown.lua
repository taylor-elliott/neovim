local code = {
    enabled = true,
    render_modes = false,
    sign = true,
    conceal_delimiters = true,
    language = true,
    position = "left",
    language_icon = true,
    language_name = true,
    language_info = true,
    language_pad = 0,
    disable_background = { "diff" },
    -- disable_background = false,
    width = "block", -- full
    left_margin = 2,
    left_pad = 2,
    right_pad = 2,
    min_width = 0,
    border = "hide",
    -- language_border = "█",
    -- language_left = "",
    -- language_right = "",
    language_border = " ",
    language_left = "",
    language_right = "",
    above = "▄",
    below = "▀",
    inline = true,
    inline_left = " ",
    inline_right = "",
    inline_pad = 0,
    highlight = "RenderMarkdownCode",
    highlight_info = "RenderMarkdownCodeInfo",
    highlight_language = nil,
    highlight_border = "RenderMarkdownCodeBorder",
    highlight_fallback = "RenderMarkdownCodeFallback",
    highlight_inline = "RenderMarkdownCodeInline",
    style = "full",
}

return {
    {
        "MeanderingProgrammer/render-markdown.nvim",
        dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" }, -- if you prefer nvim-web-devicons
        opts = {
            latex = { enabled = false },
            pipe_table = {
                enabled = true,
                preset = "round",
            },
            code = code,
            anti_conceal = {
                enabled = true,
                disabled_modes = false,
                above = 0,
                below = 0,
                -- Which elements to always show, ignoring anti conceal behavior. Values can either be
                -- booleans to fix the behavior or string lists representing modes where anti conceal
                -- behavior will be ignored. Valid values are:
                --   bullet
                --   callout
                --   check_icon, check_scope
                --   code_background, code_border, code_language
                --   dash
                --   head_background, head_border, head_icon
                --   indent
                --   link
                --   quote
                --   sign
                --   table_border
                --   virtual_lines
                ignore = {
                    -- code_background = true,
                    indent = true,
                    quote = true,
                    link = true,
                    -- head_icon = true,
                    -- code_language = true,
                    check_icon = true,
                    check_scope = true,
                    dash = true,
                    bullet = true,
                    -- code_border = true,
                    -- table_border = true,
                    -- sign = true,
                    -- head_background = true,
                    -- virtual_lines = true,
                },
            },
        },
    },
    -- {
    --     "lervag/vimtex",
    --     lazy = false, -- lazy-loading will disable inverse search
    --     config = function()
    --         -- vim.g.vimtex_mappings_disable = { ["n"] = { "K" } } -- disable `K` as it conflicts with LSP hover
    --         -- vim.g.vimtex_quickfix_method = vim.fn.executable("pplatex") == 1 and "pplatex" or "latexlog"
    --     end,
    --     keys = {
    --         { "<localLeader>l", "", desc = "+vimtex", ft = "tex" },
    --     },
    -- },
}

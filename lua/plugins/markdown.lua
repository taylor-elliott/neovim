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
            pipe_table = { preset = "round" },
            code = code
        }
    },
    {
        "lervag/vimtex",
        lazy = false,                                           -- lazy-loading will disable inverse search
        config = function()
            vim.g.vimtex_mappings_disable = { ["n"] = { "K" } } -- disable `K` as it conflicts with LSP hover
            vim.g.vimtex_quickfix_method = vim.fn.executable("pplatex") == 1 and "pplatex" or "latexlog"
        end,
        keys = {
            { "<localLeader>l", "", desc = "+vimtex", ft = "tex" },
        },
    },
}

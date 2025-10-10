return {
    {
        "hrsh7th/nvim-cmp",
        lazy = false,
        priority = 100,
        dependencies = {
            "luckasRanarison/tailwind-tools.nvim",
            "onsails/lspkind-nvim",
            -- "neovim/nvim-lspconfig",
            -- "roobert/tailwindcss-colorizer-cmp.nvim",
            -- "hrsh7th/cmp-cmdline",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            { "L3MON4D3/LuaSnip", build = "make install_jsregexp" },
            "saadparwaiz1/cmp_luasnip",
        },
        config = function()
            require "utils.completion"
        end
    },
}

return {

    {
        "folke/tokyonight.nvim",
        lazy = false, -- load immediately
        config = function()
            require("tokyonight").setup({
                style = "storm",
                transparent = true, 
                terminal_colors = true,
                styles = {
                    comments = { italic = false },
                    keywords = { italic = false },
                    sidebars = "transparent",
                    floats = "transparent",
                },
            })
            vim.cmd.colorscheme("tokyonight")

            local groups = {
                "Normal",
                "NormalNC",
                "NormalFloat",
                "FloatBorder",
                "TelescopeNormal",
                "TelescopeBorder",
                "TelescopePromptNormal",
                "TelescopePromptBorder",
            }
            for _, group in ipairs(groups) do
                vim.api.nvim_set_hl(0, group, { bg = "none" })
            end
        end,
    },
}

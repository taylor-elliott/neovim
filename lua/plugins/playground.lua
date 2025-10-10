return {
    "nvim-treesitter/playground",
    config = function()
        require("nvim-treesitter.configs").setup {
            playground = {
                enable = true,
                updatetime = 25, -- update time for highlighting
            }
        }
    end
}

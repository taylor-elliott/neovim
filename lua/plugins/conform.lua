-- return {
--   "stevearc/conform.nvim",
--   opts = {},
--   config = function()
--     require("conform").setup({
--       formatters_by_ft = {
--         lua = { "stylua" },
--         typescript = { "prettier" },
--         markdown = { "prettier" },
--         typescriptreact = { "prettier" },
--         json = { "prettier" },
--       },
--     })
--   end,
-- }

return {
  "stevearc/conform.nvim",
  opts = {},
  config = function()
    require("conform").setup({
      formatters_by_ft = {
        lua = { "stylua" },
        typescript = { "prettierd" },
        typescriptreact = { "prettierd" },
        json = { "prettierd" },
        markdown = { "prettierd" },
      },
    })

    -- Optional: autoformat on save
    vim.api.nvim_create_autocmd("BufWritePre", {
      pattern = { "*.lua", "*.ts", "*.tsx", "*.json", "*.md" },
      callback = function()
        require("conform").format({ async = false })
      end,
    })
  end,
}

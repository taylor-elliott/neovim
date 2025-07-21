return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "stevearc/conform.nvim",
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/nvim-cmp",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
        "j-hui/fidget.nvim",
    },

    config = function()
        require("conform").setup()
        local cmp = require("cmp")
        local cmp_lsp = require("cmp_nvim_lsp")
        local capabilities = vim.tbl_deep_extend(
            "force",
            {},
            vim.lsp.protocol.make_client_capabilities(),
            cmp_lsp.default_capabilities()
        )
        local lsp_signature = require("lsp_signature")

        local on_attach = function(client, bufnr)
            if client.server_capabilities.inlayHintProvider then
                vim.lsp.inlay_hint(bufnr, true)
            end

            require("completion").on_attach(client)
        end
        require("fidget").setup({})
        require("mason").setup()
        require("mason-lspconfig").setup({
            ensure_installed = {
                "lua_ls",
                "ts_ls",
                "jsonls",
            },
            handlers = {
                function(server_name) -- default handler (optional)
                    require("lspconfig")[server_name].setup({
                        capabilities = capabilities,
                        on_attach = on_attach,
                    })
                end,
                ["ts_ls"] = function()
                    require("lspconfig").ts_ls.setup({
                        capabilities = capabilities,
                        on_attach = on_attach,
                    })
                end,
                ["lua_ls"] = function()
                    local lspconfig = require("lspconfig")
                    lspconfig.lua_ls.setup({
                        capabilities = capabilities,
                        on_attach = on_attach,
                        settings = {
                            Lua = {
                                format = {
                                    enable = true,

                                    defaultConfig = {
                                        indent_style = "space",
                                        indent_size = "2",
                                    },
                                },
                            },
                        },
                    })
                end,
            },
        })

        local cmp_select = { behavior = cmp.SelectBehavior.Select }

        cmp.setup({
            snippet = {
                expand = function(args)
                    require("luasnip").lsp_expand(args.body)
                end,
            },
            mapping = cmp.mapping.preset.insert({
                -- Completion navigation
                ["<C-k>"] = cmp.mapping.select_prev_item(cmp_select),
                ["<C-j>"] = cmp.mapping.select_next_item(cmp_select),

                -- Confirm selection
                ["<CR>"] = cmp.mapping.confirm({ select = true }),

                -- Trigger completion
                ["<C-Space>"] = cmp.mapping.complete(),

                -- Tab to expand or jump in snippet
                ["<Tab>"] = cmp.mapping(function(fallback)
                    local luasnip = require("luasnip")
                    if cmp.visible() then
                        cmp.select_next_item()
                    elseif luasnip.expand_or_jumpable() then
                        luasnip.expand_or_jump()
                    else
                        fallback()
                    end
                end, { "i", "s" }),

                ["<S-Tab>"] = cmp.mapping(function(fallback)
                    local luasnip = require("luasnip")
                    if cmp.visible() then
                        cmp.select_prev_item()
                    elseif luasnip.jumpable(-1) then
                        luasnip.jump(-1)
                    else
                        fallback()
                    end
                end, { "i", "s" }),
            }),
            sources = cmp.config.sources({
                { name = "nvim_lsp" },
                { name = "luasnip" },
            }, {
                { name = "buffer" },
            }),
        })
        require("luasnip.loaders.from_lua").lazy_load({
            paths = vim.fn.stdpath("config") .. "/snippets",
        })

        vim.diagnostic.config({
            virtual_text = {
                prefix = "●", -- Could be "●", "■", "▎", or any symbol you prefer
                spacing = 2, -- space between the text and the code
                severity = { min = vim.diagnostic.severity.ERROR }, -- optional, show only errors inline
            },
            signs = true, -- keep signs in the gutter if you want
            underline = true, -- underline errors in code
            update_in_insert = false, -- or true if you want live updates while typing
            severity_sort = true,
            float = {
                focusable = false,
                style = "minimal",
                border = "rounded",
                source = "always",
                header = "",
                prefix = "",
            },
        })
    end,
}

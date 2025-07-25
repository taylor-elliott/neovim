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

        local select_opts = { behavior = cmp.SelectBehavior.Select }
        local luasnip = require("luasnip")
        require("luasnip.loaders.from_lua").lazy_load({
            paths = vim.fn.stdpath("config") .. "/snippets",
        })

        luasnip.config.set_config({
            history = false, -- prevent jumping back into old snippets
            updateevents = "TextChanged,TextChangedI",
        })
        cmp.setup({
            snippet = {
                expand = function(args)
                    luasnip.lsp_expand(args.body)
                end,
            },
            preselect = cmp.PreselectMode.None,
            completion = {
                completeopt = "menu,menuone,noinsert,noselect",
            },
            sources = {
                { name = "nvim_lsp", keyword_length = 3 },
                { name = "luasnip",  keyword_length = 3 },
                { name = "buffer",   keyword_length = 3 },
                { name = "path",     keyword_length = 3 },
            },
            window = {
                documentation = cmp.config.window.bordered(),
            },
            formatting = {
                fields = { "menu", "abbr", "kind" },
                format = function(entry, item)
                    local menu_icon = {
                        nvim_lsp = "λ",
                        luasnip = "⋗",
                        buffer = "Ω",
                        path = "🖫",
                    }

                    item.menu = menu_icon[entry.source.name]
                    return item
                end,
            },
            experimental = {
                ghost_text = false,
            },
            mapping = {
                -- ["<CR>"] = cmp.mapping.confirm({ select = false }),
                --
                ["<CR>"] = cmp.mapping(function(fallback)
                    if cmp.visible() and cmp.get_selected_entry() then
                        cmp.confirm({ select = false })
                    else
                        fallback()
                    end
                end, { "i", "s" }),
                ["<C-e>"] = cmp.mapping.abort(),
                ["<leader><CR>"] = cmp.mapping.confirm({ select = true }),
                ["<Tab>"] = cmp.mapping(function(fallback)
                    local col = vim.fn.col(".") - 1
                    if luasnip.jumpable(1) then
                        luasnip.jump(1)
                    elseif cmp.visible() then
                        cmp.select_next_item(select_opts)
                    elseif col == 0 or vim.fn.getline("."):sub(col, col):match("%s") then
                        fallback()
                    else
                        cmp.complete()
                    end
                end, {
                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        elseif cmp.visible() then
                            cmp.select_prev_item(select_opts)
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    "i",
                    "s",
                }),
            },
        })

        ---
        -- Diagnostics
        --
        local sign = function(opts)
            vim.fn.sign_define(opts.name, {
                texthl = opts.name,
                text = opts.text,
                numhl = "",
            })
        end

        sign({ name = "DiagnosticSignError", text = "✘" })
        sign({ name = "DiagnosticSignWarn", text = "▲" })
        sign({ name = "DiagnosticSignHint", text = "⚑" })
        sign({ name = "DiagnosticSignInfo", text = "" })

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

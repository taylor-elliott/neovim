vim.opt.completeopt = { "menu", "menuone", "noselect" }

local lspkind = require "lspkind"
lspkind.init {}


local luasnip = require("luasnip")
local cmp = require "cmp"
cmp.setup {
    window = {
        documentation = {
            max_height = 15,
            max_width = 60,
            border = "rounded",
        },
    },
    sources = { { name = "luasnip" }, { name = "nvim_lsp" }, { name = "path" }, { name = "buffer" }, },
    mapping = cmp.mapping.preset.insert({

        ["<Tab>"] = cmp.mapping(function(fallback)
            if luasnip.jumpable(1) then
                luasnip.jump(1)
            else
                fallback()
            end
        end, { "i", "s" }),

        ["<CR>"] = cmp.mapping.confirm({ select = false }),


        ["<S-Tab>"] = cmp.mapping(function(fallback)
            if luasnip.jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { "i", "s" }),

        ["<Down>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            else
                fallback()
            end
        end, { "i", "s" }),

        ["<Up>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            else
                fallback()
            end
        end, { "i", "s" }),
    }),
    snippet = {
        expand = function(args)
            require("luasnip").lsp_expand(args.body)
        end,
    },
}

cmp.setup.filetype({ "sql" }, {
    sources = {
        { name = "vim-dadbod-completion" },
        { name = "buffer" }
    }

})

local ls = require "luasnip"
ls.config.set_config {
    history = false,
    updateevents = "TextChanged, TextChangedI"
}
require("luasnip.loaders.from_lua").lazy_load({ paths = "~/.config/nvim-te/snippets" })

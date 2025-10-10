return {
    cmd = {
        "lua-language-server",
    },
    filetypes = {
        "lua",
    },
    root_markers = {
        ".git",
        ".luacheckrc",
        ".luarc.json",
        ".luarc.jsonc",
        ".stylua.toml",
        "selene.toml",
        "selene.yml",
        "stylua.toml",
    },
    settings = {
        Lua = {
            diagnostics = {
                globals = { "vim" },
                -- disable = { "missing-parameters", "missing-fields" },
            },
            format = {
                enable = true,
                defaultConfig = {
                    indent_style = "space",
                    indent_size = "4",
                    quote_style = "double",
                },
            },
            completion = {
                enable = false,
                callSnippet = "Disable",
                keywordSnippet = "Disable",
            }
        },
    },

    single_file_support = true,
    log_level = vim.lsp.protocol.MessageType.Warning,
}

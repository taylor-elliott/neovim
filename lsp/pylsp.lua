return {
    cmd = { "pylsp" },
    filetypes = { "python" },
    root_markers = {
        "pyproject.toml",
        "setup.py",
        "setup.cfg",
        "requirements.txt",
        "Pipfile",
        ".git",
    },
    settings = {
        pylsp = {
            plugins = {
                pycodestyle = {
                    ignore = { "W391" },
                    maxLineLength = 100
                },
                pyflakes = { enabled = true },
                mccabe = { enabled = true, threshold = 15 },
                yapf = { enabled = false }, -- or true if you want formatting via yapf
                black = { enabled = true }, -- enable Black formatting
                isort = { enabled = true }, -- enable import sorting
            },
        },
    },
    single_file_support = true,
    log_level = vim.lsp.protocol.MessageType.Warning,
}

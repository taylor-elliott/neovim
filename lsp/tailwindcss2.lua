local function find_root_dir()
    local buf = vim.api.nvim_get_current_buf()
    local clients = vim.lsp.get_clients({ bufnr = buf })

    for _, client in pairs(clients) do
        if client.name == "tailwindcss" then
            print("Tailwind CSS LSP is already running")
            return
        end
    end

    local fname = vim.api.nvim_buf_get_name(buf)
    local root_files = { ".git" }
    local root_path = nil
    local found = vim.fs.find(root_files, { path = fname, upward = true })[1]
    if found then
        root_path = vim.fs.dirname(found)
    else
        root_path = vim.loop.cwd() -- fallback to current working directory
    end
    return root_path
end

return {
    filetypes = {
        "javascript",
        "javascriptreact",
        "javascript.jsx",
        "typescript",
        "typescriptreact",
        "typescript.tsx",
    },
    root_dir = find_root_dir(),

    cmd = { "tailwindcss-language-server", "--stdio" },

    settings = {
        tailwindCSS = {
            validate = true,
            experimental = {
                -- colorDecorators = false,
            },
        },
    },
}

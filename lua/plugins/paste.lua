local unpack = table.unpack or unpack

local function get_coords()
    local output = vim.fn.system("python3 /home/telliott/Scripts/bin/overlay.py")
    output = vim.trim(output)
    local coords = {}
    for num in string.gmatch(output, "[^,]+") do
        table.insert(coords, tonumber(num))
    end
    print("Got coords from Python:", unpack(coords))
    return coords
end

local function get_screen()
    local coords = get_coords()
    print(coords)
    local area = table.concat(coords, ",")
    print(area)
    local cmd = "!scrot -a "
        .. area
        .. " /tmp/screenshot.png && "
        .. "xclip -selection clipboard -t image/png -i /tmp/screenshot.png"
    vim.cmd(cmd)
end

local function paste_and_cleanup()
    vim.cmd("PasteImage")

    local tmpfile = "/tmp/screenshot.png"
    if vim.loop.fs_stat(tmpfile) then
        vim.loop.fs_unlink(tmpfile)
    end
end

local function get_latex()
    local bufnr = vim.api.nvim_get_current_buf()
    local line_num = vim.api.nvim_win_get_cursor(0)[1]
    local equation = vim.api.nvim_buf_get_lines(0, line_num - 1, line_num, false)[1]
    print(equation)
    local quoted = "'" .. equation:gsub("'", "'\\''") .. "'"
    local cmd = "python3 /home/telliott/Scripts/bin/latex.py "
        .. quoted
        .. " && xclip -selection clipboard -t image/png -i /tmp/screenshot.png"

    vim.fn.system(cmd)
    vim.api.nvim_buf_set_lines(bufnr, line_num - 1, line_num, false, {})
    vim.api.nvim_win_set_cursor(0, { line_num - 1, 0 })
    paste_and_cleanup()
end

return {
    "HakonHarnes/img-clip.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
        { "<leader>p", paste_and_cleanup, desc = "Paste image from system clipboard" },
        { "<leader>C", get_screen,        desc = "Copy image to system clipboard" },
        { "<leader>T", get_latex },
    },
}

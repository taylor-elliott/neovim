local g = vim.g
local opt = vim.opt

vim.o.pumheight = 15 -- height of the autocompletion window

g.mapleader = " "
g.maplocalleader = " "
g.vsnip_snippet_dir = vim.fn.stdpath("config") .. "/snippets/"
g.netrw_banner = 0
g.netrw_liststyle = 3
g.netrw_sort_sequence = [[[\/]$,\.bak$,\.o$,\.h$,\.info$,\.swp$,\.obj$,.git$,\.DS_Store$]]
g.netrw_list_hide = [[\(^\|\s\s\)\zs\.\S\+]]
g.netrw_hide = 1
g.netrw_browse_split = 0
g.netrw_winsize = 25

-- opt.virtualedit = "all"
opt.guifont = "FiraCode Nerd Font:h12" -- adjust size as needed
opt.guicursor = ""
opt.mouse = "a"
opt.isfname:append("@-@")
opt.signcolumn = "yes"
opt.nu = true
opt.relativenumber = true
opt.showmode = true
opt.smartindent = true
opt.wrap = true
opt.linebreak = true
opt.breakindent = true
opt.textwidth = 80
opt.breakindentopt = { "shift:2" }
opt.showbreak = " " -- optional visual marker
opt.swapfile = false
opt.backup = false
opt.undofile = true
opt.hlsearch = false
opt.incsearch = true
opt.termguicolors = true
opt.expandtab = true
opt.scrolloff = 10
opt.softtabstop = 4
opt.shiftwidth = 4
opt.tabstop = 4
opt.updatetime = 250
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

vim.schedule(function() vim.opt.clipboard = "unnamedplus" end)

vim.cmd([[
function! NetrwCreateFileFullPath()
    let l:dir = b:netrw_curdir
    echo "Creating file in: " . l:dir
    let l:fname = input("Enter filename: ")
    if !empty(l:fname)
        let l:fullpath = l:dir . "/" . l:fname
        execute "edit " . fnameescape(l:fullpath)
    endif
endfunction
autocmd FileType netrw nnoremap <buffer> % :call NetrwCreateFileFullPath()<CR>
]])


-- vim.cmd([[highlight Headline1 guibg=#FF0000]])
-- vim.cmd([[highlight Headline2 guibg=#00FF00]])
-- vim.cmd([[highlight Headline3 guibg=#0000FF]])

-- vim.cmd([[highlight RenderMarkdownCodeInfo guibg=#252525]])
-- vim.cmd([[highlight RenderMarkdownCode guibg=#252525]])
-- vim.cmd([[highlight Dash guibg=#FF0000 gui=bold]])

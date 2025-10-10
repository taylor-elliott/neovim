local extract = require("utils.extract")
local h = require("utils.helper")
local api = vim.api

local augroup = vim.api.nvim_create_augroup
local autocmd = api.nvim_create_autocmd

local format_group = augroup("AutoFormatOnInsertLeave", { clear = true })
vim.api.nvim_set_hl(0, "YankHighlight", { fg = "#ff0000", bg = "#000000" })
local yank_group = augroup("HighlightYank", { clear = true })
-- local general = augroup("General", { clear = true })
-- autocmd({ "FocusLost", "BufLeave", "BufWinLeave", "InsertLeave" }, {
--     -- nested = true, -- for format on save
--     callback = function()
--         if vim.bo.filetype ~= "" and vim.bo.buftype == "" then
--             vim.cmd("silent! w")
--         end
--     end,
--     group = general,
--     desc = "Auto Save",
-- })

autocmd({ "BufRead", "BufNewFile" }, {
    callback = function()
        vim.fn.setreg("k", "")
    end,
})


autocmd("FileType", {
    pattern = "qf",
    callback = function()
        h.h.map("n", "a", h.open_builtin_code_action_at_quickfix)
    end,
})
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = { "*.js", "*.jsx", "*.ts", "*.tsx" },
    callback = function()
        local buf = vim.api.nvim_get_current_buf()
        local filepath = vim.fn.expand("%:p")
        local content = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        local joined = table.concat(content, "\n")

        local prettier = "prettier --stdin-filepath " .. vim.fn.shellescape(filepath)
        local output = vim.fn.systemlist(prettier, joined)

        if vim.v.shell_error ~= 0 then
            vim.notify("Prettier failed:\n" .. table.concat(output, "\n"), vim.log.levels.ERROR)
        else
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, output)
        end
    end,
    desc = "Format with Prettier on save",
})

autocmd("TermOpen", {
    pattern = "*",
    callback = function(args)
        vim.cmd("startinsert")
        h.map("n", "q", "<cmd>close<CR>", { buffer = args.buf })
    end,
})

autocmd("FileType", {
    pattern = { "typescriptreact", "javascriptreact", "c" },
    callback = function()
        local buf = vim.api.nvim_get_current_buf()
        local ft = vim.bo[buf].filetype

        if ft == "typescriptreact" or ft == "javascriptreact" then
            vim.keymap.set("v", "<leader>mv", function()
                extract.create_component("tsx") -- pass "tsx" for React files
            end, { desc = "Extract selection to src/components/{Name}.tsx", buffer = buf })
            vim.keymap.set("v", "<leader>mb", function()
                extract.set_barrel()
            end, { desc = "Extract component {Name}.tsx and update barrel index.ts", buffer = buf })
        elseif ft == "c" then
            vim.keymap.set("v", "<leader>mv", function()
                extract.create_component("c") -- pass "c" for C files
            end, { desc = "Extract selection to C file", buffer = buf })
        end
    end,
})

autocmd("BufReadPost", {
    pattern = "*.pdf",
    callback = function()
        local file = vim.fn.expand("%:p")
        os.execute("zathura " .. vim.fn.shellescape(file) .. " &")
        vim.cmd("bdelete")                                  -- close the empty buffer in Neovim
        vim.cmd("Explore")
        local parent_dir = vim.fn.fnamemodify(file, ":h:h") -- two :h to go one dir up
        local notes_file = parent_dir .. "/notes.md"
        vim.cmd("edit " .. vim.fn.fnameescape(notes_file))
    end,
})

-- "FocusLost", "BufLeave", "BufWinLeave",
-- autocmd("InsertLeave", {
-- 	group = format_group,
-- 	pattern = "*",
-- 	callback = function()
-- 		if vim.bo.buftype ~= "" or vim.fn.bufname() == "" then
-- 			return
-- 		end
--
-- 		local ft = vim.bo.filetype
-- 		if ft == "text" or ft == "markdown" then
-- 			return
-- 		end
--
-- 		-- Check if clangd client is attached (using new API)
-- 		local clients = vim.lsp.get_clients({ bufnr = 0 })
-- 		local has_clangd = false
-- 		for _, client in ipairs(clients) do
-- 			if client.name == "clangd" then
-- 				has_clangd = true
-- 				break
-- 			end
-- 		end
--
-- 		if not has_clangd then
-- 			return
-- 		end
-- 		if vim.bo.filetype == "c" then
-- 			vim.lsp.buf.format({
-- 				async = false,
-- 				filter = function(client)
-- 					return client.name == "clangd"
-- 				end,
-- 			})
--
-- 			if vim.bo.modified then
-- 				vim.cmd("silent! write")
-- 			end
-- 		end
-- 	end,
-- })

-- autocmd("LspAttach", {
-- 	callback = function(args)
-- 		local client = vim.lsp.get_client_by_id(args.data.client_id)
--         if not client then
--             return nil
--         end
-- 		if client:supports_method("textDocument/foldingRange") then
-- 			local win = vim.api.nvim_get_current_win()
-- 			vim.wo[win][0].foldexpr = "v:lua.vim.lsp.foldexpr()"
-- 		end
-- 	end,
-- })

autocmd("FileType", {
    callback = function()
        vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
        if vim.bo.filetype == "c" then
            vim.opt.foldlevel = 3
        elseif vim.bo.filetype == "markdown" then
            vim.opt.foldmethod = "expr"
            vim.opt.foldlevel = 3
            vim.opt.foldlevelstart = 1
        else
            vim.opt.foldmethod = "expr"
            vim.opt.foldtext = ""
            vim.opt.foldlevel = 3
            vim.opt.foldlevelstart = 3
            vim.opt.foldnestmax = 3
        end
    end,
})

autocmd("ColorScheme", {
    pattern = "*",
    callback = function()
        vim.api.nvim_set_hl(0, "LineNrAbove", {})
        vim.api.nvim_set_hl(0, "LineNrBelow", {})
        vim.api.nvim_set_hl(0, "LineNr", { fg = "#98C379", bold = true })
    end,
})
autocmd("TextYankPost", {
    group = yank_group,
    pattern = "*",
    callback = function()
        vim.highlight.on_yank({
            timeout = 150,
            higroup = "IncSearch",
        })
    end,
})
-- autocmd("TermOpen", {
-- 	once = true,
-- 	callback = function()
-- 		-- vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = true, silent = true })
-- 		vim.keymap.set("t", "q", [[<C-\><C-n><cmd>close<CR>]], { buffer = true, silent = true })
-- 	end,
-- })
autocmd({ "BufWritePre" }, {
    group = format_group,
    pattern = "*",
    command = [[%s/\s\+$//e]],
})

-- autocmd("LspAttach", {
-- 	group = lsp_group,
-- 	callback = function(args)
-- 		local client = lsp.get_client_by_id(args.data.client_id)
--
-- 		if
-- 			type(lsp.inlay_hint) == "function"
-- 			and client
-- 			and client.server_capabilities
-- 			and client.server_capabilities.inlayHintProvider
-- 		then
-- 			lsp.inlay_hint(args.buf, true)
-- 		end
--
-- 		local opts = { buffer = args.buf }
-- 		h.map("n", "gd", function()
-- 			lsp.buf.definition()
-- 		end, opts)
-- 		-- h.map("n", "K", function()
-- 		-- 	lsp.buf.hover()
-- 		-- end, opts)
-- 		h.map("n", "<leader>vws", function()
-- 			lsp.buf.workspace_symbol()
-- 		end, opts)
-- 		h.map("n", "<leader>vd", function()
-- 			vim.diagnostic.open_float()
-- 		end, opts)
-- 		h.map("n", "<leader>vca", function()
-- 			lsp.buf.code_action()
-- 		end, opts)
-- 		h.map("n", "<leader>vrr", function()
-- 			lsp.buf.references()
-- 		end, opts)
-- 		h.map("n", "<leader>vrn", function()
-- 			lsp.buf.rename()
-- 		end, opts)
-- 	end,
-- })

-- autocmd("BufWritePre", {
--     pattern = { "*.c", "*.ts", "*.tsx", "*.js", "*.jsx" },
--     callback = function()
--         lsp.buf.code_action({
--             context =
--             { only = { "source.organizeImports" }, diagnostics = {} },
--             apply = true,
--         })
--     end,
-- })

autocmd({ "BufRead", "BufNewFile" }, {
    pattern = "*.h",
    callback = function()
        vim.bo.filetype = "c"
    end,
})

autocmd("FileType", {
    pattern = "netrw",
    callback = function()
        vim.api.nvim_buf_del_keymap(0, "n", "gh")
        vim.api.nvim_buf_set_keymap(0, "n", "gh", "<Plug>NetrwHideToggle", {})
    end,
})

autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("my.lsp", {}),
    callback = function(args)
        local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
        if client:supports_method("textDocument/implementation") then
            -- Create a keymap for vim.lsp.buf.implementation ...
        end
        -- Enable auto-completion. Note: Use CTRL-Y to select an item. |complete_CTRL-Y|
        if client:supports_method("textDocument/completion") then
            -- Optional: trigger autocompletion on EVERY keypress. May be slow!
            -- local chars = {}; for i = 32, 126 do table.insert(chars, string.char(i)) end
            -- client.server_capabilities.completionProvider.triggerCharacters = chars
            vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
        end
        -- Auto-format ("lint") on save.
        -- Usually not needed if server supports "textDocument/willSaveWaitUntil".
        if not client:supports_method("textDocument/willSaveWaitUntil")
            and client:supports_method("textDocument/formatting") then
            vim.api.nvim_create_autocmd("BufWritePre", {
                group = vim.api.nvim_create_augroup("my.lsp", { clear = false }),
                buffer = args.buf,
                callback = function()
                    vim.lsp.buf.format({ bufnr = args.buf, id = client.id, timeout_ms = 1000 })
                end,
            })
        end
    end,
})



local latex_to_unicode = {
    ["\\sup0"] = "⁰",
    ["\\sup1"] = "¹",
    ["\\sup2"] = "²",
    ["\\sup3"] = "³",
    ["\\sup4"] = "⁴",
    ["\\sup5"] = "⁵",
    ["\\sup6"] = "⁶",
    ["\\sup7"] = "⁷",
    ["\\sup8"] = "⁸",
    ["\\sup9"] = "⁹",
    ["\\supneg"] = "⁻",
    ["\\supi"] = "ⁱ",
    ["\\supleftp"] = "⁽",
    ["\\suprightp"] = "⁾",
    ["\\suppos"] = "⁺",
    ["\\supequal"] = "⁼",
    ["\\supa"] = "ᵃ",
    ["\\supb"] = "ᵇ",
    ["\\supc"] = "ᶜ",
    ["\\supd"] = "ᵈ",
    ["\\supe"] = "ᵉ",
    ["\\supf"] = "ᶠ",
    ["\\supg"] = "ᵍ",
    ["\\suph"] = "ʰ",
    ["\\supj"] = "ᵏ",
    ["\\supk"] = "ᵏ",
    ["\\supl"] = "ˡ",
    ["\\supm"] = "ᵐ",
    ["\\supn"] = "ⁿ",
    ["\\supN"] = "ᴺ",
    ["\\supp"] = "ᵖ",
    ["\\supq"] = "ᑫ",
    ["\\supr"] = "ʳ",
    ["\\supt"] = "ᵗ",
    ["\\supu"] = "ᵘ",
    ["\\supv"] = "ᵛ",
    ["\\supw"] = "ʷ",
    ["\\supx"] = "ˣ",
    ["\\supT"] = "ᵀ",
    ["\\supy"] = "ʸ",
    ["\\supz"] = "ᶻ",
    ["\\sub0"] = "₀",
    ["\\sub1"] = "₁",
    ["\\sub2"] = "₂",
    ["\\sub3"] = "₃",
    ["\\sub4"] = "₄",
    ["\\sub5"] = "₅",
    ["\\sub6"] = "₆",
    ["\\sub7"] = "₇",
    ["\\sub8"] = "₈",
    ["\\sub9"] = "₉",
    ["\\subneg"] = "₋",
    ["\\subpos"] = "₊",
    ["\\subequal"] = "₌",
    ["\\subi"] = "ᵢ",
    ["\\subleftp"] = "₍",
    ["\\subrightp"] = "₎",
    ["\\sube"] = "ₑ",
    ["\\suba"] = "ₐ",
    ["\\subb"] = "ᵦ",
    ["\\subc"] = "ₒ",
    ["\\subd"] = "ᵈ",
    -- ["\\subf"] = "𝑓",
    ["\\subg"] = "ᵧ",
    ["\\subh"] = "ₕ",
    ["\\subj"] = "ⱼ",
    ["\\subk"] = "ₖ",
    ["\\subl"] = "ₗ",
    ["\\subm"] = "ₘ",
    ["\\subn"] = "ₙ",
    ["\\subo"] = "ₒ",
    ["\\subp"] = "ₚ",
    ["\\subq"] = "𝓆",
    ["\\subr"] = "ᵣ",
    ["\\subt"] = "ₜ",
    ["\\subu"] = "ᵘ",
    ["\\subv"] = "ᵥ",
    ["\\subw"] = "ʷ",
    ["\\subx"] = "ₓ",
    ["\\suby"] = "ʸ",
    ["\\subz"] = "ᶻ",

    -- Greek letters
    ["\\alpha"] = "α",
    ["\\beta"] = "β",
    ["\\gamma"] = "γ",
    ["\\delta"] = "δ",
    ["\\epsilon"] = "ε",
    ["\\zeta"] = "ζ",
    ["\\eta"] = "η",
    ["\\theta"] = "θ",
    ["\\iota"] = "ι",
    ["\\kappa"] = "κ",
    ["\\lambda"] = "λ",
    ["\\wave"] = "λ",
    ["\\mu"] = "μ",
    ["\\mean"] = "μ",
    ["\\nu"] = "ν",
    ["\\xi"] = "ξ",
    ["\\pi"] = "π",
    ["\\rho"] = "ρ",
    ["\\sigma"] = "σ",
    ["\\std"] = "σ",
    ["\\tau"] = "τ",
    ["\\phi"] = "φ",
    ["\\chi"] = "χ",
    ["\\psi"] = "ψ",
    ["\\omega"] = "ω",
    ["\\setnatural"] = "ℕ",
    ["\\setreal"] = "ℝ",
    ["\\xbar"] = "x̄",
    ["\\xhat"] = "x̂",
    ["\\upphi"] = "Φ",
    ["\\sum"] = "∑",
    ["\\integral"] = "∫",
    ["\\prod"] = "∏",
    ["\\infty"] = "∞",
    ["\\sqrt"] = "√",
    ["\\leq"] = "≤",
    ["\\geq"] = "≥",
    ["\\neq"] = "≠",
    ["\\times"] = "×",
    ["\\pm"] = "±",
    ["\\botharrow"] = "⟷",
    ["\\leftarrow"] = "🠐",
    ["\\rightarrow"] = "🠒",
    ["\\doublebar"] = "‖",
    -- Logical / set symbols
    ["\\land"] = "∧", -- logical AND
    ["\\lor"] = "∨", -- logical OR
    ["\\lnot"] = "¬", -- negation
    ["\\not"] = "¬", -- negation
    ["\\emptyset"] = "∅", -- empty set
    ["\\empty"] = "∅", -- empty set
    ["\\uniset"] = "𝕌",
    ["\\identity"] = "𝟙", -- identity operator
    ["\\iden"] = "𝟙", -- identity operator
    -- Set operations
    ["\\union"] = "∪",
    ["\\inter"] = "∩",
    ["\\intersection"] = "∩",
    -- Equivalence / triple bar
    ["\\equ"] = "＝",
    ["\\3bar"] = "≡",
    ["\\line"] = "⎯",
    ["\\subset"] = "⊆",
    ["\\notsubset"] = "⊈",
    ["\\contains"] = "∈",
    ["\\ele"] = "∈",
    ["\\elumentof"] = "∈",
    ["\\notelementof"] = "∉",
    ["\\notele"] = "∉",
    ["\\itlambda"] = "𝜆",
    ["\\iti"] = "𝑖",
    ["\\itx"] = "𝑥",
    ["\\itmu"] = "𝜇",
    ["\\itmean"] = "𝜇",
    ["\\itstd"] = "𝜎",
    ["\\join"] = "⋈",
    ["\\itA"] = "𝘈",
    ["\\itB"] = "𝘉",
    ["\\itC"] = "𝘊",
    ["\\itf"] = "𝑓",
    ["\\ity"] = "𝑦",
    ["\\itj"] = "𝑗",
    ["\\itk"] = "𝑘",
    ["\\ita"] = "𝒶",
    ["\\itb"] = "𝒷",
    ["\\itc"] = "𝒸",

}

local function convert_latex_to_unicode()
    local bufnr = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    for i, line in ipairs(lines) do
        for latex, unicode in pairs(latex_to_unicode) do
            local match_found = line:find(latex)
            if match_found then
                vim.notify("Replacing: " .. latex .. " -> " .. unicode)
                line = line:gsub(latex, unicode)
            end
        end
        lines[i] = line
    end
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
end

autocmd("FileType", {
    pattern = "markdown",
    callback = function()
        vim.keymap.set("n", "<leader>ff", function()
            if vim.bo.filetype ~= "markdown" then
                print("Not a Markdown buffer")
                return
            end
            convert_latex_to_unicode()
        end, { buffer = 0, desc = "Convert LaTeX to Unicode in Markdown" })
    end,
})

local M = {}

local function list_concat(A, B)
    local t = {}
    for _, value in ipairs(A) do
        table.insert(t, value)
    end
    for _, value in ipairs(B) do
        table.insert(t, value)
    end
    return t
end

local function set_import(component_name)
    local pattern = [[^import%s*{([^}]*)}%s*from%s*['"]%.?/components['"];?]]
    local import_line = string.format("import { %s } from '@components';", component_name)
    local existing_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local insert_line = 0
    local found_line_index = nil
    local existing_imports = {}

    for i, line in ipairs(existing_lines) do
        if line:match(pattern) then
            found_line_index = i
            -- Parse existing imports inside { ... }
            local imports_str = line:match(pattern)
            for name in imports_str:gmatch("[^,%s]+") do
                existing_imports[name] = true
            end
            break
        end
        if not line:match("^import") then
            insert_line = i - 1
            break
        end
    end

    -- Add the new component to the existing imports if found
    if found_line_index then
        existing_imports[component_name] = true
        -- Rebuild the import statement
        local import_list = {}
        for name in pairs(existing_imports) do
            table.insert(import_list, name)
        end
        table.sort(import_list) -- optional
        import_line = string.format("import { %s } from '@components';", table.concat(import_list, ", "))
        -- Replace the line with the updated import
        vim.api.nvim_buf_set_lines(0, found_line_index - 1, found_line_index, false, { import_line })
    else
        -- Insert a new import line at the calculated position
        vim.api.nvim_buf_set_lines(0, insert_line, insert_line, false, { import_line, "" })
    end
end

local function set_barrel()
    local start_pos = vim.fn.getpos("v")
    local end_pos = vim.fn.getpos(".")
    local ls = math.min(start_pos[2], end_pos[2])
    local le = math.max(start_pos[2], end_pos[2])

    local lines = vim.api.nvim_buf_get_lines(0, ls - 1, le, false)
    if #lines == 0 or lines[1]:match("^%s*$") then
        print("No selection!")
        return
    end

    -- Prompt for component name
    local component_name = vim.fn.input("Component name: ")
    if component_name == "" then
        print("No name given.")
        return
    end

    -- New file path
    local path = "src/components/" .. component_name .. ".tsx"
    local folder = vim.fn.fnamemodify(path, ":h")
    if vim.fn.isdirectory(folder) == 0 then
        vim.fn.mkdir(folder, "p")
    end

    local found_export = false
    for _, l in ipairs(lines) do
        if l:match("^%s*export%s+") then
            found_export = true
            break
        end
    end

    if not found_export then
        table.insert(lines, "export { " .. component_name .. " };")
    end
    -- Write exactly what you selected
    vim.fn.writefile(lines, path)

    local index_file = "src/components/index.ts"
    local export_line = string.format("export { %s } from './%s';", component_name, component_name)
    if vim.fn.filereadable(index_file) == 1 then
        local index_lines = vim.fn.readfile(index_file)
        local exists = false
        for _, l in ipairs(index_lines) do
            if l:find(export_line, 1, true) then
                exists = true
                break
            end
        end
        if not exists then
            table.insert(index_lines, export_line)
            vim.fn.writefile(index_lines, index_file)
            print("Updated barrel file: " .. index_file)
        else
            print("Already in barrel file")
        end
    else
        vim.fn.writefile({ export_line }, index_file)
        print("Created new barrel file: " .. index_file)
    end

    set_import(component_name)

    -- Remove selection from current file
    vim.api.nvim_buf_set_lines(0, ls - 1, le, false, {})
end
local function getLines()
    local start_pos = vim.fn.getpos("v")
    local end_pos = vim.fn.getpos(".")
    local ls = math.min(start_pos[2], end_pos[2])
    local le = math.max(start_pos[2], end_pos[2])

    local lines = vim.api.nvim_buf_get_lines(0, ls - 1, le, false)
    if #lines == 0 or lines[1]:match("^%s*$") then
        print("No selection!")
        return
    end
    return lines, ls - 1, le
end
local function getFilename()
    local filename = vim.fn.input("Filename (without extension): ")
    if filename == "" then
        return ""
    end
    return filename
end
local function setTsx(component_name, lines, ls, le)
    local path = "src/components/" .. component_name .. ".tsx"
    local folder = vim.fn.fnamemodify(path, ":h")
    if vim.fn.isdirectory(folder) == 0 then
        vim.fn.mkdir(folder, "p")
    end

    -- Add named export if needed
    local found_export = false
    for _, l in ipairs(lines) do
        if l:match("^%s*export%s+") then
            found_export = true
            break
        end
    end

    if not found_export then
        table.insert(lines, "export { " .. component_name .. " };")
    end

    -- Write to new file
    vim.fn.writefile(lines, path)

    -- Remove selection from current file
    vim.api.nvim_buf_set_lines(0, ls - 1, le, false, {})

    -- Add import statement at top
    local import_line = string.format("import { %s } from '@components/%s';", component_name, component_name)
    local existing_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local insert_line = 0
    for i, line in ipairs(existing_lines) do
        if not line:match("^import") then
            insert_line = i - 1
            break
        end
    end
    vim.api.nvim_buf_set_lines(0, insert_line, insert_line, false, { import_line, "" })

    -- Open new file in split
    vim.cmd("vsplit " .. path)

    print("Extracted selection to " .. path)
end

local function guard_name(filename)
    return filename:upper() .. "_H"
end

local function extract_prototypes_from_lines(lines)
    local prototypes = {}
    local in_function = false
    local func_lines = {}

    for _, line in ipairs(lines) do
        -- Accumulate lines that look like function declarations
        if not in_function and line:match("^[%w_%*%s]-[%w_]+%s*%b()%s*{?%s*$") then
            in_function = true
            table.insert(func_lines, line)
            if line:find("{") then
                -- single-line function
                local prototype = line:gsub("{.*", ""):gsub("%s+$", "") .. ";"
                table.insert(prototypes, prototype)
                in_function = false
                func_lines = {}
            end
        elseif in_function then
            table.insert(func_lines, line)
            if line:find("{") then
                -- function signature complete
                local joined = table.concat(func_lines, " ")
                local prototype = joined:gsub("{.*", ""):gsub("%s+$", "") .. ";"
                table.insert(prototypes, prototype)
                in_function = false
                func_lines = {}
            end
        end
    end

    return prototypes
end

local stdlib_headers = {
    printf = "<stdio.h>",
    fprintf = "<stdio.h>",
    FILE = "<stdio.h>",
    fopen = "<stdio.h>",
    fclose = "<stdio.h>",
    fgets = "<stdio.h>",
    strtok = "<string.h>",
    strcmp = "<string.h>",
    strcpy = "<string.h>",
    strncpy = "<string.h>",
    malloc = "<stdlib.h>",
    free = "<stdlib.h>",
    exit = "<stdlib.h>",
    memset = "<string.h>",
    memcpy = "<string.h>",
}
local function scanForHeaders(lines)
    -- Scan for used standard library functions
    local used_headers = {}
    local used = {}

    for _, line in ipairs(lines) do
        for word, header in pairs(stdlib_headers) do
            if line:find(word, 1, true) and not used[header] then
                table.insert(used_headers, "#include " .. header)
                used[header] = true
            end
        end
    end

    -- Prepend inferred headers to the .c content
    local c_file_lines = vim.list_extend(used_headers, { "" }) -- add empty line
    vim.list_extend(c_file_lines, lines)

    return c_file_lines
end
local function setC(filename, lines, start_line, end_line)
    local h_file = filename .. ".h"
    local h_path = "include/" .. h_file
    local c_path = "src/" .. filename .. ".c"
    local macro = guard_name(filename)

    local c_file_lines = scanForHeaders(lines)
    vim.fn.writefile(c_file_lines, c_path)

    -- Parse function prototypes from the lines
    local prototypes = extract_prototypes_from_lines(lines)

    if #prototypes == 0 then
        table.insert(prototypes, "// TODO: Add function declarations")
    end

    local header_lines = {
        "#ifndef " .. macro,
        "#define " .. macro,
        "",
        unpack(prototypes),
        "",
        "#endif /* " .. macro .. " */",
    }

    vim.fn.writefile(header_lines, h_path)

    -- Remove selected lines from current buffer
    vim.api.nvim_buf_set_lines(0, start_line, end_line, false, {})

    -- Insert #include "file.h" at top of current buffer
    local include_line = '#include "' .. h_file .. '"'
    local existing_lines = vim.api.nvim_buf_get_lines(0, 0, 20, false)

    local already_included = false
    for _, line in ipairs(existing_lines) do
        if line == include_line then
            already_included = true
            break
        end
    end

    if not already_included then
        -- Insert after other includes
        local insert_line = 0
        for i, line in ipairs(existing_lines) do
            if not line:match("^#include") then
                insert_line = i - 1
                break
            end
        end
        vim.api.nvim_buf_set_lines(0, insert_line, insert_line, false, { include_line, "" })
    end

    -- Open the .c and .h files
    vim.cmd("vsplit " .. c_path)
    vim.cmd("split " .. h_path)

    print("Extracted to " .. c_path .. " and generated prototype(s) in " .. h_path)
end
local function create_component(type)
    -- Get start and end of visual selection
    local lines, start_line, end_line = getLines()
    if not lines then
        return
    end
    local filename = getFilename()
    if filename == "" then
        return
    end
    if type == "tsx" then
        setTsx(filename, lines, start_line, end_line)
    elseif type == "c" then
        setC(filename, lines, start_line, end_line)
    end
end

M.list_concat = list_concat
M.set_import = set_import
M.set_barrel = set_barrel
M.create_component = create_component

return M

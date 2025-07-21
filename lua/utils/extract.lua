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
	local import_line = string.format("import { %s } from './components';", component_name)
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
		import_line = string.format("import { %s } from './components';", table.concat(import_list, ", "))
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

local function create_component()
	-- Get start and end of visual selection (robust)
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
	local import_line = string.format("import { %s } from './components/%s';", component_name, component_name)
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

M.list_concat = list_concat
M.set_import = set_import
M.set_barrel = set_barrel
M.create_component = create_component

return M

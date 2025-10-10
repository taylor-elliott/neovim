local M = {}
local function ReloadModule(name)
    local full_name = "config." .. name
    package.loaded[full_name] = nil
    require(full_name)
    print(full_name .. " reloaded!")
end

M.ReloadModule = ReloadModule

return M

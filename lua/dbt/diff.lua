-- lua/plugins/custom/dbt/diff.lua

local core = require("plugins.custom.dbt.core")
local M = {}

function M.diff_model_vs_compiled()
    local project_root = core.get_dbt_project_root()
    if not project_root then
        vim.notify("DBT_PROJECT_DIR not set", vim.log.levels.ERROR)
        return
    end

    local dbt_project_name = vim.env.DBT_PROJECT_NAME
    if not dbt_project_name or dbt_project_name == "" then
        vim.notify("DBT_PROJECT_NAME not set", vim.log.levels.ERROR)
        return
    end

    local buf_path = core.normalize(vim.api.nvim_buf_get_name(0))
    local model_rel = core.extract_model_relative_path(buf_path, project_root)
    if not model_rel then
        vim.notify("Not a valid DBT model-related file", vim.log.levels.INFO)
        return
    end

    local model_path = project_root .. "/" .. model_rel
    local compiled_path = project_root .. "/target/compiled/" .. dbt_project_name .. "/" .. model_rel

    local file = io.open(compiled_path, "r")
    if not file then
        vim.notify("Compiled file not found: " .. compiled_path, vim.log.levels.WARN)
        return
    end
    file:close()

    vim.cmd("edit " .. vim.fn.fnameescape(model_path))
    vim.cmd("vert diffsplit " .. vim.fn.fnameescape(compiled_path))
end

return M

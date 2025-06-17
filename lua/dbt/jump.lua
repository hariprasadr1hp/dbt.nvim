-- lua/plugins/custom/dbt/jump.lua

local core = require("plugins.custom.dbt.core")

local M = {}

local function open_path(path, open_cmd)
    local file = io.open(path, "r")
    if file then
        file:close()
        vim.cmd((open_cmd or "edit") .. " " .. vim.fn.fnameescape(path))
    else
        print("File not found: " .. path)
    end
end

local function jump_to_variant(model_rel, type)
    local dbt_dir = core.normalize(vim.env.DBT_PROJECT_DIR)
    local dbt_name = vim.env.DBT_PROJECT_NAME

    local path = (type == "models") and dbt_dir .. "/" .. model_rel
        or dbt_dir .. "/target/" .. type .. "/" .. dbt_name .. "/" .. model_rel

    open_path(path)
end

function M.jump_to_model()
    local buf_path = core.normalize(vim.api.nvim_buf_get_name(0))
    local rel =
        core.extract_model_relative_path(buf_path, core.normalize(vim.env.DBT_PROJECT_DIR), vim.env.DBT_PROJECT_NAME)
    if rel then
        jump_to_variant(rel, "models")
    end
end

function M.jump_to_compiled()
    local buf_path = core.normalize(vim.api.nvim_buf_get_name(0))
    local rel =
        core.extract_model_relative_path(buf_path, core.normalize(vim.env.DBT_PROJECT_DIR), vim.env.DBT_PROJECT_NAME)
    if rel then
        jump_to_variant(rel, "compiled")
    end
end

function M.jump_to_run()
    local buf_path = core.normalize(vim.api.nvim_buf_get_name(0))
    local rel =
        core.extract_model_relative_path(buf_path, core.normalize(vim.env.DBT_PROJECT_DIR), vim.env.DBT_PROJECT_NAME)
    if rel then
        jump_to_variant(rel, "run")
    end
end

function M.jump_between_model_and_schema()
    local buf_path = core.normalize(vim.api.nvim_buf_get_name(0))
    local ext = buf_path:match("^.+(%..+)$")
    if ext ~= ".sql" and ext ~= ".yml" then
        print("Not a .sql or .yml DBT file.")
        return
    end
    local other = buf_path:gsub(ext == ".sql" and "%.sql$" or "%.yml$", ext == ".sql" and ".yml" or ".sql")
    open_path(other)
end

return M

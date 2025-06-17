-- dbt/cycle.lua

local core = require("dbt.core")

local M = {}

local function build_variants(model_rel, dbt_dir, dbt_name)
    local stem = model_rel:gsub("%.sql$", ""):gsub("%.yml$", "")
    return {
        { label = "schema", path = dbt_dir .. "/" .. stem .. ".yml" },
        { label = "compiled", path = dbt_dir .. "/target/compiled/" .. dbt_name .. "/" .. stem .. ".sql" },
        { label = "run", path = dbt_dir .. "/target/run/" .. dbt_name .. "/" .. stem .. ".sql" },
        { label = "model", path = dbt_dir .. "/" .. stem .. ".sql" },
    }
end

local function open_next_variant(model_rel, current_path, variants, dir)
    local norm = core.normalize
    local idx
    for i, v in ipairs(variants) do
        if norm(v.path) == current_path then
            idx = i
            break
        end
    end
    for offset = 1, #variants do
        local next = ((idx or 0) + offset * dir - 1) % #variants + 1
        local try = variants[next]
        local file = io.open(try.path, "r")
        if file then
            file:close()
            vim.cmd("edit " .. vim.fn.fnameescape(try.path))
            return
        end
    end
    print("No other DBT view found for this model.")
end

function M.toggle_dbt_cycling()
    M.cycling_enabled = not M.cycling_enabled
    local msg = M.cycling_enabled and "DBT cycling enabled" or "DBT cycling disabled"
    vim.notify(msg, vim.log.levels.INFO)
end

function M.cycle(direction)
    if not M.cycling_enabled then
        vim.notify("DBT cycling is currently disabled", vim.log.levels.INFO)
        return
    end

    local dbt_dir = core.normalize(vim.env.DBT_PROJECT_DIR)
    local dbt_name = vim.env.DBT_PROJECT_NAME
    local buf = core.normalize(vim.api.nvim_buf_get_name(0))

    -- local rel = core.extract_model_relative_path(buf, dbt_dir, dbt_name)
    local rel = core.extract_model_relative_path(buf, dbt_dir)
    if not rel then
        print("Not a DBT model/compiled/run/schema file.")
        return
    end

    local variants = build_variants(rel, dbt_dir, dbt_name)
    open_next_variant(rel, buf, variants, direction)
end

return M

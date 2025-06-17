-- lua/plugins/custom/dbt/graph.lua

local core = require("plugins.custom.dbt.core")

local M = {}
local manifest = nil

--- Load and cache manifest.json
local function load_manifest()
    if manifest then
        return manifest
    end

    local dbt_dir = core.get_dbt_project_root()
    if not dbt_dir then
        return
    end

    local path = dbt_dir .. "/target/manifest.json"
    local file = io.open(path, "r")
    if not file then
        vim.notify("manifest.json not found", vim.log.levels.ERROR)
        return
    end

    local content = file:read("*a")
    file:close()

    manifest = vim.json.decode(content)
    return manifest
end

--- Get the current model's node ID and node object
local function get_current_model_node()
    local project_root = core.get_dbt_project_root()
    if not project_root then
        return
    end

    local buf_path = core.normalize(vim.api.nvim_buf_get_name(0))
    local rel_path = core.extract_model_relative_path(buf_path, project_root)
    if not rel_path then
        return
    end

    local mf = load_manifest()
    if not mf then
        return
    end

    for node_id, node in pairs(mf.nodes) do
        if node.resource_type == "model" and node.original_file_path == rel_path then
            return node_id, node
        end
    end

    vim.notify("Current model not found in manifest", vim.log.levels.WARN)
end

--- Get paths of upstream or downstream models
---@param direction "upstream"|"downstream"
local function get_related_model_paths(direction)
    local mf = load_manifest()
    if not mf then
        return {}
    end

    local node_id, _ = get_current_model_node()
    if not node_id then
        return {}
    end

    local related_ids = {}
    if direction == "upstream" then
        related_ids = mf.parent_map[node_id] or {}
    elseif direction == "downstream" then
        related_ids = mf.child_map[node_id] or {}
    end

    local dbt_dir = core.get_dbt_project_root()
    local paths = {}

    for _, id in ipairs(related_ids) do
        local node = mf.nodes[id]
        if node and node.resource_type == "model" and node.original_file_path then
            table.insert(paths, dbt_dir .. "/" .. node.original_file_path)
        end
    end

    return paths
end

--- Prompt user to select a related model
---@param direction "upstream"|"downstream"
function M.select_related_model(direction)
    if vim.bo.filetype ~= "sql" then
        vim.notify("Only works for DBT model .sql files", vim.log.levels.INFO)
        return
    end

    local paths = get_related_model_paths(direction)
    if #paths == 0 then
        vim.notify("No " .. direction .. " models found", vim.log.levels.INFO)
        return
    end

    require("fzf-lua").fzf_exec(paths, {
        prompt = direction .. " models> ",
        actions = {
            ["default"] = function(selected)
                vim.cmd("edit " .. vim.fn.fnameescape(selected[1]))
            end,
        },
    })
end

return M

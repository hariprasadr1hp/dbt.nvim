-- dbt/core.lua

local M = {}

--- Normalize a path to absolute, Unix-style, without trailing slashes
---@param path string
---@return string
function M.normalize(path)
    return (vim.fn.fnamemodify(path, ":p"):gsub("\\", "/"):gsub("/+$", ""))
end

--- Get the dbt project root (absolute) from environment
---@return string|nil
function M.get_dbt_project_root()
    local env_dir = vim.env.DBT_PROJECT_DIR
    if not env_dir or env_dir == "" then
        return nil
    end
    return M.normalize(env_dir)
end

--- Get the model-relative path for the current buffer (as used in manifest.json)
---@param buf_path string
---@param project_root string
---@return string|nil
function M.extract_model_relative_path(buf_path, project_root)
    -- Try to match from the "models/" segment
    local rel_path = buf_path:gsub("^" .. project_root .. "/", "")
    if rel_path:match("^models/") then
        return rel_path
    end

    -- If buf_path is a compiled/run path, strip off target/... prefix and map to model path
    rel_path = buf_path:match("target/[^/]+/[^/]+/models/.*$")
    if rel_path then
        return rel_path:gsub("^target/[^/]+/[^/]+/models/", "models/")
    end

    return nil
end

return M

-- dbt/init.lua

local jump = require("dbt.jump")
local cycle = require("dbt.cycle")
local diff = require("dbt.diff")
local graph = require("dbt.graph")

local M = {}

-- Optional default config if you want to allow user config later
local defaults = {
    keymaps_enabled = true,
    cycling_enabled = true,
}

---@param opts table|nil
function M.setup(opts)
    opts = vim.tbl_deep_extend("force", defaults, opts or {})

    if opts.cycling_enabled then
        cycle.cycling_enabled = true
    else
        cycle.cycling_enabled = false
    end

    if opts.keymaps_enabled then
        vim.api.nvim_create_user_command("DBTToggleCyclingFiles", function()
            cycle.toggle_dbt_cycling()
        end, {
            desc = "Toggle DBT file view cycling",
        })

        vim.keymap.set("n", "]v", function()
            cycle.cycle(1)
        end, { desc = "next-variant" })

        vim.keymap.set("n", "[v", function()
            cycle.cycle(-1)
        end, { desc = "prev-variant" })

        vim.api.nvim_create_user_command("DBTUpstreamFiles", function()
            graph.select_related_model("upstream")
        end, { desc = "Select upstream DBT models" })

        vim.api.nvim_create_user_command("DBTDownstreamFiles", function()
            graph.select_related_model("downstream")
        end, { desc = "Select downstream DBT models" })

        vim.api.nvim_create_user_command("DBTDiffModelAndCompiled", function()
            diff.diff_model_vs_compiled()
        end, { desc = "Diff in a vertical split, between model and its corresponding compiled sql target" })
    end
end

-- Expose public API
M.jump_to_model = jump.jump_to_model
M.jump_to_compiled = jump.jump_to_compiled
M.jump_to_run = jump.jump_to_run
M.jump_between_model_and_schema = jump.jump_between_model_and_schema
M.cycle = cycle.cycle
M.toggle_dbt_cycling = cycle.toggle_dbt_cycling
M.diff_model_vs_compiled = diff.diff_model_vs_compiled
M.select_upstream_models = function()
    graph.select_related_model("upstream")
end
M.select_downstream_models = function()
    graph.select_related_model("downstream")
end

return M

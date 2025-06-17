# dbt.nvim

A Neovim plugin to work with [dbt](https://www.getdbt.com/).
It lets you navigate and manage DBT models like code — with full support for model dependencies, compiled SQL, and schema files.

---

## ✨ Features

- Jump between:
  - `model.sql` ⇄ `compiled.sql` ⇄ `run.sql`
  - `model.sql` ⇄ `schema.yml`
- Cycle through file types with `[v` / `]v`
- Explore upstream/downstream dependencies with `:DBTUpstream` and `:DBTDownstream`
- `:DBTDiff` – see a diff between the model and its compiled output
- Toggle file cycling with `:DBTToggleCyclingFiles`

---

## ⚙ Requirements

- [`fzf-lua`](https://github.com/ibhagwan/fzf-lua)
- `DBT_PROJECT_DIR` and `DBT_PROJECT_NAME` must be set as environment variables
- Works with DBT's `manifest.json` (produced by `dbt compile`, `dbt run`, etc.)

---

## 🛠 Installation (Local Plugin)

### With [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "hariprasadr1hp/dbt.nvim",
  config = function()
    require("dbt").setup()
  end,
}

```

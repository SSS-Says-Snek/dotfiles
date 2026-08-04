return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  branch = "main",
  config = function ()
    local configs = require("nvim-treesitter.config")
    vim.g.ts_install = {
        "c",
        "cpp",
        "css",
        "lua",
        "vim",
        "vimdoc",
        "query",
        "elixir",
        "heex",
        "javascript",
        "html",
        "python",
        "rust",
        "markdown",
        "markdown_inline",
        -- "java",
        "html",
        "svelte",
        "typescript",
        -- "latex"
    }

    local ts_install = vim.g.ts_install or {}
    local ts_filetypes = vim
    .iter(ts_install)
    :map(function(lang)
      return vim.treesitter.language.get_filetypes(lang)
    end)
    :flatten()
    :totable()

    require("nvim-treesitter").install(ts_install)

    vim.api.nvim_create_autocmd("FileType", {
      desc = "Setup treesitter for a buffer",
      -- NOTE: We explicitly define filetypes
      pattern = ts_filetypes,
      group = vim.api.nvim_create_augroup("ts_setup", { clear = true }),
      callback = function(e)
        vim.treesitter.start(e.buf)
        vim.wo.foldmethod = "expr"
        vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
    vim.treesitter.language.register('qmljs', 'qml')

    configs.setup({
      ensure_installed = {
        "c",
        "cpp",
        "css",
        "lua",
        "vim",
        "vimdoc",
        "query",
        "elixir",
        "heex",
        "javascript",
        "html",
        "python",
        "rust",
        "markdown",
        "markdown_inline",
        -- "java",
        "html",
        "svelte",
        "typescript",
        -- "latex"
      },
      sync_install = false,
      highlight = { enable = true },
      indent = {
        enable = true
      },
    })
  end
}

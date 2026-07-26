---@module 'lazy'
---@type LazySpec
return {
  { -- Autoformat
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>f',
        function() require('conform').format { async = true } end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    ---@module 'conform'
    ---@type conform.setupOpts
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        -- You can specify filetypes to autoformat on save here:
        local enabled_filetypes = {
          -- lua = true,
          -- python = true,
        }
        if enabled_filetypes[vim.bo[bufnr].filetype] then
          return { timeout_ms = 500 }
        else
          return nil
        end
      end,
      default_format_opts = {
        lsp_format = 'fallback', -- Use external formatters if configured below, otherwise use LSP formatting. Set to `false` to disable LSP formatting entirely.
      },
      -- You can also specify external formatters in here.
      formatters_by_ft = {
        lua = { 'stylua' },
        go = { 'goimports', 'gofumpt' },

        -- Python: isort (imports) then black (formatting)
        python = { 'isort', 'black' },

        -- TypeScript/JavaScript
        javascript = { 'prettier', stop_after_first = true },
        typescript = { 'prettier', stop_after_first = true },
        javascriptreact = { 'prettier', stop_after_first = true },
        typescriptreact = { 'prettier', stop_after_first = true },

        -- Web formats (all handled by prettier)
        html = { 'prettier', stop_after_first = true },
        css = { 'prettier', stop_after_first = true },
        json = { 'prettier', stop_after_first = true },
        jsonc = { 'prettier', stop_after_first = true },

        -- Rust
        rust = { 'rustfmt', stop_after_first = true },

        -- SQL
        sql = { 'sql-formatter', stop_after_first = true },

        -- Markdown
        markdown = { 'prettier', stop_after_first = true },
      },
    },
  },
}
-- vim: ts=2 sts=2 sw=2 et

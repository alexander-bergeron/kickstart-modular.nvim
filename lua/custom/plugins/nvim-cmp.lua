local M = {
  'hrsh7th/nvim-cmp',
  dependencies = {
    -- COMMENTED OUT: These are now handled by kickstart/cmp.lua
    -- 'hrsh7th/cmp-nvim-lsp',
    -- 'hrsh7th/cmp-nvim-lua',
    -- 'hrsh7th/cmp-buffer',
    -- 'hrsh7th/cmp-path',
    -- 'hrsh7th/cmp-cmdline',
    -- 'saadparwaiz1/cmp_luasnip',
    -- 'L3MON4D3/LuaSnip',
  },
}

-- DISABLED: Custom cmp config removed to prevent overriding kickstart/cmp.lua
-- The kickstart config provides all core functionality (snippet nav, completion, etc.)
-- This custom config was overriding it and removing snippet navigation keybinds (<C-l>, <C-h>)
-- See lua/kickstart/plugins/cmp.lua for the active configuration
--
-- Future enhancement: If you want to re-enable cmp-buffer and cmp-cmdline,
-- they should be added to kickstart/cmp.lua instead of duplicating here
--[[
M.config = function()
  local cmp = require 'cmp'
  vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }

  cmp.setup {
    snippet = {
      expand = function(args)
        require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
      end,
    },
    window = {
      -- completion = cmp.config.window.bordered(),
      -- documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert {
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm { select = true }, -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    },
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'nvim_lua' },
      { name = 'luasnip' }, -- For luasnip users.
      -- { name = "orgmode" },
    }, {
      { name = 'buffer' },
      { name = 'path' },
    }),
  }

  cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = 'path' },
    }, {
      { name = 'cmdline' },
    }),
  })
end
]]--

return M

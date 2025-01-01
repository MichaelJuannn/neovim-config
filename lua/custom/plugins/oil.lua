return {
  'stevearc/oil.nvim',
  ---@module 'oil'
  ---@type oil.SetupOpts
  opts = {},
  -- Optional dependencies
  dependencies = { { 'echasnovski/mini.icons', opts = {} } },
  keys = {
    { '<leader>e', '<cmd>Oil --float<CR>', 'n', desc = 'Oil' },
  },
}

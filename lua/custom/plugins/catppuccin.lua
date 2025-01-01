return {
  'catppuccin/nvim',
  name = 'catppuccin',
  priority = 1000,
  opts = {
    integrations = { blink_cmp = true },
  },
  init = function()
    vim.cmd.colorscheme 'catppuccin-mocha'
  end,
}
-- vim: ts=2 sts=2 sw=2 et

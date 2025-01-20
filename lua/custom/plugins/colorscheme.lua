return {
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000,
    opts = {
      integrations = { blink_cmp = true },
    },
  },
  {
    'rebelot/kanagawa.nvim',
    name = 'kanagawa',
    priority = 1000,
    opts = {},
    init = function()
      vim.cmd.colorscheme 'kanagawa-dragon'
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et

-- LSP Plugins
return {
  "mason-org/mason-lspconfig.nvim",
  dependencies = {
    { "mason-org/mason.nvim", opts = {} },
    "neovim/nvim-lspconfig"
  },
  opts = {}
}
-- vim: ts=2 sts=2 sw=2 et

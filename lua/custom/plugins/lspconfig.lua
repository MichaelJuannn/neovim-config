-- LSP Plugins
return {
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        { path = 'luvit-meta/library', words = { 'vim%.uv' } },
      },
    },
  },
  { 'Bilal2453/luvit-meta', lazy = true },
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'williamboman/mason.nvim', opts = {} }, -- NOTE: Must be loaded before dependants
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      { 'j-hui/fidget.nvim', opts = {} },
      'saghen/blink.cmp',
    },
    config = function()
      local servers = {
        vtsls = {
          root_dir = require('lspconfig').util.root_pattern 'package.json',
          single_file_support = false,
        },
        denols = {
          mason = false,
          root_dir = require('lspconfig').util.root_pattern('deno.json', 'deno.jsonc'),
        },
        lua_ls = {
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
            },
          },
        },
        ruff = {
          cmd_env = { RUFF_TRACE = 'messages' },
          init_options = {
            settings = {
              logLevel = 'error',
            },
          },
          keys = {
            {
              '<leader>co',
              '<cmd>echo ex<cr>',
              desc = 'Organize Imports',
            },
          },
        },
        basedpyright = {
          settings = {
            basedpyright = {
              analysis = {
                typeCheckingMode = 'standard',
              },
            },
          },
        },
      }

      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          -- NOTE: Remember that Lua is a real programming language, and as such it is possible
          -- to define small helper and utility functions so you don't have to repeat yourself.
          --
          -- In this case, we create a function that lets us more easily define mappings specific
          -- for LSP related items. It sets the mode, buffer and description for us each time.
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          map('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
          map('gr', vim.lsp.buf.references, '[G]oto [R]eferences')
          map('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
          map('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
          map('<leader>ds', vim.lsp.buf.document_symbol, '[D]ocument [S]ymbols')
          map('<leader>ws', vim.lsp.buf.workspace_symbol, '[W]orkspace [S]ymbols')
          map('<leader>cr', vim.lsp.buf.rename, 'Lsp Rename')
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })

          map('<leader>cA', function()
            vim.lsp.buf.code_action {
              apply = true,
              context = {
                only = { 'source' },
                diagnostics = {},
              },
            }
          end, 'Source Actions', { 'n', 'x' })

          -- WARN: This is not Goto Definition, this is Goto Declaration.
          --  For example, in C this would take you to the header.
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          -- The following code creates a keymap to toggle inlay hints in your
          -- code, if the language server you are using supports them
          --
          -- This may be unwanted, since they displace some of your code
          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      if vim.g.have_nerd_font then
        local signs = {
          ERROR = '',
          WARN = '',
          INFO = '',
          HINT = '',
        }
        local diagnostic_signs = {}

        for type, icon in pairs(signs) do
          diagnostic_signs[vim.diagnostic.severity[type]] = icon
        end

        vim.diagnostic.config {
          underline = true,
          update_in_insert = false,
          virtual_text = {
            spacing = 4,
            source = 'if_many',
            prefix = '●', -- Fallback prefix
            -- Uncomment the following lines if your Neovim build supports function prefix
            prefix = function(diagnostic)
              local icons = {
                [vim.diagnostic.severity.ERROR] = diagnostic_signs[vim.diagnostic.severity.ERROR],
                [vim.diagnostic.severity.WARN] = diagnostic_signs[vim.diagnostic.severity.WARN],
                [vim.diagnostic.severity.HINT] = diagnostic_signs[vim.diagnostic.severity.HINT],
                [vim.diagnostic.severity.INFO] = diagnostic_signs[vim.diagnostic.severity.INFO],
              }
              return ' ' .. icons[diagnostic.severity]
            end,
          },
          severity_sort = true,
          signs = {
            text = diagnostic_signs,
            severity = {
              min = vim.diagnostic.severity.HINT,
            },
            icons = {
              [vim.diagnostic.severity.ERROR] = diagnostic_signs[vim.diagnostic.severity.ERROR],
              [vim.diagnostic.severity.WARN] = diagnostic_signs[vim.diagnostic.severity.WARN],
              [vim.diagnostic.severity.HINT] = diagnostic_signs[vim.diagnostic.severity.HINT],
              [vim.diagnostic.severity.INFO] = diagnostic_signs[vim.diagnostic.severity.INFO],
            },
          },
        }
      end

      --  NOTE: THIS IS USING BLINK CMP NOT NVIM CMP for capabilities
      local capabilities = require('blink.cmp').get_lsp_capabilities()
      local lspconfig = require 'lspconfig'
      for server, config in pairs(servers) do
        -- passing config.capabilities to blink.cmp merges with the capabilities in your
        -- `opts[server].capabilities, if you've defined it
        config.capabilities = require('blink.cmp').get_lsp_capabilities(config.capabilities)
        lspconfig[server].setup(config)
      end

      -- tailwindcss xd ?
      local function setup_tailwindcss(_, opts)
        local default_config = lspconfig.tailwindcss.document_config.default_config

        -- Ensure opts.filetypes is initialized
        opts.filetypes = opts.filetypes or {}

        -- Add default filetypes
        vim.list_extend(opts.filetypes, default_config.filetypes)

        -- Remove excluded filetypes
        opts.filetypes = vim.tbl_filter(function(ft)
          return not vim.tbl_contains(opts.filetypes_exclude or {}, ft)
        end, opts.filetypes)

        -- Add additional filetypes
        vim.list_extend(opts.filetypes, opts.filetypes_include or {})

        -- Setup Tailwind CSS LSP with the modified options
        lspconfig.tailwindcss.setup(opts)
      end

      setup_tailwindcss(nil, {
        filetypes_exclude = { 'markdown' },
        filetypes_include = {},
      })

      -- Fix hover problem no manual entry
      vim.lsp.handlers['textDocument/hover'] = function(_, result, ctx, config)
        config = config or {}
        config.focus_id = ctx.method
        if not (result and result.contents) then
          return
        end
        local markdown_lines = vim.lsp.util.convert_input_to_markdown_lines(result.contents)
        markdown_lines = vim.lsp.util.trim_empty_lines(markdown_lines)
        if vim.tbl_isempty(markdown_lines) then
          return
        end
        return vim.lsp.util.open_floating_preview(markdown_lines, 'markdown', config)
      end

      require('mason-lspconfig').setup {
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            -- This handles overriding only values explicitly passed
            -- by the server configuration above. Useful when disabling
            -- certain features of an LSP (for example, turning off formatting for ts_ls)
            --
            --
            if server_name == 'ruff' then
              server.on_attach = function(client, bufnr)
                client.server_capabilities.hoverProvider = false
              end
            end
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end,
        },
      }
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et

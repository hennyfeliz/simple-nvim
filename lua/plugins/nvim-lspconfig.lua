return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "stevearc/conform.nvim",
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline",
    "hrsh7th/nvim-cmp",
    "L3MON4D3/LuaSnip",
    "saadparwaiz1/cmp_luasnip",
    "j-hui/fidget.nvim",
    "saghen/blink.cmp",

    {
      "folke/lazydev.nvim",
      opts = {
        library = {
          { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        },
      },
    },
  },

  config = function()
    -- Setup formatters
    require("conform").setup({ formatters_by_ft = {} })

    -- LSP capabilities from blink.cmp
    local capabilities = require("blink.cmp").get_lsp_capabilities()

    -- Mason setup
    require("mason").setup()
    require("mason-lspconfig").setup({
      ensure_installed = { "lua_ls", "rust_analyzer", "gopls", "html", "cssls", "emmet_ls", "typescript-language-server", "jdtls" },
      handlers = {
        function(server_name)
          require("lspconfig")[server_name].setup({ capabilities = capabilities })
        end,
        ["emmet_ls"] = function()
          require("lspconfig").emmet_ls.setup({
            capabilities = capabilities,
            filetypes = {
              "html",
              "css",
              "scss",
              "javascriptreact",
              "typescriptreact",
              "vue",
            },
            init_options = {
              html = {
                options = {
                  ["bem.enabled"] = true,
                },
              },
            },
          })
        end,

        ["lua_ls"] = function()
          require("lspconfig").lua_ls.setup({
            capabilities = capabilities,
            settings = {
              Lua = {
                runtime = { version = "Lua 5.1" },
                diagnostics = {
                  globals = { "bit", "vim", "it", "describe", "before_each", "after_each" },
                },
              },
            },
          })
        end,

        ["zls"] = function()
          local lspconfig = require("lspconfig")
          lspconfig.zls.setup({
            root_dir = lspconfig.util.root_pattern(".git", "build.zig", "zls.json"),
            settings = {
              zls = {
                enable_inlay_hints = true,
                enable_snippets = true,
                warn_style = true,
              },
            },
          })
          vim.g.zig_fmt_parse_errors = 0
          vim.g.zig_fmt_autosave = 0
                end,

        ["jdtls"] = function()
          -- Skip jdtls here - handled by nvim-jdtls plugin
        end,

        ["typescript-language-server"] = function()
          -- TypeScript/JavaScript Language Server configuration  
          require("lspconfig").tsserver.setup({
            capabilities = capabilities,
            settings = {
              typescript = {
                inlayHints = {
                  includeInlayParameterNameHints = 'all',
                  includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                  includeInlayFunctionParameterTypeHints = true,
                  includeInlayVariableTypeHints = true,
                  includeInlayPropertyDeclarationTypeHints = true,
                  includeInlayFunctionLikeReturnTypeHints = true,
                  includeInlayEnumMemberValueHints = true,
                }
              },
              javascript = {
                inlayHints = {
                  includeInlayParameterNameHints = 'all',
                  includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                  includeInlayFunctionParameterTypeHints = true,
                  includeInlayVariableTypeHints = true,
                  includeInlayPropertyDeclarationTypeHints = true,
                  includeInlayFunctionLikeReturnTypeHints = true,
                  includeInlayEnumMemberValueHints = true,
                }
              }
            }
          })
        end,
      },
    })

    -- TypeScript is now handled in the ts_ls handler above


    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        local c = vim.lsp.get_client_by_id(args.data.client_id)
        if not c then
          return
        end

        -- Format on save for Lua
        if vim.bo.filetype == "lua" then
          vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = args.buf,
            callback = function()
              vim.lsp.buf.format({ bufnr = args.buf, id = c.id })
            end,
          })
        end

        -- LSP keymaps
        local buf = args.buf
        local opts = { buffer = buf, noremap = true, silent = true }

        -- Navigation
        vim.keymap.set("n", "J", vim.lsp.buf.definition,
          vim.tbl_extend("force", opts, { desc = "Go to Definition" }))
        vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references,
          vim.tbl_extend("force", opts, { desc = "Find References" }))
        vim.keymap.set("n", "<leader>gi", vim.lsp.buf.implementation,
          vim.tbl_extend("force", opts, { desc = "Go to Implementation" }))
        vim.keymap.set("n", "K", vim.lsp.buf.hover,
          vim.tbl_extend("force", opts, { desc = "Hover Docs" }))

        -- Code actions
        vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action,
          vim.tbl_extend("force", opts, { desc = "Code Actions" }))
        
        -- Rename
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename,
          vim.tbl_extend("force", opts, { desc = "Rename Symbol" }))

        -- Signature help
        vim.keymap.set("n", "<C-h>", vim.lsp.buf.signature_help,
          vim.tbl_extend("force", opts, { desc = "Signature Help" }))
      end,
    })

    -- cmp setup
    local cmp = require("cmp")
    local cmp_select = { behavior = cmp.SelectBehavior.Select }
    cmp.setup({
      snippet = {
        expand = function(args)
          require("luasnip").lsp_expand(args.body)
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
        ["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
        ["<C-y>"] = cmp.mapping.confirm({ select = true }),
        ["<C-Space>"] = cmp.mapping.complete(),
      }),
      sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" },
      }, {
        { name = "buffer" },
      }),
    })

    -- Diagnostics config
    vim.diagnostic.config({
      float = {
        focusable = false,
        style = "minimal",
        border = "rounded",
        source = "always",
        header = "",
        prefix = "",
      },
    })

    -- Fidget UI
    require("fidget").setup({})
  end,
}

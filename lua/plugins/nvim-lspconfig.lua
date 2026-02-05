return {
  "neovim/nvim-lspconfig",
  enabled = true,
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
    -- LSP compatibility fix
    if vim.lsp._request_name_to_capability == nil then
      vim.lsp._request_name_to_capability = setmetatable({}, {
        __index = function(_, key)
          return {}
        end,
      })
    end

    -- Setup formatters
    require("conform").setup({ formatters_by_ft = {} })

    -- LSP capabilities from blink.cmp
    local capabilities = require("blink.cmp").get_lsp_capabilities()

    -- Mason setup
    require("mason").setup()
    require("mason-lspconfig").setup({
      ensure_installed = { "lua_ls", "html", "cssls", "jsonls" },
    })

    -- Lua LSP setup
    vim.lsp.config("lua_ls", {
      capabilities = capabilities,
      settings = {
        Lua = {
          runtime = { version = "LuaJIT" },
          diagnostics = { globals = { "vim" } },
          workspace = {
            library = vim.api.nvim_get_runtime_file("", true),
            checkThirdParty = false,
          },
          telemetry = { enable = false },
        },
      },
    })
    vim.lsp.enable("lua_ls")

    -- Mason setup for other servers
    require("mason-lspconfig").setup({
      ensure_installed = { "rust_analyzer", "gopls", "html", "cssls", "emmet_ls", "ts_ls" },
      handlers = {
        function(server_name)
          vim.lsp.config(server_name, { capabilities = capabilities })
          vim.lsp.enable(server_name)
        end,
        ["emmet_ls"] = function()
          vim.lsp.config("emmet_ls", {
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
          vim.lsp.enable("emmet_ls")
        end,

        ["zls"] = function()
          vim.lsp.config("zls", {
            root_dir = function(bufnr, on_dir)
              on_dir(vim.fs.root(vim.api.nvim_buf_get_name(bufnr), { ".git", "build.zig", "zls.json" }))
            end,
            settings = {
              zls = {
                enable_inlay_hints = true,
                enable_snippets = true,
                warn_style = true,
              },
            },
          })
          vim.lsp.enable("zls")
          vim.g.zig_fmt_parse_errors = 0
          vim.g.zig_fmt_autosave = 0
        end,

        ["jdtls"] = function() end, -- gestionado por nvim-java

        ["ts_ls"] = function()
          vim.lsp.config("ts_ls", {
            capabilities = capabilities,
            settings = {
              typescript = {
                inlayHints = {
                  includeInlayParameterNameHints = "all",
                  includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                  includeInlayFunctionParameterTypeHints = true,
                  includeInlayVariableTypeHints = true,
                  includeInlayPropertyDeclarationTypeHints = true,
                  includeInlayFunctionLikeReturnTypeHints = true,
                  includeInlayEnumMemberValueHints = true,
                },
              },
              javascript = {
                inlayHints = {
                  includeInlayParameterNameHints = "all",
                  includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                  includeInlayFunctionParameterTypeHints = true,
                  includeInlayVariableTypeHints = true,
                  includeInlayPropertyDeclarationTypeHints = true,
                  includeInlayFunctionLikeReturnTypeHints = true,
                  includeInlayEnumMemberValueHints = true,
                },
              },
            },
          })
          vim.lsp.enable("ts_ls")
        end,
      },
    })

    -- LSP keymaps (sin format on save)
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        local c = vim.lsp.get_client_by_id(args.data.client_id)
        if not c then return end

        -- LSP keymaps
        local opts = { buffer = args.buf, silent = true }
        vim.keymap.set("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover" }))
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code Action" }))
        vim.keymap.set({ "n", "v" }, "<leader>cj", function()
          local ok, actions = pcall(require, 'java.actions')
          if ok and vim.bo[args.buf].filetype == 'java' then
            actions.menu()
          else
            vim.notify('Java generators not available here', vim.log.levels.WARN)
          end
        end, vim.tbl_extend("force", opts, { desc = "Java Generators (local)" }))
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename" }))
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

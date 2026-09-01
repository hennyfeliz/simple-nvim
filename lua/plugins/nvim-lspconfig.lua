return {
  "neovim/nvim-lspconfig",
  enabled = true,
  dependencies = {
    "stevearc/conform.nvim",
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "hrsh7th/cmp-nvim-lsp",
    "j-hui/fidget.nvim",

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

    -- Completion remains provided by nvim-cmp; no se cargan dos engines LSP.
    local capabilities = require("cmp_nvim_lsp").default_capabilities()

    -- Mason setup
    require("mason-lspconfig").setup({
      ensure_installed = {
        "lua_ls",
        "rust_analyzer",
        "gopls",
        "html",
        "cssls",
        "emmet_ls",
        "ts_ls",
        "jsonls",
      },
      handlers = {
        ["lua_ls"] = function()
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
        end,
        function(server_name)
          if server_name == "lua_ls" or server_name == "jdtls" then return end
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

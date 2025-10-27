-- lua/plugins/web-ls.lua
return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = { "williamboman/mason-lspconfig.nvim" },
  opts = {
    servers = {
      tsserver = {
        settings = {
          typescript = {
            inlayHints = {
              includeInlayParameterNameHints = "all",
              includeInlayVariableTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
            },
            preferences = { includeCompletionsForModuleExports = true },
          },
          javascript = { inlayHints = { includeInlayParameterNameHints = "all" } },
        },
      },
      eslint = { settings = { workingDirectories = { mode = "auto" } } },
      html = { filetypes = { "html", "templ", "twig", "erb" } },
      cssls = {},
      emmet_ls = { filetypes = { "css","html","javascriptreact","typescriptreact" } },
      tailwindcss = { filetypes = { "html","css","javascriptreact","typescriptreact" } },
      jsonls = { settings = { json = { validate = { enable = true } } } },
    },
  },
  config = function(_, opts)
    local lsp = require("lspconfig")
    for name, cfg in pairs(opts.servers or {}) do
      lsp[name].setup(cfg)
    end
  end,
}


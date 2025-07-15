-- Mason LSP Config - manages LSP servers and formatters
return {
  "williamboman/mason-lspconfig.nvim",
  dependencies = { "williamboman/mason.nvim" },
  config = function()
    -- LSP compatibility fix
    if vim.lsp._request_name_to_capability == nil then
      vim.lsp._request_name_to_capability = setmetatable({}, {
        __index = function(_, key)
          return {}
        end,
      })
    end
    
    require("mason-lspconfig").setup({
      -- Ensure these LSP servers are installed
      ensure_installed = {
        "jdtls",           -- Java Language Server
        "ts_ls",           -- TypeScript/JavaScript LSP
        "eslint",          -- ESLint LSP
        "html",            -- HTML LSP
        "cssls",           -- CSS LSP
        "jsonls",          -- JSON LSP
        "lua_ls",          -- Lua LSP
      },
      -- Auto-install LSP servers
      automatic_installation = true,
    })
  end,
}

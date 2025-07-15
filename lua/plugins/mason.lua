-- Mason core plugin
return {
  "williamboman/mason.nvim",
  cmd = "Mason", -- lazy-load on :Mason
  keys = {
    { "<leader>m", "<cmd>Mason<CR>", desc = "Open Mason" },
  },
  config = function()
    require("mason").setup({
      ensure_installed = {
        -- LSP servers
        "jdtls",              -- Java Language Server
        "ts_ls",              -- TypeScript/JavaScript LSP
        "eslint",             -- ESLint LSP
        "html",               -- HTML LSP
        "cssls",              -- CSS LSP
        "jsonls",             -- JSON LSP
        "lua_ls",             -- Lua LSP
        
        -- Formatters
        "prettier",           -- JavaScript/TypeScript/HTML/CSS formatter
        "stylua",             -- Lua formatter
        "black",              -- Python formatter
        "clang_format",       -- C/C++ formatter
        "shfmt",              -- Shell formatter
        "rustfmt",            -- Rust formatter
      },
      automatic_installation = true,
    })
  end,
}

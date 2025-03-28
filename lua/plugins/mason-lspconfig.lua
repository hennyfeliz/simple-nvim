-- (Optional) mason-lspconfig if you want LSP integration
return {
  "williamboman/mason-lspconfig.nvim",
  dependencies = { "williamboman/mason.nvim" },
  config = function()
    require("mason-lspconfig").setup()
  end,
}

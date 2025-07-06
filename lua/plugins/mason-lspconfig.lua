-- (Optional) mason-lspconfig if you want LSP integration
return {
  "williamboman/mason-lspconfig.nvim",
  enabled = false, -- DISABLED - causing crashes
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
    
    require("mason-lspconfig").setup()
  end,
}

-- lua/plugins/powershell-es.lua
return {
  "neovim/nvim-lspconfig",
  ft = { "ps1","psm1","psd1" },
  config = function()
    vim.lsp.config("powershell_es", {
      bundle_path = require("mason-registry").get_package("powershell-editor-services"):get_install_path(),
      settings = { powershell = { codeFormatting = { Preset = "OTBS" } } },
    })
    vim.lsp.enable("powershell_es")
  end,
}


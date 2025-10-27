-- lua/plugins/html-emmet-tweaks.lua
return {
  "neovim/nvim-lspconfig",
  ft = { "html","css","javascriptreact","typescriptreact" },
  config = function()
    -- Pequeños extras útiles para React
    vim.g.user_emmet_leader_key = "<C-y>"
    vim.g.user_emmet_settings = { jsx = { options = { ["jsx.enabled"] = true } } }
  end,
}


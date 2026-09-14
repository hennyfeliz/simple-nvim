-- PLUGIN: LazyGit
return {
  "kdheepak/lazygit.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  cmd = "LazyGit", -- load the plugin when the LazyGit command is called
  init = function()
    -- Usa toda la ventana de Neovim, igual que LazyGit ejecutado directamente.
    vim.g.lazygit_floating_window_scaling_factor = 1.0
  end,
  keys = {
    {
      "<leader>kg",
      "<cmd>LazyGit<CR>",
      desc = "Open LazyGit",
      silent = true,
    },
  },
}

-- PLUGIN: LazyGit
return {
  "kdheepak/lazygit.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  cmd = "LazyGit", -- load the plugin when the LazyGit command is called
  keys = {
    {
      "<leader>kg",
      "<cmd>LazyGit<CR>",
      desc = "Open LazyGit",
      silent = true,
    },
  },
}

-- ~/.config/nvim/lua/plugins.lua

return require("lazy").setup({
  -- 1) Plenary (a required dependency for many plugins, including Telescope)
  {
    "nvim-lua/plenary.nvim",
    lazy = false,  -- load it immediately
  },

  -- 2) Telescope
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup({
        defaults = {
          prompt_prefix = "🔍 ",
          selection_caret = "➜ ",
          path_display = { "smart" },
        },
        -- pickers = { ... } -- optional per-picker configs
        -- extensions = { ... } -- optional extension configs
      })
    end,
  },

  -- 3) Telescope File Browser extension
  {
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      -- Load the extension after Telescope is set up
      require("telescope").load_extension("file_browser")
    end,
  },

  -- PLUGIN: LazyGit
  {
    "kdheepak/lazygit.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = "LazyGit",   -- load the plugin when the LazyGit command is called
    keys = {
      {
        "<leader>kg",
        "<cmd>LazyGit<CR>",
        desc = "Open LazyGit", silent = true
      },
    },
  },
})

-- 2) Telescope
return {
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
}

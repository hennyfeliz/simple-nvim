-- lua/plugins/symbols-outline.lua
return {
  "simrat39/symbols-outline.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("symbols-outline").setup()
  end,
}

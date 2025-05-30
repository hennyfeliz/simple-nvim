-- ~/.config/nvim/lua/plugins/vim-surround.lua
return {
  {
    "tpope/vim-surround",
    event = "VeryLazy",
    keys = {
      -- Normal-mode mappings
      { "yss",  mode = "n", desc = "Surround whole line" },
      { "yS",   mode = "n", desc = "Surround WORD" },
      { "ysiw", mode = "n", desc = "Surround inner word" },
      { "ds",   mode = "n", desc = "Delete surrounding" },
      { "cs",   mode = "n", desc = "Change surrounding" },
      -- Visual-mode mapping
      { "S",    mode = "v", desc = "Surround visual selection" },
    },
    config = function()
      -- no extra config needed; uses tpope’s defaults
      -- usage examples:
      --   ysiw"  → "VARIABLE"
      --   ysiw'  → 'VARIABLE'
      --   ysiw*  → *VARIABLE*
      --   ds"    → remove quotes
      --   cs"'   → change " to '
    end,
  },
}

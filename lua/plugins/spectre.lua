-- lua/plugins/spectre.lua
return {
  "nvim-pack/nvim-spectre",
  cmd = "Spectre",
  opts = { open_cmd = "vnew" }, -- opcional
  keys = {
    { "<leader>sr", function() require("spectre").open() end, desc = "Search & Replace (project)" },
    { "<leader>sw", function() require("spectre").open_visual({ select_word=true }) end, desc = "Replace word (project)" },
    { "<leader>sf", function() require("spectre").open_file_search() end, desc = "Replace in file" },
  },
}


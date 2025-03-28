-- Mason core plugin
return {
  "williamboman/mason.nvim",
  cmd = "Mason", -- lazy-load on :Mason
  keys = {
    { "<leader>m", "<cmd>Mason<CR>", desc = "Open Mason" },
  },
  config = function()
    require("mason").setup()
  end,
}

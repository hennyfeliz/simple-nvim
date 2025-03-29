-- 3) Telescope File Browser extension
return {
  "nvim-telescope/telescope-file-browser.nvim",
  dependencies = { "nvim-telescope/telescope.nvim" },
  config = function()
    -- Load the extension after Telescope is set up
    require("telescope").load_extension("file_browser")
  end,
}

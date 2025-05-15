-- nvim web devicons
return {
  "kyazdani42/nvim-web-devicons",
  config = function()
    require("nvim-web-devicons").setup {
      -- enable “override” for custom files
      override = {
        -- example: markdown files get the Markdown icon
        md = {
          icon = "",
          color = "#519aba",
          name = "Markdown"
        },
      },
      default = true,
    }
  end,
}

-- nvim web devicons
return {
  "kyazdani42/nvim-web-devicons",
  config = function()
    require("nvim-web-devicons").setup {
      -- enable “override” for custom files
      override = {
        zsh = {
          icon = "",
          color = "#428850",
          cterm_color = "65",
          name = "Zsh",
        },
        -- example: markdown files get the Markdown icon
        md = {
          icon = "",
          color = "#519aba",
          name = "Markdown"
        },
      },
      color_icons = true,
      default = true,
      strict = true,
      variant = "light|dark",
      override_by_filename = {
        [".gitignore"] = {
          icon = "",
          color = "#f1502f",
          name = "Gitignore",
        },
      },
      override_by_extension = {
        log = {
          icon = "",
          color = "#81e043",
          name = "Log",
        },
      },
      override_by_operating_system = {
        apple = {
          icon = "",
          color = "#A2AAAD",
          cterm_color = "248",
          name = "Apple",
        },
      },
    }
  end,
}

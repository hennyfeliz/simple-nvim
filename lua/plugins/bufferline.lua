-- bufferline
return {
  "akinsho/bufferline.nvim",
  version = "*",
  dependencies = "nvim-tree/nvim-web-devicons",
  config = function()
    require("bufferline").setup({
      options = {
        mode = "buffers",          -- this shows buffers, not tabpages
        diagnostics = "nvim_lsp",  -- optional: show LSP error indicators
        separator_style = "slant", -- or "thick", "thin", "padded_slant"
        always_show_bufferline = true,
        show_buffer_close_icons = false,
        show_close_icon = false,
        offsets = {
          {
            filetype = "NvimTree",
            text = "File Explorer",
            highlight = "Directory",
            text_align = "left",
          },
        },
      },
    })
  end,
}

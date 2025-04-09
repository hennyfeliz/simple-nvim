-- add any tools you want to have installed below
return {
  "nvim-tree/nvim-tree.lua",
  opts = {
    view = {
      width = 30,
      side = "left",
    },
  },
  config = function()
    -- disable netrw at the very start of your init.lua
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

    -- optionally enable 24-bit colour
    vim.opt.termguicolors = true

    -- empty setup using defaults
    require("nvim-tree").setup()

    -- OR setup with some options
    require("nvim-tree").setup({
      sort = {
        sorter = "case_sensitive",
      },
      view = {
        width = 30,
      },
      renderer = {
        group_empty = true,
      },
      filters = {
        dotfiles = true,
      },
    })
    vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { noremap = true, silent = true })
    --set a keybind to exit nvim tree when enter a file and with C-enters "<C-<CR>> i think..." it opens the file, but keeps nvim tree open
    -- vim.keymap.set("n", "<C-CR>", ":NvimTreeClose<CR>", { noremap = true, silent = true })
    -- vim.keymap.set("n", "<C-CR>", "<CR><leader>e", { noremap = true, silent = true })
    -- vim.keymap.set("n", "<CR>", "<CR>:NvimTreeClose<CR>", { noremap = true, silent = true })
    -- vim.keymap.set("n", "<C-h>", ":NvimTreeFocus<CR>")
  end,
}

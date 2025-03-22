-- ~/.config/nvim/lua/keymaps.lua
local map = vim.keymap.set

-- Telescope’s built-in pickers
map("n", "<leader>ff", function() require("telescope.builtin").find_files() end, { desc = "Find files" })
map("n", "<leader>fg", function() require("telescope.builtin").live_grep() end, { desc = "Live grep" })
map("n", "<leader>fb", function() require("telescope.builtin").buffers() end,    { desc = "List buffers" })
map("n", "<leader>fh", function() require("telescope.builtin").help_tags() end,  { desc = "Help tags" })

-- File browser extension
map("n", "<leader>fe", function()
  require("telescope").extensions.file_browser.file_browser()
end, { desc = "File browser" })

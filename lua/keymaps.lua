-- ~/.config/nvim/lua/keymaps.lua
local map = vim.keymap.set

-- Telescope’s built-in pickers
map("n", "<leader>ff", function()
	require("telescope.builtin").find_files()
end, { desc = "Find files" })
map("n", "<leader>fg", function()
	require("telescope.builtin").live_grep()
end, { desc = "Live grep" })
map("n", "<leader>fb", function()
	require("telescope.builtin").buffers()
end, { desc = "List buffers" })
map("n", "<leader>fh", function()
	require("telescope.builtin").help_tags()
end, { desc = "Help tags" })

-- File browser extension
map("n", "<leader>fe", function()
	require("telescope").extensions.file_browser.file_browser()
end, { desc = "File browser" })

-- bufferline work keys
map("n", "<S-h>", "<Cmd>BufferLineCyclePrev<CR>", { desc = "Prev buffer" })
map("n", "<S-l>", "<Cmd>BufferLineCycleNext<CR>", { desc = "Next buffer" })
map("n", "<leader>z", "<cmd>bdelete<CR>", { desc = "Delete current buffer" })

-- format code
map({ "n", "v" }, "<leader>f", function()
	require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "Format file or range" })

-- FORMAT CODE KEYBINDS
--
map({ "n", "v" }, "<leader>f", function()
	require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "Format file or range" })

--
-- LSP CONFIG KEYBINDS
-- Go to next/prev diagnostic
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next Diagnostic" })
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev Diagnostic" })

-- Open floating diagnostic
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show Diagnostic" })

-- List all diagnostics with Telescope
vim.keymap.set("n", "<leader>ld", "<cmd>Telescope diagnostics<CR>", { desc = "List Diagnostics" })

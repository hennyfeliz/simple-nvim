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

-- normal mode
map("n", "sj", "i<CR><esc>")
map("n", "sk", "<S-i><backspace><esc>")
map("n", "ss", "<S-a><CR><esc>")

-- bufferline work keys
map("n", "<S-h>", "<Cmd>BufferLineCyclePrev<CR>", { desc = "Prev buffer" })
map("n", "<S-l>", "<Cmd>BufferLineCycleNext<CR>", { desc = "Next buffer" })
map("n", "<C-i>", "<cmd>bdelete<CR>", { desc = "Delete current buffer" })

-- selection keybindings
map("n", "<leader>aa", "gg<S-v><S-g>", { desc = "Select all" })
map("n", "<leader>ar",
  "gg<S-v><S-g>:s/",
  { desc = "Select & search all" }
)
map("v", "<leader>r",
  ":s/",
  { desc = "Substitute in visual selection" }
)

-- window navigation
map("n", "<C-j>", "<C-w>j", { noremap = true })
map("n", "<C-k>", "<C-w>k", { noremap = true })
map("n", "<C-h>", "<C-w>h", { noremap = true })
map("n", "<C-l>", "<C-w>l", { noremap = true })

-- closed bracket keybindings
-- map("n", "f}", "/}\\n", { noremap = true, silent = true })
-- map("v", "f}", "/}\\n", { noremap = true, silent = true })

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
-- vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show Diagnostic" })

-- List all diagnostics with Telescope
vim.keymap.set("n", "<leader>ld", "<cmd>Telescope diagnostics<CR>", { desc = "List Diagnostics" })

-- Copy text to " register
vim.keymap.set("n", "<leader>y", '"+y', { desc = 'Yank into " register' })
vim.keymap.set("v", "<leader>y", '"+y', { desc = 'Yank into " register' })
vim.keymap.set("n", "<leader>Y", '"+Y', { desc = 'Yank into " register' })
vim.keymap.set("n", "<leader>ya", 'gg<S-v><S-g>"+Y', { desc = 'Yank all into " register' })

-- reeplace everything
vim.keymap.set("n", "<leader>ca", 'gg<S-v><S-g>d"*p', { desc = 'Paste everything in the paper " register' })

-- vim.keymap.set("n", "<C-d>", "yyp", { desc = 'Duplicate line', noremap = true })
-- Duplicate current line in normal mode:
vim.keymap.set("n", "<C-d>", "yyp", { desc = 'Duplicate line', noremap = true })
-- Duplicate selected lines in visual mode:
vim.keymap.set("v", "<C-d>", ":t'><CR>", { desc = "Duplicate selection", noremap = true, silent = true })

vim.keymap.set("n", "<C-j>", "10j", { desc = '10 lines down', noremap = true })
vim.keymap.set("n", "<C-k>", "10k", { desc = '10 lines up', noremap = true })
vim.keymap.set("v", "<C-j>", "10j", { desc = '10 lines down', noremap = true })
vim.keymap.set("v", "<C-k>", "10k", { desc = '10 lines up', noremap = true })

-- LSP Nav keymaps
vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, { desc = "Go to Definition" })
vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover Docs" })
vim.keymap.set("n", "<leader>gi", vim.lsp.buf.implementation, { desc = "Go to Implementation" })
vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, { desc = "List References" })
vim.keymap.set("n", "<leader>gt", vim.lsp.buf.type_definition, { desc = "Type Definition" })
--

-- toggleterm keymaps
vim.api.nvim_set_keymap("n", "<leader>ls", ":ToggleTerm direction=vertical<CR>", { noremap = true, silent = true })

-- indentation buttons keymaps
-- --
vim.api.nvim_set_keymap('v', '>', '>gv', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<', '<gv', { noremap = true, silent = true })

-- in your init.lua

-- Move selected block down with Alt-j
vim.keymap.set('v', '<A-j>',
  ":m '>+1<CR>gv=gv",
  { desc = "Move visual selection down", silent = true }
)

-- Move selected block up with Alt-k
vim.keymap.set('v', '<A-k>',
  ":m '<-2<CR>gv=gv",
  { desc = "Move visual selection up", silent = true }
)

-- Move current line down/up
vim.keymap.set('n', '<A-j>',
  ":m .+1<CR>==",
  { desc = "Move line down", silent = true }
)
vim.keymap.set('n', '<A-k>',
  ":m .-2<CR>==",
  { desc = "Move line up", silent = true }
)

-- always paste your last yank
vim.keymap.set("n", "p", '"0p', { noremap = true, silent = true })
vim.keymap.set("n", "P", '"0P', { noremap = true, silent = true })

-- when replacing a visual selection, dump it to black hole then paste from 0
vim.keymap.set("x", "p", '"_d"0p', { noremap = true, silent = true })
vim.keymap.set("x", "P", '"_d"0P', { noremap = true, silent = true })

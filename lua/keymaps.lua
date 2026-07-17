-- ~/.config/nvim/lua/keymaps.lua
local map = vim.keymap.set
local set_keymap = vim.api.nvim_set_keymap
local clean = vim.g.nvim_clean

local function get_last_visual_selection()
  local start_pos = vim.api.nvim_buf_get_mark(0, "<")
  local end_pos = vim.api.nvim_buf_get_mark(0, ">")
  local srow, scol = start_pos[1], start_pos[2]
  local erow, ecol = end_pos[1], end_pos[2]

  if srow == 0 or erow == 0 then
    return nil
  end

  if srow > erow or (srow == erow and scol > ecol) then
    srow, erow = erow, srow
    scol, ecol = ecol, scol
  end

  local lines = vim.api.nvim_buf_get_text(0, srow - 1, scol, erow - 1, ecol + 1, {})
  if not lines or #lines == 0 then
    return nil
  end

  local text = table.concat(lines, "\n")
  if text == "" then
    return nil
  end

  return text
end

local function escape_for_substitute(text)
  local escaped = text:gsub("\\", "\\\\"):gsub("/", "\\/"):gsub("\n", "\\n")
  return "\\V" .. escaped
end

-- CodeCompanion
map("n", "<leader>cc", "<cmd>CodeCompanion<cr>", { desc = "Chat" })
map("v", "<leader>cc", "<cmd>CodeCompanion<cr>", { desc = "Chat sobre selección" })
map("n", "<leader>cr", "<cmd>CodeCompanionActions<cr>", { desc = "Acciones (inline)" })

-- Avante
map("n", "<leader>av", "<cmd>Avante<cr>", { desc = "Abrir panel Avante" })

-- Telescope's built-in pickers
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

-- Search for text inside quotes
map("n", "<leader>sf", function()
  -- Save cursor position
  local cursor_pos = vim.api.nvim_win_get_cursor(0)

  -- Enter visual mode, select inside quotes, and yank to unnamed register
  vim.cmd('normal! vi"y')

  -- Get the yanked text
  local search_text = vim.fn.getreg('"')

  -- Restore cursor position
  vim.api.nvim_win_set_cursor(0, cursor_pos)

  -- If we found text, search for it with telescope
  if search_text and search_text ~= "" then
    require("telescope.builtin").live_grep({ default_text = search_text })
  else
    print("No text found inside quotes")
  end
end, { desc = "Search text inside quotes with telescope" })

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
map("n", "<C-A-i>", function()
  Snacks.bufdelete.all()
end, { desc = "Delete all buffers" })

-- selection keybindings
map("n", "<leader>aa", "gg<S-v><S-g>", { desc = "Select all" })
-- map("n", "<leader>ar",
--   "gg<S-v><S-g>:s/",
--   { desc = "Select & search all" }
-- )
map("v", "<leader>r",
  ":s/",
  { desc = "Substitute in visual selection" }
)

-- window navigation
map("n", "<C-j>", "<C-w>j", { noremap = true })
map("n", "<C-k>", "<C-w>k", { noremap = true })
map("n", "<C-h>", "<C-w>h", { noremap = true })
map("n", "<C-l>", "<C-w>l", { noremap = true })

if not clean then
  -- format code
  map({ "n", "v" }, "<leader>f", function()
    require("conform").format({ async = true, lsp_fallback = true })
  end, { desc = "Format file or range" })

  -- FORMAT CODE KEYBINDS - Works for all file types
  map({ "n", "v" }, "<leader>fm", function()
    require("conform").format({ async = true, lsp_fallback = true })
  end, { desc = "Format code" })

  -- ORGANIZE IMPORTS - Separate from formatting
  map("n", "<leader>jo", function()
    vim.lsp.buf.code_action({ context = { only = { "source.organizeImports" } } })
  end, { desc = "Organize imports" })

  --
  -- LSP CONFIG KEYBINDS
  -- Go to next/prev diagnostic
  map("n", "]d", vim.diagnostic.goto_next, { desc = "Next Diagnostic" })
  map("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev Diagnostic" })

  -- List all diagnostics with Telescope
  map("n", "<leader>ld", "<cmd>Telescope diagnostics<CR>", { desc = "List Diagnostics" })
end

-- Copy text to " register
map('n', '<leader>y', '"+y', { desc = 'Yank into " register' })
map('v', '<leader>y', '"+y', { desc = 'Yank into " register' })
map('n', '<leader>Y', '"+Y', { desc = 'Yank into " register' })
-- map('n', '<leader>ya', 'gg<S-v><S-g>"+Y', { desc = 'Yank all into " register' })

-- Copy visual selection to system clipboard (Ctrl+C)
map('v', '<C-c>', '"+y', { desc = 'Copy to system clipboard' })

-- Paste from system clipboard (Ctrl+V)
map('i', '<C-v>', '<C-r>+', { desc = 'Paste from system clipboard' })
map('c', '<C-v>', '<C-r>+', { desc = 'Paste from system clipboard' })

-- Fallback: C-q si el terminal intercepta C-v
map('i', '<C-q>', '<C-r>+', { desc = 'Paste from system clipboard (fallback)' })
map('c', '<C-q>', '<C-r>+', { desc = 'Paste from system clipboard (fallback)' })

-- Copy full file path to system clipboard (fp)
map('n', '<leader>fp', function()
  local path = vim.fn.expand('%:p')
  vim.fn.setreg('+', '"' .. path .. '"')
end, { desc = 'Copy full file path to clipboard' })

-- Copy directory path to system clipboard (dp)
map('n', '<leader>dp', function()
  local path = vim.fn.expand('%:p:h')
  vim.fn.setreg('+', '"' .. path .. '"')
end, { desc = 'Copy directory path to clipboard' })

-- map('n', '<leader>as', 'gg<S-v><S-g><leader>"+y', { desc = 'Yank all into " register' })

-- reeplace everything
-- map("n", "<leader>ca", 'gg<S-v><S-g>d"*p', { desc = 'Paste everything in the paper " register' })

-- map("n", "<C-d>", "yyp", { desc = 'Duplicate line', noremap = true })
-- Duplicate current line in normal mode:
map("n", "<C-d>", "yyp", { desc = 'Duplicate line', noremap = true })
-- Duplicate selected lines in visual mode:
map("v", "<C-d>", ":t'><CR>gv",
  { desc = "Duplicate selection (keep selection)", noremap = true, silent = true })

map("n", "<C-j>", "5j", { desc = '5 lines down', noremap = true })
map("n", "<C-k>", "5k", { desc = '5 lines up', noremap = true })
map("v", "<C-j>", "5j", { desc = '5 lines down', noremap = true })
map("v", "<C-k>", "5k", { desc = '5 lines up', noremap = true })

-- map("n", "<C-h>", "10h", { desc = '10 lines left', noremap = true })
-- map("n", "<C-l>", "10l", { desc = '10 lines right', noremap = true })
-- map("v", "<C-h>", "10h", { desc = '10 lines left', noremap = true })
-- map("v", "<C-l>", "10l", { desc = '10 lines right', noremap = true })

-- quotes surrounding
-- -- wrap word in double-quotes with <leader>"
-- map('n', '<leader>"', 'viw<esc>a"<esc>bi"<esc>', { noremap = true, silent = true })

-- -- wrap word in single-quotes with <leader>'
-- map('n', "<leader>'", "viw<esc>a'<esc>bi'<esc>", { noremap = true, silent = true })

if not clean then
  -- LSP Nav keymaps
  map("n", "<leader>gd", vim.lsp.buf.definition, { desc = "Go to Definition" })
  map("n", "K", vim.lsp.buf.hover, { desc = "Hover Docs" })
  map("n", "<leader>gi", vim.lsp.buf.implementation, { desc = "Go to Implementation" })
  map("n", "<leader>gr", vim.lsp.buf.references, { desc = "List References" })
  map("n", "<leader>gt", vim.lsp.buf.type_definition, { desc = "Type Definition" })

  -- Code Actions and Refactoring
  map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Actions" })
  map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename Symbol" })
  map("n", "<leader>rs", vim.lsp.buf.signature_help, { desc = "Signature Help" })
  map("n", "<leader>jr", ":JavaRefresh<Enter>", { desc = "Java Refresh" })
end

map({ "n", "v" }, "<leader>rr", function()
  local mode = vim.fn.mode()
  local selected = get_last_visual_selection()
  local target = (selected and selected ~= "") and selected or vim.fn.expand("<cword>")
  local pattern = escape_for_substitute(target)

  if mode:match("[vV\22]") then
    vim.cmd("normal! <Esc>")
  end

  vim.fn.feedkeys(":%s/" .. pattern .. "/", "n")
end, { desc = "Rename Symbols" })

local function open_global_substitute(pattern)
  if not pattern or pattern == "" then
    vim.api.nvim_input(":%s/")
    return
  end

  vim.fn.setreg("/", pattern)
  local cmd = vim.api.nvim_replace_termcodes(":%s/<C-r>//", true, false, true)
  vim.api.nvim_input(cmd)
end

map("n", "<A-s>", ":%s/", { desc = "Global substitute" })

map("n", "<A-d>", function()
  local word = vim.fn.expand("<cword>")
  open_global_substitute(word)
end, { desc = "Global substitute current word" })

map({ "n", "v" }, "<A-f>", function()
  local mode = vim.fn.mode()
  if not mode:match("[vV\22]") then
    open_global_substitute(nil)
    return
  end

  local saved = vim.fn.getreg("z")
  local saved_type = vim.fn.getregtype("z")

  vim.cmd('normal! "zy')
  local selected = vim.fn.getreg("z")
  vim.fn.setreg("z", saved, saved_type)

  local escaped = "\\V" .. selected:gsub("\\", "\\\\"):gsub("/", "\\/"):gsub("\n", "\\n")
  local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
  vim.api.nvim_input(esc)
  open_global_substitute(escaped)
end, { desc = "Global substitute visual selection" })

-- toggleterm keymaps
set_keymap("n", "<leader>ls", ":ToggleTerm direction=vertical<CR>", { noremap = true, silent = true })

-- indentation buttons keymaps
-- --
set_keymap('v', '>', '>gv', { noremap = true, silent = true })
set_keymap('v', '<', '<gv', { noremap = true, silent = true })

-- Quote/bracket selection helpers (Normal mode)
-- map('n', '{', 'vi"', { noremap = true, silent = true, nowait = true, desc = 'Select inside ""' })
-- map('n', '}', 'va"', { noremap = true, silent = true, nowait = true, desc = 'Select around ""' })
-- map('n', '[', "va'", { noremap = true, silent = true, nowait = true, desc = "Select around ''" })
-- map('n', ']', "vi'", { noremap = true, silent = true, nowait = true, desc = "Select inside ''" })
--
-- -- Quote/bracket selection helpers (Visual mode)
-- map('v', '{', '<Esc>llvi"', { noremap = true, silent = true, nowait = true, desc = 'Select inside ""' })
-- map('v', '}', '<Esc>llva"', { noremap = true, silent = true, nowait = true, desc = 'Select inside ""' })
-- map('v', '[', "<Esc>llva'", { noremap = true, silent = true, nowait = true, desc = "Select around ''" })
-- map('v', ']', "<Esc>llvi'", { noremap = true, silent = true, nowait = true, desc = "Select inside ''" })
--
--
-- map('n', '}', 'va"', { noremap = true, silent = true, nowait = true, desc = 'Select around ""' })
-- map('n', '[', "va'", { noremap = true, silent = true, nowait = true, desc = "Select around ''" })
-- map('n', ']', "vi'", { noremap = true, silent = true, nowait = true, desc = "Select inside ''" })


-- No special mappings in visual mode for { } now

-- Move selected block down with Alt-j
map('v', '<A-j>',
  ":m '>+1<CR>gv=gv",
  { desc = "Move visual selection down", silent = true }
)

-- Move selected block up with Alt-k
map('v', '<A-k>',
  ":m '<-2<CR>gv=gv",
  { desc = "Move visual selection up", silent = true }
)

-- Move current line down/up
map('n', '<A-j>',
  ":m .+1<CR>==",
  { desc = "Move line down", silent = true }
)

map('n', '<A-k>',
  ":m .-2<CR>==",
  { desc = "Move line up", silent = true }
)

-- always paste your last yank
-- leave p/P default, but give <leader>p for "paste last yank"
map("n", "<leader>p", '"0p', { desc = "Paste last yank" })
map("n", "<leader>P", '"0P', { desc = "Paste last yank (before cursor)" })
-- map("n", "p", '"0p', { noremap = true, silent = true })
-- map("n", "P", '"0P', { noremap = true, silent = true })

-- when replacing a visual selection, dump it to black hole then paste from 0
-- map("x", "p", '"_d"0p', { noremap = true, silent = true })
-- map("x", "P", '"_d"0P', { noremap = true, silent = true })

-- search for the selected text in visual mode
-- map('v', '<leader>fl', '"*y<leader>fg<C-v>', { noremap = true, silent = true })

-- resume last Telescope picker (incl. live_grep) with your previous query
map('n', '<leader>fk',
  require('telescope.builtin').resume,
  { silent = true, desc = 'Resume last Telescope search' }
)

-- viw -> selects the word
-- "*y -> yanks the word
-- <leader>fg opens the `live grep` finder
-- <D-v> pastes the copied word

map('n', '{', function()
  local word = vim.fn.expand("<cword>")
  require('telescope.builtin').live_grep({ default_text = word })
end, { desc = 'Live grep for word under cursor' })

map('v', '{', function()
  local text = get_visual_selection()
  require('telescope.builtin').live_grep({ default_text = text })
end, { desc = 'Live grep for visual selection' })

-- map('v', '{', function()
--   -- Get visual selection
--   local s = vim.fn.getreg("v")                    -- backup visual register
--   vim.cmd('normal! "vy')                          -- yank visual selection into "v
--   local text = vim.fn.getreg("v"):gsub("\n", " ") -- get and sanitize
--   vim.fn.setreg("v", s)                           -- restore register
--   require('telescope.builtin').live_grep({ default_text = text })
-- end, { desc = 'Live grep for visual selection' })

map('n', '}', function()
  local word = vim.fn.expand("<cword>")
  require('telescope.builtin').find_files({ default_text = word })
end, { desc = 'Find files with word under cursor' })

map('v', '}', function()
  local text = get_visual_selection()
  require('telescope.builtin').find_files({ default_text = text })
end, { desc = 'Find files with visual selection' })

-- map('v', '}', function()
--   local s = vim.fn.getreg("v")
--   vim.cmd('normal! "vy')
--   local text = vim.fn.getreg("v"):gsub("\n", " ")
--   vim.fn.setreg("v", s)
--   require('telescope.builtin').find_files({ default_text = text })
-- end, { desc = 'Find files with visual selection' })

-- word to search

--
--
--
--
--
--
--
--
--
-- end of the file...

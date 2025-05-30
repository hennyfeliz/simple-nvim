-- cursor config
vim.opt.guicursor = "n-v-c:block,i-ci-ve:ver50,r-cr:hor20,o:hor50"

vim.opt.clipboard = "unnamedplus"

vim.g.mapleader = " "
vim.g.maplocalleader = " "
-- vim.opt.swapfile = true
-- vim.opt.directory = os.getenv("HOME") .. "/.config/nvim/swap//"
vim.opt.swapfile = false

vim.env.PATH = "C:/Users/henny/scoop/persist/nodejs/bin;" .. vim.env.PATH

-- ~/.config/nvim/init.lua

-- 1. Bootstrap lazy.nvim (the plugin manager)
--    This automatically clones lazy.nvim to your system if it’s not present.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- 2. Load your plugins (defined in lua/plugins.lua)
require("plugins")
require("keymaps")
require("config")
require("theme")

-- make absolutely sure no highlight group paints its own bg
-- vim.cmd([[
--   " Core background groups
--   hi Normal           guibg=NONE ctermbg=NONE
--   hi NormalNC         guibg=NONE ctermbg=NONE
--   hi SignColumn       guibg=NONE ctermbg=NONE
--   hi EndOfBuffer      guibg=NONE ctermbg=NONE
--
--   " nvim-tree panels
--   hi NvimTreeNormal   guibg=NONE
--   hi NvimTreeEndOfBuffer guibg=NONE
--
--   " bufferline (tabs/buffers)
--   hi BufferLineBackground      guibg=NONE
--   hi BufferLineFill            guibg=NONE
--   hi BufferLineSeparator       guibg=NONE
--   hi BufferLineSeparatorInactive guibg=NONE
--   hi BufferLineSeparatorVisible   guibg=NONE
--   hi BufferLineBuffer          guibg=NONE
--   hi BufferLineBufferVisible   guibg=NONE
--   hi BufferLineBufferSelected  guibg=NONE
--   hi BufferLineTab             guibg=NONE
--   hi BufferLineTabActive       guibg=NONE
--   hi BufferLineTabVisible      guibg=NONE
--   hi BufferLineTabSeparator    guibg=NONE
-- ]])


-- 3. (Optional) Set some basic options or keymaps here
--    e.g.:
-- Set <leader> to space
vim.opt.nu = true
-- vim.opt.relativenumber = true

vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

vim.opt.smartindent = true
vim.opt.wrap = true

-- vim.o.number = true
-- vim.keymap.set("n", "<Space>", "", { noremap = true })
-- ...

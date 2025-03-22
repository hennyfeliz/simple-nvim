vim.g.mapleader = " "
vim.g.maplocalleader = " "

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

-- 3. (Optional) Set some basic options or keymaps here
--    e.g.:
-- Set <leader> to space
vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

vim.opt.smartindent = true
vim.opt.wrap = true

-- vim.o.number = true
-- vim.keymap.set("n", "<Space>", "", { noremap = true })
-- ...

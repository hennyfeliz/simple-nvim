-- CRITICAL: LSP compatibility fix must be loaded FIRST
-- This prevents crashes on Neovim < 0.10
if vim.lsp._request_name_to_capability == nil then
  vim.lsp._request_name_to_capability = setmetatable({}, {
    __index = function(_, key)
      return {}
    end,
  })
end

-- cursor config
vim.opt.guicursor = "n-v-c:block,i-ci-ve:ver50,r-cr:hor20,o:hor50"

-- EOL: usar LF siempre y detectar CRLF al abrir
vim.opt.fileformat = "unix"
vim.opt.fileformats = { "unix", "dos" }

-- Fuerza LF y elimina ^M (carriage return) en lectura/escritura
local fix_crlf_group = vim.api.nvim_create_augroup("FixCRLF", { clear = true })
vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePre" }, {
  group = fix_crlf_group,
  pattern = "*",
  callback = function(args)
    -- siempre guardar como LF
    vim.bo[args.buf].fileformat = "unix"
    -- si hay CR literales (mostrados como ^M), eliminarlos
    local view = vim.fn.winsaveview()
    vim.cmd([[%s/\r$//e]])
    vim.fn.winrestview(view)
  end,
  desc = "Forzar finales de línea LF y limpiar ^M",
})

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.o.relativenumber = true

-- vim.opt.swapfile = true
-- vim.opt.directory = os.getenv("HOME") .. "/.config/nvim/swap//"
vim.opt.swapfile = false
vim.opt.shadafile = 'NONE'

vim.env.PATH = "C:/Users/henny/scoop/persist/nodejs/bin;" .. vim.env.PATH

-- ~/.config/nvim/init.lua

-- 1. Bootstrap lazy.nvim (the plugin manager)
--    This automatically clones lazy.nvim to your system if it's not present.
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

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true -- default; Java lo sobreescribimos a tabs en on_attach de JDTLS

vim.opt.smartindent = true
vim.opt.wrap = true

function get_visual_selection()
  -- Save current register
  local saved_reg = vim.fn.getreg('"')
  local saved_regtype = vim.fn.getregtype('"')
  
  -- Yank the visual selection to the unnamed register
  vim.cmd('normal! ""y')
  
  -- Get the yanked text
  local text = vim.fn.getreg('"')
  
  -- Restore the register
  vim.fn.setreg('"', saved_reg, saved_regtype)
  
  -- Clean up the text (remove newlines and extra spaces)
  text = text:gsub('\n', ' '):gsub('%s+', ' '):gsub('^%s+', ''):gsub('%s+$', '')
  
  return text
end

-- vim.o.number = true
-- vim.keymap.set("n", "<Space>", "", { noremap = true })
-- ...

-- Diagnósticos: asegurar que estén visibles incluso sin nvim-lspconfig
vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = false,
})

-- Comando auxiliar para listar clientes LSP adjuntos
vim.api.nvim_create_user_command("LspClients", function()
  local clients = vim.lsp.get_active_clients({ bufnr = 0 })
  local rows = {}
  for _, c in ipairs(clients) do
    table.insert(rows, string.format("%s  (root: %s)", c.name, c.config and c.config.root_dir or ""))
  end
  if #rows == 0 then
    print("No LSP clients attached")
  else
    print(table.concat(rows, "\n"))
  end
end, { desc = "Lista clientes LSP del buffer actual" })

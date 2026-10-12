-- CRITICAL: LSP compatibility fix must be loaded FIRST
-- This prevents crashes on Neovim < 0.10
if vim.lsp._request_name_to_capability == nil then
  vim.lsp._request_name_to_capability = setmetatable({}, {
    __index = function(_, key)
      return {}
    end,
  })
end

-- Compat shim: plugins viejos aún llaman get_active_clients (deprecado en 0.11)
if vim.lsp.get_clients and vim.lsp.get_active_clients then
  vim.lsp.get_active_clients = vim.lsp.get_clients
end

-- Modo limpio ("versión limpia"): sin LSP, lint ni format. Activa con:
--   NVIM_CLEAN=1 nvim   (cmd: set NVIM_CLEAN=1 && nvim)
--   PowerShell: $env:NVIM_CLEAN='1'; nvim
--   nvim --cmd "lua vim.g.nvim_clean = true"
-- Nota: -o en Neovim ya significa ventanas en horizontal; usa nvim-clean.cmd o la variable.
vim.g.nvim_clean = (vim.env.NVIM_CLEAN == "1") or (vim.g.nvim_clean == true)
if vim.g.nvim_clean then
  vim.diagnostic.config({
    virtual_text = false,
    signs = false,
    underline = false,
    update_in_insert = false,
  })
end

-- cursor config
vim.opt.guicursor = "n-v-c:block,i-ci-ve:ver50,r-cr:hor20,o:hor50"

-- Leer como DOS retira los CR finales incluso si el archivo mezcla LF y CRLF.
-- BufReadPost cambia el formato a Unix para guardar siempre con LF.
vim.opt.fileformat = "unix"
vim.opt.fileformats = { "dos" }

-- Fuerza LF y elimina ^M (carriage return) en lectura/escritura
local fix_crlf_group = vim.api.nvim_create_augroup("FixCRLF", { clear = true })
vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePre" }, {
  group = fix_crlf_group,
  pattern = "*",
  callback = function(args)
    local buffer = args.buf
    if vim.bo[buffer].buftype ~= "" or vim.bo[buffer].binary then
      return
    end

    -- siempre guardar como LF
    vim.bo[buffer].fileformat = "unix"

    -- No cambiar líneas durante BufReadPost: la recarga todavía puede estar
    -- notificando sus cambios al LSP, y otro cambio rompe su diff incremental.
    -- fileformat=unix basta para guardar con LF incluso tras leer CRLF.
    if args.event == "BufReadPost" then
      return
    end

    local function clean_lines()
      if not vim.api.nvim_buf_is_valid(buffer) or not vim.api.nvim_buf_is_loaded(buffer)
        or vim.api.nvim_buf_line_count(buffer) > 100000 then
        return
      end
      local lines = vim.api.nvim_buf_get_lines(buffer, 0, -1, false)
      local changed = false
      for index, line in ipairs(lines) do
        local cleaned_line = line:gsub("\r$", "")
        if cleaned_line ~= line then
          lines[index] = cleaned_line
          changed = true
        end
      end
      if changed then
        vim.api.nvim_buf_set_lines(buffer, 0, -1, false, lines)
      end
    end

    clean_lines()
  end,
  desc = "Forzar finales de línea LF y limpiar ^M",
})

-- :checktime reutiliza el fileformat=unix del buffer existente al recargar.
-- Si el editor externo escribió CRLF, releer con ++ff=dos quita los CR durante
-- la lectura nativa, sin editar líneas desde BufReadPost mientras LSP sincroniza.
vim.api.nvim_create_autocmd("FileChangedShellPost", {
  group = fix_crlf_group,
  callback = function(args)
    local buffer = args.buf
    if not vim.api.nvim_buf_is_valid(buffer) or not vim.api.nvim_buf_is_loaded(buffer)
      or vim.bo[buffer].buftype ~= "" or vim.bo[buffer].binary
      or vim.bo[buffer].modified or vim.api.nvim_buf_line_count(buffer) > 100000 then
      return
    end
    local has_cr = false
    for _, line in ipairs(vim.api.nvim_buf_get_lines(buffer, 0, -1, false)) do
      if line:sub(-1) == "\r" then
        has_cr = true
        break
      end
    end
    if not has_cr then
      return
    end
    local tick = vim.api.nvim_buf_get_changedtick(buffer)
    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(buffer) or not vim.api.nvim_buf_is_loaded(buffer)
        or vim.bo[buffer].modified or vim.api.nvim_buf_get_changedtick(buffer) ~= tick then
        return
      end
      vim.api.nvim_buf_call(buffer, function()
        vim.cmd("edit ++ff=dos")
      end)
    end)
  end,
  desc = "Releer CRLF externo sin alterar el buffer durante BufReadPost",
})

-- Marca buffers grandes antes de que los plugins de sintaxis/LSP intenten
-- indexarlos. El umbral sólo afecta a archivos de más de 2 MiB.
local bigfile_group = vim.api.nvim_create_augroup("BigFileGuard", { clear = true })
vim.api.nvim_create_autocmd("BufReadPre", {
  group = bigfile_group,
  pattern = "*",
  callback = function(args)
    local name = vim.api.nvim_buf_get_name(args.buf)
    local stat = vim.loop.fs_stat(name)
    if stat and stat.size > 2 * 1024 * 1024 then
      vim.b[args.buf].bigfile = true
    end
  end,
  desc = "Marca archivos grandes para evitar indexación costosa",
})

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.o.relativenumber = true

-- vim.opt.swapfile = true
-- vim.opt.directory = os.getenv("HOME") .. "/.config/nvim/swap//"
vim.opt.swapfile = false
vim.opt.shadafile = 'NONE'

if vim.fn.has("win32") == 1 then
  vim.env.PATH = "C:/Users/henny/scoop/persist/nodejs/bin;" .. vim.env.PATH
end

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
require("restart")
require("commitAi")
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

-- Windows clipboard provider (clip.exe + PowerShell)
-- Sin esto, "+y nunca llegaría al portapapeles del sistema en Windows
if vim.fn.has("win32") == 1 then
vim.g.clipboard = {
  name = 'win-clipboard',
  copy = {
    ['+'] = 'clip.exe',
    ['*'] = 'clip.exe',
  },
  paste = {
    ['+'] = 'powershell -NoProfile -Command "Get-Clipboard | Set-Content -Path CON"',
    ['*'] = 'powershell -NoProfile -Command "Get-Clipboard | Set-Content -Path CON"',
  },
  cache_enabled = true,
}
end

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

-- Diagnósticos: el modo completo los configura en lua/config/full.lua

-- Comando auxiliar para listar clientes LSP adjuntos
vim.api.nvim_create_user_command("LspClients", function()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
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

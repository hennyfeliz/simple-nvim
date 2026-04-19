-- ~/.config/nvim/lua/plugins.lua
-- Plugins LSP/lint/format se desactivan en modo limpio (vim.g.nvim_clean / NVIM_CLEAN=1).

local function unless_clean(spec)
  local s = spec
  if type(spec) == "function" then
    s = spec()
  end
  if type(s) == "table" then
    s.enabled = function()
      return not vim.g.nvim_clean
    end
  end
  return s
end

return require("lazy").setup({
  require("plugins.snacks"),
  require("plugins.snacks-picker"),
  require("plugins.plenary"),
  require("plugins.telescope"),
  require("plugins.lazygit"),
  unless_clean(require("plugins.mason")),
  require("plugins.nvim-autopairs"),
  require("plugins.bufferline"),
  unless_clean(require("plugins.conform")),
  unless_clean(require("plugins.nvim-lint")),
  require("plugins.nvim-web-devicons"),
  require("plugins.nvim-treesitter"),
  unless_clean(require("plugins.nvim-lspconfig")),
  require("plugins.gitsigns"),
  require("plugins.lualine"),
  unless_clean(require("plugins.autocomplete")),
  require("plugins.onedark"),
  require("plugins.luasnip"),
  require("plugins.nvim-tree"),
  require("plugins.vim-surround"),
  unless_clean(require("plugins.symbols-outline")),
  require("plugins.vim-visual-multi"),
  unless_clean(require("plugins.tiny-line-diagnostic")),
  require("plugins.tiny-glimmer"),
  require("plugins.spectre"),

  require("plugins.store-nvim"),
  require("plugins.opencode"),
  require("plugins.cursor-ai-replacement"),

  -- commented pluings
  -- require("plugins.telescope-file-browser"),
  -- require("plugins.trouble"),
  -- require("plugins.harpoon"),
  -- require("plugins.nvim-lsp-ts-utils"),
  -- require("plugins.toggleterm"),
  -- require("plugins.dadbod"),
  -- require("plugins.goose"),
  unless_clean(require("plugins.nvim-dap")),
  -- require("plugins.error_lens"),
  require("plugins.catppuccin"),
  -- require("plugins.playground"),
  -- require("plugins.mason-lspconfig"),
  unless_clean(require("plugins.nvim-java")),
  -- require("plugins.markview"),
})

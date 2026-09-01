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
    require("plugins.persistence"),
    require("plugins.plenary"),
    require("plugins.telescope"),
    require("plugins.lazygit"),
    require("plugins.nvim-autopairs"),
    require("plugins.bufferline"),
    require("plugins.nvim-web-devicons"),
    require("plugins.nvim-treesitter"),
    require("plugins.gitsigns"),
    require("plugins.lualine"),
    require("plugins.luasnip"),
    require("plugins.nvim-tree"),
    require("plugins.vim-surround"),
    require("plugins.vim-visual-multi"),
    require("plugins.tiny-glimmer"),
    require("plugins.spectre"),
    require("plugins.catppuccin"),
    require("plugins.store-nvim"),
    require("plugins.opencode"),

    unless_clean(require("plugins.mason")),
    unless_clean(require("plugins.conform")),
    unless_clean(require("plugins.nvim-lspconfig")),
    unless_clean(require("plugins.autocomplete")),
    unless_clean(require("plugins.symbols-outline")),
    unless_clean(require("plugins.tiny-line-diagnostic")),
    unless_clean(require("plugins.nvim-dap")),
    unless_clean(require("plugins.nvim-java")),

    -- commented pluings
    -- require("plugins.error_lens"),
    -- require("plugins.telescope-file-browser"),
    -- require("plugins.trouble"),
    -- require("plugins.harpoon"),
    -- require("plugins.nvim-lsp-ts-utils"),
    -- require("plugins.toggleterm"),
    -- require("plugins.dadbod"),
    -- require("plugins.goose"),
    -- require("plugins.playground"),
    -- require("plugins.mason-lspconfig"),
    -- require("plugins.markview"),
})

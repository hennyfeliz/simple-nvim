-- add any tools you want to have installed below
return {
  "nvim-tree/nvim-tree.lua",
  opts = {
    view = {
      width = 60,
      side = "left",
    },
  },
  config = function()
    -- disable netrw at the very start of your init.lua
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

    -- optionally enable 24-bit colour
    vim.opt.termguicolors = true

    -- Función on_attach personalizada
    local function on_attach(bufnr)
      local api = require("nvim-tree.api")
      api.config.mappings.default_on_attach(bufnr)
      vim.keymap.del("n", "<C-k>", { buffer = bufnr })
    end

    local function dap_sync_close_for_explorer()
      local sync = rawget(_G, "__dap_explorer_sync")
      if sync and sync.close_for_explorer then
        sync.close_for_explorer()
      end
    end

    local function dap_sync_reopen_after_explorer()
      local sync = rawget(_G, "__dap_explorer_sync")
      if sync and sync.reopen_after_explorer then
        sync.reopen_after_explorer()
      end
    end

    -- Setup con todas las opciones
    require("nvim-tree").setup({
      on_attach = on_attach,
      sort = {
        sorter = "case_sensitive",
      },
      view = {
        width = 60,
        adaptive_size = false, -- desactivado para respetar el ancho fijo
        side = "left",
      },
      renderer = {
        group_empty = true,
      },
      filters = {
        dotfiles = true,
      },
      update_focused_file = {
        enable      = true, -- auto-locate the current file
        update_cwd  = true, -- also cd into its folder
        ignore_list = {},   -- files/dirs to skip, if any
      },
    })

    local ok_api, api = pcall(require, "nvim-tree.api")
    if ok_api and api.events and api.events.subscribe then
      api.events.subscribe(api.events.Event.TreeOpen, function()
        dap_sync_close_for_explorer()
      end)
      api.events.subscribe(api.events.Event.TreeClose, function()
        dap_sync_reopen_after_explorer()
      end)
    end

    vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { noremap = true, silent = true, desc = "NvimTree: Toggle" })
    vim.keymap.set("n", "<leader>je", ":NvimTreeFindFile<CR>", { silent = true })
    --set a keybind to exit nvim tree when enter a file and with C-enters "<C-<CR>> i think..." it opens the file, but keeps nvim tree open
    -- vim.keymap.set("n", "<C-CR>", ":NvimTreeClose<CR>", { noremap = true, silent = true })
    -- vim.keymap.set("n", "<C-CR>", "<CR><leader>e", { noremap = true, silent = true })
    -- vim.keymap.set("n", "<CR>", "<CR>:NvimTreeClose<CR>", { noremap = true, silent = true })
    -- vim.keymap.set("n", "<C-h>", ":NvimTreeFocus<CR>")
  end,
}

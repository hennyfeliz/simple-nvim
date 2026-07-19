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

    -- Funcion on_attach personalizada
    local function on_attach(bufnr)
      local api = require("nvim-tree.api")
      api.config.mappings.default_on_attach(bufnr)
      vim.keymap.del("n", "<C-k>", { buffer = bufnr })

      local function open_keep_focus_and_step()
        local tree_win = vim.api.nvim_get_current_win()
        local cursor = vim.api.nvim_win_get_cursor(tree_win)
        local current_line = cursor[1]
        local max_line = vim.api.nvim_buf_line_count(bufnr)
        local has_next = current_line < max_line

        local node = api.tree.get_node_under_cursor()
        if not node then
          return
        end

        local is_file = node.type == "file" or (node.nodes == nil)

        -- For directories, keep default behavior.
        if not is_file then
          api.node.open.edit()
          return
        end

        api.node.open.edit()

        if vim.api.nvim_win_is_valid(tree_win) then
          vim.api.nvim_set_current_win(tree_win)
          if has_next then
            local new_max = vim.api.nvim_buf_line_count(bufnr)
            local target = math.min(current_line + 1, new_max)
            vim.api.nvim_win_set_cursor(tree_win, { target, 0 })
          end
        end
      end

      -- Shift+L quick open from tree (reliable in terminals where Shift+Enter is not distinct).
      vim.keymap.set("n", "<S-l>", open_keep_focus_and_step,
        { buffer = bufnr, noremap = true, silent = true, desc = "Open file and stay in tree" })

      -- Multi-seleccion (marks)
      vim.keymap.set("n", "<Tab>",   function() api.marks.toggle() end,       { buffer = bufnr, desc = "Toggle mark" })
      vim.keymap.set("n", "<S-Tab>", function() api.marks.clear() end,        { buffer = bufnr, desc = "Clear all marks" })
      vim.keymap.set("n", "<C-d>",   function() api.marks.clear() end,        { buffer = bufnr, desc = "Unmark all visible" })

      -- Ctrl+A: mark all visible nodes by walking each line of the tree buffer
      vim.keymap.set("n", "<C-a>", function()
        local count = vim.api.nvim_buf_line_count(bufnr)
        for ln = 2, count do
          pcall(vim.api.nvim_win_set_cursor, 0, { ln, 0 })
          pcall(api.marks.toggle)
        end
      end, { buffer = bufnr, desc = "Mark all visible" })

      -- Bulk actions sobre nodos marcados
      vim.keymap.set("n", "<leader>md", function() api.marks.bulk.trash() end, { buffer = bufnr, desc = "Trash marked" })
      vim.keymap.set("n", "<leader>mm", function() api.marks.bulk.move() end,  { buffer = bufnr, desc = "Move marked" })
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

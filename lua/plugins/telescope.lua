-- 2) Telescope
return {
  "nvim-telescope/telescope.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = function(_, opts)
    local ivy = require("telescope.themes").get_ivy({
      layout_config = { height = 0.50, preview_width = 0.5 },
      -- remove titles
      results_title = false,
      preview_title = false,
      -- ordenar desde arriba hacia abajo (normal)
      sorting_strategy = "ascending",
    })

    -- custom border: only a vertical line between results & preview
    ivy.borderchars = {
      prompt = { " ", " ", " ", " ", " ", " ", " ", " " },
      results = { " ", " ", " ", " ", " ", " ", " ", " " },
      preview = { " ", "│", " ", " ", " ", " ", " ", " " },
    }

    -- custom helper to show only parentdir/filename
    local function parentdir_filename(_, path)
      local fname = vim.fn.fnamemodify(path, ':t')        -- filename
      local parent = vim.fn.fnamemodify(path, ':h:t')     -- parent dir tail
      if parent == '.' or parent == '' then
        return fname
      end
      return parent .. '/' .. fname
    end

    ivy.path_display = parentdir_filename

    opts.defaults = vim.tbl_deep_extend("force", opts.defaults or {}, ivy)

  -- custom helper to show only parentdir/filename
    local function parentdir_filename(_, path)
      local fname = vim.fn.fnamemodify(path, ':t')        -- filename
      local parent = vim.fn.fnamemodify(path, ':h:t')     -- parent dir tail
      if parent == '.' or parent == '' then
        return fname
      end
      return parent .. '/' .. fname
    end

    -- CONFIGURACIÓN DEFAULTS (aplicará a todos los pickers)
    opts.defaults = {
      -- Aplicar tema ivy por defecto
      layout_strategy = "bottom_pane",
      sorting_strategy = "ascending",
      layout_config = {
        height = 0.50,
        preview_width = 0.5,
        preview_cutoff = 1,
      },

      -- Configurar preview
      preview = {
        check_mime_type = false,
        filesize_limit = 0.1,
      },

      -- Títulos
      results_title = false,
      preview_title = false,

      -- Bordes personalizados: solo línea vertical entre resultados y preview
      borderchars = {
        prompt = { " ", " ", " ", " ", " ", " ", " ", " " },
        results = { " ", " ", " ", " ", " ", " ", " ", " " },
        preview = { " ", "│", " ", " ", " ", " ", " ", " " },
      }, 
    }
    end,
}

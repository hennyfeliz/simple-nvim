-- 2) Telescope
return {
  "nvim-telescope/telescope.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = function(_, opts)
    local ivy = require("telescope.themes").get_ivy({
      layout_config = { height = 0.30, preview_width = 0.7 },
      -- remove titles
      results_title = false,
      preview_title = false,
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
  end,
}

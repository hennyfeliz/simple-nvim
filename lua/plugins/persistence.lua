return {
  "folke/persistence.nvim",
  lazy = false,
  opts = {
    need = 1,
    branch = true,
  },
  config = function(_, opts)
    local persistence = require("persistence")
    persistence.setup(opts)

    local group = vim.api.nvim_create_augroup("ProjectSessionRestorePrompt", { clear = true })
    vim.api.nvim_create_autocmd("VimEnter", {
      group = group,
      callback = function()
        -- Skip session restore in clean mode.
        if vim.g.nvim_clean then
          return
        end

        -- Skip when opening files explicitly (e.g. `nvim file1 file2`).
        if vim.fn.argc(-1) > 0 then
          return
        end

        local current = persistence.current()
        if vim.fn.filereadable(current) == 0 then
          return
        end

        vim.schedule(function()
          vim.ui.select({ "Sí", "No" }, {
            prompt = "Restaurar buffers de la ultima sesion de este proyecto?",
          }, function(choice)
            if choice == "Sí" then
              persistence.load()
            end
          end)
        end)
      end,
      desc = "Ask to restore project session on startup",
    })
  end,
}

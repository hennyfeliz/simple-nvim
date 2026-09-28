local function project_path(path)
  local resolved = vim.uv.fs_realpath(path) or vim.fn.fnamemodify(path, ":p")
  return resolved:gsub("\\", "/"):gsub("/$", ""):lower()
end

local function is_project_file(path, root)
  if path == "" then
    return false
  end
  local file = project_path(path)
  return file:sub(1, #root + 1) == root .. "/"
end

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

    local loading_root
    local existing_buffers
    vim.api.nvim_create_autocmd("User", {
      pattern = "PersistenceLoadPre",
      callback = function()
        loading_root = project_path(vim.fn.getcwd())
        existing_buffers = {}
        for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
          existing_buffers[buffer] = true
        end
      end,
    })
    vim.api.nvim_create_autocmd("User", {
      pattern = "PersistenceLoadPost",
      callback = function()
        local root = loading_root
        loading_root = nil
        if not root then
          return
        end

        local project_buffer
        local foreign = {}
        for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
          local name = vim.api.nvim_buf_get_name(buffer)
          if is_project_file(name, root) then
            project_buffer = project_buffer or buffer
          elseif name ~= "" and not existing_buffers[buffer] and not vim.bo[buffer].modified then
            foreign[buffer] = true
          end
        end
        existing_buffers = nil

        if project_buffer then
          for _, window in ipairs(vim.api.nvim_list_wins()) do
            if foreign[vim.api.nvim_win_get_buf(window)] then
              vim.api.nvim_win_set_buf(window, project_buffer)
            end
          end
        end
        for buffer in pairs(foreign) do
          pcall(vim.api.nvim_buf_delete, buffer, { force = false })
        end
      end,
    })

    local group = vim.api.nvim_create_augroup("ProjectSessionRestorePrompt", { clear = true })
    vim.api.nvim_create_autocmd("VimEnter", {
      group = group,
      callback = function()
        -- Skip session restore in clean mode.
        if vim.g.nvim_clean then
          return
        end

        -- Skip when opening files explicitly (e.g. `nvim file1 file2`).
        if vim.fn.argc(-1) > 0 or vim.v.this_session ~= '' then
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

-- lua/plugins/editorconfig.lua
-- Plugin + config en un solo archivo para LazyVim

return {
  {
    "gpanders/editorconfig.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local ok, ec = pcall(require, "editorconfig")
      if not ok then return end

      -- Asegurar que EditorConfig esté activo
      vim.g.editorconfig = true

      -- Helper para booleanos "true/false", "1/0", "yes/no"
      local function truthy(v)
        v = tostring(v):lower()
        return v == "1" or v == "true" or v == "yes" or v == "on"
      end

      -- Propiedades extra/estándar mapeadas a opciones de Neovim
      ec.properties.max_line_length = function(buf, val)
        local n = tonumber(val)
        if n then vim.bo[buf].textwidth = n end
      end

      -- Personalizadas: activar spell y elegir idioma
      ec.properties.spell = function(buf, val)
        vim.bo[buf].spell = truthy(val)
      end
      ec.properties.spell_language = function(buf, val)
        vim.bo[buf].spelllang = val
      end

      -- Personalizada: recortar espacios al guardar
      ec.properties.trim_trailing_whitespace_on_save = function(buf, val)
        if not truthy(val) then return end
        local aug = vim.api.nvim_create_augroup("ECTrimWS_" .. buf, { clear = true })
        vim.api.nvim_create_autocmd("BufWritePre", {
          buffer = buf,
          group = aug,
          callback = function()
            local view = vim.fn.winsaveview()
            vim.cmd([[%s/\s\+$//e]])
            vim.fn.winrestview(view)
          end,
          desc = "Trim trailing whitespace (EditorConfig)",
        })
      end

      -- Comando para inspeccionar propiedades aplicadas
      vim.api.nvim_create_user_command("EditorConfigInfo", function()
        print(vim.inspect(vim.b.editorconfig or {}))
      end, { desc = "Show buffer EditorConfig properties" })
    end,
  },
}


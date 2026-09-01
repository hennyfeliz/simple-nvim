-- Modo limpio: sin cmp/LSP; init.lua ya desactivó diagnósticos visibles.
if vim.lsp._request_name_to_capability == nil then
  vim.lsp._request_name_to_capability = setmetatable({}, {
    __index = function(_, _)
      return {}
    end,
  })
end

-- Telescope y Treesitter se cargan bajo demanda también en el modo limpio.
require("tiny-glimmer").setup({
  enabled = true,
  disable_warnings = true,
  refresh_interval_ms = 16,
  overwrite = {
    auto_map = true,
    yank = { enabled = true, default_animation = "fade" },
    search = {
      enabled = false,
      default_animation = "pulse",
      next_mapping = "n",
      prev_mapping = "N",
    },
    paste = {
      enabled = true,
      default_animation = "reverse_fade",
      paste_mapping = "p",
      Paste_mapping = "P",
    },
    undo = {
      enabled = false,
      default_animation = {
        name = "fade",
        settings = {
          from_color = "DiffDelete",
          max_duration = 500,
          min_duration = 500,
        },
      },
      undo_mapping = "u",
    },
    redo = {
      enabled = false,
      default_animation = {
        name = "fade",
        settings = {
          from_color = "DiffAdd",
          max_duration = 500,
          min_duration = 500,
        },
      },
      redo_mapping = "<c-r>",
    },
  },
  support = {
    substitute = { enabled = false, default_animation = "fade" },
  },
  presets = {
    pulsar = {
      enabled = false,
      on_events = { "CursorMoved", "CmdlineEnter", "WinEnter" },
      default_animation = {
        name = "fade",
        settings = {
          max_duration = 1000,
          min_duration = 1000,
          from_color = "DiffDelete",
          to_color = "Normal",
        },
      },
    },
  },
  transparency_color = nil,
  animations = {
    fade = {
      max_duration = 400,
      min_duration = 300,
      easing = "outQuad",
      chars_for_max_duration = 10,
      from_color = "Visual",
      to_color = "Normal",
    },
    reverse_fade = {
      max_duration = 380,
      min_duration = 300,
      easing = "outBack",
      chars_for_max_duration = 10,
      from_color = "Visual",
      to_color = "Normal",
    },
    bounce = {
      max_duration = 500,
      min_duration = 400,
      chars_for_max_duration = 20,
      oscillation_count = 1,
      from_color = "Visual",
      to_color = "Normal",
    },
    left_to_right = {
      max_duration = 350,
      min_duration = 350,
      min_progress = 0.85,
      chars_for_max_duration = 25,
      lingering_time = 50,
      from_color = "Visual",
      to_color = "Normal",
    },
    pulse = {
      max_duration = 600,
      min_duration = 400,
      chars_for_max_duration = 15,
      pulse_count = 2,
      intensity = 1.2,
      from_color = "Visual",
      to_color = "Normal",
    },
    rainbow = {
      max_duration = 600,
      min_duration = 350,
      chars_for_max_duration = 20,
    },
    custom = {
      max_duration = 350,
      chars_for_max_duration = 40,
      color = "#ff0000",
      effect = function(self, progress)
        return self.settings.color, progress
      end,
    },
  },
  hijack_ft_disabled = {
    "alpha",
    "snacks_dashboard",
  },
  virt_text = { priority = 2048 },
})

vim.filetype.add({
  extension = {
    jsx = "javascriptreact",
  },
})

vim.treesitter.language.register("tsx", "javascriptreact")

vim.keymap.set({ "i", "s" }, "<Tab>", function()
  return require("luasnip").jumpable(1) and require("luasnip").jump(1) or "<Tab>"
end, { expr = true, silent = true })

vim.keymap.set({ "i", "s" }, "<S-Tab>", function()
  return require("luasnip").jumpable(-1) and require("luasnip").jump(-1) or "<S-Tab>"
end, { expr = true, silent = true })

vim.keymap.set("x", "p", '"_dP', { noremap = true, silent = true, desc = "Paste without overwriting yank" })

vim.opt.shadafile = "NONE"

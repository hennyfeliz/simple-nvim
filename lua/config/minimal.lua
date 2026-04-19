-- Modo limpio: sin cmp/LSP; init.lua ya desactivó diagnósticos visibles.
if vim.lsp._request_name_to_capability == nil then
  vim.lsp._request_name_to_capability = setmetatable({}, {
    __index = function(_, _)
      return {}
    end,
  })
end

require("nvim-treesitter.install").compilers = { "zig" }

local actions = require("telescope.actions")
local status, lualine_ok = pcall(require, "lualine")
if not lualine_ok then
  return
end

local lualine_theme = require("lualine.themes.catppuccin")
for _, mode in pairs(lualine_theme) do
  for _, section in pairs(mode) do
    section.bg = "NONE"
  end
end

require("telescope").setup({
  defaults = {
    mappings = {
      i = {
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,
        ["<C-l>"] = actions.select_default,
      },
    },
  },
})

require("tiny-glimmer").setup({
  enabled = true,
  disable_warnings = true,
  refresh_interval_ms = 8,
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

require("luasnip.loaders.from_lua").lazy_load({ paths = "~/AppData/Local/nvim/lua/snippets/" })

require("nvim-web-devicons").setup({
  override = {
    zsh = {
      icon = "",
      color = "#428850",
      cterm_color = "65",
      name = "Zsh",
    },
  },
  color_icons = true,
  default = true,
  strict = true,
  variant = "light|dark",
  override_by_filename = {
    [".gitignore"] = {
      icon = "",
      color = "#f1502f",
      name = "Gitignore",
    },
  },
  override_by_extension = {
    ["log"] = {
      icon = "",
      color = "#81e043",
      name = "Log",
    },
  },
  override_by_operating_system = {
    ["apple"] = {
      icon = "",
      color = "#A2AAAD",
      cterm_color = "248",
      name = "Apple",
    },
  },
})

require("lualine").setup({
  options = {
    icons_enabled = true,
    theme = lualine_theme,
    section_separators = { left = "", right = "" },
    component_separators = { left = "", right = "" },
    disabled_filetypes = {},
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = { "branch" },
    lualine_c = {
      { "filename", file_status = true, path = 0 },
    },
    lualine_x = { "encoding", "filetype" },
    lualine_y = { "progress" },
    lualine_z = { "location" },
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {
      { "filename", file_status = true, path = 1 },
    },
    lualine_x = { "location" },
    lualine_y = {},
    lualine_z = {},
  },
  tabline = {},
  extensions = { "fugitive" },
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

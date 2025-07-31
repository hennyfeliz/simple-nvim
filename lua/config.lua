-- Global LSP compatibility fix for Neovim < 0.10
-- This prevents the "bad argument #1 to 'ipairs' (table expected, got nil)" error
if vim.lsp._request_name_to_capability == nil then
  vim.lsp._request_name_to_capability = setmetatable({}, {
    __index = function(_, key)
      -- Always return an empty table so ipairs() doesn't fail
      return {}
    end,
  })
end

require("nvim-treesitter.install").compilers = { "zig" }
local servers = require("servers.config")

-- require("catppuccin").setup({
--   flavour = "mocha", -- Puede ser "latte", "frappe", "macchiato", "mocha"
--   background = {
--     light = "latte",
--     dark = "mocha",
--   },
--   integrations = {
--     cmp = true,
--     gitsigns = true,
--     telescope = true,
--     treesitter = true,
--     -- agrega más si usas otros plugins
--   },
-- })

-- vim.cmd.colorscheme "catppuccin"
-- vim.cmd.colorscheme("catppuccin")

local cmp = require("cmp")
local actions = require("telescope.actions")
local status, lualine = pcall(require, "lualine")
if not status then
  return
end

local function server_status()
  local status = {}
  for name, server in pairs(servers) do
    if server.job_id then
      table.insert(status, name .. ": Running")
    else
      table.insert(status, name .. ": Stopped")
    end
  end
  return table.concat(status, " | ")
end

-- Configuración de Telescope...
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

-- Default configuration with all available options
-- require('goose').setup({
--   default_global_keymaps = true, -- If false, disables all default global keymaps
--   keymap = {
--     global = {
--       toggle = '<leader>gg',                 -- Open goose. Close if opened
--       open_input = '<leader>gi',             -- Opens and focuses on input window on insert mode
--       open_input_new_session = '<leader>gI', -- Opens and focuses on input window on insert mode. Creates a new session
--       open_output = '<leader>go',            -- Opens and focuses on output window
--       toggle_focus = '<leader>gt',           -- Toggle focus between goose and last window
--       close = '<leader>gq',                  -- Close UI windows
--       toggle_fullscreen = '<leader>gf',      -- Toggle between normal and fullscreen mode
--       select_session = '<leader>gs',         -- Select and load a goose session
--       goose_mode_chat = '<leader>gmc',       -- Set goose mode to `chat`. (Tool calling disabled. No editor context besides selections)
--       goose_mode_auto = '<leader>gma',       -- Set goose mode to `auto`. (Default mode with full agent capabilities)
--       configure_provider = '<leader>gp',     -- Quick provider and model switch from predefined list
--       diff_open = '<leader>gd',              -- Opens a diff tab of a modified file since the last goose prompt
--       diff_next = '<leader>g]',              -- Navigate to next file diff
--       diff_prev = '<leader>g[',              -- Navigate to previous file diff
--       diff_close = '<leader>gc',             -- Close diff view tab and return to normal editing
--       diff_revert_all = '<leader>gra',       -- Revert all file changes since the last goose prompt
--       diff_revert_this = '<leader>grt',      -- Revert current file changes since the last goose prompt
--     },
--     window = {
--       submit = '<cr>',               -- Submit prompt
--       close = '<esc>',               -- Close UI windows
--       stop = '<C-c>',                -- Stop goose while it is running
--       next_message = ']]',           -- Navigate to next message in the conversation
--       prev_message = '[[',           -- Navigate to previous message in the conversation
--       mention_file = '@',            -- Pick a file and add to context. See File Mentions section
--       toggle_pane = '<tab>',         -- Toggle between input and output panes
--       prev_prompt_history = '<up>',  -- Navigate to previous prompt in history
--       next_prompt_history = '<down>' -- Navigate to next prompt in history
--     }
--   },
--   ui = {
--     window_width = 0.35,      -- Width as percentage of editor width
--     input_height = 0.15,      -- Input height as percentage of window height
--     fullscreen = false,       -- Start in fullscreen mode (default: false)
--     layout = "right",         -- Options: "center" or "right"
--     floating_height = 0.8,    -- Height as percentage of editor height for "center" layout
--     display_model = true,     -- Display model name on top winbar
--     display_goose_mode = true -- Display mode on top winbar: auto|chat
--   },
--   providers = {
--     --[[
--     Define available providers and their models for quick model switching
--     anthropic|azure|bedrock|databricks|google|groq|ollama|openai|openrouter
--     Example:
--     openrouter = {
--       "anthropic/claude-3.5-sonnet",
--       "openai/gpt-4.1",
--     },
--     ollama = {
--       "cogito:14b"
--     }
--     --]]
--   }
-- })

-- Remove deprecated shim functions that are causing warnings
-- Modern Neovim handles these automatically

local function on_attach(bufnr)
  local api = require("nvim-tree.api")
  api.config.mappings.default_on_attach(bufnr)
  vim.keymap.del("n", "<C-k>", { buffer = bufnr })
end

require("nvim-tree").setup {
  on_attach = on_attach,
}

vim.diagnostic.config({
  virtual_text = {
    prefix = "●",
    spacing = 2,
  },
  signs = true,
  underline = true,
  update_in_insert = false,
})


-- snippets config
require("luasnip.loaders.from_lua").lazy_load({ paths = "~/AppData/Local/nvim/lua/snippets/" })

require("nvim-web-devicons").setup({
  -- your personal icons can go here (to override)
  -- you can specify color or cterm_color instead of specifying both of them
  -- DevIcon will be appended to `name`
  override = {
    zsh = {
      icon = "",
      color = "#428850",
      cterm_color = "65",
      name = "Zsh",
    },
  },
  -- globally enable different highlight colors per icon (default to true)
  -- if set to false all icons will have the default icon's color
  color_icons = true,
  -- globally enable default icons (default to false)
  -- will get overriden by `get_icons` option
  default = true,
  -- globally enable "strict" selection of icons - icon will be looked up in
  -- different tables, first by filename, and if not found by extension; this
  -- prevents cases when file doesn't have any extension but still gets some icon
  -- because its name happened to match some extension (default to false)
  strict = true,
  -- set the light or dark variant manually, instead of relying on `background`
  -- (default to nil)
  variant = "light|dark",
  -- same as `override` but specifically for overrides by filename
  -- takes effect when `strict` is true
  override_by_filename = {
    [".gitignore"] = {
      icon = "",
      color = "#f1502f",
      name = "Gitignore",
    },
  },
  -- same as `override` but specifically for overrides by extension
  -- takes effect when `strict` is true
  override_by_extension = {
    ["log"] = {
      icon = "",
      color = "#81e043",
      name = "Log",
    },
  },
  -- same as `override` but specifically for operating system
  -- takes effect when `strict` is true
  override_by_operating_system = {
    ["apple"] = {
      icon = "",
      color = "#A2AAAD",
      cterm_color = "248",
      name = "Apple",
    },
  },

  -- lualine setup config
  require("lualine").setup({
    options = {
      icons_enabled = true,
      theme = "catppuccin",
      section_separators = { left = "", right = "" },
      component_separators = { left = "", right = "" },
      disabled_filetypes = {},
    },
    sections = {
      lualine_a = { "mode" },
      lualine_b = { "branch" },
      lualine_c = {
        { "filename",    file_status = true,                        path = 0 },
        { server_status, color = { fg = "#ffffff", bg = "#3a3a3a" } }, -- Custom server status
      },
      lualine_x = {
        {
          "diagnostics",
          sources = { "nvim_diagnostic" },
          symbols = { error = " ", warn = " ", info = " ", hint = " " },
        },
        "encoding",
        "filetype",
      },
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
  }),

  cmp.setup({
    snippet = {
      expand = function(args)
        require("luasnip").lsp_expand(args.body)
      end,
    },
    sources = {
      { name = "nvim_lsp" },
      { name = "buffer" },
      { name = "path" },
      { name = "luasnip" },
    },
    mapping = cmp.mapping.preset.insert({
      ["<Tab>"] = cmp.mapping.select_next_item(),
      ["<S-Tab>"] = cmp.mapping.select_prev_item(),
      ["<CR>"] = cmp.mapping.confirm({ select = true }),
    }),
  }),

  cmp.setup.filetype({ "sql" }, {
    sources = {
      { name = "vim-dadbod-completion" },
      { name = "buffer" },
    },
  }),

  vim.filetype.add({
    extension = {
      jsx = "javascriptreact",
    },
  }),

  --
  --
  vim.treesitter.language.register("tsx", "javascriptreact"),

  -- luasnip keymaps
  vim.keymap.set({ "i", "s" }, "<Tab>", function()
    return require("luasnip").jumpable(1) and require("luasnip").jump(1) or "<Tab>"
  end, { expr = true, silent = true }),

  vim.keymap.set({ "i", "s" }, "<S-Tab>", function()
    return require("luasnip").jumpable(-1) and require("luasnip").jump(-1) or "<S-Tab>"
  end, { expr = true, silent = true }),
})

vim.keymap.set("x", "p", '"_dP', { noremap = true, silent = true, desc = "Paste without overwriting yank" })

vim.opt.shadafile = 'NONE'

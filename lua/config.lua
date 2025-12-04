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


-- animations - tiny glimmer
require("tiny-glimmer").setup({
    -- Enable/disable the plugin
    enabled = true,

    -- Disable warnings for debugging highlight issues
    disable_warnings = true,

    -- Animation refresh rate in milliseconds
    refresh_interval_ms = 8,

    -- Automatic keybinding overwrites
    overwrite = {
        -- Automatically map keys to overwrite operations
        -- Set to false if you have custom mappings or prefer manual API calls
        auto_map = true,

        -- Yank operation animation
        yank = {
            enabled = true,
            default_animation = "fade",
        },

        -- Search navigation animation
        search = {
            enabled = false,
            default_animation = "pulse",
            next_mapping = "n", -- Key for next match
            prev_mapping = "N", -- Key for previous match
        },

        -- Paste operation animation
        paste = {
            enabled = true,
            default_animation = "reverse_fade",
            paste_mapping = "p", -- Paste after cursor
            Paste_mapping = "P", -- Paste before cursor
        },

        -- Undo operation animation
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

        -- Redo operation animation
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

    -- Third-party plugin integrations
    support = {
        -- Support for gbprod/substitute.nvim
        -- Usage: require("substitute").setup({
        --     on_substitute = require("tiny-glimmer.support.substitute").substitute_cb,
        --     highlight_substituted_text = { enabled = false },
        -- })
        substitute = {
            enabled = false,
            default_animation = "fade",
        },
    },

    -- Special animation presets
    presets = {
        -- Pulsar-style cursor highlighting on specific events
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

    -- Override background color for animations (for transparent backgrounds)
    transparency_color = nil,

    -- Animation configurations
    animations = {
        fade = {
            max_duration = 400,          -- Maximum animation duration in ms
            min_duration = 300,          -- Minimum animation duration in ms
            easing = "outQuad",          -- Easing function
            chars_for_max_duration = 10, -- Character count for max duration
            from_color = "Visual",       -- Start color (highlight group or hex)
            to_color = "Normal",         -- End color (highlight group or hex)
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
            oscillation_count = 1, -- Number of bounces
            from_color = "Visual",
            to_color = "Normal",
        },
        left_to_right = {
            max_duration = 350,
            min_duration = 350,
            min_progress = 0.85,
            chars_for_max_duration = 25,
            lingering_time = 50, -- Time to linger after completion
            from_color = "Visual",
            to_color = "Normal",
        },
        pulse = {
            max_duration = 600,
            min_duration = 400,
            chars_for_max_duration = 15,
            pulse_count = 2, -- Number of pulses
            intensity = 1.2, -- Pulse intensity
            from_color = "Visual",
            to_color = "Normal",
        },
        rainbow = {
            max_duration = 600,
            min_duration = 350,
            chars_for_max_duration = 20,
            -- Note: Rainbow animation does not use from_color/to_color
        },

        -- Custom animation example
        custom = {
            max_duration = 350,
            chars_for_max_duration = 40,
            color = "#ff0000", -- Custom property

            -- Custom effect function
            -- @param self table - The effect object with settings
            -- @param progress number - Animation progress [0, 1]
            -- @return string color - Hex color or highlight group
            -- @return number progress - How much of the animation to draw
            effect = function(self, progress)
                return self.settings.color, progress
            end,
        },
    },

    -- Filetypes to disable hijacking/overwrites
    hijack_ft_disabled = {
        "alpha",
        "snacks_dashboard",
    },

    -- Virtual text display priority
    virt_text = {
        priority = 2048, -- Higher values appear above other plugins
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

-- La configuración de nvim-tree se maneja en lua/plugins/nvim-tree.lua
-- para evitar conflictos y sobrescrituras

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

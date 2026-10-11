-- lua/plugins/lualine.lua
return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons", "catppuccin" },
  event = "VeryLazy",
  config = function()
    local lualine = require("lualine")

    -- Color table for highlights
    -- stylua: ignore
    local colors = {
      bg       = '#202328',
      fg       = '#bbc2cf',
      yellow   = '#ECBE7B',
      cyan     = '#008080',
      darkblue = '#081633',
      green    = '#98be65',
      orange   = '#FF8800',
      violet   = '#a9a1e1',
      magenta  = '#c678dd',
      blue     = '#51afef',
      red      = '#ec5f67',
    }

    local conditions = {
      buffer_not_empty = function()
        return vim.fn.empty(vim.fn.expand('%:t')) ~= 1
      end,
      hide_in_width = function()
        return vim.fn.winwidth(0) > 80
      end,
      check_git_workspace = function()
        local filepath = vim.fn.expand('%:p:h')
        local gitdir = vim.fn.finddir('.git', filepath .. ';')
        return gitdir and #gitdir > 0 and #gitdir < #filepath
      end,
    }

    -- Base config
    local config = {
      options = {
        component_separators = '',
        section_separators   = '',
        theme = 'catppuccin-nvim',
      },
      sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {},
      },
      inactive_sections = {
        lualine_a = {}, lualine_b = {},
        lualine_c = {}, lualine_x = {},
        lualine_y = {}, lualine_z = {},
      },
    }

    local function ins_left(component)
      table.insert(config.sections.lualine_c, component)
    end

    local function ins_right(component)
      table.insert(config.sections.lualine_x, component)
    end

    -- Left
    ins_left {
      function() return '▊' end,
      color   = { fg = colors.blue },
      padding = { left = 0, right = 1 },
    }
    ins_left {
      function() return '' end,
      color   = function()
        local mode_color = {
          n = colors.red, i = colors.green, v = colors.blue,
          [''] = colors.blue, V = colors.blue, c = colors.magenta,
          no = colors.red, s = colors.orange, S = colors.orange,
          [''] = colors.orange, ic = colors.yellow, R = colors.violet,
          Rv = colors.violet, cv = colors.red, ce = colors.red,
          r = colors.cyan, rm = colors.cyan, ['r?'] = colors.cyan,
          ['!'] = colors.red, t = colors.red,
        }
        return { fg = mode_color[vim.fn.mode()] }
      end,
      padding = { right = 1 },
    }
    ins_left { 'filesize', cond = conditions.buffer_not_empty }
    ins_left {
      'filename',
      path  = 3, -- absolute path, shorten home to ~
      cond  = conditions.buffer_not_empty,
      color = { fg = colors.magenta, gui = 'bold' },
    }
    ins_left {
      'diagnostics',
      sources = { 'nvim_diagnostic' },
      symbols = { error = ' ', warn = ' ', info = ' ' },
      diagnostics_color = {
        error = { fg = colors.red },
        warn  = { fg = colors.yellow },
        info  = { fg = colors.cyan },
      },
    }

    -- center divider
    ins_left { function() return '%=' end }

    -- LSP client name
    ins_left {
      function()
        local msg = 'No Active Lsp'
        local buf_ft = vim.api.nvim_get_option_value('filetype', { buf = 0 })
        for _, client in ipairs(vim.lsp.get_clients()) do
          if client.config.filetypes and vim.tbl_contains(client.config.filetypes, buf_ft) then
            return client.name
          end
        end
        return msg
      end,
      icon  = ' LSP:',
      color = { fg = '#ffffff', gui = 'bold' },
    }

    -- Right
    -- Estado del overlay que alterna Espacio g o, independiente del seguimiento Git.
    local function minidiff_overlay_state()
      local diff = package.loaded['mini.diff']
      local data = diff and diff.get_buf_data(0)
      if not data then return 'N/A' end
      return data.overlay and 'ON' or 'OFF'
    end
    ins_right {
      function() return 'MiniDiff: ' .. minidiff_overlay_state() end,
      color = function()
        local state = minidiff_overlay_state()
        return { fg = state == 'ON' and colors.green or (state == 'OFF' and colors.orange or colors.fg) }
      end,
    }
    -- Refresca el indicador al alternar el overlay o actualizar los cambios.
    vim.api.nvim_create_autocmd('User', {
      group = vim.api.nvim_create_augroup('MiniDiffStatusline', { clear = true }),
      pattern = 'MiniDiffUpdated',
      callback = function() lualine.refresh({ place = { 'statusline' } }) end,
    })
    ins_right {
      'o:encoding',
      fmt  = string.upper,
      cond = conditions.hide_in_width,
      color = { fg = colors.green, gui = 'bold' },
    }
    ins_right {
      'fileformat',
      fmt           = string.upper,
      icons_enabled = false,
      color         = { fg = colors.green, gui = 'bold' },
    }
    ins_right {
      'branch',
      icon  = '',
      color = { fg = colors.violet, gui = 'bold' },
    }

    -- initialize!
    lualine.setup(config)
  end,
}

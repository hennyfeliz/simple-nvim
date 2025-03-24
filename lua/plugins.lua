-- ~/.config/nvim/lua/plugins.lua

return require("lazy").setup({
  -- 1) Plenary (a required dependency for many plugins, including Telescope)
  {
    "nvim-lua/plenary.nvim",
    lazy = false, -- load it immediately
  },

  -- 2) Telescope
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup({
        defaults = {
          prompt_prefix = "🔍 ",
          selection_caret = "➜ ",
          path_display = { "smart" },
        },
        -- pickers = { ... } -- optional per-picker configs
        -- extensions = { ... } -- optional extension configs
      })
    end,
  },

  -- 3) Telescope File Browser extension
  {
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      -- Load the extension after Telescope is set up
      require("telescope").load_extension("file_browser")
    end,
  },

  -- PLUGIN: LazyGit
  {
    "kdheepak/lazygit.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = "LazyGit", -- load the plugin when the LazyGit command is called
    keys = {
      {
        "<leader>kg",
        "<cmd>LazyGit<CR>",
        desc = "Open LazyGit",
        silent = true,
      },
    },
  },

  -- Mason core plugin
  {
    "williamboman/mason.nvim",
    cmd = "Mason", -- lazy-load on :Mason
    keys = {
      { "<leader>m", "<cmd>Mason<CR>", desc = "Open Mason" },
    },
    config = function()
      require("mason").setup()
    end,
  },

  -- (Optional) mason-lspconfig if you want LSP integration
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup()
    end,
  },

  -- (Optional) mason-null-ls if you want formatters/linters
  {
    "jay-babu/mason-null-ls.nvim",
    dependencies = { "williamboman/mason.nvim", "jose-elias-alvarez/null-ls.nvim" },
    config = function()
      require("mason-null-ls").setup()
    end,
  },

  -- AUTOPAIRS
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = true,
    -- use opts = {} for passing setup options
    -- this is equivalent to setup({}) function
  },

  -- bufferline
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      require("bufferline").setup({
        options = {
          mode = "buffers",          -- this shows buffers, not tabpages
          diagnostics = "nvim_lsp",  -- optional: show LSP error indicators
          separator_style = "slant", -- or "thick", "thin", "padded_slant"
          always_show_bufferline = true,
          show_buffer_close_icons = false,
          show_close_icon = false,
          offsets = {
            {
              filetype = "NvimTree",
              text = "File Explorer",
              highlight = "Directory",
              text_align = "left",
            },
          },
        },
      })
    end,
  },

  -- CONFORM
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    config = function()
      require("conform").setup({
        format_on_save = {
          timeout_ms = 500,
          lsp_fallback = true,
        },
        formatters_by_ft = {
          lua = { "stylua" },
          javascript = { "eslint_d", "prettier" },
          typescript = { "eslint_d", "prettier" },
          javascriptreact = { "eslint_d", "prettier" },
          typescriptreact = { "eslint_d", "prettier" },
          json = { "prettier" },
          html = { "prettier" },
          css = { "prettier" },
          python = { "black" },
          c = { "clang_format" },
          cpp = { "clang_format" },
          sh = { "shfmt" },
          go = { "gofmt" },
          java = { "google_java_format" },
        },
        formatters = {
          eslint_d = {
            command = "eslint_d",
            args = { "--fix" },
            stdin = false,
          },
          prettier = {
            prepend_args = { "--tab-width", "2", "--use-tabs", "false" },
          },
          stylua = {
            prepend_args = { "--indent-width", "2" },
          },
          clang_format = {
            prepend_args = { "--style={IndentWidth: 2, UseTab: Never}" },
          },
          shfmt = {
            prepend_args = { "-i", "2" },
          },
          google_java_format = {
            -- google-java-format does not support config via CLI for indent size,
            -- you’ll need to use the default or switch to clang-format for Java if critical
          },
        },
      })
    end,
  },

  -- nvim web devicons
  { "nvim-tree/nvim-web-devicons", opts = {} },

  -- truble for errors and warnings debugging
  {
    "folke/trouble.nvim",
    opts = {}, -- for default options, refer to the configuration section for custom setup.
    cmd = "Trouble",
    keys = {
      {
        "<leader>xx",
        "<cmd>Trouble diagnostics toggle<cr>",
        desc = "Diagnostics (Trouble)",
      },
      {
        "<leader>xX",
        "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
        desc = "Buffer Diagnostics (Trouble)",
      },
      {
        "<leader>cs",
        "<cmd>Trouble symbols toggle focus=false<cr>",
        desc = "Symbols (Trouble)",
      },
      {
        "<leader>cl",
        "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
        desc = "LSP Definitions / references / ... (Trouble)",
      },
      {
        "<leader>xL",
        "<cmd>Trouble loclist toggle<cr>",
        desc = "Location List (Trouble)",
      },
      {
        "<leader>xQ",
        "<cmd>Trouble qflist toggle<cr>",
        desc = "Quickfix List (Trouble)",
      },
      {
        "<leader>xn",
        function()
          require("trouble").next({ skip_groups = true, jump = true })
        end,
        desc = "Next Trouble Item",
      },
      {
        "<leader>xp",
        function()
          require("trouble").previous({ skip_groups = true, jump = true })
        end,
        desc = "Previous Trouble Item",
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      local configs = require("nvim-treesitter.configs")

      configs.setup({
        ensure_installed = {
          "javascript",
          "typescript",
          "tsx",
          "c",
          "lua",
          "vim",
          "vimdoc",
          "query",
          "elixir",
          "erlang",
          "heex",
          "eex",
          "kotlin",
          "jq",
          "dockerfile",
          "json",
          "html",
          "terraform",
          "go",
          "tsx",
          "bash",
          "ruby",
          "markdown",
          "java",
          "astro",
        },
        sync_install = false,
        highlight = { enable = true },
        indent = { enable = true },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<C-space>",
            node_incremental = "<C-space>",
            scope_incremental = "<C-CR>",
            node_decremental = "<bs>",
          },
        },
        textobjects = {
          select = {
            enable = true,
            lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
            keymaps = {
              -- You can use the capture groups defined in textobjects.scm
              ["aa"] = "@parameter.outer",
              ["ia"] = "@parameter.inner",
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = "@class.inner",
            },
          },
          move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
              ["]m"] = "@function.outer",
              ["]]"] = "@class.outer",
            },
            goto_next_end = {
              ["]M"] = "@function.outer",
              ["]["] = "@class.outer",
            },
            goto_previous_start = {
              ["[m"] = "@function.outer",
              ["[["] = "@class.outer",
            },
            goto_previous_end = {
              ["[M"] = "@function.outer",
              ["[]"] = "@class.outer",
            },
          },
          swap = {
            enable = true,
            swap_next = {
              ["<leader>p"] = "@parameter.inner",
            },
            swap_previous = {
              ["<leader>ps"] = "@parameter.inner",
            },
          },
        },
      })
    end,
  },
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    init = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "OilActionsPost",
        callback = function(event)
          if event.data.actions.type == "move" then
            Snacks.rename.on_rename_file(event.data.actions.src_url, event.data.actions.dest_url)
          end
        end,
      })
    end,
    keys = {
      {
        "<leader>bd",
        function()
          Snacks.bufdelete()
        end,
        desc = "Buffer delete",
        mode = "n",
      },
      {
        "<leader>ba",
        function()
          Snacks.bufdelete.all()
        end,
        desc = "Buffer delete all",
        mode = "n",
      },
      {
        "<leader>bo",
        function()
          Snacks.bufdelete.other()
        end,
        desc = "Buffer delete other",
        mode = "n",
      },
      {
        "<leader>bz",
        function()
          Snacks.zen()
        end,
        desc = "Toggle Zen Mode",
        mode = "n",
      },
    },
    opts = {
      bigfile = { enabled = false },
      dashboard = {
        preset = {
          pick = nil,
          ---@type snacks.dashboard.Item[]
          keys = {
            { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
            { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
            { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
            { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
            {
              icon = " ",
              key = "c",
              desc = "Config",
              action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
            },
            { icon = " ", key = "s", desc = "Restore Session", section = "session" },
            { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
            { icon = " ", key = "q", desc = "Quit", action = ":qa" },
          },
          header =
          [[
                                                      
               ████ ██████           █████      ██
              ███████████             █████ 
              █████████ ███████████████████ ███   ███████████
             █████████  ███    █████████████ █████ ██████████████
            █████████ ██████████ █████████ █████ █████ ████ █████
          ███████████ ███    ███ █████████ █████ █████ ████ █████
         ██████  █████████████████████ ████ █████ █████ ████ ██████
           ]],
        },
        sections = {
          { section = "header" },
          {
            section = "keys",
            indent = 1,
            padding = 1,
          },
          { section = "recent_files", icon = " ", title = "Recent Files", indent = 3, padding = 2 },
          { section = "startup" },
        },
      },
      explorer = { enabled = false },
      indent = { enabled = true },
      input = { enabled = false },
      picker = { enabled = false },
      notifier = { enabled = false },
      quickfile = { enabled = true },
      scope = { enabled = false },
      statuscolumn = { enabled = false },
      words = { enabled = false },
      rename = { enabled = true },
      zen = {
        enabled = true,
        toggles = {
          ufo = true,
          dim = true,
          git_signs = false,
          diagnostics = false,
          line_number = false,
          relative_number = false,
          signcolumn = "no",
          indent = false,
        },
      },
    },
    config = function(_, opts)
      require("snacks").setup(opts)

      Snacks.toggle.new({
        id = "ufo",
        name = "Enable/Disable ufo",
        get = function()
          return require("ufo").inspect()
        end,
        set = function(state)
          if state == nil then
            require("noice").enable()
            require("ufo").enable()
            vim.o.foldenable = true
            vim.o.foldcolumn = "1"
          else
            require("noice").disable()
            require("ufo").disable()
            vim.o.foldenable = false
            vim.o.foldcolumn = "0"
          end
        end,
      })
    end,
  },

  {
    "ThePrimeagen/harpoon",
    config = function()
      local mark = require("harpoon.mark")
      local ui = require("harpoon.ui")

      vim.keymap.set("n", "<leader>a", mark.add_file, { desc = "Harpoon: Mark File" })
      vim.keymap.set("n", "<C-e>", ui.toggle_quick_menu, { desc = "Toggle Harpoon Menu" })

      vim.keymap.set("n", "<C-t>", function()
        ui.nav_file(1)
      end, { desc = "Harpoon File 1" })
      vim.keymap.set("n", "<C-s>", function()
        ui.nav_file(2)
      end, { desc = "Harpoon File 2" })
      vim.keymap.set("n", "<C-b>", function()
        ui.nav_file(3)
      end, { desc = "Harpoon File 3" })
      vim.keymap.set("n", "<C-g>", function()
        ui.nav_file(4)
      end, { desc = "Harpoon File 4" })
    end,
  },

  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "stevearc/conform.nvim",
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/nvim-cmp",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "j-hui/fidget.nvim",
      "saghen/blink.cmp",
      {
        "folke/lazydev.nvim",
        opts = {
          library = {
            { path = "${3rd}/luv/library", words = { "vim%.uv" } },
          },
        },
      },
    },

    config = function()
      -- Setup formatters
      require("conform").setup({ formatters_by_ft = {} })

      -- LSP capabilities from blink.cmp
      local capabilities = require("blink.cmp").get_lsp_capabilities()

      -- Mason setup
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "rust_analyzer", "gopls", "html", "cssls", "emmet_ls" },
        handlers = {
          function(server_name)
            require("lspconfig")[server_name].setup({ capabilities = capabilities })
          end,
          ["emmet_ls"] = function()
            require("lspconfig").emmet_ls.setup({
              capabilities = capabilities,
              filetypes = {
                "html", "css", "scss", "javascriptreact", "typescriptreact", "vue",
              },
              init_options = {
                html = {
                  options = {
                    ["bem.enabled"] = true,
                  },
                },
              },
            })
          end,


          ["lua_ls"] = function()
            require("lspconfig").lua_ls.setup({
              capabilities = capabilities,
              settings = {
                Lua = {
                  runtime = { version = "Lua 5.1" },
                  diagnostics = {
                    globals = { "bit", "vim", "it", "describe", "before_each", "after_each" },
                  },
                },
              },
            })
          end,

          ["zls"] = function()
            local lspconfig = require("lspconfig")
            lspconfig.zls.setup({
              root_dir = lspconfig.util.root_pattern(".git", "build.zig", "zls.json"),
              settings = {
                zls = {
                  enable_inlay_hints = true,
                  enable_snippets = true,
                  warn_style = true,
                },
              },
            })
            vim.g.zig_fmt_parse_errors = 0
            vim.g.zig_fmt_autosave = 0
          end,
        },
      })

      -- TypeScript custom cmd
      require("lspconfig").tsserver.setup({
        capabilities = capabilities,
        cmd = {
          "C:/Users/henny/scoop/apps/nodejs/current/bin/typescript-language-server.cmd",
          "--stdio",
        },
      })
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local c = vim.lsp.get_client_by_id(args.data.client_id)
          if not c then return end

          -- Format on save (you already have this)
          if vim.bo.filetype == "lua" then
            vim.api.nvim_create_autocmd("BufWritePre", {
              buffer = args.buf,
              callback = function()
                vim.lsp.buf.format({ bufnr = args.buf, id = c.id })
              end,
            })
          end

          -- Auto format Lua on save
          -- LSP keymaps
          local buf = args.buf
          local opts = { buffer = buf, noremap = true, silent = true }

          -- vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition,
          --   vim.tbl_extend("force", opts, { desc = "Go to Definition" }))
          vim.keymap.set("n", "J", vim.lsp.buf.definition,
            vim.tbl_extend("force", opts, { desc = "Go to Definition" }))
          vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references,
            vim.tbl_extend("force", opts, { desc = "Find References" }))
          vim.keymap.set("n", "<leader>gi", vim.lsp.buf.implementation,
            vim.tbl_extend("force", opts, { desc = "Go to Implementation" }))
          vim.keymap.set("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover Docs" }))
        end,
      })

      -- cmp setup
      local cmp = require("cmp")
      local cmp_select = { behavior = cmp.SelectBehavior.Select }
      cmp.setup({
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
          ["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
          ["<C-y>"] = cmp.mapping.confirm({ select = true }),
          ["<C-Space>"] = cmp.mapping.complete(),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
        }, {
          { name = "buffer" },
        }),
      })

      -- Diagnostics config
      vim.diagnostic.config({
        float = {
          focusable = false,
          style = "minimal",
          border = "rounded",
          source = "always",
          header = "",
          prefix = "",
        },
      })

      -- Fidget UI
      require("fidget").setup({})
    end,
  },

  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns

          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- Navigation
          map("n", "]c", function()
            if vim.wo.diff then
              return "]c"
            end
            vim.schedule(function()
              gs.next_hunk()
            end)
            return "<Ignore>"
          end, { expr = true })

          map("n", "[c", function()
            if vim.wo.diff then
              return "[c"
            end
            vim.schedule(function()
              gs.prev_hunk()
            end)
            return "<Ignore>"
          end, { expr = true })

          -- Actions
          map("n", "<leader>hs", gs.stage_hunk, { desc = "GitSigns state hunk" })
          map("n", "<leader>hr", gs.reset_hunk, { desc = "GitSigns reset hunk" })
          map("v", "<leader>hs", function()
            gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
          end, { desc = "GitSigns stage_hunk" })
          map("v", "<leader>hr", function()
            gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
          end, { desc = "GitSigns reset_hunk" })
          map("n", "<leader>hS", gs.stage_buffer, { desc = "GitSigns stage_buffer" })
          map("n", "<leader>hu", gs.undo_stage_hunk, { desc = "GitSigns undo_stage_hunk" })
          map("n", "<leader>hR", gs.reset_buffer, { desc = "GitSigns reset_buffer" })
          map("n", "<leader>hp", gs.preview_hunk, { desc = "GitSigns preview_hunk" })
          map("n", "<leader>hb", function()
            gs.blame_line({ full = true })
          end, { desc = "GitSigns blame line" })
          map("n", "<leader>htb", gs.toggle_current_line_blame, { desc = "GitSigns toggle blame" })
          map("n", "<leader>hd", gs.diffthis, { desc = "GitSigns diffthis" })
          map("n", "<leader>hD", function()
            gs.diffthis("~")
          end, { desc = "GitSigns diffthis" })
          map("n", "<leader>htd", gs.toggle_deleted, { desc = "GitSigns toggle_deleted" })

          -- Text object
          map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "GitSigns select hunk" })
        end,
      })
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },

  -- Autocomplete core
  { "hrsh7th/nvim-cmp" },
  -- LSP source
  { "hrsh7th/cmp-nvim-lsp" },
  -- Snippet engine
  { "L3MON4D3/LuaSnip" },
  -- Snippets source
  { "saadparwaiz1/cmp_luasnip" },
  -- Path and buffer completions
  { "hrsh7th/cmp-path" },
  { "hrsh7th/cmp-buffer" },

  {
    "navarasu/onedark.nvim",
    priority = 1000,
    config = function()
      require("onedark").setup({
        -- Your config goes here
        style = "darker",
        transparent = false,
        term_colors = true,
        ending_tildes = false,
        cmp_itemkind_reverse = false,
        toggle_style_key = nil,
        toggle_style_list = { "dark", "darker", "cool", "deep", "warm", "warmer", "light" },
        code_style = {
          comments = "italic",
          keywords = "none",
          functions = "none",
          strings = "none",
          variables = "none",
        },
        lualine = {
          transparent = false,
        },
        colors = {},
        highlights = {},
        diagnostics = {
          darker = true,
          undercurl = true,
          background = true,
        },
      })
      require("onedark").load()
    end,
  },

  {
    "nvim-treesitter/playground",
    cmd = "TSPlaygroundToggle",
    config = function()
      require("nvim-treesitter.configs").setup({
        playground = { enable = true },
      })
    end,
  },
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        suggestion = {
          enabled = true,
          auto_trigger = false,
          hide_during_completion = false,
          debounce = 25,
          keymap = {
            accept = false,
            accept_word = false,
            accept_line = "<Tab>",
            next = false,
            prev = false,
            dismiss = false,
          },
        },
      })
    end,
  },
  {
    "OXY2DEV/markview.nvim",
    lazy = false,

    -- For blink.cmp's completion
    -- source
    dependencies = {
      "saghen/blink.cmp"
    },
  },
})

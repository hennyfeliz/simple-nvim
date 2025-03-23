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
					mode = "buffers", -- this shows buffers, not tabpages
					diagnostics = "nvim_lsp", -- optional: show LSP error indicators
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
					javascript = { "prettier" },
					typescript = { "prettier" },
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
					header = [[
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
})

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

	-- -- add tsserver and setup with typescript.nvim instead of lspconfig
	-- {
	-- 	"neovim/nvim-lspconfig",
	-- 	dependencies = {
	-- 		"jose-elias-alvarez/typescript.nvim",
	-- 	},
	-- 	opts = {
	-- 		servers = {
	-- 			tsserver = {
	-- 				-- don't call setup manually!
	-- 				-- tsserver will use typescript.nvim internally
	-- 				settings = {},
	-- 				on_attach = function(_, bufnr)
	-- 					vim.keymap.set(
	-- 						"n",
	-- 						"<leader>co",
	-- 						"<cmd>TypescriptOrganizeImports<CR>",
	-- 						{ buffer = bufnr, desc = "Organize Imports" }
	-- 					)
	-- 					vim.keymap.set("n", "<leader>cR", "<cmd>TypescriptRenameFile<CR>", { buffer = bufnr, desc = "Rename File" })
	-- 				end,
	-- 			},
	-- 			jdtls = {},
	-- 		},
	-- 	},
	-- },
})

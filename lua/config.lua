vim.cmd.colorscheme("onedark")
local cmp = require("cmp")
local actions = require("telescope.actions")
local status, lualine = pcall(require, "lualine")
if not status then
	return
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

	lualine.setup({
		options = {
			icons_enabled = true,
			theme = "onedark",
			section_separators = { left = "", right = "" },
			component_separators = { left = "", right = "" },
			disabled_filetypes = {},
		},
		sections = {
			lualine_a = { "mode" },
			lualine_b = { "branch" },
			lualine_c = {
				{
					"filename",
					file_status = true, -- displays file status (readonly status, modified status)
					path = 0, -- 0 = just filename, 1 = relative path, 2 = absolute path
				},
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
				{
					"filename",
					file_status = true, -- displays file status (readonly status, modified status)
					path = 1, -- 0 = just filename, 1 = relative path, 2 = absolute path
				},
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

	vim.filetype.add({
		extension = {
			jsx = "javascriptreact",
		},
	}),

	vim.treesitter.language.register("tsx", "javascriptreact"),
})

-- nvim treesitter
return {
  "nvim-treesitter/nvim-treesitter",
  event = { "BufReadPre", "BufNewFile" },
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.install").compilers = { "zig" }
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
        "bash",
        "ruby",
        "markdown",
        "java",
        "astro",
      },
      sync_install = false,
      highlight = {
        enable = true,
        disable = function(_, bufnr)
          return bufnr ~= nil and vim.b[bufnr].bigfile == true
        end,
      },
      indent = {
        enable = true,
        disable = function(_, bufnr)
          return bufnr ~= nil and vim.b[bufnr].bigfile == true
        end,
      },
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
            ["]q"] = "@string.outer",
          },
          goto_next_end = {
            ["]M"] = "@function.outer",
            ["]["] = "@class.outer",
            ["]Q"] = "@string.outer",
          },
          goto_previous_start = {
            ["[m"] = "@function.outer",
            ["[["] = "@class.outer",
            ["[q"] = "@string.outer",
          },
          goto_previous_end = {
            ["[M"] = "@function.outer",
            ["[]"] = "@class.outer",
            ["[Q"] = "@string.outer",
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
}

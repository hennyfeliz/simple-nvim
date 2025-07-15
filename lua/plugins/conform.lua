-- CONFORM
return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  config = function()
    require("conform").setup({
      -- Disable format_on_save to give manual control
      format_on_save = false,
      formatters_by_ft = {
        lua = { "stylua" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        json = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
        python = { "black" },
        c = { "clang_format" },
        cpp = { "clang_format" },
        sh = { "shfmt" },
        go = { "gofmt" },
        -- Java formatting handled by LSP
        java = {},
        rust = { "rustfmt" },
      },
      formatters = {
        prettier = {
          prepend_args = { "--tab-width", "2", "--use-tabs", "false" },
        },
        stylua = {
          prepend_args = { "--indent-width", "2" },
        },
        clang_format = {
          prepend_args = { "--style={IndentWidth: 4, UseTab: Never}" },
        },
        shfmt = {
          prepend_args = { "-i", "2" },
        },
        rustfmt = {
          command = "rustfmt",
          args = { "--edition", "2021" },
          stdin = true,
        },
      },
    })
  end,
}

-- CONFORM
return {
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
        java = { "clang_format" },
        rust = { "rustfmt", "rust_hdl" },
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
        rust_hdl = {
          command = "rust_hdl",
          args = { "--format", "verilog" },
          stdin = true,
        },
      },
    })
  end,
}

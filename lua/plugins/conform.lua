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
}

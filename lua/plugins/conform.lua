-- CONFORM
return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  config = function()
    require("conform").setup({
      -- Sin autoformato en guardado
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
        -- Java: usar google-java-format (evita errores de JDTLS al formatear)
        java = { "google_java_format" },
        rust = { "rustfmt" },
      },
      formatters = {
        google_java_format = (function()
          local function detect_java()
            local env = vim.env.JAVA_HOME and (vim.env.JAVA_HOME .. (vim.fn.has("win32") == 1 and "\\bin\\java.exe" or "/bin/java"))
            if env and vim.fn.executable(env) == 1 then return env end
            local sys = vim.fn.exepath("java")
            if sys ~= "" then return sys end
            return "java"
          end
          local mason = vim.fn.stdpath("data") .. "/mason/packages/google-java-format"
          local jar = vim.fn.glob(mason .. "/google-java-format*-all-deps.jar")
          if jar == nil or jar == "" then
            -- fallback: buscar cualquier jar
            jar = vim.fn.glob(mason .. "/*.jar")
          end
          return {
            command = detect_java(),
            args = function(ctx)
              -- --aosp = indentación de 4 espacios
              return { "-jar", jar, "--aosp", "-" }
            end,
            stdin = true,
          }
        end)(),
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

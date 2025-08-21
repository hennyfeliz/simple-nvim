-- Mason core plugin
return {
  "williamboman/mason.nvim",
  cmd = "Mason", -- lazy-load on :Mason
  keys = {
    { "<leader>m", "<cmd>Mason<CR>", desc = "Open Mason" },
  },
  config = function()
    require("mason").setup({})

    -- Instala herramientas críticas para Java (rápido y con prioridad)
    local registry = require("mason-registry")
    local ensure = {
      "jdtls",                       -- LSP de Java
      "sonarlint-language-server",   -- Linter SonarLint (LSP)
      "google-java-format",          -- Formatter Java
    }
    local function ensure_installed()
      for _, name in ipairs(ensure) do
        local ok, pkg = pcall(registry.get_package, name)
        if ok and not pkg:is_installed() then
          pkg:install()
        end
      end
    end
    if registry.refresh then
      registry.refresh(ensure_installed)
    else
      ensure_installed()
    end

    -- Arranque automático de SonarLint (LSP) para Java
    -- No depende de nvim-lspconfig. Usa la API nativa de LSP.
    local function build_sonarlint_cmd()
      local mason_root = vim.fn.stdpath("data") .. "/mason"
      local exe = mason_root .. "/bin/sonarlint-language-server"
      if vim.fn.has("win32") == 1 then exe = exe .. ".cmd" end

      local cmd = {}
      if vim.fn.executable(exe) == 1 then
        table.insert(cmd, exe)
      else
        table.insert(cmd, "sonarlint-language-server") -- confiar en PATH
      end
      table.insert(cmd, "-stdio")

      -- Localiza los analyzers (necesario al menos sonarjava)
      -- En Mason, SonarLint-LS incluye analyzers en extension/analyzers. Intentar detectar sonarjava
      local base = mason_root .. "/packages/sonarlint-language-server/extension/analyzers"
      local sonarjava = vim.fn.glob(base .. "/sonarjava-*.jar")
      if sonarjava and sonarjava ~= "" then
        table.insert(cmd, "-analyzers")
        table.insert(cmd, sonarjava)
      end

      return cmd
    end

    local function detect_root(fname)
      local path = fname or vim.api.nvim_buf_get_name(0)
      return vim.fs.root(path, { "pom.xml", "mvnw", "gradlew", "build.gradle", ".git" }) or vim.loop.cwd()
    end

    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "java" },
      callback = function(args)
        -- Evita duplicados por proyecto
        vim.lsp.start({
          name = "sonarlint",
          cmd = build_sonarlint_cmd(),
          root_dir = detect_root(vim.api.nvim_buf_get_name(args.buf)),
          filetypes = { "java" },
          settings = {
            sonarlint = {
              telemetry = { enabled = false },
              rules = {},
            },
          },
        })
      end,
    })
  end,
}

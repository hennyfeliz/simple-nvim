-- Mason core plugin
return {
  "williamboman/mason.nvim",
  lazy = false, -- cargar al inicio para registrar autocmds (sonarlint)
  cmd = "Mason",
  keys = {
    { "<leader>m", "<cmd>Mason<CR>", desc = "Open Mason" },
  },
  config = function()
    require("mason").setup({
      registries = {
        -- Añade el registry de nvim-java y mantiene el oficial de mason
        "github:nvim-java/mason-registry",
        "github:mason-org/mason-registry",
      },
    })

    -- Instala herramientas críticas para Java (rápido y con prioridad)
    local registry = require("mason-registry")
    local ensure = {
      -- Ya no forzamos jdtls aquí; nvim-java lo gestiona
      "sonarlint-language-server",  -- Linter SonarLint (LSP)
      "google-java-format",         -- Formateador Java
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
    -- Arranque de SonarLint para Java (no requiere Maven global)
    local function build_sonarlint_cmd()
      local mason_root = vim.fn.stdpath("data") .. "/mason"
      local exe = mason_root .. "/bin/sonarlint-language-server"
      if vim.fn.has("win32") == 1 then exe = exe .. ".cmd" end

      local cmd = {}
      if vim.fn.executable(exe) == 1 then
        table.insert(cmd, exe)
      else
        table.insert(cmd, "sonarlint-language-server")
      end
      table.insert(cmd, "-stdio")

      -- Analyzers (Java)
      local base = mason_root .. "/packages/sonarlint-language-server/extension/analyzers"
      local jars = vim.fn.glob(base .. "/sonarjava-*.jar", 1, 1) or {}
      if #jars > 0 then
        local sep = (vim.loop.os_uname().sysname == 'Windows_NT') and ';' or ':'
        table.insert(cmd, "-analyzers")
        table.insert(cmd, table.concat(jars, sep))
      end

      return cmd
    end

    local function detect_root(fname)
      local path = fname or vim.api.nvim_buf_get_name(0)
      return vim.fs.root(path, { "pom.xml", "mvnw", "gradlew", "build.gradle", ".git" }) or vim.loop.cwd()
    end

    vim.api.nvim_create_autocmd({ "FileType", "BufReadPost", "BufEnter" }, {
      pattern = { "java" },
      callback = function(args)
        local root = detect_root(vim.api.nvim_buf_get_name(args.buf))
        local existing = vim.lsp.get_active_clients({ name = "sonarlint", root_dir = root })
        if existing and #existing > 0 then return end
        vim.lsp.start({
          name = "sonarlint",
          cmd = build_sonarlint_cmd(),
          root_dir = root,
          filetypes = { "java" },
          on_attach = function(_, bufnr)
            vim.diagnostic.enable(bufnr)
          end,
          settings = { sonarlint = { telemetry = { enabled = false } } },
        })
      end,
    })
  end,
}

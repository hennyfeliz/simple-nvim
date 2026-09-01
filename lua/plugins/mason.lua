-- Mason core plugin
return {
  "williamboman/mason.nvim",
  lazy = false, -- Mason registra herramientas y servidores LSP
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
      "java-debug-adapter",         -- DAP Java (launch/attach)
      "java-test",                  -- Soporte debug/run de tests Java
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
        local global_exe = vim.fn.exepath("sonarlint-language-server")
        if global_exe == "" then
          return nil
        end
        table.insert(cmd, global_exe)
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

    local java_root_markers = { "pom.xml", "mvnw", "gradlew", "build.gradle", "settings.gradle", ".git" }

    local function detect_root(fname)
      local path = fname or vim.api.nvim_buf_get_name(0)
      return vim.fs.root(path, java_root_markers) or vim.loop.cwd()
    end

    local function start_sonarlint(bufnr)
      if vim.bo[bufnr].filetype ~= "java" then
        vim.notify("SonarLint: el buffer actual no es Java", vim.log.levels.WARN)
        return
      end

      local root = detect_root(vim.api.nvim_buf_get_name(bufnr))
      local normalized_root = vim.fs.normalize(root)
      for _, client in ipairs(vim.lsp.get_clients({ name = "sonarlint" })) do
        local client_root = client.config and client.config.root_dir
        if client_root and vim.fs.normalize(client_root) == normalized_root then
          vim.notify("SonarLint ya está activo para este proyecto", vim.log.levels.INFO)
          return
        end
      end

      local cmd = build_sonarlint_cmd()
      if not cmd then
        vim.notify("SonarLint no está instalado en Mason", vim.log.levels.ERROR)
        return
      end

      vim.api.nvim_buf_call(bufnr, function()
        vim.lsp.start({
          name = "sonarlint",
          cmd = cmd,
          root_dir = root,
          filetypes = { "java" },
          on_attach = function(_, bufnr)
            vim.diagnostic.enable(true, { bufnr = bufnr })
          end,
          settings = { sonarlint = { telemetry = { enabled = false } } },
        })
      end)
    end

    local function stop_sonarlint()
      local root = vim.fs.normalize(detect_root(vim.api.nvim_buf_get_name(0)))
      local stopped = false
      for _, client in ipairs(vim.lsp.get_clients({ name = "sonarlint" })) do
        local client_root = client.config and client.config.root_dir
        if client_root and vim.fs.normalize(client_root) == root then
          client.stop(true)
          stopped = true
        end
      end
      vim.notify(stopped and "SonarLint detenido para este proyecto" or "SonarLint no estaba activo", vim.log.levels.INFO)
    end

    vim.api.nvim_create_user_command("JavaStartSonarLint", function()
      start_sonarlint(0)
    end, { desc = "Inicia SonarLint sólo para el proyecto Java actual" })

    vim.api.nvim_create_user_command("JavaStopSonarLint", stop_sonarlint, {
      desc = "Detiene SonarLint del proyecto Java actual",
    })

    -- Compatibilidad opcional: sólo se activa si el usuario la solicita explícitamente.
    if vim.g.java_sonarlint_autostart == true or vim.env.NVIM_SONARLINT == "1" then
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "java",
        callback = function(args)
          start_sonarlint(args.buf)
        end,
      })
    end
  end,
}

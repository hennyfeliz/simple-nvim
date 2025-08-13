return {
  "mfussenegger/nvim-jdtls",
  ft = { "java" },
  priority = 1000,
  config = function()
    -- Define a reusable start function
    local function start_jdtls()
      local jdtls = require("jdtls")
      
      -- Guard: evita iniciar JDTLS en buffers sin ruta real
      local bufname = vim.api.nvim_buf_get_name(0)
      if not bufname or bufname == "" then
        vim.notify("JDTLS: guarda el archivo primero (buffer sin nombre)", vim.log.levels.WARN)
        return
      end

      -- Locate a Java 21+ executable. Prefer $JAVA_HOME, else rely on PATH, else fallback hard-coded.
      local function detect_java()
        local env_java_home = vim.env.JAVA_HOME and (vim.env.JAVA_HOME .. "/bin/java.exe")
        if env_java_home and vim.fn.executable(env_java_home) == 1 then
          return env_java_home
        end
        local sys_java = vim.fn.exepath("java")
        if sys_java ~= "" then
          return sys_java
        end
        -- Hard-coded fallback – EDIT if you placed JDK elsewhere
        return "C:/Program Files/Java/jdk-21/bin/java.exe"
      end
      local java_cmd = detect_java()
      
      -- Paths
      local mason_path = vim.fn.stdpath("data") .. "/mason/packages"
      local jdtls_path = mason_path .. "/jdtls"
      -- Dynamically resolve the launcher JAR (version changes frequently)
      local launcher_jar = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
      if launcher_jar == nil or launcher_jar == "" then
        vim.notify("No se encontró el launcher de JDTLS en Mason. Abre :Mason y reinstala jdtls.", vim.log.levels.ERROR)
        return
      end

      -- Use config_win if available, otherwise fall back to config_linux
      local config_path = jdtls_path .. "/config_win"
      if vim.fn.isdirectory(config_path) == 0 then
        config_path = jdtls_path .. "/config_linux"
      end

      -- Determine project root (supports Maven/Gradle/Quarkus) – no fallback
      local root_dir = jdtls.setup.find_root({ "pom.xml", "mvnw", "gradlew", "build.gradle", "settings.gradle", ".git" })
      if not root_dir or root_dir == "" then
        vim.notify("JDTLS: no se encontró raíz del proyecto (pom.xml/gradle/.git). No se inicia.", vim.log.levels.WARN)
        return
      end

      -- Workspace directory – uno por proyecto (único por ruta absoluta)
      local root_real = vim.loop.fs_realpath(root_dir) or root_dir
      local sanitized = root_real:gsub("[^%w%._-]", "_")
      local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. sanitized

      -- Try to locate a Lombok JAR on the local machine (for Quarkus & others)
      local function find_lombok_jar()
        local home = vim.fn.expand("~")
        local pattern = home .. "/.m2/repository/org/projectlombok/lombok/*/lombok-*.jar"
        local jars = vim.fn.glob(pattern, 1, 1)
        if #jars > 0 then
          table.sort(jars)
          return jars[#jars] -- newest version
        end
      end
      local lombok_jar = find_lombok_jar()

      -- Build the command array for jdtls
      local cmd = {
        java_cmd,
        "-Declipse.application=org.eclipse.jdt.ls.core.id1",
        "-Dosgi.bundles.defaultStartLevel=4",
        "-Declipse.product=org.eclipse.jdt.ls.core.product",
        "-Dlog.level=ALL",
        "-Xmx1g",
        "--add-modules=ALL-SYSTEM",
        "--add-opens", "java.base/java.util=ALL-UNNAMED",
        "--add-opens", "java.base/java.lang=ALL-UNNAMED",
      }

      -- Inject Lombok if found (fixes missing symbols & completions)
      if lombok_jar and #lombok_jar > 0 then
        table.insert(cmd, 2, "-Xbootclasspath/a:" .. lombok_jar)
        table.insert(cmd, 2, "-javaagent:" .. lombok_jar)
      end

      -- Finish building the command
      vim.list_extend(cmd, {
        "-jar", launcher_jar,
        "-configuration", config_path,
        "-data", workspace_dir,
      })
      
      local config = {
        cmd = cmd,
        root_dir = root_dir,
        settings = {
          java = {
            eclipse = { downloadSources = true },
            configuration = {
              updateBuildConfiguration = "automatic",
              runtimes = {},
            },
            maven = { downloadSources = true },
            import = { maven = { enabled = true } },
            autobuild = { enabled = true },
            errors = { incompleteClasspath = { severity = "warning" } },
            format = { enabled = true },
            saveActions = { organizeImports = false },
          },
        },
        init_options = {
          bundles = {},
        },
        capabilities = (function()
          local capabilities = vim.lsp.protocol.make_client_capabilities()
          local ok_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
          if ok_cmp then
            capabilities = cmp_lsp.default_capabilities(capabilities)
          end
          return capabilities
        end)(),
        on_attach = function(client, bufnr)
          local opts = { buffer = bufnr, silent = true }
          
          -- LSP mappings
          vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
          vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
          vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)
          vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
          vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
          
          -- Format function
          vim.keymap.set("n", "<leader>fm", function()
            vim.lsp.buf.format({ async = true })
          end, { buffer = bufnr, silent = true, desc = "Format Java code" })
          
          -- Organize imports function
          vim.keymap.set("n", "<leader>jo", function()
            local name = vim.api.nvim_buf_get_name(0)
            if not name or name == "" then
              vim.notify("Guarda el archivo antes de organizar imports", vim.log.levels.WARN)
              return
            end
            require('jdtls').organize_imports()
          end, { buffer = bufnr, silent = true, desc = "Organize imports" })
        end,
        -- Add error and exit handlers for debugging
        on_error = function(err)
          vim.notify("JDTLS error: " .. vim.inspect(err), vim.log.levels.ERROR)
        end,
        on_exit = function(code, signal)
          vim.notify(string.format("JDTLS exited (code=%s, signal=%s)", code, signal), vim.log.levels.WARN)
        end,
      }
      
      -- Start JDTLS
      jdtls.start_or_attach(config)
    end

    -- 1. Run immediately for the current buffer (when plugin has just loaded via ft=java)
    if vim.bo.filetype == "java" then
      start_jdtls()
    end

    -- 2. Register for future Java buffers
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "java",
      callback = start_jdtls,
    })
  end,
} 

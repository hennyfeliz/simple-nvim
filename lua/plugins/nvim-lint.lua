-- Lint para Java con Checkstyle en proyectos Maven/Gradle
return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    local lint = require("lint")

    -- Resolver cómo ejecutar checkstyle (bin directo o java -jar del paquete)
    local function detect_java()
      local env_java_home = vim.env.JAVA_HOME and (vim.env.JAVA_HOME .. (vim.fn.has("win32") == 1 and "\\bin\\java.exe" or "/bin/java"))
      if env_java_home and vim.fn.executable(env_java_home) == 1 then
        return env_java_home
      end
      local sys_java = vim.fn.exepath("java")
      if sys_java ~= "" then
        return sys_java
      end
      return "java" -- confiar en PATH
    end

    local mason_data = vim.fn.stdpath("data") .. "/mason"
    local mason_bin = mason_data .. "/bin/checkstyle"
    local checkstyle_cmd = vim.fn.has("win32") == 1 and (mason_bin .. ".cmd") or mason_bin
    local runner_cmd = checkstyle_cmd
    local prepend_args = {}
    if vim.fn.executable(runner_cmd) ~= 1 then
      -- Buscar el jar dentro del paquete mason de checkstyle
      local pkg_dir = mason_data .. "/packages/checkstyle"
      local jar = vim.fn.glob(pkg_dir .. "/checkstyle-*.jar")
      if jar ~= nil and jar ~= "" then
        runner_cmd = detect_java()
        prepend_args = { "-jar", jar }
      end
    end

    local function detect_checkstyle_config()
      local candidates = {
        "checkstyle.xml",
        "config/checkstyle/checkstyle.xml",
        ".checkstyle.xml",
      }
      for _, name in ipairs(candidates) do
        local found = vim.fs.find(name, { upward = true, stop = vim.loop.os_homedir() })[1]
        if found and found ~= "" then
          return found
        end
      end
      -- Usa el perfil por defecto del jar de Checkstyle
      return "/google_checks.xml"
    end

    lint.linters.checkstyle = {
      cmd = runner_cmd,
      stdin = false,
      args = function()
        local args = {}
        vim.list_extend(args, prepend_args)
        vim.list_extend(args, { "-c", detect_checkstyle_config(), "-f", "plain", vim.fn.expand("%:p") })
        return args
      end,
      stream = "both",
      ignore_exitcode = true,
      parser = function(output, bufnr)
        local diagnostics = {}
        for line in output:gmatch("[^\r\n]+") do
          -- Intento 1: formato 'plain' sin prefijo
          local lnum, col, msg = line:match(":(%d+):(%d+):%s*(.+)$")
          local sev = vim.diagnostic.severity.WARN

          -- Intento 2: con prefijo [ERROR]/[WARN]
          if not lnum then
            local sev_str
            sev_str, lnum, col, msg = line:match("^%s*%[([A-Z]+)%]%s+.-:(%d+):(%d+):%s*(.+)$")
            if sev_str == "ERROR" then sev = vim.diagnostic.severity.ERROR end
            if sev_str == "WARN" then sev = vim.diagnostic.severity.WARN end
            if sev_str == "INFO" then sev = vim.diagnostic.severity.INFO end
          end

          -- Intento 3: solo linea (sin columna)
          if not lnum then
            local alt_msg
            lnum, alt_msg = line:match(":(%d+):%s*(.+)$")
            if lnum and alt_msg then
              col = 1
              msg = alt_msg
            end
          end

          if lnum and msg then
            table.insert(diagnostics, {
              lnum = tonumber(lnum) - 1,
              col = tonumber(col or 1) - 1,
              severity = sev,
              message = msg,
              source = "checkstyle",
            })
          end
        end
        return diagnostics
      end,
    }

    -- Fallback por Maven: si el bin directo no funciona, ejecuta el plugin Checkstyle de Maven
    local function detect_maven_cmd(root)
      local mvnw = root and vim.loop.fs_stat(root .. "/mvnw.cmd") and (root .. "/mvnw.cmd") or nil
      if vim.fn.has("win32") == 1 then
        if mvnw then return mvnw end
        local mvn_cmd = vim.fn.exepath("mvn.cmd")
        if mvn_cmd ~= "" then return mvn_cmd end
        local mvn = vim.fn.exepath("mvn")
        if mvn ~= "" then return mvn end
        return "mvn" -- fallback PATH
      else
        local mvnw_sh = root and vim.loop.fs_stat(root .. "/mvnw") and (root .. "/mvnw") or nil
        if mvnw_sh then return mvnw_sh end
        local mvn = vim.fn.exepath("mvn")
        if mvn ~= "" then return mvn end
        return "mvn"
      end
    end

    lint.linters.maven_checkstyle = {
      cmd = function()
        local pom = vim.fs.find("pom.xml", { upward = true, stop = vim.loop.os_homedir() })[1]
        local root = pom and vim.fn.fnamemodify(pom, ":h") or vim.loop.cwd()
        return detect_maven_cmd(root)
      end,
      stdin = false,
      args = function()
        local pom = vim.fs.find("pom.xml", { upward = true, stop = vim.loop.os_homedir() })[1]
        local root = pom and vim.fn.fnamemodify(pom, ":h") or vim.loop.cwd()
        local rel = pom and vim.fn.fnamemodify(vim.fn.expand("%:p"), ":.:") or vim.fn.expand("%:p")
        -- Ejecuta checkstyle con salida a consola; incluye solo el archivo actual si es posible
        local args = {
          "-q",
          "-f", pom or "pom.xml",
          "-Dcheckstyle.consoleOutput=true",
          "-Dcheckstyle.failsOnError=false",
          -- "-Dcheckstyle.includes=" .. rel, -- puede no estar soportado en versiones antiguas
          "checkstyle:checkstyle",
        }
        return args
      end,
      stream = "both",
      ignore_exitcode = true,
      parser = function(output, bufnr)
        local diags = {}
        -- Patrones comunes de la salida del plugin maven-checkstyle
        for line in output:gmatch("[^\r\n]+") do
          -- [ERROR] C:\...\File.java:[line,column] ... message
          local sev_str, file, lnum, col, msg = line:match("%[([A-Z]+)%]%s+([^:]+):%[(%d+),(%d+)%]%s*(.+)$")
          if not sev_str then
            -- [WARN] /path/File.java:line:col: message (otro formato)
            sev_str, file, lnum, col, msg = line:match("%[([A-Z]+)%]%s+([^:]+):(%d+):(%d+):%s*(.+)$")
          end
          if sev_str and file and lnum and col and msg then
            local target = vim.fn.expand("%:p"):gsub("/", "\\")
            local file_norm = file:gsub("/", "\\")
            if file_norm:sub(-#target) == target or target:sub(-#file_norm) == file_norm then
              local sev = vim.diagnostic.severity.WARN
              if sev_str == "ERROR" then sev = vim.diagnostic.severity.ERROR end
              if sev_str == "INFO" then sev = vim.diagnostic.severity.INFO end
              table.insert(diags, {
                lnum = tonumber(lnum) - 1,
                col = tonumber(col) - 1,
                severity = sev,
                message = msg,
                source = "maven-checkstyle",
              })
            end
          end
        end
        -- Fallback: parsear XML generado por Maven en target/checkstyle-result.xml
        if #diags == 0 then
          local pom = vim.fs.find("pom.xml", { upward = true, stop = vim.loop.os_homedir() })[1]
          local root = pom and vim.fn.fnamemodify(pom, ":h") or vim.loop.cwd()
          local xml_path = root .. (vim.loop.os_uname().sysname == 'Windows_NT' and "\\target\\checkstyle-result.xml" or "/target/checkstyle-result.xml")
          local fh = io.open(xml_path, "r")
          if fh then
            local xml = fh:read("*a"); fh:close()
            local current_file
            for tag, attr in xml:gmatch("<(file)%s+name=\"([^\"]+)\"[^>]*>") do
              current_file = attr
              -- Iterate errors under this file
              local file_block = xml:match('<file%s+name=\"' .. attr:gsub('([%^%$%(%)%%%.%[%]%*%+%-%?])','%%%1') .. '\"[^>]*>(.-)</file>')
              if file_block then
                for line, col, sev_str, msg in file_block:gmatch('<error[^>]-line=\"(%d+)\"[^>]-column=\"(%d+)\"[^>]-severity=\"([^\"]+)\"[^>]-message=\"([^\"]+)\"[^>]*/>') do
                  local target = vim.fn.expand("%:p")
                  if current_file and target:sub(-#current_file) == current_file then
                    local sev = vim.diagnostic.severity.WARN
                    if sev_str == 'error' or sev_str == 'ERROR' then sev = vim.diagnostic.severity.ERROR end
                    table.insert(diags, {
                      lnum = tonumber(line) - 1,
                      col = tonumber(col) - 1,
                      severity = sev,
                      message = msg,
                      source = "maven-checkstyle(xml)",
                    })
                  end
                end
              end
            end
          end
        end
        return diags
      end,
    }

    lint.linters_by_ft = { java = { "checkstyle", "maven_checkstyle" } }

    local function in_build_root()
      -- Quarkus projects a veces generan submódulos; asegurar que detectamos la raíz de Maven
      local pom = vim.fs.find("pom.xml", { upward = true, stop = vim.loop.os_homedir() })[1]
      if pom and pom ~= "" then return true end
      local gradle = vim.fs.find({"build.gradle", "settings.gradle"}, { upward = true, stop = vim.loop.os_homedir() })[1]
      if gradle and gradle ~= "" then return true end
      local mvnw = vim.fs.find("mvnw", { upward = true, stop = vim.loop.os_homedir() })[1]
      if mvnw and mvnw ~= "" then return true end
      local gradlew = vim.fs.find("gradlew", { upward = true, stop = vim.loop.os_homedir() })[1]
      if gradlew and gradlew ~= "" then return true end
      return false
    end

    local function try_lint()
      if vim.bo.filetype == "java" and in_build_root() then
        lint.try_lint()
      end
    end

    vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, { callback = try_lint })

    -- Comando manual para depurar rápida ejecución
    vim.api.nvim_create_user_command("CheckstyleRun", function()
      try_lint()
      print("Checkstyle ejecutado para " .. vim.fn.expand('%:p'))
    end, {})
  end,
}


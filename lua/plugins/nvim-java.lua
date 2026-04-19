-- nvim-java: integración completa de Java para Neovim
-- Nota: No se debe usar junto a mfussenegger/nvim-jdtls (plugin).
-- Este archivo declara el plugin y realiza la configuración mínima recomendada:
-- 1) require('java').setup() primero
-- 2) luego vim.lsp.config('jdtls', {}) y vim.lsp.enable('jdtls')
return {
    "nvim-java/nvim-java",
    ft = { "java" },
    dependencies = {
        "neovim/nvim-lspconfig",
        -- Recomendado por nvim-java para depuración/pruebas si decides habilitar luego
        -- "mfussenegger/nvim-dap",
    },
    config = function()
        -- Evita warning del framework legado de lspconfig al acceder `lspconfig.jdtls`
        -- desde nvim-java en Neovim 0.11+.
        local function prewarm_lspconfig_jdtls()
            local ok_cfgs, cfgs = pcall(require, "lspconfig.configs")
            if not ok_cfgs then
                return
            end
            if cfgs.jdtls == nil then
                local ok_jdtls, jdtls_cfg = pcall(require, "lspconfig.configs.jdtls")
                if ok_jdtls then
                    cfgs.jdtls = jdtls_cfg
                end
            end
        end

        local function has_command(client, command_name)
            local commands = ((((client or {}).server_capabilities or {}).executeCommandProvider or {}).commands or {})
            return vim.tbl_contains(commands, command_name)
        end

        prewarm_lspconfig_jdtls()

        -- 1) Inicializa nvim-java (STS4, debug, test, etc.)
        -- Desactivamos spring-boot-tools por incompatibilidad de bundles en este entorno.
        require("java").setup({
            spring_boot_tools = {
                enable = false,
            },
        })

        -- Evita crash de `dap configuration failed` cuando JDTLS aún no exporta
        -- comandos vscode.java.* (workspace stale o bundles no cargados).
        do
            local ok_dap_api, java_dap_api = pcall(require, "java.api.dap")
            if ok_dap_api and java_dap_api and type(java_dap_api.config_dap) == "function" then
                local orig_config_dap = java_dap_api.config_dap
                java_dap_api.config_dap = function()
                    local jdtls = vim.lsp.get_clients({ name = "jdtls" })[1]
                    if not jdtls then
                        return
                    end
                    if not has_command(jdtls, "vscode.java.resolveMainClass") then
                        vim.notify(
                            "Java DAP: jdtls no expone resolveMainClass; omitiendo auto-launch por ahora.",
                            vim.log.levels.WARN
                        )
                        return
                    end
                    return orig_config_dap()
                end
            end
        end

        -- Utilidad: detectar una instalación de JDK 21 para el classpath de proyecto
        local function detect_jdk21()
            -- Preferir JAVA_HOME si apunta a 21
            local java_home = vim.env.JAVA_HOME
            if java_home and java_home:match("21") then
                return java_home
            end
            -- Windows: buscar instalaciones comunes
            if vim.fn.has("win32") == 1 then
                local candidates = {}
                local function push_glob(pattern)
                    local found = vim.fn.glob(pattern, 1, 1)
                    if type(found) == "table" then
                        for _, p in ipairs(found) do table.insert(candidates, p) end
                    elseif found ~= nil and found ~= "" then
                        table.insert(candidates, found)
                    end
                end
                push_glob("C:/Program Files/Java/jdk-21*")
                push_glob("C:/Program Files/Eclipse Adoptium/jdk-21*")
                push_glob("C:/Program Files/Microsoft/DistributedJDK/jdk-21*")
                -- Tomar el primero existente
                for _, p in ipairs(candidates) do
                    if vim.loop.fs_stat(p) then return p end
                end
            end
            return nil
        end

        -- Ajustes recomendados para que JDTLS reimporte Maven y resuelva dependencias externas
        local jdk21 = detect_jdk21()
        local jdt_settings = {
            java = {
                configuration = {
                    updateBuildConfiguration = "automatic",
                    runtimes = (function()
                        if jdk21 then
                            return {
                                { name = "JavaSE-21", path = jdk21, default = true },
                            }
                        end
                        return nil
                    end)(),
                },
                maven = {
                    downloadSources = true,
                },
                imports = {
                    gradle = { enabled = false },
                    maven = { enabled = true },
                },
                compile = {
                    nullAnalysis = { enabled = true },
                },
                contentProvider = { preferred = "fernflower" },
            },
        }

        -- 2) Registrar JDTLS con vim.lsp.config DESPUÉS de java.setup() con root y settings explícitos
        local function detect_root(fname)
            local path = fname or vim.api.nvim_buf_get_name(0)
            return vim.fs.root(path, { "pom.xml", "mvnw", "gradlew", "build.gradle", "settings.gradle", ".git" })
                or vim.loop.cwd()
        end

        local base_jdtls = {}
        do
            local ok_server, server = pcall(require, "java-core.ls.servers.jdtls")
            if ok_server and server and type(server.get_config) == "function" then
                base_jdtls = server.get_config({
                    root_markers = { "pom.xml", "mvnw", "gradlew", "build.gradle", "settings.gradle", ".git" },
                    jdtls_plugins = { "java-test", "java-debug-adapter" },
                    use_mason_jdk = true,
                }) or {}
            end
        end

        vim.lsp.config("jdtls", vim.tbl_deep_extend("force", base_jdtls, {
            root_dir = function(bufnr, on_dir)
                on_dir(detect_root(vim.api.nvim_buf_get_name(bufnr)))
            end,
            settings = jdt_settings,
            on_attach = function(_, bufnr)
                vim.diagnostic.enable(true, { bufnr = bufnr })
            end,
        }))
        vim.lsp.enable("jdtls")

        -- 3) Comandos para refrescar/limpiar el workspace manualmente cuando Maven cambie
        vim.api.nvim_create_user_command("JavaRefresh", function()
            -- Enviar comandos sólo al cliente JDTLS (evita errores en SonarLint)
            local jdt = nil
            for _, c in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
                if c.name == 'jdtls' then jdt = c break end
            end
            if jdt then
                local function jexec(cmd, args)
                    jdt.request('workspace/executeCommand', { command = cmd, arguments = args or {} }, function() end)
                end
                pcall(jexec, 'java.projectConfiguration.update')
                pcall(jexec, 'java.project.import')
                vim.notify('Java: proyecto actualizado (JDTLS)', vim.log.levels.INFO)
            else
                vim.notify('Java: JDTLS no está activo en este buffer', vim.log.levels.WARN)
            end
        end, { desc = "Refresca import/configuración del proyecto Java (JDTLS)" })

        vim.api.nvim_create_user_command("JavaCleanWorkspace", function()
            pcall(vim.lsp.buf.execute_command, { command = "java.clean.workspace" })
            vim.notify("Java: solicitado clean del workspace (reinicia JDTLS si es necesario)", vim.log.levels.WARN)
        end, { desc = "Limpia el workspace de JDTLS" })

        -- 4) Keymaps Java DAP: launch local + attach local/remoto.
        local opts = { silent = true, noremap = true }
        local function get_jdtls_client()
            return vim.lsp.get_clients({ name = "jdtls", bufnr = 0 })[1]
        end

        local function request_resolve_main_count(callback)
            local jdtls = get_jdtls_client()
            if not jdtls then
                callback(nil, "missing-jdtls")
                return
            end
            jdtls.request("workspace/executeCommand", {
                command = "vscode.java.resolveMainClass",
                arguments = {},
            }, function(err, res)
                if err then
                    callback(nil, err.message or tostring(err))
                    return
                end
                callback(#(res or {}), nil)
            end, 0)
        end

        local function get_java_seed_config()
            local dap = require("dap")
            for _, cfg in ipairs(dap.configurations.java or {}) do
                if cfg.mainClass and cfg.projectName then
                    return cfg
                end
            end
            return nil
        end

        local function ensure_java_configs_then(callback, opts_)
            local opts_poll = vim.tbl_extend("force", {
                tries = 8,
                interval_ms = 1200,
            }, opts_ or {})

            local function poll(remaining)
                local seed = get_java_seed_config()
                if seed then
                    callback(seed)
                    return
                end
                if remaining <= 0 then
                    callback(nil)
                    return
                end
                pcall(function()
                    require("java").dap.config_dap()
                end)
                vim.defer_fn(function()
                    poll(remaining - 1)
                end, opts_poll.interval_ms)
            end

            poll(opts_poll.tries)
        end

        local function continue_java_debug()
            local dap = require("dap")
            if #(dap.configurations.java or {}) > 0 then
                dap.continue()
                return
            end

            ensure_java_configs_then(function(seed)
                if not seed then
                    vim.notify(
                        "Java DAP: no hay launch configs. Si es Quarkus, usa <leader>ja (attach remoto). Si no, ejecuta :JavaRefresh.",
                        vim.log.levels.WARN
                    )
                    return
                end
                dap.continue()
            end)
        end

        local function run_remote_attach(host, port)
            local dap = require("dap")
            dap.adapters.java_remote_attach = function(callback, _)
                local jdtls = get_jdtls_client()
                if not jdtls then
                    vim.notify("Java Attach: jdtls no activo. Abre proyecto Java y ejecuta :JavaRefresh.", vim.log.levels.ERROR)
                    callback({ type = "server", host = "127.0.0.1", port = -1 })
                    return
                end
                if not has_command(jdtls, "vscode.java.startDebugSession") then
                    vim.notify("Java Attach: jdtls no soporta vscode.java.startDebugSession.", vim.log.levels.ERROR)
                    callback({ type = "server", host = "127.0.0.1", port = -1 })
                    return
                end

                jdtls.request("workspace/executeCommand", {
                    command = "vscode.java.startDebugSession",
                    arguments = {},
                }, function(err, adapter_port)
                    if err or not adapter_port then
                        vim.notify(
                            "Java Attach: no se pudo iniciar Java Debug Adapter: " .. tostring((err and err.message) or adapter_port),
                            vim.log.levels.ERROR
                        )
                        callback({ type = "server", host = "127.0.0.1", port = -1 })
                        return
                    end
                    callback({
                        type = "server",
                        host = "127.0.0.1",
                        port = tonumber(adapter_port),
                    })
                end, 0)
            end
            dap.run({
                type = "java_remote_attach",
                request = "attach",
                name = string.format("Java Remote Attach %s:%d", host, port),
                hostName = host,
                port = port,
            })
        end

        vim.keymap.set("n", "<leader>dd", function()
            continue_java_debug()
        end, vim.tbl_extend("force", opts, { desc = "DAP: Iniciar/Continuar" }))

        vim.keymap.set("n", "<leader>dm", function()
            require("java").test.debug_current_method()
        end, vim.tbl_extend("force", opts, { desc = "Java: Debug método actual" }))

        vim.keymap.set("n", "<leader>dc", function()
            require("java").test.debug_current_class()
        end, vim.tbl_extend("force", opts, { desc = "Java: Debug clase actual" }))

        vim.keymap.set("n", "<leader>da", function()
            run_remote_attach("127.0.0.1", 5005)
        end, vim.tbl_extend("force", opts, { desc = "Java: Attach (localhost:5005)" }))

        vim.keymap.set("n", "<leader>ja", function()
            local host = vim.fn.input("Java host: ", "127.0.0.1")
            local port = tonumber(vim.fn.input("Java port: ", "5005")) or 5005
            run_remote_attach(host, port)
        end, vim.tbl_extend("force", opts, { desc = "Java: Attach rapido (host/port)" }))

        vim.keymap.set("n", "<leader>dA", function()
            local host = vim.fn.input("Java host: ", "127.0.0.1")
            local port = tonumber(vim.fn.input("Java port: ", "5005")) or 5005
            run_remote_attach(host, port)
        end, vim.tbl_extend("force", opts, { desc = "Java: Attach remoto (alias legacy)" }))

        vim.keymap.set("n", "<leader>dl", function()
            pcall(function()
                require("java").dap.config_dap()
            end)
        end, vim.tbl_extend("force", opts, { desc = "Java: Refrescar launch configs DAP" }))

        pcall(vim.api.nvim_create_user_command, "JavaDebugHealth", function()
            local dap = require("dap")
            local jdtls = get_jdtls_client()
            local commands = ((((jdtls or {}).server_capabilities or {}).executeCommandProvider or {}).commands or {})
            local has_resolve = vim.tbl_contains(commands, "vscode.java.resolveMainClass")
            local cfg_count = #(dap.configurations.java or {})
            request_resolve_main_count(function(resolve_count, err)
                local lines = {
                    "JavaDebugHealth:",
                    "  jdtls_active=" .. tostring(jdtls ~= nil),
                    "  dap_adapter_java=" .. tostring(dap.adapters.java ~= nil),
                    "  dap_adapter_java_remote_attach=" .. tostring(dap.adapters.java_remote_attach ~= nil),
                    "  java_remote_attach_ready="
                        .. tostring(jdtls ~= nil and has_command(jdtls, "vscode.java.startDebugSession")),
                    "  java_launch_configs=" .. tostring(cfg_count),
                    "  has_resolveMainClass=" .. tostring(has_resolve),
                    "  resolve_main_class_count=" .. tostring(resolve_count),
                    "  attach_default=127.0.0.1:5005",
                }
                if err then
                    table.insert(lines, "  resolve_error=" .. tostring(err))
                end
                if resolve_count == 0 then
                    table.insert(lines, "  recommendation=No mainClass (Quarkus probable). Use <leader>ja for remote attach.")
                end
                vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO)
            end)
        end, { desc = "Estado rapido Java LSP/DAP" })

        -- 5) Auto-refresh cuando cambie el pom.xml
        vim.api.nvim_create_autocmd({ "BufWritePost" }, {
            pattern = { "pom.xml" },
            callback = function()
                pcall(vim.cmd, "JavaRefresh")
            end,
        })
    end,
}

-- nvim-java: integración completa de Java para Neovim
-- Nota: No se debe usar junto a mfussenegger/nvim-jdtls (plugin).
-- Este archivo declara el plugin y realiza la configuración mínima recomendada:
-- 1) require('java').setup() primero
-- 2) luego lspconfig.jdtls.setup({})
return {
    "nvim-java/nvim-java",
    ft = { "java" },
    dependencies = {
        "neovim/nvim-lspconfig",
        -- Recomendado por nvim-java para depuración/pruebas si decides habilitar luego
        -- "mfussenegger/nvim-dap",
    },
    config = function()
        -- 1) Inicializa nvim-java (usa defaults seguros). Gestiona STS4, debug, test, etc.
        require("java").setup({
            -- nvim-java gestiona JDTLS, Lombok, Java Test/Debug, etc.
        })

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
                push_glob("C:/Program Files/Microsoft/DistibutedJDK/jdk-21*")
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

        -- 2) Registrar JDTLS en lspconfig DESPUÉS de java.setup() con root y settings explícitos
        local function detect_root(fname)
            local path = fname or vim.api.nvim_buf_get_name(0)
            return vim.fs.root(path, { "pom.xml", "mvnw", ".git" }) or vim.loop.cwd()
        end

        require("lspconfig").jdtls.setup({
            root_dir = function(fname) return detect_root(fname) end,
            settings = jdt_settings,
            on_attach = function(client, bufnr)
                -- Habilitar diagnósticos
                vim.diagnostic.enable(bufnr)
            end,
        })

        -- 3) Comandos para refrescar/limpiar el workspace manualmente cuando Maven cambie
        vim.api.nvim_create_user_command("JavaRefresh", function()
            -- Enviar comandos sólo al cliente JDTLS (evita errores en SonarLint)
            local jdt = nil
            for _, c in ipairs(vim.lsp.get_active_clients({ bufnr = 0 })) do
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

        -- 4) Keymaps cómodos para depurar con Java
        local opts = { silent = true, noremap = true }
        vim.keymap.set("n", "<leader>dd", function()
            require("dap").continue()
        end, vim.tbl_extend("force", opts, { desc = "DAP: Iniciar/Continuar" }))

        vim.keymap.set("n", "<leader>dm", function()
            require("java").test.debug_current_method()
        end, vim.tbl_extend("force", opts, { desc = "Java: Debug método actual" }))

        vim.keymap.set("n", "<leader>dc", function()
            require("java").test.debug_current_class()
        end, vim.tbl_extend("force", opts, { desc = "Java: Debug clase actual" }))

        vim.keymap.set("n", "<leader>da", function()
            require("java").debug.attach({ host = "127.0.0.1", port = 5005 })
        end, vim.tbl_extend("force", opts, { desc = "Java: Attach (localhost:5005)" }))

        -- 5) Auto-refresh cuando cambie el pom.xml
        vim.api.nvim_create_autocmd({ "BufWritePost" }, {
            pattern = { "pom.xml" },
            callback = function()
                pcall(vim.cmd, "JavaRefresh")
            end,
        })
    end,
}

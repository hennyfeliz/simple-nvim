-- Modelo local de ICBR (NetBeans/Ant). No modifica el build ni el checkout.
local M = {}
local uv = vim.uv or vim.loop

---Devuelve la raiz ICBR solo cuando coinciden sus fuentes y metadatos NetBeans.
---@param path string
---@return string|nil
function M.root(path)
    local root = vim.fs.root(path, { '.git' })
    if root and uv.fs_stat(root .. '/src/nbproject/project.properties')
        and uv.fs_stat(root .. '/src/src/java/PropertyManager/ArchProperty.java') then
        return vim.fs.normalize(root)
    end
end

---Construye ajustes acotados para las fuentes y bibliotecas de ICBR.
---Falla con un mensaje concreto si falta un JDK o una API del servidor local.
---@param root string
---@return table
function M.settings(root)
    local jdk8 = 'C:/Program Files/Java/jdk1.8.0_171'
    assert(uv.fs_stat(jdk8 .. '/bin/javac.exe'), 'ICBR LSP: falta el JDK 8 de IcbrDev.ps1')
    local oracle = 'C:/Oracle/Middleware/Oracle_Home/'
    local libraries = {}
    -- Estas APIs provienen del servidor; evitar versiones duplicadas de JPA.
    local server_apis = {
        'oracle_common/modules/javax.persistence_2.1.jar',
        'oracle_common/modules/javax.servlet_2.2.0.0_3-0.jar',
        'oracle_common/modules/javax.ejb_3.3.0.jar',
        'oracle_common/modules/javax.annotation_1.2.0.0_1-1.jar',
        'oracle_common/modules/javax.jsp_4.0.0.0_2-2.jar',
        'wlserver/modules/javax.enterprise.inject_1.2.jar',
        'wlserver/modules/javax.interceptor_1.3.jar',
        'wlserver/modules/javax.validation_1.2.0.jar',
    }
    for _, relative in ipairs(server_apis) do
        local jar = oracle .. relative
        assert(uv.fs_stat(jar), 'ICBR LSP: falta API local ' .. jar)
        table.insert(libraries, jar)
    end
    for _, jar in ipairs(vim.fn.glob(root .. '/src/lib/*.jar', false, true)) do
        local name = vim.fs.basename(jar)
        if not name:find('javax.persistence', 1, true) and name ~= 'javax.ejb.jar' then
            table.insert(libraries, vim.fs.normalize(jar))
        end
    end
    return {
        java = {
            configuration = {
                runtimes = { { name = 'JavaSE-1.8', path = jdk8, default = true } },
                updateBuildConfiguration = 'disabled',
            },
            project = { sourcePaths = { 'src/src/java' }, referencedLibraries = libraries },
            import = {
                maven = { enabled = false },
                gradle = { enabled = false },
                exclusions = { '**/build/**', '**/dist/**', '**/nbproject/**', '**/.git/**' },
            },
            maven = { downloadSources = false },
            references = { includeDecompiledSources = false },
            maxConcurrentBuilds = 1,
            autobuild = { enabled = true },
            compile = { nullAnalysis = { mode = 'disabled' } },
        },
    }
end

---Usa JDK 21 para el servidor; el proyecto sigue compilando contra Java 8.
---@param command string[]
---@param workspace string
---@return string[]
function M.command(command, workspace)
    local cmd = vim.deepcopy(command)
    cmd[1] = 'C:/Program Files/Java/jdk-21/bin/java.exe'
    assert(uv.fs_stat(cmd[1]), 'ICBR LSP: falta JDK 21 para ejecutar JDTLS')
    for i, arg in ipairs(cmd) do
        if arg:match('^%-Xmx') then cmd[i] = '-Xmx1536m' end
        if arg == '-configuration' then cmd[i + 1] = workspace .. '/configuration' end
    end
    table.insert(cmd, 2, '-XX:ActiveProcessorCount=2')
    return cmd
end

return M

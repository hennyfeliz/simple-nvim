-- Ejecutar con nvim --headless -u NONE -c "luafile .../tests/icbrConfig.lua".
vim.opt.runtimepath:append(vim.fn.stdpath('config'))
local icbr = require('java.icbr')
local root = vim.fs.normalize(vim.env.USERPROFILE .. '/banreservas/icbr')
assert(icbr.root(root .. '/src/src/java/PropertyManager/ArchProperty.java') == root)
assert(icbr.root(vim.env.USERPROFILE .. '/banreservas/cbs-api/pom.xml') == nil)
local settings = icbr.settings(root).java
assert(settings.configuration.runtimes[1].name == 'JavaSE-1.8')
assert(settings.project.sourcePaths[1] == 'src/src/java')
assert(not settings.import.maven.enabled and not settings.import.gradle.enabled)
for _, jar in ipairs(settings.project.referencedLibraries) do
    assert(vim.uv.fs_stat(jar), 'Missing library: ' .. jar)
    assert(not jar:find('javax.persistence_1.', 1, true), 'Duplicate old JPA')
end
local original = { 'java', '-Xmx2048m', '-configuration', 'shared', '-data', 'old' }
local command = icbr.command(original, 'cache/icbr')
assert(original[1] == 'java' and original[4] == 'shared', 'Mutated shared command')
assert(vim.tbl_contains(command, '-Xmx1536m'))
assert(vim.tbl_contains(command, '-XX:ActiveProcessorCount=2'))
assert(vim.tbl_contains(command, 'cache/icbr/configuration'))
assert(loadfile(vim.fn.stdpath('config') .. '/lua/plugins/nvim-java.lua'))
print('ICBR_CONFIG=PASS (scope, runtimes, classpath, isolated command, syntax)')
vim.cmd('qa!')

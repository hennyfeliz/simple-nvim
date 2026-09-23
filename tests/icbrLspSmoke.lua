-- Ejecutar desde ICBR con nvim --headless -l no carga la config: usar -c luafile.
-- Abre un controlador real, prueba LSP y cambia solo su buffer (nunca guarda).
require('persistence').stop()
local report = { checks = {}, maxTickMs = 0 }
local buffer, original, client
local finished = false
local timer = vim.uv.new_timer()
local last = vim.uv.hrtime()
timer:start(100, 100, vim.schedule_wrap(function()
    local now = vim.uv.hrtime()
    report.maxTickMs = math.max(report.maxTickMs, (now - last) / 1e6)
    last = now
end))

local function finish(err)
    if finished then return end
    finished = true
    timer:stop()
    timer:close()
    if original and vim.api.nvim_buf_is_valid(buffer) then
        vim.api.nvim_buf_set_lines(buffer, 0, -1, false, original)
    end
    report.error = err
    report.ok = err == nil
    vim.fn.writefile({ vim.json.encode(report) }, vim.env.TEMP .. '/icbr-lsp-smoke.json')
    vim.cmd(err and 'cquit 1' or 'qa!')
end

local function wait_for(predicate, next_step, label, attempts)
    attempts = attempts or 120
    if finished then return end
    if predicate() then
        table.insert(report.checks, label)
        next_step()
    elseif attempts == 0 then
        finish('Timeout: ' .. label)
    else
        vim.defer_fn(function() wait_for(predicate, next_step, label, attempts - 1) end, 500)
    end
end

local function errors()
    return vim.diagnostic.get(buffer, { severity = vim.diagnostic.severity.ERROR })
end

local function test_diagnostics()
    original = vim.api.nvim_buf_get_lines(buffer, 0, -1, false)
    local close = #original
    while not original[close]:match('^%s*}%s*$') do close = close - 1 end
    vim.api.nvim_buf_set_lines(buffer, close - 1, close - 1, false, {
        '    private void codexLspProbe() { int probe = "invalid type"; }',
    })
    wait_for(function()
        for _, diagnostic in ipairs(errors()) do
            if diagnostic.message:find('cannot convert from String to int', 1, true) then return true end
        end
        return false
    end, function()
        vim.api.nvim_buf_set_lines(buffer, 0, -1, false, original)
        wait_for(function() return #errors() == 0 end, function() finish() end,
            'diagnostics clear after correction')
    end, 'type error detected without saving')
end

vim.cmd('edit src/src/java/JPAPersistence/CBSRubrosReportesJpaController.java')
buffer = vim.api.nvim_get_current_buf()
wait_for(function()
    client = vim.lsp.get_clients({ name = 'jdtls', bufnr = buffer })[1]
    return client and client.initialized
end, function()
    report.runtime = client.settings.java.configuration.runtimes
    report.root = client.config.root_dir
    if #vim.lsp.get_clients({ name = 'jdtls', bufnr = buffer }) ~= 1 then
        finish('duplicate JDTLS'); return
    end
    local lines = vim.api.nvim_buf_get_lines(buffer, 0, -1, false)
    local position
    for index, line in ipairs(lines) do
        local column = line:find('CBSRubrosReportes;', 1, true)
        if column and line:find('import ', 1, true) then position = { line = index - 1, character = column } end
    end
    local function definition()
        client:request('textDocument/definition', {
            textDocument = { uri = vim.uri_from_bufnr(buffer) }, position = position,
        }, function(err, result)
            if err then finish(err.message); return end
            if not result or #result == 0 then vim.defer_fn(definition, 500); return end
            report.definition = result[1].uri
            if not report.definition:find('/Entitys/CBS/CBSRubrosReportes.java', 1, true) then
                finish('unexpected definition'); return
            end
            table.insert(report.checks, 'definition resolves project entity')
            wait_for(function() return #errors() == 0 end, test_diagnostics, 'no false import/package errors')
        end, buffer)
    end
    definition()
end, 'single initialized JDTLS')
vim.defer_fn(function() finish('overall timeout') end, 90000)

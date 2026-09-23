local M = {}

-- Guarda los archivos y la sesion; el lanzador reinicia el proceso al salir.
function M.restart()
    local request = vim.env.NVIM_RESTART_FILE
    if not request or request == '' then
        vim.notify('Abre Neovim con el wrapper nvim de PowerShell actualizado para usar :soo.', vim.log.levels.ERROR)
        return
    end
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.bo[buf].buftype == 'terminal' then
            local job = vim.b[buf].terminal_job_id
            if job and vim.fn.jobwait({ job }, 0)[1] == -1 then
                vim.notify('Cierra los procesos de las terminales internas antes de reiniciar.', vim.log.levels.WARN)
                return
            end
        end
    end
    local session = request .. '.vim'
    local ok, err = pcall(function()
        vim.cmd('wall')
        vim.cmd('mksession! ' .. vim.fn.fnameescape(session))
    end)
    if not ok then
        vim.notify('No se reinicio: ' .. tostring(err), vim.log.levels.ERROR)
        return
    end
    -- Solo pide reinicio cuando Neovim realmente acepta salir.
    local id = vim.api.nvim_create_autocmd('VimLeavePre', {
        once = true,
        callback = function() vim.fn.writefile({ session }, request) end,
    })
    local quit_ok, quit_err = pcall(vim.cmd, 'qa')
    pcall(vim.api.nvim_del_autocmd, id)
    if not quit_ok then vim.notify(tostring(quit_err), vim.log.levels.ERROR) end
end

vim.api.nvim_create_user_command('Soo', M.restart, { desc = 'Reiniciar Neovim y restaurar la sesion' })
-- Los comandos de usuario exigen mayuscula; acepta exactamente :soo al escribirlo.
vim.cmd([[cnoreabbrev <expr> soo getcmdtype() == ':' && getcmdline() == 'soo' ? 'Soo' : 'soo']])

return M

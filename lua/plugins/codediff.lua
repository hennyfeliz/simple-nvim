return {
    "esmuellert/codediff.nvim",
    tag = "v4.0.6",
    cmd = "CodeDiff",
    keys = {
        -- Abre los cambios del repositorio, incluidos los archivos en conflicto.
        { "<leader>gvv", "<cmd>CodeDiff<CR>", desc = "CodeDiff: cambios del repositorio" },
        -- Compara el archivo actual contra HEAD.
        { "<leader>gvf", "<cmd>CodeDiff file HEAD<CR>", desc = "CodeDiff: archivo contra HEAD" },
        -- Muestra los cambios preparados para el proximo commit.
        { "<leader>gvs", "<cmd>CodeDiff --staged<CR>", desc = "CodeDiff: cambios staged" },
        -- Abre el historial del archivo actual.
        { "<leader>gvh", "<cmd>CodeDiff history %<CR>", desc = "CodeDiff: historial del archivo" },
    },
    opts = function()
        -- Evita que los defaults locales oculten atajos de Gitsigns, LSP o NvimTree.
        -- Solo habilitamos las acciones documentadas abajo, dentro del grupo libre gv.
        local keys = vim.deepcopy(require("codediff.config").defaults.keymaps)
        for _, group in pairs(keys) do
            for action, value in pairs(group) do
                if type(value) ~= "boolean" then group[action] = false end
            end
        end
        -- Cierra la pestaña de comparacion.
        keys.view.quit = "<leader>gvq"
        -- Enfoca el listado de archivos.
        keys.view.focus_explorer = "<leader>gve"
        -- Salta al siguiente bloque de cambios.
        keys.view.next_hunk = "<leader>gvj"
        -- Salta al bloque de cambios anterior.
        keys.view.prev_hunk = "<leader>gvk"
        -- Abre el siguiente archivo cambiado.
        keys.view.next_file = "<leader>gvl"
        -- Abre el archivo cambiado anterior.
        keys.view.prev_file = "<leader>gvH"
        -- Alterna comparacion lado a lado e inline.
        keys.view.toggle_layout = "<leader>gvt"
        -- Prepara o retira del staging el archivo actual.
        keys.view.toggle_stage = "<leader>gva"
        -- Muestra la ayuda con los atajos de esta vista.
        keys.view.show_help = "<leader>gv?"
        -- Abre el archivo seleccionado en el explorador de CodeDiff.
        keys.explorer.select = "<leader>gvo"
        -- Actualiza el listado de cambios.
        keys.explorer.refresh = "<leader>gvr"
        -- Expande el commit o abre el archivo seleccionado en el historial.
        keys.history.select = "<leader>gvo"
        -- Actualiza el historial.
        keys.history.refresh = "<leader>gvr"
        -- Acepta la version propia (ours) para el conflicto actual.
        keys.conflict.accept_current = "<leader>gv1"
        -- Acepta la version entrante (theirs) para el conflicto actual.
        keys.conflict.accept_incoming = "<leader>gv2"
        -- Conserva ambas versiones del conflicto actual, entrante primero.
        keys.conflict.accept_both = "<leader>gv3"
        -- Salta al siguiente conflicto pendiente.
        keys.conflict.next_conflict = "<leader>gvn"
        -- Salta al conflicto pendiente anterior.
        keys.conflict.prev_conflict = "<leader>gvp"
        return { keymaps = keys, diff = { layout = "side-by-side" } }
    end,
}

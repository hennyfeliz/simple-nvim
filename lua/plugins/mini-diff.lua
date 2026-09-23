return {
    "nvim-mini/mini.diff",
    version = "*",
    event = { "BufReadPre", "BufNewFile" },
    keys = {
        {
            "<leader>go",
            function()
                require("mini.diff").toggle_overlay(0)
            end,
            desc = "MiniDiff: mostrar/ocultar cambios",
        },
    },
    opts = {
        -- Gitsigns mantiene los signos; mini.diff colorea los numeros de linea.
        view = { style = "number" },
        -- Explicitos para conservar los atajos aunque cambien los defaults.
        mappings = {
            -- Aplica al indice Git la seleccion o movimiento: ghgh bloque, gh_ linea.
            apply = "gh",
            -- Restaura desde el indice: gHgh bloque, gH_ linea; descarta cambios locales.
            reset = "gH",
            -- Selecciona el bloque como objeto de texto para operadores (por ejemplo ghgh).
            textobject = "gh",
            -- Espacio, H, k: primer bloque (H mayuscula indica extremo).
            goto_first = "<leader>Hk",
            -- Alt+s: salta al bloque anterior sin modificar contenido.
            goto_prev = "<A-S-s>",
            -- Alt+f: salta al bloque siguiente sin modificar contenido.
            goto_next = "<A-S-d>",
            -- Espacio, H, j: ultimo bloque (H mayuscula indica extremo).
            goto_last = "<leader>Hj",
        },
    },
}

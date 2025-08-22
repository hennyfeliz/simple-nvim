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
            -- Puedes ajustar opciones avanzadas aquí si lo necesitas.
            -- Por defecto instala JDK con mason si falta, y usa jdtls, lombok, java-test, etc.
        })

        -- 2) Registra jdtls en lspconfig DESPUÉS de java.setup()
        require("lspconfig").jdtls.setup({})

        -- 3) Keymaps cómodos para depurar con Java
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
    end,
}

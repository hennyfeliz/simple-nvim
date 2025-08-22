-- ~/.plugins/nvim-dap.lua
--
return {
    {
        "mfussenegger/nvim-dap",
        recommended = true,
        desc = "Debugging support. Requires language specific adapters to be configured. (see lang extras)",

        dependencies = {
            "rcarriga/nvim-dap-ui",
            -- virtual text for the debugger
            {
                "theHamsta/nvim-dap-virtual-text",
                opts = {},
            },
        },

        -- stylua: ignore
        keys = {
            {
                "<F5>",
                function() require("dap").continue() end,
                desc = "DAP: Continue"
            },
            {
                "<S-F5>",
                function() require("dap").terminate() end,
                desc = "DAP: Terminate"
            },
            {
                "<C-F5>",
                function() require("dap").run_last() end,
                desc = "DAP: Run Without Debugging"
            },
            {
                "<F6>",
                function() require("dap").pause() end,
                desc = "DAP: Pause"
            },
            {
                "<F7>",
                function() require("dap").repl.toggle() end,
                desc = "DAP: Toggle REPL"
            },
            {
                "<F8>",
                function() require("dap").run_to_cursor() end,
                desc = "DAP: Run to Cursor"
            },
            {
                "<F9>",
                function() require("dap").toggle_breakpoint() end,
                desc = "DAP: Toggle Breakpoint"
            },
            {
                "<C-F9>",
                function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end,
                desc = "DAP: Conditional Breakpoint"
            },

            {
                "<S-F9>",
                function()
                    require("dap").set_exception_breakpoints({ "uncaught" })
                    print("🟠 Break on UNCAUGHT exceptions enabled")
                end,
                desc = "DAP: Break on Uncaught Exceptions"
            },

            {
                "<C-S-F9>",
                function()
                    require("dap").set_exception_breakpoints({ "all" })
                    print("🔴 Break on ALL exceptions enabled")
                end,
                desc = "DAP: Break on All Exceptions"
            },

            {
                "<C-M-F9>",
                function()
                    require("dap").set_exception_breakpoints({})
                    print("⚪ Break on Exceptions DISABLED")
                end,
                desc = "DAP: Disable Break on Exceptions"
            },

            { "<F10>",   function() require("dap").step_over() end, desc = "DAP: Step Over" },
            { "<F11>",   function() require("dap").step_into() end, desc = "DAP: Step Into" },
            { "<S-F11>", function() require("dap").step_out() end,  desc = "DAP: Step Out" },

            {
                "<F12>",
                function()
                    local widgets = require("dap.ui.widgets")
                    widgets.hover()
                end,
                desc = "DAP: Hover variable"
            },

            {
                "<C-S-F5>",
                function()
                    require("dap").terminate()
                    vim.defer_fn(function()
                        require("dap").run_last()
                    end, 300)
                end,
                desc = "DAP: Restart Session"
            },

        },

        config = function()
            local dap = require("dap")

            -- Set up highlight for stopped line
            vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })

            -- Define DAP signs with default icons
            local dap_icons = {
                Breakpoint = "🔴",
                BreakpointCondition = "🟡",
                BreakpointRejected = "🚫",
                LogPoint = "📝",
                Stopped = "➡️",
            }

            for name, icon in pairs(dap_icons) do
                vim.fn.sign_define(
                    "Dap" .. name,
                    { text = icon, texthl = "DiagnosticInfo", linehl = "", numhl = "" }
                )
            end

            -- setup dap config by VsCode launch.json file (optional)
            local vscode = require("dap.ext.vscode")
            local json = require("plenary.json")
            vscode.json_decode = function(str)
                return vim.json.decode(json.json_strip_comments(str))
            end
        end,
    },

    {
        "rcarriga/nvim-dap-ui",
        dependencies = {
            "mfussenegger/nvim-dap", -- obligatorio
            "nvim-neotest/nvim-nio",
        },
        keys = {
            {
                "<leader>du",
                function()
                    require("dapui").toggle()
                end,
                desc = "DAP: Toggle UI",
                mode = "n",
            },
        },
        config = function()
            local dap, dapui = require("dap"), require("dapui")

            dapui.setup()

            dap.listeners.after.event_initialized["dapui_config"] = function()
                dapui.open()
            end
            dap.listeners.before.event_terminated["dapui_config"] = function()
                dapui.close()
            end
            dap.listeners.before.event_exited["dapui_config"] = function()
                dapui.close()
            end

            -- el mapeo ya se declara arriba en `keys` para que funcione al primer golpe
        end,
    },

    {
        "theHamsta/nvim-dap-virtual-text",
        dependencies = {
            "mfussenegger/nvim-dap",
        },
        opts = {
            commented = true,      -- muestra los valores como si fueran comentarios
            virt_text_pos = "eol", -- puede ser 'inline', 'eol', o 'overlay'
        },
    },
}

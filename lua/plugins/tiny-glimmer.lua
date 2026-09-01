return {
    "rachartier/tiny-glimmer.nvim",
    event = "VeryLazy",
    priority = 10, -- Low priority to catch other plugins' keybindings
    config = function(_, opts)
        require("tiny-glimmer").setup(opts)
    end,
    opts = {
        refresh_interval_ms = 16,
    },
}

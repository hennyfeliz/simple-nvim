-- lua/plugins/cursor-ai-replacement.lua
return {
  {
    "olimorris/codecompanion.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
    opts = function()
      local adapters = require("codecompanion.adapters")
      return {
        strategies = {
          chat   = { adapter = "openai", },
          inline = { adapter = "openai", },
        },
        adapters = {
          openai = function()
            return adapters.extend("openai", {
              env = { api_key = vim.env.OPENAI_API_KEY }, -- usa tu variable
              schema = { model = { default = "gpt-5" } },
            })
          end,
          -- evita Copilot si no lo usas
          copilot = false,
        },
      }
    end,
  },

  {
    "yetone/avante.nvim",
    opts = {
      provider = "openai",
      providers = {
        openai = {
          endpoint = "https://api.openai.com/v1",
          api_key = vim.env.OPENAI_API_KEY,
          model = "gpt-5",
        },
      },
    },
  },
}


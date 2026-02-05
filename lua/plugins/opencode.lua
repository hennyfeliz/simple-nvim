return {
  "NickvanDyke/opencode.nvim",
  dependencies = {
    { "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
  },
  keys = {
    {
      "<leader>ot",
      function()
        require("opencode").toggle()
      end,
      mode = { "n" },
      desc = "Toggle OpenCode",
    },
    {
      "<leader>os",
      function()
        require("opencode").select({ submit = true })
      end,
      mode = { "n", "x" },
      desc = "OpenCode select",
    },
    {
      "<leader>oa",
      function()
        require("opencode").ask("", { submit = true })
      end,
      mode = { "n", "x" },
      desc = "OpenCode ask",
    },
    {
      "<leader>oA",
      function()
        require("opencode").ask("@this: ", { submit = true })
      end,
      mode = { "n", "x" },
      desc = "OpenCode ask with context",
    },
    {
      "<leader>ob",
      function()
        require("opencode").ask("@file ", { submit = true })
      end,
      mode = { "n", "x" },
      desc = "OpenCode ask about buffer",
    },
    {
      "<leader>op",
      function()
        require("opencode").prompt("@this", { submit = true })
      end,
      mode = { "n", "x" },
      desc = "OpenCode prompt",
    },
    -- Built-in prompts
    {
      "<leader>oe",
      function()
        require("opencode").prompt("explain", { submit = true })
      end,
      mode = { "n", "x" },
      desc = "OpenCode explain",
    },
    {
      "<leader>of",
      function()
        require("opencode").prompt("fix", { submit = true })
      end,
      mode = { "n", "x" },
      desc = "OpenCode fix",
    },
    {
      "<leader>od",
      function()
        require("opencode").prompt("diagnose", { submit = true })
      end,
      mode = { "n", "x" },
      desc = "OpenCode diagnose",
    },
    {
      "<leader>or",
      function()
        require("opencode").prompt("review", { submit = true })
      end,
      mode = { "n", "x" },
      desc = "OpenCode review",
    },
    {
      "<leader>ots",
      function()
        require("opencode").prompt("test", { submit = true })
      end,
      mode = { "n", "x" },
      desc = "OpenCode test",
    },
    {
      "<leader>oo",
      function()
        require("opencode").prompt("optimize", { submit = true })
      end,
      mode = { "n", "x" },
      desc = "OpenCode optimize",
     },
     {
       "<leader>ox",
       function()
         require("opencode").toggle()
       end,
       mode = { "n", "t" },
       desc = "Close OpenCode",
     },
   },
   config = function()
    vim.g.opencode_opts = {
      provider = {
        snacks = {
          win = {
            position = "right",
            enter_insert = false,
            enter_normal = true,
          },
        },
      },
    }
    vim.o.autoread = true
    vim.api.nvim_create_autocmd("BufEnter", {
      callback = function()
        if vim.bo.buftype == "terminal" then
          vim.cmd("stopinsert")
        end
      end
    })
  end,
}





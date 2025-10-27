-- lua/plugins/store.lua
return {
  {
    "alex-popov-tech/store.nvim",
    dependencies = { "OXY2DEV/markview.nvim" },
    -- fuerza setup y sobreescribe el comando para pasar {}
    config = function(_, opts)
      require("store").setup(opts or {})
      vim.api.nvim_create_user_command("Store", function()
        require("store").open({})   -- <- evita el nil
      end, {})
    end,
    keys = {
      { "<leader>ps", function() require("store").open({}) end, desc = "Plugin Store" },
    },
  },
}


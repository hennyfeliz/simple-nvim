-- Mason core plugin
return {
  "williamboman/mason.nvim",
  cmd = "Mason", -- lazy-load on :Mason
  keys = {
    { "<leader>m", "<cmd>Mason<CR>", desc = "Open Mason" },
  },
  config = function()
    require("mason").setup({})

    -- Instala herramientas críticas para Java (rápido y con prioridad)
    local registry = require("mason-registry")
    local ensure = {
      "jdtls",      -- LSP de Java
      "checkstyle", -- Linter de Java
    }
    local function ensure_installed()
      for _, name in ipairs(ensure) do
        local ok, pkg = pcall(registry.get_package, name)
        if ok and not pkg:is_installed() then
          pkg:install()
        end
      end
    end
    if registry.refresh then
      registry.refresh(ensure_installed)
    else
      ensure_installed()
    end
  end,
}

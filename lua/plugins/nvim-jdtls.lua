return {
  "mfussenegger/nvim-jdtls",
  ft = { "java" },
  config = function()
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "java",
      callback = function()
        local mason_path = vim.fn.stdpath("data") .. "/mason/packages"
        local jdtls_path = mason_path .. "/jdtls"
        
        -- Find jar file
        local jar_patterns = {
          jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar",
        }
        
        local jar_file = ""
        for _, pattern in ipairs(jar_patterns) do
          local found = vim.fn.glob(pattern)
          if found ~= "" then
            jar_file = found
            break
          end
        end
        
        if jar_file == "" then
          vim.notify("JDTLS jar file not found", vim.log.levels.ERROR)
          return
        end
        
        local config = {
          cmd = {
            "java",
            "-Declipse.application=org.eclipse.jdt.ls.core.id1",
            "-Dosgi.bundles.defaultStartLevel=4", 
            "-Declipse.product=org.eclipse.jdt.ls.core.product",
            "-Dlog.protocol=true",
            "-Dlog.level=ALL",
            "-Xmx1g",
            "--add-modules=ALL-SYSTEM",
            "--add-opens", "java.base/java.util=ALL-UNNAMED",
            "--add-opens", "java.base/java.lang=ALL-UNNAMED",
            "-jar", jar_file,
            "-configuration", jdtls_path .. "/config_" .. (vim.fn.has("win32") == 1 and "win" or "linux"),
            "-data", vim.fn.stdpath("data") .. "/jdtls-workspace/" .. vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
          },
          
          root_dir = vim.fs.dirname(vim.fs.find({'.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle'}, { upward = true })[1]),
          
          settings = {
            java = {
              signatureHelp = { enabled = true },
              contentProvider = { preferred = 'fernflower' },
            }
          },
          
          init_options = {
            bundles = {}
          },
          
          capabilities = require("blink.cmp").get_lsp_capabilities(),
          
          on_attach = function(client, bufnr)
            local opts = { buffer = bufnr, silent = true }
            vim.keymap.set({'n', 'v'}, '<leader>ca', vim.lsp.buf.code_action, opts)
            vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
            vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
            vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
            vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
            
            -- Java specific
            vim.keymap.set('n', '<leader>jo', "<Cmd>lua require'jdtls'.organize_imports()<CR>", opts)
          end,
        }
        
        require("jdtls").start_or_attach(config)
      end,
    })
  end,
} 
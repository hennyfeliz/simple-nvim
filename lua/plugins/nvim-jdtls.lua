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
            "-Xmx2g", -- Increased memory for better performance
            "--add-modules=ALL-SYSTEM",
            "--add-opens", "java.base/java.util=ALL-UNNAMED",
            "--add-opens", "java.base/java.lang=ALL-UNNAMED",
            "-jar", jar_file,
            "-configuration", jdtls_path .. "/config_" .. (vim.fn.has("win32") == 1 and "win" or "linux"),
            "-data", vim.fn.stdpath("data") .. "/jdtls-workspace/" .. vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
          },
          
          -- Improved root directory detection
          root_dir = vim.fs.dirname(vim.fs.find({'.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle', 'settings.gradle'}, { upward = true })[1]) or vim.fn.getcwd(),
          
          settings = {
            java = {
              signatureHelp = { enabled = true },
              contentProvider = { preferred = 'fernflower' },
              
              -- CRITICAL: Enable Maven/Gradle source downloads
              maven = {
                downloadSources = true,
                updateSnapshots = true,
              },
              gradle = {
                downloadSources = true,
              },
              
              -- Auto-update build configuration when pom.xml/build.gradle changes
              configuration = {
                updateBuildConfiguration = "automatic",
              },
              
              -- Enable automatic dependency resolution
              autobuild = { enabled = true },
              
              -- Import and organize imports automatically
              -- saveActions = {
              --   organizeImports = true,
              -- },
            }
          },
          
          init_options = {
            bundles = {},
            -- Enable extended client capabilities
            extendedClientCapabilities = {
              progressReportsSupport = true,
              classFileContentsSupport = true,
              generateToStringPromptSupport = true,
              hashCodeEqualsPromptSupport = true,
              advancedExtractRefactoringSupport = true,
              advancedOrganizeImportsSupport = true,
              generateConstructorsPromptSupport = true,
              generateDelegateMethodsPromptSupport = true,
              moveRefactoringSupport = true,
            },
          },
          
          -- Minimal capabilities to avoid LSP conflicts
          capabilities = {
            textDocument = {
              completion = {
                completionItem = {
                  snippetSupport = true,
                },
              },
            },
          },
          
          on_attach = function(client, bufnr)
            -- Essential Java keymaps only
            local opts = { buffer = bufnr, silent = true }
            
            -- Core LSP functions
            vim.keymap.set('n', 'K', vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover Documentation" }))
            vim.keymap.set('n', 'gd', vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to Definition" }))
            vim.keymap.set('n', 'gr', vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "Find References" }))
            vim.keymap.set({'n', 'v'}, '<leader>ca', vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code Actions" }))
            vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename Symbol" }))
            
            -- Java-specific commands
            vim.keymap.set('n', '<leader>jo', "<Cmd>lua require'jdtls'.organize_imports()<CR>", vim.tbl_extend("force", opts, { desc = "Organize Imports" }))
            vim.keymap.set('n', '<leader>jc', "<Cmd>lua require'jdtls'.compile('full')<CR>", vim.tbl_extend("force", opts, { desc = "Compile Project" }))
            vim.keymap.set('n', '<leader>ju', "<Cmd>JdtUpdateConfig<CR>", vim.tbl_extend("force", opts, { desc = "Update Project Config" }))
            
            -- Notify when ready
            vim.notify("Java LSP attached successfully!", vim.log.levels.INFO)
          end,
        }
        
        require("jdtls").start_or_attach(config)
      end,
    })
  end,
} 

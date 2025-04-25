return {
  "tpope/vim-dadbod",
  dependencies = {
    "kristijanhusak/vim-dadbod-ui",
    "kristijanhusak/vim-dadbod-completion",
  },
  config = function()
    vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/db_ui"
    vim.g.db_ui_show_help = 0
    vim.g.db_ui_auto_execute_table_helpers = 1
    vim.g.db_ui_table_helpers_filetype = { "sql", "plsql" }
  end,
}

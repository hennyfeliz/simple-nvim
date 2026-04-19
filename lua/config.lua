-- Router: modo completo vs modo limpio (NVIM_CLEAN=1 / vim.g.nvim_clean)
if vim.g.nvim_clean then
  require("config.minimal")
else
  require("config.full")
end

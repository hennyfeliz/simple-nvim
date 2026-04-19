@echo off
REM Neovim en modo limpio: sin LSP, lint ni format (NVIM_CLEAN=1).
set NVIM_CLEAN=1
nvim %*

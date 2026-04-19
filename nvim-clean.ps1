# Neovim en modo limpio: sin LSP, lint ni format (NVIM_CLEAN=1).
$env:NVIM_CLEAN = "1"
& nvim @args

# simple-nvim

Configuración personal de Neovim para Windows, organizada con
[`lazy.nvim`](https://github.com/folke/lazy.nvim) y [`mason.nvim`](https://github.com/williamboman/mason.nvim).
Incluye soporte de primera clase para **Java** (JDTLS + nvim-java + DAP),
múltiples asistentes de IA (Copilot, Opencode, Cursor AI replacement),
tema [Catppuccin](https://github.com/catppuccin/nvim)/OneDark, picker con
[`snacks.nvim`](https://github.com/folke/snacks.nvim) + Telescope, y un
**modo limpio** para arrancar sin LSP/lint/format cuando hace falta velocidad.

---

## Requisitos

- Neovim **0.10+** (se recomienda 0.11).
- [Git](https://git-scm.com/).
- Un compilador para Treesitter (MSVC o `zig`).
- [Node.js 20](https://nodejs.org/) (para LSPs web, Copilot, etc.).
- [`ripgrep`](https://github.com/BurntSushi/ripgrep) para grep en pickers.
- [`lazygit`](https://github.com/jesseduffield/lazygit) opcional.
- JDK 17+ en el `PATH` si vas a usar Java.

### Instalación rápida con Scoop (Windows)

```powershell
scoop bucket add extras
scoop install main/ripgrep version/nodejs20 main/gcc main/clangd extras/lazygit
```

---

## Instalación

Clona el repo directamente en la ruta de configuración de Neovim en Windows:

```powershell
git clone https://github.com/hennyfeliz/simple-nvim "$env:LOCALAPPDATA\nvim"
nvim
```

En el primer arranque, `lazy.nvim` se auto-instalará y descargará todos los
plugins. Luego puedes abrir `:Mason` para ver/instalar LSPs, formatters y linters.

### Herramientas que normalmente instalo vía Mason

- `copilot-language-server`
- `eslint-lsp`, `eslint_d`, `ts-standard`, `prettier`
- `lua-language-server`, `stylua`
- `jdtls`, `google-java-format`
- `gopls`, `rust-analyzer`, `clangd`
- `sqlls`, `sql-formatter`, `phpmd`, `shfmt`, `pico8-ls`

---

## Estructura

```
.
├── init.lua                # entry point (shims LSP, leader, options)
├── lazy-lock.json          # lockfile de plugins
├── nvim-clean.cmd          # arranque en modo limpio (Windows cmd)
├── nvim-clean.ps1          # arranque en modo limpio (PowerShell)
└── lua/
    ├── plugins.lua         # registro de plugins para lazy.nvim
    ├── keymaps.lua         # atajos globales
    ├── config.lua          # dispatcher: carga config/minimal o config/full
    ├── theme.lua           # colores y overrides de highlights
    ├── config/
    │   ├── minimal.lua     # modo limpio (sin LSP/cmp)
    │   └── full.lua        # modo completo (LSP, cmp, diagnostics)
    ├── plugins/            # un archivo por plugin
    ├── java/               # helpers de JDTLS/nvim-java
    ├── servers/            # overrides de servidores LSP
    ├── snippets/           # snippets de LuaSnip
    └── utils/              # utilidades internas
```

---

## Modos de arranque

Esta config soporta dos modos, útiles para separar "editor pesado" de
"editor rápido para notas/scratch".

### Modo completo (por defecto)

```powershell
nvim
```

Carga todo: LSP, `nvim-cmp`, formateadores (conform), linters (nvim-lint),
diagnósticos inline, Java (JDTLS + nvim-java), DAP, etc.

### Modo limpio

Desactiva LSP, lint, format, autocomplete y diagnósticos visibles. Útil para
abrir archivos grandes o editar config sin que nada se "meta en medio".

```powershell
# cmd
nvim-clean.cmd archivo.txt

# PowerShell
./nvim-clean.ps1 archivo.txt

# o manualmente
$env:NVIM_CLEAN = "1"; nvim
```

El switch se detecta en `init.lua` mediante `vim.g.nvim_clean` y se propaga
a `lua/plugins.lua` (vía `unless_clean`) y `lua/keymaps.lua`.

---

## Plugins destacados

| Categoría        | Plugin                                                                 |
|------------------|------------------------------------------------------------------------|
| Plugin manager   | [`lazy.nvim`](https://github.com/folke/lazy.nvim)                      |
| Picker / UI      | [`snacks.nvim`](https://github.com/folke/snacks.nvim), `telescope.nvim`|
| LSP              | `nvim-lspconfig`, `mason.nvim`, `mason-lspconfig`                      |
| Java             | `nvim-java`, `nvim-jdtls`                                              |
| Autocompletado   | `nvim-cmp` + fuentes, `LuaSnip`                                        |
| Formato / Lint   | `conform.nvim`, `nvim-lint`                                            |
| Git              | `gitsigns.nvim`, `lazygit.nvim`                                        |
| DAP              | `nvim-dap`, `nvim-dap-ui` (sincronizados con nvim-tree/snacks explorer) |
| Explorador       | `nvim-tree.lua`, `Snacks.explorer`                                     |
| Sintaxis         | `nvim-treesitter`                                                      |
| Status / Tabs    | `lualine.nvim`, `bufferline.nvim`                                      |
| Temas            | `catppuccin`, `onedark`                                                |
| Edición          | `vim-surround`, `nvim-autopairs`, `vim-visual-multi`, `spectre`        |
| Diagnósticos     | `tiny-line-diagnostic`, `trouble.nvim` (opcional)                      |
| IA               | `copilot.lua`, `copilot-chat`, `opencode.nvim`, `cursor-ai-replacement`|

Lista completa en `lua/plugins.lua` y `lua/plugins/`.

---

## Keymaps principales

`<leader>` está mapeado a **espacio**. Algunos de los más usados:

### Navegación y búsqueda

| Atajo         | Acción                                           |
|---------------|--------------------------------------------------|
| `<leader>ff`  | Buscar archivos (Telescope)                      |
| `<leader>fg`  | Live grep (Telescope)                            |
| `<leader>fb`  | Listar buffers                                   |
| `<leader>fk`  | Reanudar última búsqueda de Telescope            |
| `<leader>sf`  | Buscar texto entre comillas bajo el cursor       |
| `{` (normal)  | Live grep de la palabra bajo el cursor           |
| `{` (visual)  | Live grep del texto seleccionado                 |
| `}` (normal)  | Find files con la palabra bajo el cursor         |
| `<leader>e`   | Toggle `nvim-tree`                               |
| `<leader>E`   | Toggle `Snacks.explorer` (sincronizado con DAP)  |

### Buffers / ventanas

| Atajo       | Acción                       |
|-------------|------------------------------|
| `<S-h>`     | Buffer anterior              |
| `<S-l>`     | Buffer siguiente             |
| `<C-i>`     | Cerrar buffer actual         |
| `<C-h/j/k/l>` | Saltar entre splits        |

### Edición

| Atajo          | Acción                                        |
|----------------|-----------------------------------------------|
| `sj`           | Partir línea en el cursor                     |
| `sk`           | Unir línea con la anterior                    |
| `ss`           | Nueva línea al final                          |
| `<C-d>`        | Duplicar línea / selección                    |
| `<A-j>` / `<A-k>` | Mover línea o bloque arriba/abajo          |
| `<leader>y` / `<leader>Y` | Yank al clipboard del sistema      |
| `<leader>p` / `<leader>P` | Pegar el último yank               |
| `<leader>aa`   | Seleccionar todo                              |
| `<leader>rr`   | Reemplazar en todo el archivo (`:%s/`)        |

### LSP (modo completo)

| Atajo         | Acción                         |
|---------------|--------------------------------|
| `<leader>gd`  | Ir a la definición             |
| `<leader>gi`  | Ir a la implementación         |
| `<leader>gr`  | Listar referencias             |
| `<leader>gt`  | Definición de tipo             |
| `K`           | Hover / documentación          |
| `<leader>ca`  | Code actions                   |
| `<leader>rn`  | Renombrar símbolo              |
| `<leader>f` / `<leader>fm` | Formatear (conform)  |
| `<leader>jo`  | Organizar imports              |
| `<leader>jr`  | `:JavaRefresh`                 |
| `]d` / `[d`   | Diagnóstico siguiente/anterior |
| `<leader>ld`  | Listar diagnósticos            |

### DAP (debugger)

| Atajo         | Acción                                                 |
|---------------|--------------------------------------------------------|
| `<leader>du`  | Toggle `dapui` (se sincroniza con los exploradores)    |

Para la lista completa revisa `lua/keymaps.lua` y cada archivo en `lua/plugins/`.

---

## Integración DAP UI + Exploradores

`nvim-dap`, `nvim-tree` y `Snacks.explorer` están coordinados mediante un
estado global `__dap_explorer_sync` (ver `lua/plugins/nvim-dap.lua`):

- Al abrir el árbol/explorador, `dapui` se cierra temporalmente para evitar
  conflictos de layout.
- Al cerrar el explorador, si hay una sesión DAP activa, `dapui` vuelve a
  abrirse automáticamente.
- `<leader>du` respeta ese estado para que el toggle manual no se pelee con
  la sincronización.

---

## Solución de problemas

- **Crashes con LSP en Neovim < 0.10**: `init.lua` ya incluye un shim para
  `vim.lsp._request_name_to_capability`. Aun así, **actualiza a 0.10+**.
- **Archivos con finales de línea CRLF**: `init.lua` fuerza `LF` al guardar
  y limpia `^M` en `BufReadPost`/`BufWritePre`.
- **Java no arranca**: verifica `:Mason` → `jdtls` instalado y `java --version`
  en el `PATH`.
- **Copilot / LSPs web**: se añade `C:/Users/henny/scoop/persist/nodejs/bin`
  al `PATH` desde `init.lua` (ajústalo si no usas Scoop).
- **`:LspClients`**: comando utilitario incluido que lista los clientes LSP
  adjuntos al buffer actual.

---

## Branches

- `main` — versión estable.
- `fixes` — rama activa de cambios y pruebas (por ejemplo, la sincronización
  DAP ↔ exploradores).

---

## Licencia

Configuración personal, sin licencia explícita. Úsala como referencia o
fork libremente.

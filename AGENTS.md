# AGENTS.md — Referencia para agregar plugins y atajos

Guia basada en la configuracion real de este repo (NvChad v2.5 + lazy.nvim).

---

## Arquitectura del repo

```
~/.config/nvim/
├── init.lua                    # Entry point: bootstrap lazy.nvim, carga NvChad
├── lua/
│   ├── options.lua             # Opciones de Neovim (rtp, luarocks paths)
│   ├── mappings.lua            # Atajos de teclado (globales + desarrollo)
│   ├── autocmds.lua            # Autocomandos (LSP warning, auto-reload, image viewer)
│   ├── chadrc.lua              # Config de NvChad (ui, theme)
│   ├── configs/                # Configs individuales de plugins
│   │   ├── lspconfig.lua       # Servidores LSP (html, cssls, pyright, ts_ls, etc.)
│   │   ├── conform.lua         # Formatters
│   │   ├── lint.lua            # Linters (ruff, mypy, etc.)
│   │   ├── dap.lua             # Debugger (nvim-dap)
│   │   ├── neotest.lua         # Testing (neotest)
│   │   ├── jdtls.lua           # Java/Kotlin LSP (jdtls)
│   │   ├── image.lua           # Image.nvim (view images in terminal)
│   │   └── minuet.lua          # AI completion (Minuet)
│   └── plugins/                # lazy.nvim auto-carga archivos .lua de aqui
│       ├── init.lua            # Plugins principales (295+ lineas)
│       ├── opencode.lua        # Opencode AI (asistente, chat, sesiones)
│       ├── persistence.lua     # Persistence.nvim (sesiones)
│       ├── trouble.lua         # Trouble.nvim (diagnosticos, quickfix)
│       ├── todo-comments.lua   # Todo-comments (Trouble + Telescope)
│       ├── yazi.lua            # Yazi (explorador de archivos)
│       ├── codecompanion.lua   # AI chat (CodeCompanion, opcional)
│       └── ...                 # Otros plugins autocargados
├── .env.example                # Template de variables de entorno
└── lazy-lock.json              # Versiones fijas de plugins
```

### Flujo de carga

```
init.lua
  → vim.g.mapleader = " "          # Leader key (DEBE ser antes de lazy)
  → require("lazy").setup(...)
      → import "nvchad.plugins"     # Plugins base de NvChad
      → import "plugins"            # Tus plugins (auto-carga lua/plugins/*.lua)
  → require "options"
  → require "autocmds"
  → require "mappings"              # (dentro de vim.schedule)
```

---

## Como agregar un plugin nuevo

### Paso 1: Crear archivo en `lua/plugins/`

Lazy.nvim auto-carga cualquier archivo `.lua` en `lua/plugins/`. El archivo debe **retornar** la spec del plugin.

**Plantilla basica:**

```lua
-- lua/plugins/mi-plugin.lua
return {
  "autor/nombre-plugin",
  dependencies = { "otra/dependencia" },  -- opcional
  opts = {
    -- opciones que se pasan a require("nombre-plugin").setup(opts)
  },
}
```

### Paso 2: Entender lazy.nvim triggers

Los plugins se cargan **bajo demanda** por defecto (`lazy = true`). Necesitas un trigger:

| Trigger | Cuando carga | Ejemplo |
|---------|-------------|---------|
| `cmd = {}` | Al ejecutar un comando `:Foo` | `cmd = { "Foo", "FooBar" }` |
| `keys = {}` | Al presionar un atajo | `keys = { { "<leader>ff", ... } }` |
| `event = {}` | Al ocurrir un evento de Vim | `event = "VeryLazy"` |
| `ft = {}` | Al abrir un filetype | `ft = { "python", "lua" }` |
| `lazy = false` | Siempre, al iniciar Neovim | Para plugins criticos |
| `build = ""` | Al instalar/actualizar | `build = ":TSUpdate"` |

**IMPORTANTE:** Si tu plugin registra comandos `:ComandoAlgo`, necesitas `cmd = { "ComandoAlgo" }`. Sin esto, lazy.nvim nunca lo carga y el comando no existe (chicken-and-egg).

### Paso 3: Agregar atajos de teclado

Hay **3 formas** de agregar atajos:

#### Forma A: En `keys` de la spec (recomendada para plugins)

```lua
return {
  "autor/plugin",
  keys = {
    { "<leader>ff", "<cmd>PluginCommand<cr>", desc = "Description" },
    { "<leader>fg", function() require("plugin").do_thing() end, desc = "Do thing" },
    { "<leader>fv", "<cmd>PluginCommand<cr>", mode = "v", desc = "Visual mode" },
  },
  opts = {},
}
```

Ventaja: lazy.nvim carga el plugin automaticamente al presionar el atajo.

#### Forma B: En `lua/mappings.lua` (para plugins que ya cargaron)

```lua
local map = vim.keymap.set

-- Plugin que puede no estar instalado
local ok, plugin = pcall(require, "mi-plugin")
if ok then
  map("n", "<leader>xx", function() plugin.action() end, { desc = "Mi accion" })
end
```

Ventaja: funciona con plugins que se cargan con `lazy = false`.

#### Forma C: En el `config` function de la spec

```lua
return {
  "autor/plugin",
  config = function()
    require("plugin").setup({})
    -- Aqui podes registrar keymaps despues del setup
    vim.keymap.set("n", "<leader>xx", function() require("plugin").action() end)
  end,
}
```

### Convenciones de atajos de este repo

| Prefijo | Categoria | Ejemplos | Origen |
|---------|-----------|----------|--------|
| `<leader>d*` | Debugging (DAP) | `db` toggle bp, `dc` continue, `dn` step over, `du` toggle UI | `lua/mappings.lua` |
| `<leader>t*` | Testing (neotest) | `tt` run nearest, `tf` run file, `ts` summary, `td` debug | `lua/mappings.lua` |
| `<leader>o*` | Opencode (AI) | `oa` ask, `ob` ask buffer, `oo` launch TUI, `on*` session mgmt | `lua/plugins/opencode.lua` |
| `<leader>x*` | Trouble / Diagnostics | `xx` diagnostics, `xX` buffer diag, `xL` loclist, `xQ` quickfix, `xt` todo | `lua/plugins/trouble.lua`, `lua/plugins/todo-comments.lua` |
| `<leader>c*` | LSP / Symbols / Git | `cs` symbols, `cl` LSP refs, `cm` git commits | `lua/plugins/trouble.lua`, `lua/mappings.lua` |
| `<leader>f*` | Telescope / Archivos | `ff` find files, `fw` live grep, `fb` buffers, `fo` oldfiles, `fa` all files | NvChad core |
| `<leader>g*` | Git (con wrapper) | `gt` git status, `cm` commits (ambos con chequeo de git) | `lua/mappings.lua` (override) |
| `<leader>l*` | Linting | `ll` lint buffer | `lua/mappings.lua` |
| `<leader>q*` | Sesiones | `qs` restore, `qS` select, `ql` last, `qd` don't save | `lua/plugins/persistence.lua` |
| `<leader>w*` | Ventanas / WhichKey | `ws` split, `wv` vsplit, `wK` which-key all, `wk` which-key query | `lua/mappings.lua`, NvChad core |
| `<leader>b*` | Buffers | `b` new buffer (`:enew`) | NvChad core |
| `<leader>e*` | Explorador de archivos | `e` abrir Yazi (reemplaza NvimTree) | `lua/plugins/yazi.lua` (override) |
| `<leader>h*` / `<leader>v*` | Terminales | `h` horizontal, `v` vertical | NvChad core |
| `<leader>n*` / `<leader>r*` | Numeros de linea | `n` toggle nu, `rn` toggle rnu | NvChad core |
| `<leader>m*` | Marcas | `ma` telescope marks | NvChad core |
| `<leader>p*` | Terminal oculta | `pt` pick term | NvChad core |
| `<leader>th` | Temas | `th` telescope nvchad themes | NvChad core |
| `<leader>ds` | LSP | `ds` diagnostic loclist | NvChad core |
| `<leader>ch` | Ayuda | `ch` NvCheatsheet | NvChad core |
| `<leader>fm` | Formateo | `fm` format buffer (conform) | NvChad core |
| `<leader>/` | Comentarios | `/` toggle comment (n + v) | NvChad core |
| `<leader>x` | Buffer | `x` cerrar buffer actual | NvChad core |

---

## Como agregar un formatter/linter

### Formatter (conform.nvim)

Editar `lua/configs/conform.lua`:

```lua
local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    python = { "ruff_format" },
    -- Agregar nuevo lenguaje:
    go = { "gofmt" },
  },
  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = true,
  },
}
return options
```

### Linter (nvim-lint)

Editar `lua/configs/lint.lua`:

```lua
return {
  linters_by_ft = {
    python = { "ruff", "mypy" },
    -- Agregar nuevo lenguaje:
    go = { "golangci-lint" },
  },
  linters = {
    -- Configuracion de args para un linter especifico:
    ruff = { args = { "check", "--output-format", "json" } },
  },
}
```

### LSP server

Editar `lua/configs/lspconfig.lua`:

```lua
local servers = {
  "html",
  "cssls",
  "pyright",
  -- Agregar nuevo servidor:
  "gopls",
}

vim.lsp.enable(servers)
```

**Nota:** El servidor debe estar instalado via Mason (`:Mason`) o en el PATH del sistema.

---

## Como configurar un adaptador de API/LLM

### Patron comun (OpenAI-compatible)

```lua
return {
  "plugin/usando-llm",
  opts = {
    adapter = {
      my_adapter = function()
        return require("plugin.adapters").extend("openai_compatible", {
          name = "my_adapter",
          env = {
            url = "https://api.example.com",
            api_key = "MY_API_KEY_ENV_VAR",  -- nombre de env var, NO el valor
            chat_url = "/v1/chat/completions",
          },
          schema = {
            model = {
              default = "modelo-default",
              choices = { "fast", "quality" },
            },
          },
        })
      end,
    },
  },
}
```

**Regla de oro:** NUNCA hardcodear API keys. Siempre usar `os.getenv("NOMBRE_VAR")` o el nombre de la env var como string.

---

## Variables de entorno

Las env vars se cargan desde `~/.bashrc` o `~/.zshrc`. No hay soporte automatico para archivos `.env`.

```bash
# En ~/.bashrc o ~/.zshrc
export MINUET_API_KEY="tu-key-aqui"
export MY_SERVICE_KEY="otra-key"
```

Verificar que existen:
```bash
source ~/.bashrc && echo $MINUET_API_KEY
```

El `.env.example` documenta las variables requeridas pero no se carga automaticamente.

---

## Errores comunes y como resolverlos

### "No es una orden del editor: PluginCommand"

**Causa:** El plugin no se cargo porque lazy.nvim no tiene trigger.
**Solucion:** Agregar `cmd = { "PluginCommand" }` o `keys = { ... }` a la spec.

### Sobreescritura de atajos

**Causa:** Dos `map()` con el mismo `<leader>xx`.
**Solucion:** Buscar con `grep -rn "leader.*xx" lua/` antes de agregar. Verificar `lua/mappings.lua` Y `lua/plugins/*.lua`.

### Plugin no funciona despues de clone

**Causa:** Faltan dependencias del sistema (node, python, gcc, etc.).
**Solucion:** Documentar prerrequisitos en README. Verificar con `:checkhealth`.

### Rutas hardcodeadas no funcionan en otro SO

**Causa:** Usar `/usr/bin/foo` o `/usr/lib/jvm/...`.
**Solucion:** Usar `vim.fn.exepath("foo")` o `vim.fn.glob(pattern)` o deteccion dinamica.

---

## Atajos de desarrollo (LSP)

Estos atajos funcionan **buffer-local** (solo en buffers con un LSP activo). Se configuran en `lua/mappings.lua` via el autocmd `LspAttach`.

### Navegacion de codigo

| Atajo | Accion | Descripcion |
|-------|--------|-------------|
| `gd` | Ir a definicion | Salta a donde se define el simbolo bajo el cursor |
| `gD` | Ir a declaracion | Salta a la declaracion del simbolo |
| `gi` | Ir a implementacion | Salta a la implementacion del simbolo |
| `gr` | Referencias | Lista todas las referencias del simbolo |
| `K` | Hover / Documentacion | Muestra documentacion, firmas, tipos |
| `<leader>D` | Ir a type definition | Salta a la definicion del tipo |
| `<leader>cs` | Simbolos (Trouble) | Arbol de simbolos del documento (Trouble) |
| `<leader>cl` | LSP references | Panel lateral de referencias (Trouble) |

### Diagnosticos

| Atajo | Accion | Descripcion |
|-------|--------|-------------|
| `[d` | Diagnostico anterior | Salta al error/warning anterior |
| `]d` | Siguiente diagnostico | Salta al siguiente error/warning |
| `<leader>ds` | Diagnostic loclist | Envia diagnosticos a la loclist |
| `<leader>xx` | Troubles diagnostics | Panel de diagnosticos (Trouble) |
| `<leader>xX` | Buffer diagnostics | Diagnosticos solo del buffer actual |
| `<leader>ll` | Lint buffer | Ejecuta el linter manualmente |

### Acciones de codigo

| Atajo | Accion | Descripcion |
|-------|--------|-------------|
| `<leader>ca` | Code action | Muestra acciones disponibles (refactor, quickfix, etc.) |
| `<leader>rn` | Renombrar | Renombra el simbolo bajo el cursor en todo el proyecto |
| `<leader>ra` | Renombrar (NvChad) | Alternativa de rename (NvChad renamer) |
| `<leader>fm` | Formatear | Formatea el archivo (via conform + lsp fallback) |

### Navegacion por archivos

| Atajo | Accion | Descripcion |
|-------|--------|-------------|
| `<leader>ff` | Find files | Busca archivos por nombre |
| `<leader>fa` | Find all files | Busca incluyendo ocultos/ignorados |
| `<leader>fw` | Live grep | Busca texto en todo el proyecto |
| `<leader>fb` | Buffers | Cambia entre buffers abiertos |
| `<leader>fo` | Oldfiles | Archivos recientes |
| `<leader>fz` | Fuzzy find buffer | Busca texto dentro del buffer actual |
| `<leader>e` | Yazi | Explorador de archivos (Yazi) |

### Debugging (DAP)

Configurado en `lua/mappings.lua`. Requiere `nvim-dap` y adaptadores instalados via `:Mason`.

| Atajo | Accion |
|-------|--------|
| `<leader>db` | Toggle breakpoint |
| `<leader>dB` | Breakpoint condicional |
| `<leader>dC` | Limpiar breakpoints |
| `<leader>dc` | Continue / iniciar debug |
| `<leader>dn` | Step over |
| `<leader>di` | Step into |
| `<leader>do` | Step out |
| `<leader>dr` | Toggle REPL |
| `<leader>dl` | Run last |
| `<leader>dt` | Terminar debug |
| `<leader>du` | Toggle DAP UI |

### Testing (neotest)

Configurado en `lua/mappings.lua`. Soporta pytest, jest, unittest, etc.

| Atajo | Accion |
|-------|--------|
| `<leader>tt` | Run test mas cercano |
| `<leader>tf` | Run todo el archivo de tests |
| `<leader>ts` | Toggle summary (panel de resultados) |
| `<leader>to` | Toggle output panel |
| `<leader>td` | Debug test mas cercano |

### AI / Opencode

Configurado en `lua/plugins/opencode.lua`. Usa Opencode AI como asistente.

| Atajo | Accion |
|-------|--------|
| `<leader>oa` | Ask (seleccion/palabra bajo cursor) |
| `<leader>ob` | Ask about buffer completo |
| `<leader>oo` | Launch TUI (terminal vertical) |
| `<leader>os` | Select server/modelo |
| `<leader>on*` | Session management (new, list, interrupt, etc.) |

### Sesiones (persistence.nvim)

Configurado en `lua/plugins/persistence.lua`. Guarda/restaura el estado de Neovim.

| Atajo | Accion |
|-------|--------|
| `<leader>qs` | Restaurar sesion |
| `<leader>qS` | Seleccionar sesion |
| `<leader>ql` | Restaurar ultima sesion |
| `<leader>qd` | No guardar sesion actual |

### Buffer / Cerrar

| Atajo / Comando | Accion |
|-----------------|--------|
| `<leader>x` | Cerrar buffer actual (NvChad) |
| `:Q` | Cerrar buffer actual. Si es el ultimo, cierra Neovim |
| `:Q!` | Forzar cierre (sin guardar) |
| `<leader>b` | Nuevo buffer vacio |

---

## Comando `:Q` — Cerrar buffer o salir

Definido en `lua/mappings.lua`. Comportamiento:

1. Cuenta los buffers **listados** (los que ves en la tabline).
2. Si hay **mas de uno**: ejecuta `:bdelete` — cierra el buffer actual. Si estaba en un split, cierra el split. Si era el unico en una pestaña, cierra la pestaña.
3. Si es el **unico buffer**: ejecuta `:q` — sale de Neovim.
4. Con `:Q!` fuerza el cierre aunque haya cambios sin guardar.

---

## Aviso de LSP faltante

Definido en `lua/autocmds.lua`. Al abrir un archivo cuyo filetype tiene un LSP configurado pero no se conecta, muestra una advertencia via `vim.notify`:

- Si es Kotlin: mensaje especifico sobre la incompatibilidad con Neovim 0.12.
- Otros: sugiere revisar `:Mason` y `lspconfig.lua`.

La deteccion es **dinamica**: escanea `vim.lsp.config()` al inicio para saber que filetypes deberian tener LSP. Si agregas un nuevo servidor en `lspconfig.lua`, se incluye automaticamente.

---

## Keymaps del chat buffer (CodeCompanion)

Estos solo funcionan DENTRO del chat buffer, no globalmente:

| Key | Accion |
|-----|--------|
| `<CR>` o `<C-s>` | Enviar mensaje |
| `<C-c>` | Cerrar chat |
| `q` | Detener request |
| `gr` | Regenerar respuesta |
| `gy` | Copiar codeblock |
| `gc` | Insertar codeblock vacio |
| `gx` | Limpiar mensajes |
| `[[` / `]]` | Navegar headers |
| `{` / `}` | Cambiar entre chats |
| `ga` | Cambiar adapter/modelo |
| `gf` | Fold codeblocks |
| `gd` | Debug info |
| `gs` | Toggle system prompt |
| `?` | Opciones |

---

## Comandos de Neovim utiles

```vim
:checkhealth              " Verificar salud de plugins
:Lazy                     " Ver plugins instalados, updates pendientes
:Mason                    " Ver/instalar LSPs, linters, formatters
:TSInstallInfo            " Ver parsers de treesitter
:Q                        " Cerrar buffer actual (o salir si es el ultimo)
:CodeCompanionChat        " Abrir chat AI
:CodeCompanionActions     " Action palette
:ConformInfo              " Ver formatters configurados
:LintInfo                 " Ver linters configurados
```

# AGENTS.md — Referencia para agregar plugins y atajos

Guia basada en la configuracion real de este repo (NvChad v2.5 + lazy.nvim).

---

## Arquitectura del repo

```
~/.config/nvim/
├── init.lua                    # Entry point: bootstrap lazy.nvim, carga NvChad
├── lua/
│   ├── options.lua             # Opciones de Neovim (rtp, luarocks paths)
│   ├── mappings.lua            # Atajos de teclado (globales)
│   ├── autocmds.lua            # Autocomandos (auto-reload, image viewer)
│   ├── chadrc.lua              # Config de NvChad (ui, theme)
│   ├── configs/                # Configs individuales de plugins
│   │   ├── lspconfig.lua       # Servidores LSP
│   │   ├── conform.lua         # Formatters
│   │   ├── lint.lua            # Linters
│   │   ├── dap.lua             # Debugger
│   │   ├── neotest.lua         # Testing
│   │   ├── jdtls.lua           # Java/Kotlin LSP
│   │   ├── image.lua           # Image.nvim
│   │   └── minuet.lua          # AI completion
│   └── plugins/                # lazy.nvim auto-carga archivos .lua de aqui
│       ├── init.lua            # Plugins principales (295 lineas)
│       └── codecompanion.lua   # AI chat (ejemplo de plugin separado)
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
:CodeCompanionChat        " Abrir chat AI
:CodeCompanionActions     " Action palette
:ConformInfo              " Ver formatters configurados
:LintInfo                 " Ver linters configurados
```

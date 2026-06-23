# NvChad Config — CesarGuzmanLopez

Configuracion personal de **Neovim** basada en [NvChad v2.5](https://github.com/NvChad/NvChad) + [lazy.nvim](https://github.com/folke/lazy.nvim).

> NvChad se usa como plugin externo (no fork). Este repo solo contiene la configuracion propia.

---

## Caracteristicas

| Categoria | Herramientas |
|-----------|-------------|
| **LSP** | pyright, ts_ls, rust_analyzer, clangd, lua_ls, intelephese, bashls, jsonls, yamlls, marksman, dockerls, taplo, cmake, angularls, qmlls |
| **Formateo** | conform.nvim (ruff_format, stylua, prettier, etc.) |
| **Linting** | nvim-lint (ruff, mypy) |
| **Debugging** | nvim-dap + nvim-dap-ui |
| **Testing** | neotest (pytest, jest, unittest) |
| **AI Chat** | Opencode AI (asistente, chat, sesiones) + CodeCompanion (opcional) |
| **Explorador** | Yazi (terminal file manager) |
| **Diagnosticos** | Trouble.nvim |
| **Sesiones** | persistence.nvim |
| **Git** | Telescope + wrappers con chequeo de git |
| **Temas** | NvChad themes (cambiables con `<leader>th`) |

---

## Instalacion

### Prerrequisitos

```bash
# Neovim >= 0.11 (recomendado 0.12)
# Node.js (para LSPs como ts_ls, intelephese, etc.)
# Python 3 (para pyright, ruff, etc.)
# Rust (para rust_analyzer)
# kitty (para image viewer)
# yazi (para explorador de archivos)
```

### Clone

```bash
git clone https://github.com/CesarGuzmanLopez/starter.git ~/.config/nvim
nvim --headless "+Lazy! sync" +qa
nvim
```

Al abrir Neovim, Mason instalara automaticamente los LSPs y linters. Puedes verificar con `:checkhealth`.

---

## Actualizacion

```bash
# Actualizar plugins (lazy.nvim)
nvim --headless "+Lazy! sync" +qa

# Alternativa: abrir Neovim y ejecutar
:Lazy

# Para actualizar solo este repo (sin tocar NvChad):
cd ~/.config/nvim && git pull

# Para actualizar NvChad a la version mas reciente:
:Lazy update NvChad
```

> ⚠ **Importante:** Este repo es un fork del starter de NvChad. NvChad se maneja como plugin via lazy.nvim, por lo que no necesitas clonarlo por separado. Para personalizarlo, edita los archivos en `lua/` (ver `AGENTS.md`).

---

## Atajos principales

Ver `AGENTS.md` para la lista completa. Aqui los mas usados:

| Accion | Atajo |
|--------|-------|
| Buscar archivos | `<leader>ff` |
| Buscar texto | `<leader>fw` |
| Cerrar buffer | `:Q` o `<leader>x` |
| Ir a definicion | `gd` |
| Documentacion | `K` |
| Code action | `<leader>ca` |
| Renombrar | `<leader>rn` |
| Diagnosticos | `<leader>xx` |
| Debug toggle bp | `<leader>db` |
| Test run | `<leader>tt` |
| Opencode AI | `<leader>oa` |
| Explorador | `<leader>e` |
| Terminal horiz | `<leader>h` |
| Terminal vert | `<leader>v` |

---

## Estructura del repo

```
~/.config/nvim/
├── init.lua              # Entry point
├── lua/
│   ├── mappings.lua      # Atajos de teclado
│   ├── autocmds.lua      # Autocomandos
│   ├── options.lua       # Opciones de Neovim
│   ├── chadrc.lua        # Config de NvChad (ui, theme)
│   ├── configs/          # Configs de plugins (LSP, formatter, linter, etc.)
│   └── plugins/          # Plugins via lazy.nvim
├── AGENTS.md             # Referencia detallada para contribuir
└── lazy-lock.json        # Versiones fijas
```

---

## Personalizacion

### Agregar un LSP

1. Instalar via `:Mason`
2. Agregar el nombre del servidor en `lua/configs/lspconfig.lua`

### Agregar un formatter/linter

1. Instalar via `:Mason`
2. Editar `lua/configs/conform.lua` o `lua/configs/lint.lua`

### Agregar un plugin

1. Crear `lua/plugins/mi-plugin.lua`
2. Retornar la spec de lazy.nvim (ver `AGENTS.md`)

---

## Notas

- **Kotlin:** `kotlin-language-server` 1.3.13 es incompatible con Neovim 0.12. Desactivado hasta nueva version.
- **NvimTree:** Reemplazado por Yazi como explorador de archivos.
- **CodeCompanion:** Instalado pero opcional. Se puede activar con `:CodeCompanionChat`.
- **Minuet:** AI autocompletion configurado pero requiere API key en variable de entorno.

---

## Creditos

- [NvChad](https://github.com/NvChad/NvChad) — Framework base
- [LazyVim](https://github.com/LazyVim/LazyVim) — Inspiracion para el starter
- Todos los autores de los plugins incluidos

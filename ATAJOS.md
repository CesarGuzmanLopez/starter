# Atajos de Neovim

`<leader>` = **Espacio**. Modos: `n` normal, `i` insert, `x` visual, `s` select, `t` terminal.

---

## 1. Modo INSERT

### Completado — menú nvim-cmp (LSP · Snippet · Buffer · Lua · Path)

| Tecla | Acción |
|---|---|
| `<Tab>` | Dentro de un snippet → siguiente placeholder. Menú abierto → siguiente opción (**solo resalta, no inserta**). Menú cerrado + IA inline → acepta la IA. Si no → tab normal. |
| `<S-Tab>` | Anterior (placeholder / opción / sugerencia IA). |
| `<C-n>` | Siguiente opción (solo resalta). |
| `<C-p>` | Opción anterior (solo resalta). |
| `<CR>` | **Confirma** el item seleccionado del menú. |
| `<C-Space>` | Abre / fuerza el menú. |
| `<C-e>` | Cierra el menú. |
| `<C-d>` | Desplaza la documentación hacia abajo. |
| `<C-f>` | Desplaza la documentación hacia arriba. |

> El menú **no** incluye la IA a propósito: la IA va aparte (inline) para no mezclar sugerencias multi-línea.

### IA inline — Minuet (ghost text)

| Tecla | Acción |
|---|---|
| `<A-CR>` (Alt+Enter) | Aceptar la sugerencia inline. |
| `<A-n>` | Siguiente sugerencia inline (cicla). |
| `<A-p>` | Sugerencia anterior inline. |
| `<C-]>` | Descartar la sugerencia inline. |

### Edición

| Tecla | Acción |
|---|---|
| `jk` | Salir de insert (equivale a `<ESC>`). |

---

## 2. Creados por el usuario

### Generales (`lua/mappings.lua`)

| Tecla | Modo | Acción |
|---|---|---|
| `;` | n | Entrar a modo comando (`:`). |
| `jk` | i | Salir de insert (ESC). |
| `:Q` | cmd | Cierra el buffer actual; si es el último, sale. `:Q!` fuerza el descarte. |
| `<leader>ut` | n | Toggle tema claro/oscuro (auto). |

### LSP (buffer-local, solo con LSP activo)

| Tecla | Modo | Acción |
|---|---|---|
| `K` | n | Hover / documentación. |
| `gr` | n | Referencias. |
| `gi` | n | Ir a implementación. |
| `[d` / `]d` | n | Diagnóstico anterior / siguiente. |
| `<leader>ca` | n, v | Code action. |
| `<leader>rn` | n | Renombrar símbolo. |

### Debug (DAP)

| Tecla | Acción |
|---|---|
| `<leader>db` | Toggle breakpoint |
| `<leader>dB` | Breakpoint condicional |
| `<leader>dC` | Limpiar breakpoints |
| `<leader>dc` | Continue |
| `<leader>dn` | Step over |
| `<leader>di` | Step into |
| `<leader>do` | Step out |
| `<leader>dr` | Toggle REPL |
| `<leader>dl` | Run last |
| `<leader>dt` | Terminar |
| `<leader>du` | Toggle DAP UI |

### Testing (neotest)

| Tecla | Acción |
|---|---|
| `<leader>tt` | Correr test más cercano |
| `<leader>tf` | Correr archivo de tests |
| `<leader>ts` | Toggle summary |
| `<leader>to` | Toggle output |
| `<leader>td` | Debug test más cercano |

### Diagnósticos / Trouble / Todo

| Tecla | Acción |
|---|---|
| `<leader>xx` | Diagnostics (Trouble) |
| `<leader>xX` | Buffer diagnostics |
| `<leader>cs` | Símbolos (Trouble) |
| `<leader>cl` | LSP definitions/references |
| `<leader>xL` | Location list |
| `<leader>xQ` | Quickfix list |
| `<leader>xt` | Todo (Trouble) |
| `<leader>xT` | Todo/Fix/Fixme (Trouble) |
| `]t` / `[t` | Siguiente / anterior todo-comment |

### Git

| Tecla | Acción |
|---|---|
| `<leader>gt` | Telescope git status |
| `<leader>cm` | Telescope git commits |

### Ventanas

| Tecla | Acción |
|---|---|
| `<leader>ws` | Split horizontal |
| `<leader>wv` | Split vertical |

### Sesiones (persistence)

| Tecla | Acción |
|---|---|
| `<leader>qs` | Restaurar sesión |
| `<leader>qS` | Seleccionar sesión |
| `<leader>ql` | Restaurar última sesión |
| `<leader>qd` | No guardar la sesión actual |

### Archivos / Lint

| Tecla | Acción |
|---|---|
| `<leader>e` | Abrir Yazi (explorador) |
| `<leader>ll` | Lint del buffer |

### OpenCode (IA)

| Tecla | Modo | Acción |
|---|---|---|
| `<leader>oa` | n, x | Ask opencode (palabra/selección) |
| `<leader>ob` | n, x | Ask sobre el buffer |
| `<leader>os` | n, x | Seleccionar servidor |
| `<leader>ons` | n, x | Selector de prompt/command |
| `go` | n, x | Enviar rango (operador) |
| `goo` | n | Enviar la línea actual |
| `<leader>onc` | n | Compact session |
| `<leader>onn` | n | Nueva sesión |
| `<leader>onl` | n | Listar sesiones |
| `<leader>oni` | n | Interrumpir sesión |
| `<leader>onu` | n | Undo de la última acción |
| `<leader>onr` | n | Redo |
| `<leader>oo` | n | Abrir TUI (split vertical) |
| `<S-C-u>` | n | Scroll arriba (TUI opencode) |
| `<S-C-d>` | n | Scroll abajo (TUI opencode) |

### Kitty navigator (Neovim ↔ kitty)

| Tecla | Modo | Acción |
|---|---|---|
| `<C-h>` / `<C-Left>` | n, t | Navegar izquierda |
| `<C-j>` / `<C-Down>` | n, t | Navegar abajo |
| `<C-k>` / `<C-Up>` | n, t | Navegar arriba |
| `<C-l>` / `<C-Right>` | n, t | Navegar derecha |

### Textobjects y surrounds (mini.nvim)

| Tecla | Modo | Acción |
|---|---|---|
| `ys{motion}{char}` | n, x | Agregar surround |
| `ds{char}` | n, x | Eliminar surround |
| `cs{old}{new}` | n, x | Cambiar surround |
| `af` / `if` | n, x | Textobject función (outer/inner) |
| `ac` / `ic` | n, x | Textobject clase (outer/inner) |
| `aa` / `ia` | n, x | Textobject argumento (outer/inner) |
| `[b` / `]b` | n | Buffer anterior/siguiente |
| `[c` / `]c` | n | Comentario anterior/siguiente |
| `[x` / `]x` | n | Conflicto anterior/siguiente |
| `[d` / `]d` | n | Diagnóstico anterior/siguiente |
| `[f` / `]f` | n | Archivo anterior/siguiente |
| `[i` / `]i` | n | Indent anterior/siguiente |
| `[j` / `]j` | n | Jump anterior/siguiente |
| `[l` / `]l` | n | Location anterior/siguiente |
| `[o` / `]o` | n | Oldfile anterior/siguiente |
| `[q` / `]q` | n | Quickfix anterior/siguiente |

### Visor de imágenes (buffer-local)

| Tecla | Modo | Acción |
|---|---|---|
| `q` | n | Cerrar la imagen |
| `<Esc>` | n | Cerrar la imagen |

---

### Mouse

| Botón | Modo | Acción |
|---|---|---|
| Click derecho | n | Pegar desde el portapapeles del sistema (`"+p`). |
| Click derecho | v | Copiar la selección al portapapeles del sistema (`"+y`). |

> El menú contextual del click derecho está deshabilitado (`mousemodel = "extend"`).

---

## Notas

- Para ver **todos** los atajos (incluidos los de NvChad core) usá `:NvCheatsheet` (`<leader>ch`).
- El tema claro/oscuro se ajusta solo según el fondo de la terminal; `<leader>ut` lo fuerza manualmente.
- La IA (Minuet/Groq) no aparece en el menú de completado: solo como ghost text inline.

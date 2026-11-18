require "nvchad.mappings"

-- <leader>e queda como prefijo: ey=Yazi, ee=explorer izquierdo.
pcall(vim.keymap.del, "n", "<leader>e")
-- Exploracion movida de NvChad (ff/fw/fb) a <leader>e*.
pcall(vim.keymap.del, "n", "<leader>ff")
pcall(vim.keymap.del, "n", "<leader>fw")
pcall(vim.keymap.del, "n", "<leader>fb")

-- add yours here

local map = vim.keymap.set

------------------------------
-- Comando :Q para cerrar pestaña / salir
------------------------------
-- :Q  → cierra la pestaña actual. Si es la ultima, cierra Neovim.
vim.api.nvim_create_user_command("Q", function(opts)
  -- Contar buffers listados (los que realmente importan)
  local bufs = vim.api.nvim_list_bufs()
  local listed = 0
  for _, buf in ipairs(bufs) do
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted then
      listed = listed + 1
    end
  end

  if listed <= 1 then
    -- Ultimo buffer: salir de Neovim
    vim.cmd("q" .. (opts.bang and "!" or ""))
  else
    -- Cerrar solo el buffer actual (bdelete cierra split/pestania si era el unico)
    vim.cmd("bdelete" .. (opts.bang and "!" or ""))
  end
end, {
  bang = true,
  desc = "Close current buffer (or quit if last). :Q! forces discard.",
})
-- :q cierra solo el buffer actual (= :Q); :qa sigue saliendo de todo.
-- Solo expande cuando la linea es exactamente `q`: no toca :qa, :g//q, :cq, etc.
vim.cmd([[cabbrev q <c-r>=(getcmdtype()==':' && getcmdline()=='q' ? 'Q' : 'q')<CR>]])

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

-------------------------------
-- Telescope git (safe wrappers)
-------------------------------
local telescope_ok, telescope = pcall(require, "telescope.builtin")
if telescope_ok then
  local function in_git_repo(fn)
    return function()
      local root = vim.fn.system("git rev-parse --show-toplevel 2>/dev/null"):gsub("\n", "")
      if vim.v.shell_error ~= 0 then
        vim.notify("Not a git repository", vim.log.levels.WARN)
        return
      end
      fn({ cwd = root })
    end
  end

  map("n", "<leader>gt", in_git_repo(telescope.git_status), { desc = "Telescope git status" })
  map("n", "<leader>cm", in_git_repo(telescope.git_commits), { desc = "Telescope git commits" })

  -- Exploracion (movida de ff/fw/fb): buffers, difusa, por nombre de archivo.
  -- Raiz del proyecto (git) con fallback a cwd; excluye .git y node_modules.
  local function project_root()
    local root = vim.fn.system("git rev-parse --show-toplevel 2>/dev/null"):gsub("\n", "")
    if vim.v.shell_error ~= 0 or root == "" then
      return vim.fn.getcwd()
    end
    return root
  end
  local ignore = { ".git/", "node_modules/" }
  map("n", "<leader>eb", telescope.buffers, { desc = "Buffers abiertos" })
  map("n", "<leader>ef", function()
    telescope.live_grep({ cwd = project_root(), file_ignore_patterns = ignore })
  end, { desc = "Búsqueda difusa (texto, proyecto)" })
  map("n", "<leader>ew", function()
    telescope.find_files({ cwd = project_root(), hidden = true, file_ignore_patterns = ignore })
  end, { desc = "Buscar por nombre de archivo (proyecto)" })
  -- Recientes: fuera de NvimTree. Dentro del árbol <leader>er sigue siendo
  -- renombrar (buffer-local en nvimtree.lua).
  map("n", "<leader>er", telescope.oldfiles, { desc = "Archivos recientes" })
end

-------------------------------
-- Debugging (nvim-dap)
-------------------------------
local dap_ok, dap = pcall(require, "dap")
if dap_ok then
  -- Breakpoints
  map("n", "<leader>db", function() dap.toggle_breakpoint() end, { desc = "DAP toggle breakpoint" })
  map("n", "<leader>dB", function() dap.set_breakpoint(vim.fn.input "Condition: ") end, { desc = "DAP conditional breakpoint" })
  map("n", "<leader>dC", function() dap.clear_breakpoints() end, { desc = "DAP clear breakpoints" })

  -- Continue / step
  map("n", "<leader>dc", function() dap.continue() end, { desc = "DAP continue" })
  map("n", "<leader>dn", function() dap.step_over() end, { desc = "DAP step over" })
  map("n", "<leader>di", function() dap.step_into() end, { desc = "DAP step into" })
  map("n", "<leader>do", function() dap.step_out() end, { desc = "DAP step out" })

  -- REPL
  map("n", "<leader>dr", function() dap.repl.toggle() end, { desc = "DAP toggle REPL" })
  map("n", "<leader>dl", function() dap.run_last() end, { desc = "DAP run last" })

  -- Terminate
  map("n", "<leader>dt", function() dap.terminate() end, { desc = "DAP terminate" })
end

-- DAP UI
local dapui_ok, dapui = pcall(require, "dapui")
if dapui_ok then
  map("n", "<leader>du", function() dapui.toggle() end, { desc = "DAP toggle UI" })
end

-------------------------------
-- Linting (nvim-lint)
-------------------------------
map("n", "<leader>ll", function()
  -- cwd = dir del archivo: el lint por stdin (eslint_d) resuelve su config
  -- desde el cwd, no desde el archivo; con nvim abierto en la raíz del
  -- monorepo el .eslintrc del front no se encontraba y el .ts se parseaba
  -- como JS ("Parsing error: The keyword 'import' is reserved").
  require("lint").try_lint(nil, { cwd = vim.fn.expand("%:p:h") })
end, { desc = "Lint current buffer" })

-------------------------------
-- Navegar a definición con fallback a texto del proyecto
-------------------------------
-- gd primero vía LSP; si ningún servidor responde con ubicaciones y el cursor
-- está sobre un string 'algo.clave' (típico de claves i18n en cualquier
-- lenguaje: 'alert.call_911', "menu.emergency"...), busca el texto en el
-- proyecto. Los strings literales no tienen definición para ningún LSP.
-- Si el proyecto trae src/i18n/diccionario.ts se busca ahí directo;
-- si no, grep repo-wide (ripgrep, respeta .gitignore).
local function raiz_proyecto()
  local dir = vim.fn.expand("%:p:h")
  local git = vim.fn.systemlist("git -C " .. vim.fn.shellescape(dir) .. " rev-parse --show-toplevel")[1]
  if vim.v.shell_error == 0 and git and git ~= "" then return git end
  return vim.fn.getcwd()
end

local function diccionario_i18n()
  local dir = vim.fn.expand("%:p:h")
  for _ = 1, 8 do
    local cand = dir .. "/src/i18n/diccionario.ts"
    if vim.uv.fs_stat(cand) then return cand end
    local parent = vim.fn.fnamemodify(dir, ":h")
    if parent == dir then break end
    dir = parent
  end
  return nil
end

local function buscar_clave_proyecto()
  local cword = vim.fn.expand("<cWORD>")
  local stripped = cword:gsub("^['\"]", ""):gsub("['\"]$", "")
  if stripped == cword then return false end -- no era string entre comillas
  local key = stripped:gsub("[,;]+$", "")
  if not key:match("^[%w_]+%.[%w_.%-/]+$") then return false end
  local dict = diccionario_i18n()
  local ok, telescope = pcall(require, "telescope.builtin")
  if ok then
    if dict then
      telescope.live_grep({ search_dirs = { vim.fn.fnamemodify(dict, ":h") }, default_text = key })
    else
      telescope.live_grep({
        search_dirs = { raiz_proyecto() },
        default_text = key,
        additional_args = { "--fixed-strings" },
      })
    end
    return true
  end
  if vim.fn.executable("rg") == 1 then
    local raiz = dict and vim.fn.fnamemodify(dict, ":h") or raiz_proyecto()
    local out = vim.fn.systemlist({ "rg", "--vimgrep", "--fixed-strings", "--smart-case", key, raiz })
    if vim.v.shell_error ~= 0 or #out == 0 then
      vim.notify("Sin resultados para '" .. key .. "'", vim.log.levels.INFO)
      return true
    end
    local items = {}
    for _, l in ipairs(out) do
      local f, ln, col, txt = l:match("^(.-):(%d+):(%d+):(.*)$")
      if f then
        items[#items + 1] = { filename = f, lnum = tonumber(ln), col = tonumber(col), text = txt }
      end
    end
    vim.fn.setqflist({}, " ", { title = "Texto '" .. key .. "'", items = items })
    vim.cmd("copen")
    return true
  end
  vim.notify("Instala telescope o ripgrep para buscar texto", vim.log.levels.WARN)
  return true
end

local function goto_definition()
  local bufnr = vim.api.nvim_get_current_buf()
  local enc = "utf-8"
  for _, c in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    if c.supports_method("textDocument/definition") then
      enc = c.offset_encoding
      break
    end
  end
  local params = vim.lsp.util.make_position_params(0, enc)
  local found = {}
  local resp = vim.lsp.buf_request_sync(bufnr, "textDocument/definition", params, 2000)
  if resp then
    for _, r in pairs(resp) do
      local res = r.result
      if type(res) == "table" then
        if res.uri ~= nil or res.targetUri ~= nil then
          found[#found + 1] = res
        elseif #res > 0 then
          vim.list_extend(found, res)
        end
      end
    end
  end
  if #found == 1 then
    vim.lsp.util.show_document(found[1], enc)
    return
  elseif #found > 1 then
    vim.fn.setqflist({}, " ", {
      title = "Definiciones LSP",
      items = vim.lsp.util.locations_to_items(found, enc),
    })
    vim.cmd("copen")
    return
  end
  if not buscar_clave_proyecto() then
    vim.notify("Sin definición", vim.log.levels.INFO)
  end
end

-------------------------------
-- LSP keymaps de desarrollo (buffer-local)
-------------------------------
-- Se agregan via LspAttach para que solo existan en buffers con LSP.
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLSPMappings", { clear = true }),
  callback = function(args)
    local buf = args.buf
    local function bmap(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = "LSP " .. desc })
    end

    -- Navegacion: definicion, hover, referencias
    bmap("n", "gd", goto_definition, "Go to definition (LSP + i18n)")
    bmap("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
    bmap("n", "K", vim.lsp.buf.hover, "Hover documentation")
    bmap("n", "gr", vim.lsp.buf.references, "References")
    bmap("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
    bmap("n", "<leader>D", vim.lsp.buf.type_definition, "Go to type definition")

    -- Diagnosticos: navegar entre errores/warnings
    bmap("n", "[d", vim.diagnostic.goto_prev, "Previous diagnostic")
    bmap("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")

    -- Acciones: code action y rename
    bmap({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
    bmap("n", "<leader>rn", function()
      vim.ui.input({ prompt = "Rename to: ", default = vim.fn.expand "<cword>" }, function(new_name)
        if new_name then vim.lsp.buf.rename(new_name) end
      end)
    end, "Rename symbol")
  end,
})

-------------------------------
-- i18n: ir a la clave de traducción bajo el cursor
-------------------------------
-- En plantillas Angular las claves ('menu.emergency' | t) son strings
-- literales: ningún LSP (ni angularls) las resuelve al diccionario.
-- <leader>ti busca la clave en src/i18n/diccionario.ts del proyecto
-- (sube directorios, soporta monorepo) con Telescope o vimgrep.
map("n", "<leader>ti", function()
  if not buscar_clave_proyecto() then
    vim.notify("Sin clave bajo el cursor", vim.log.levels.WARN)
  end
end, { desc = "Buscar texto/clave en el proyecto" })

-------------------------------
-- Testing (neotest)
-------------------------------
local neotest_ok, neotest = pcall(require, "neotest")
if neotest_ok then
  map("n", "<leader>tt", function() neotest.run.run() end, { desc = "Test: run nearest" })
  map("n", "<leader>tf", function() neotest.run.run(vim.fn.expand "%") end, { desc = "Test: run file" })
  map("n", "<leader>ts", function() neotest.summary.toggle() end, { desc = "Test: toggle summary" })
  map("n", "<leader>to", function() neotest.output_panel.toggle() end, { desc = "Test: toggle output" })
  map("n", "<leader>td", function() neotest.run.run { strategy = "dap" } end, { desc = "Test: debug nearest" })
end

-------------------------------
-- Window splits
-------------------------------
map("n", "<leader>ws", "<cmd>split<cr>", { desc = "Split window horizontal" })
map("n", "<leader>wv", "<cmd>vsplit<cr>", { desc = "Split window vertical" })

------------------------------
-- Tab / S-Tab: placeholders de LuaSnip
------------------------------
-- Neovim 0.12 mapea <Tab>/<S-Tab> a vim.snippet (motor nativo), que no conoce
-- los snippets de LuaSnip. Este mapping los reemplaza para saltar placeholders
-- reales de LuaSnip y, si no hay snippet, cae al comportamiento normal (cmp lo
-- toma como fallback cuando instala sus propios mappings).
-- Solo salta placeholders de un snippet YA activo. No expande triggers:
-- eso se hace eligiendo el snippet en el menu de cmp y confirmando con <CR>.
-- (Antes usaba expand_or_jumpable(), que incluye expandable() y podia dejar
-- Tab sin hacer nada si habia un trigger bajo el cursor.)
local function snippet_jump(direction)
  local ok, ls = pcall(require, "luasnip")
  if ok then
    if direction == 1 and ls.jumpable(1) then
      ls.jump(1)
      return ""
    end
    if direction == -1 and ls.jumpable(-1) then
      ls.jump(-1)
      return ""
    end
  end
  return direction == 1 and "<Tab>" or "<S-Tab>"
end

map({ "i", "s" }, "<Tab>", function()
  return snippet_jump(1)
end, { expr = true, silent = true, desc = "Tab: LuaSnip placeholder / fallback" })

map({ "i", "s" }, "<S-Tab>", function()
  return snippet_jump(-1)
end, { expr = true, silent = true, desc = "S-Tab: LuaSnip placeholder back" })

------------------------------
-- Tema claro/oscuro automatico
------------------------------
-- Sigue el fondo real de la terminal (kitty). Fuerza el modo opuesto a mano.
map("n", "<leader>ut", function()
  require("configs.auto_theme").toggle()
end, { desc = "Toggle tema claro/oscuro (auto)" })

------------------------------
-- Botón secundario del mouse (click derecho)
------------------------------
-- Deshabilita el menú contextual de Neovim.
--   con selección (modo visual) -> copia al portapapeles
--   sin selección (modo normal) -> pega desde el portapapeles
map("n", "<RightMouse>", '"+p', { desc = "Click derecho: pegar" })
map("v", "<RightMouse>", '"+y', { desc = "Click derecho: copiar selección" })

------------------------------
-- Edición: guardar, yank, mover líneas
------------------------------
map({ "i", "v" }, "<C-s>", "<cmd>w<cr>", { desc = "Guardar archivo" })
map("n", "Y", "y$", { desc = "Yank hasta fin de línea" })

-- Mover líneas con Alt+j / Alt+k
map("n", "<A-j>", ":m .+1<cr>==", { desc = "Mover línea abajo" })
map("n", "<A-k>", ":m .-2<cr>==", { desc = "Mover línea arriba" })
map("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Mover selección abajo" })
map("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Mover selección arriba" })

-- NvChad usa <leader>rn para alternar relativenumber; el rename LSP es
-- buffer-local y gana en buffers con LSP. Movemos el toggle a <leader>rN.
map("n", "<leader>rN", "<cmd>set rnu!<cr>", { desc = "Toggle relative number" })


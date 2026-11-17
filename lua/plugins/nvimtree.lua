return {
  "nvim-tree/nvim-tree.lua",
  cmd = { "NvimTreeToggle", "NvimTreeFocus" },
  keys = {
    {
      "<leader>ee",
      function()
        -- Siempre raiz donde se abrio nvim, no el cwd actual (yazi lo cambia).
        local root = vim.g.startup_cwd or vim.fn.getcwd()
        require("nvim-tree.api").tree.toggle({ path = root, focus = true })
      end,
      desc = "Explorer izquierdo toggle (raiz proyecto)",
    },
  },
  init = function()
    -- Congela la raiz de arranque una sola vez.
    if not vim.g.startup_cwd then
      vim.g.startup_cwd = vim.fn.getcwd()
    end
  end,
  opts = function()
    local base = require "nvchad.configs.nvimtree"
    -- No seguir cambios de cwd ni del buffer: raiz fija al arranque.
    base.sync_root_with_cwd = false
    base.respect_buf_cwd = false
    base.prefer_startup_root = true
    -- Compacto: 1 espacio por nivel y sin marcadores de indentacion (los
    -- arboles java con src/main/java/com/app/... se comian media ventana).
    base.renderer = base.renderer or {}
    base.renderer.indent_width = 1
    base.renderer.indent_markers = { enable = false }
    base.renderer.icons = base.renderer.icons or {}
    base.renderer.icons.show = vim.tbl_extend("force", base.renderer.icons.show or {}, {
      folder_arrow = true, -- chevron junto a la carpeta: se ve el nivel sin sangria
    })
    base.renderer.icons.glyphs = vim.tbl_deep_extend("force", base.renderer.icons.glyphs or {}, {
      folder = {
        arrow_closed = "",
        arrow_open = "",
      },
    })
    base.view = vim.tbl_extend("force", base.view or {}, { width = 34 })
    -- Crear rutas anidadas comodamente: el prompt de `a` acepta
    -- "sub/dir/" (carpeta) y "sub/dir/Archivo.java" (archivo), creando los
    -- directorios intermedios. Estos atajos lo dejan a un dedo, tanto dentro
    -- del arbol como desde el buffer.
    base.on_attach = function(bufnr)
      local api = require "nvim-tree.api"
      api.config.mappings.default_on_attach(bufnr)
      local function map(lhs, fn, desc)
        vim.keymap.set("n", lhs, fn, { buffer = bufnr, noremap = true, silent = true, desc = desc })
      end
      map("<leader>en", function()
        api.fs.create()
      end, "Nuevo: 'sub/dir/Archivo.java' o 'carpeta/'")
      map("<leader>er", function()
        api.fs.rename()
      end, "Renombrar (ruta completa)")
      map("<leader>eD", function()
        api.fs.remove()
      end, "Borrar nodo")
    end
    -- Reveal al enfocar un archivo: con el arbol abierto, expande las carpetas
    -- hasta el archivo del buffer actual y lo selecciona. Si el arbol esta
    -- cerrado no hace nada (find_file hace return sin `open`). La raiz NO
    -- cambia: update_root desactivado, sigue congelada al arranque.
    base.update_focused_file = {
      enable = true,
      update_root = { enable = false },
      exclude = function(args)
        local buf = args.buf
        if not vim.api.nvim_buf_is_valid(buf) then
          return true
        end
        -- terminal, nofile, quickfix, prompt...
        if vim.bo[buf].buftype ~= "" then
          return true
        end
        if vim.bo[buf].filetype == "NvimTree" then
          return true
        end
        local name = vim.api.nvim_buf_get_name(buf)
        if name == "" then
          return true
        end
        -- fugitive://, man://, etc.
        if name:match "^%w+://" then
          return true
        end
        return false
      end,
    }
    return base
  end,
}

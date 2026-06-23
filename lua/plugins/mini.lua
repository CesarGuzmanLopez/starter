return {
  "nvim-mini/mini.nvim",
  version = "*",
  event = "VeryLazy",
  config = function()
    -- mini.surround: ys/ds/cs para surround (paréntesis, comillas, tags, etc.)
    require("mini.surround").setup({
      mappings = {
        add = "ys",      -- ys{motion}{char} - agregar surround
        delete = "ds",   -- ds{char} - eliminar surround
        replace = "cs",  -- cs{old}{new} - cambiar surround
        find = "",       -- deshabilitado (conflicta con flash/leap)
        find_left = "",
        highlight = "",
        update_n_lines = "",
        suffix_last = "",
        suffix_next = "",
      },
      search_method = "cover_or_next",
    })

    -- mini.ai: text objects mejorados (ai, ii, a), i), a}, i}, etc.)
    require("mini.ai").setup({
      n_lines = 500,
      custom_textobjects = {
        -- Textobjects para funciones, clases, etc. (usa treesitter)
        f = require("mini.ai").gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
        c = require("mini.ai").gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),
        -- Textobject para argumentos
        a = require("mini.ai").gen_spec.treesitter({ a = "@parameter.outer", i = "@parameter.inner" }),
      },
    })

    -- mini.bracketed: navegación por brackets [b/]b, [q/]q, [d/]d, etc.
    require("mini.bracketed").setup({
      buffer = { suffix = "b", options = {} },
      comment = { suffix = "c", options = {} },
      conflict = { suffix = "x", options = {} },
      diagnostic = { suffix = "d", options = {} },
      file = { suffix = "f", options = {} },
      indent = { suffix = "i", options = {} },
      jump = { suffix = "j", options = {} },
      location = { suffix = "l", options = {} },
      oldfile = { suffix = "o", options = {} },
      quickfix = { suffix = "q", options = {} },
      treesitter = { suffix = "t", options = {} },
      undo = { suffix = "u", options = {} },
      window = { suffix = "w", options = {} },
      yank = { suffix = "y", options = {} },
    })

    -- mini.indentscope: animación visual del scope de indentación
    require("mini.indentscope").setup({
      symbol = "│",
      draw = {
        delay = 50,
        animation = require("mini.indentscope").gen_animation.quadratic({ easing = "out", duration = 100 }),
        priority = 2,
      },
      options = { try_as_border = true },
    })

    -- NO configurar mini.pairs ni mini.comment (ya los tienes via NvChad):
    -- - nvim-autopairs maneja auto-pairs
    -- - Comment.nvim maneja comentarios con <leader>/
  end,
}
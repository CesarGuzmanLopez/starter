-- lua/plugins/android.lua
-- Stack Android (Java/Kotlin/XML): parsers, LSP y formatters.
-- NOTA: kotlin-language-server 1.3.13 es incompatible con Neovim 0.12
-- (ver lua/configs/lspconfig.lua): se instala via Mason pero NO se habilita
-- solo (automatic_enable = false). jdtls se configura en configs/jdtls.lua.
return {
  -- Parsers Android (java/kotlin ya vienen de init.lua; aqui se suma xml).
  -- branch=main obligatorio: es la API que espera NvChad v2.5.
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      for _, parser in ipairs { "kotlin", "java", "xml" } do
        if not vim.tbl_contains(opts.ensure_installed, parser) then
          table.insert(opts.ensure_installed, parser)
        end
      end
    end,
  },

  -- Declarado en init.lua; se lista para documentar la dependencia.
  { "neovim/nvim-lspconfig" },

  -- Instala jdtls + kotlin_language_server via Mason (sin habilitarlos solos).
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = { "jdtls", "kotlin_language_server" },
      automatic_enable = false,
    },
  },

  -- Completado LSP (fuentes nvim_lsp ya configuradas en init.lua).
  {
    "hrsh7th/nvim-cmp",
    dependencies = { "hrsh7th/cmp-nvim-lsp" },
  },

  -- Formatters/linters Android (ktlint, google-java-format via Mason).
  {
    "nvimtools/none-ls.nvim",
    main = "null-ls",
    dependencies = { "nvim-lua/plenary.nvim" },
    ft = { "java", "kotlin", "xml" },
    opts = function()
      local null_ls = require "null-ls"
      return {
        sources = {
          null_ls.builtins.formatting.ktlint,
          null_ls.builtins.formatting.google_java_format,
          null_ls.builtins.diagnostics.ktlint,
        },
      }
    end,
  },
}

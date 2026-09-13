return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts = require "configs.conform",
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      local cmp = require "cmp"
      local luasnip = require "luasnip"

      -- Menu de completado "normal": LSP + snippets + buffer + paths.
      -- La IA NO entra aca a proposito: sus sugerencias suelen ser multi-linea
      -- y no se ven completas en el menu. La IA va aparte como ghost text.
      opts.sources = {
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "buffer" },
        { name = "nvim_lua" },
        { name = "async_path" },
      }

      -- Timeout un poco mas alto por si alguna fuente tarda; no bloquea al resto.
      opts.performance = vim.tbl_deep_extend("force", opts.performance or {}, { fetching_timeout = 2000 })

      -- No insertar el item seleccionado hasta confirmar (<CR>).
      opts.completion = vim.tbl_deep_extend("force", opts.completion or {}, {
        completeopt = "menu,menuone,noinsert",
      })

      -- Etiqueta de origen en el menu, para distinguir de donde sale cada item.
      local labels = {
        nvim_lsp = "LSP",
        luasnip = "Snippet",
        buffer = "Buffer",
        nvim_lua = "Lua",
        async_path = "Path",
        path = "Path",
      }
      local base_format = opts.formatting.format
      opts.formatting.format = function(entry, item)
        item = base_format(entry, item)
        item.menu = labels[entry.source.name] or entry.source.name
        item.menu_hl_group = "comment"
        return item
      end

      -- Tab en insert. Para confirmar del menu se usa <CR>. Orden:
      --   1. dentro de un snippet -> salta al siguiente placeholder
      --   2. menu de cmp abierto  -> recorre las opciones (ver opciones)
      --   3. ghost text de IA     -> lo acepta (autocompletar en linea)
      --   4. si no                -> tab normal
      local function minuet_virtualtext()
        return require("minuet.virtualtext").action
      end

      opts.mapping["<Tab>"] = cmp.mapping(function(fallback)
        -- OJO: no usar expand_or_jumpable() antes del menu, porque incluye
        -- expandable() (true con un trigger de snippet bajo el cursor) y
        -- expandia el snippet con el menu abierto en vez de navegar.
        if luasnip.jumpable(1) then
          -- Ya dentro de un snippet: saltar al siguiente placeholder.
          luasnip.jump()
        elseif cmp.visible() then
          -- Menu abierto: ver opciones sin insertar (behavior=Select).
          cmp.select_next_item { behavior = cmp.SelectBehavior.Select }
        elseif luasnip.expandable() then
          -- Trigger de snippet, sin menu abierto: expandir.
          luasnip.expand()
        elseif minuet_virtualtext().is_visible() then
          -- IA inline: aceptar.
          minuet_virtualtext().accept()
        else
          fallback()
        end
      end, { "i", "s" })

      opts.mapping["<S-Tab>"] = cmp.mapping(function(fallback)
        if luasnip.jumpable(-1) then
          luasnip.jump(-1)
        elseif cmp.visible() then
          cmp.select_prev_item { behavior = cmp.SelectBehavior.Select }
        elseif minuet_virtualtext().is_visible() then
          minuet_virtualtext().prev()
        else
          fallback()
        end
      end, { "i", "s" })

      -- NvChad deja <C-n>/<C-p> con el default de cmp (Insert), que pega el
      -- texto al navegar. Los alineamos a Select: ver opciones sin pegar nada.
      opts.mapping["<C-n>"] = cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Select }
      opts.mapping["<C-p>"] = cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Select }
    end,
  },

  {
    "mfussenegger/nvim-jdtls",
    ft = { "java", "kotlin" },
    config = function()
      require("configs.jdtls").setup()
    end,
  },

  {
    "3rd/image.nvim",
    ft = { "markdown", "html", "css", "vimwiki" },
    config = function()
      require("image").setup(require "configs.image")
    end,
  },

  {
    -- NvChad v2.5 ya se encarga de la instalacion (:TSInstallAll / build) y
    -- del highlighting (vim.treesitter.start en su autocmd). Solo extendemos
    -- la lista de parsers; no hace falta config custom ni bloquear el arranque.
    -- branch=main obligatorio: es la API que espera NvChad v2.5 (master esta
    -- archivada). Sin esto, lazy puede resolver a master por el origin/HEAD local.
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    opts = function(_, opts)
      local extra = {
        "vim", "lua", "vimdoc",
        "html", "css",
        "rust", "toml",
        "c", "cpp",
        "typescript", "javascript", "tsx",
        "python",
        "json", "yaml", "markdown", "markdown_inline",
        "java", "kotlin",
      }
      for _, parser in ipairs(extra) do
        if not vim.tbl_contains(opts.ensure_installed, parser) then
          table.insert(opts.ensure_installed, parser)
        end
      end
    end,
  },

  -- AI code completion (Codeium) - disabled (requested login)
  -- To re-enable: remove `enabled = false`, run :Codeium Auth, and restart
  --{
  --  "Exafunction/codeium.nvim",
  --  event = "InsertEnter",
  --  config = function()
  --    require("codeium").setup({
  --      enable_cmp_source = true,
  --      virtual_text = {
  --        enabled = true,
  --        manual = false,
  --        filetypes = {},
  --        default_filetype_enabled = true,
  --        idle_delay = 75,
  --        virtual_text_priority = 65535,
  --        map_keys = {
  --          accept = "<A-A>",
  --          accept_line = "<A-a>",
  --          accept_word = "<A-w>",
  --          next = "<A-]>",
  --          prev = "<A-[>",
  --          dismiss = "<A-e>",
  --        },
  --      },
  --    })
  --  end,
  --},

  ---------------------------------------------------------------------------
  -- TIER 1: Debugging
  ---------------------------------------------------------------------------
  {
    "nvim-neotest/nvim-nio",
    lazy = true,
  },

  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local dap = require "dap"
      local dapui = require "dapui"
      local configs = require "configs.dap"

      -- UI setup
      dapui.setup(configs.ui)
      require("nvim-dap-virtual-text").setup()

      -- Auto-open/close UI
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      -- Adapters
      dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = {
          command = vim.fn.stdpath "data" .. "/mason/bin/codelldb",
          args = { "--port", "${port}" },
        },
      }
      dap.adapters.debugpy = {
        type = "server",
        port = "${port}",
        executable = {
          command = vim.fn.stdpath "data" .. "/mason/bin/debugpy",
          args = { "-m", "debugpy.adapter", "--listen", "127.0.0.1:${port}" },
        },
      }
      dap.adapters["js-debug"] = {
        type = "server",
        port = "${port}",
        executable = {
          command = vim.fn.stdpath "data" .. "/mason/bin/js-debug-adapter",
          args = { "--port", "${port}" },
        },
      }

      -- Configurations per language
      for lang, configs_list in pairs(configs.configurations) do
        dap.configurations[lang] = configs_list
      end

      -- Map adapter names to types in configurations
      for _, cfg in ipairs(dap.configurations.c or {}) do
        cfg.type = "codelldb"
      end
      for _, cfg in ipairs(dap.configurations.cpp or {}) do
        cfg.type = "codelldb"
      end
      for _, cfg in ipairs(dap.configurations.python or {}) do
        cfg.type = "debugpy"
      end
      for _, cfg in ipairs(dap.configurations.javascript or {}) do
        cfg.type = "js-debug"
      end
      for _, cfg in ipairs(dap.configurations.typescript or {}) do
        cfg.type = "js-debug"
      end
    end,
  },

  {
    "jay-babu/mason-nvim-dap.nvim",
    event = "VeryLazy",
    dependencies = {
      "williamboman/mason.nvim",
      "mfussenegger/nvim-dap",
    },
    config = function()
      require("mason-nvim-dap").setup {
        ensure_installed = { "codelldb", "debugpy", "js-debug-adapter" },
        automatic_installation = true,
      }
    end,
  },

  ---------------------------------------------------------------------------
  -- TIER 1: Linting
  ---------------------------------------------------------------------------
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require "lint"
      local configs = require "configs.lint"

      lint.linters_by_ft = configs.linters_by_ft

      -- Custom linter args
      for name, cfg in pairs(configs.linters) do
        if lint.linters[name] then
          lint.linters[name].args = cfg.args
        end
      end

      -- Auto-lint on save and on text change
      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
        group = vim.api.nvim_create_augroup("NvChadLint", { clear = true }),
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },

  ---------------------------------------------------------------------------
  -- TIER 1: Testing
  ---------------------------------------------------------------------------
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-treesitter/nvim-treesitter",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-neotest/neotest-python",
      "marilari88/neotest-vitest",
      "alfaix/neotest-gtest",
    },
    config = function()
      local adapters = {
        require "neotest-python" {
          dap = { justMyCode = false },
          runner = "pytest",
        },
        require "neotest-vitest" {},
      }

      -- Optional: add gtest if available
      local gtest_ok, gtest = pcall(require, "neotest-gtest")
      if gtest_ok then
        table.insert(adapters, gtest)
      end

      -- La config base vive en lua/configs/neotest.lua (incluye strategies).
      local configs = require "configs.neotest"
      configs.adapters = adapters
      require("neotest").setup(configs)
    end,
  },

  ---------------------------------------------------------------------------
  -- TIER 2: C/C++ extras
  ---------------------------------------------------------------------------
  {
    "p00f/clangd_extensions.nvim",
    ft = { "c", "cpp", "h", "hpp" },
    config = function()
      require("clangd_extensions").setup {
        inlay_hints = {
          inline = vim.fn.has "nvim-0.10" == 1,
        },
        ast = { role = "ast", kind = "Type" },
        symbol_info = { border = "rounded" },
      }
    end,
  },

  {
    "Civitasv/cmake-tools.nvim",
    ft = { "cmake", "c", "cpp", "h", "hpp" },
    config = function()
      require("cmake-tools").setup {
        cmake_command = "cmake",
        build_directory = "build",
        configure_on_open = true,
        quickfix = {
          enabled = true,
          auto_open_when_run = false,
        },
      }
    end,
  },
}

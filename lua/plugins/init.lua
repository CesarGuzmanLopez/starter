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
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    priority = 100,
    build = ":TSUpdate",
    opts = {},
    config = function()
      pcall(function()
        dofile(vim.g.base46_cache .. "treesitter")
      end)

      require("nvim-treesitter").setup {}

      local parsers = {
        "vim", "lua", "vimdoc",
        "html", "css",
        "rust", "toml",
        "c", "cpp",
        "typescript", "javascript", "tsx",
        "python",
        "json", "yaml", "markdown", "markdown_inline",
        "java", "kotlin",
      }
      require("nvim-treesitter").install(parsers):wait(300000)

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("NvChadTsHighlight", { clear = true }),
        callback = function(args)
          pcall(vim.treesitter.start, args.buf)
        end,
      })

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("NvChadTsIndent", { clear = true }),
        callback = function(args)
          vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },

  -- AI code completion (Codeium)
  {
    "Exafunction/codeium.nvim",
    event = "InsertEnter",
    config = function()
      require("codeium").setup({
        enable_cmp_source = true,
        virtual_text = {
          enabled = true,
          manual = false,
          filetypes = {},
          default_filetype_enabled = true,
          idle_delay = 75,
          virtual_text_priority = 65535,
          map_keys = {
            accept = "<A-A>",
            accept_line = "<A-a>",
            accept_word = "<A-w>",
            next = "<A-]>",
            prev = "<A-[>",
            dismiss = "<A-e>",
          },
        },
      })
    end,
  },

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

      require("neotest").setup {
        adapters = adapters,
        discovery = { enabled = true },
        status = { enabled = true, signs = true, virtual_text = false },
        output = { enabled = true, open_on_run = false },
        summary = { enabled = true, follow = true },
        icons = {
          passed = "",
          running = "",
          failed = "",
          unknown = "",
          skipped = "",
        },
      }
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

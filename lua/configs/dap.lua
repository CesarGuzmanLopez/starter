return {
  -- DAP UI
  ui = {
    icons = {
      expanded = "",
      collapsed = "",
      circular = "",
    },
    layouts = {
      {
        elements = {
          { id = "scopes", size = 0.25 },
          { id = "breakpoints", size = 0.25 },
          { id = "stacks", size = 0.25 },
          { id = "watches", size = 0.25 },
        },
        size = 40,
        position = "left",
      },
      {
        elements = {
          { id = "repl", size = 0.5 },
          { id = "console", size = 0.5 },
        },
        size = 0.25,
        position = "bottom",
      },
    },
  },

  -- Adapters to install via mason
  mason_dap = {
    ensure_installed = {
      "codelldb",       -- C/C++/Rust
      "debugpy",        -- Python
      "js-debug-adapter", -- JS/TS
    },
  },

  -- Language configurations
  configurations = {
    c = {
      {
        name = "Launch (codelldb)",
        type = "codelldb",
        request = "launch",
        program = function()
          return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
        end,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
      },
    },
    cpp = {
      {
        name = "Launch (codelldb)",
        type = "codelldb",
        request = "launch",
        program = function()
          return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
        end,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
      },
    },
    python = {
      {
        type = "debugpy",
        request = "launch",
        name = "Launch file",
        program = "${file}",
        pythonPath = function()
          return vim.fn.exepath "python3"
        end,
      },
    },
    javascript = {
      {
        type = "js-debug-adapter",
        request = "launch",
        name = "Launch file",
        program = "${file}",
        cwd = "${workspaceFolder}",
      },
    },
    typescript = {
      {
        type = "js-debug-adapter",
        request = "launch",
        name = "Launch file",
        program = "${file}",
        cwd = "${workspaceFolder}",
      },
    },
  },
}

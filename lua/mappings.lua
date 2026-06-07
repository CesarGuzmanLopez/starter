require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

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
map("n", "<leader>ll", function() require("lint").try_lint() end, { desc = "Lint current buffer" })

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

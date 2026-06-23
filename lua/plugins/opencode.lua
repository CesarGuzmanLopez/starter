return {
  "nickjvandyke/opencode.nvim",
  version = "*",
  keys = {
    { "<leader>oa", desc = "Ask opencode" },
    { "<leader>ob", desc = "Ask opencode about buffer" },
    { "<leader>os", desc = "OC: select server" },
    { "<leader>oo", desc = "OpenCode: launch TUI" },
    { "<leader>ons", desc = "OC: select prompt/command" },
    { "<leader>onc", desc = "OC: compact session" },
    { "<leader>onn", desc = "OC: new session" },
    { "<leader>onl", desc = "OC: list sessions" },
    { "<leader>oni", desc = "OC: interrupt session" },
    { "<leader>onu", desc = "OC: undo last action" },
    { "<leader>onr", desc = "OC: redo last undone" },
  },
  config = function()
    ---@type opencode.Opts
    vim.g.opencode_opts = {
      -- Auto-detect opencode server running with --port
      -- If not found, starts via term://opencode --port
      server = {},
    }

    local map = vim.keymap.set

    ------------------------------------------------------------
    -- Ask / Select
    ------------------------------------------------------------
    -- Ask opencode with cursor word / selection as context
    map({ "n", "x" }, "<leader>oa", function()
      require("opencode").ask("@this: ")
    end, { desc = "Ask opencode" })

    -- Ask about the full buffer
    map({ "n", "x" }, "<leader>ob", function()
      require("opencode").ask("@buffer: ")
    end, { desc = "Ask opencode about buffer" })

    -- Select / connect to a running opencode server
    map({ "n", "x" }, "<leader>os", function()
      require("opencode").select({
        prompts = false,
        commands = false,
        server = {
          ["server.select"] = "Select server",
          ["server.start"]  = "Start configured server",
        },
      })
    end, { desc = "OC: select server" })

    -- Full selector: prompts + commands + server
    map({ "n", "x" }, "<leader>ons", function()
      require("opencode").select()
    end, { desc = "OC: select prompt/command" })

    ------------------------------------------------------------
    -- Operator (motion / text-object support)
    ------------------------------------------------------------
    -- Usage: `go<motion>` or visual selection then `go`
    map({ "n", "x" }, "go", function()
      return require("opencode").operator("@this ")
    end, { desc = "Send range to opencode", expr = true })

    -- `goo` sends the current line
    map("n", "goo", function()
      return require("opencode").operator("@this ") .. "_"
    end, { desc = "Send line to opencode", expr = true })

    ------------------------------------------------------------
    -- Session management
    ------------------------------------------------------------
    map("n", "<leader>onc", function()
      require("opencode").command("session.compact")
    end, { desc = "OC: compact session" })

    map("n", "<leader>onn", function()
      require("opencode").command("session.new")
    end, { desc = "OC: new session" })

    map("n", "<leader>onl", function()
      require("opencode").command("session.list")
    end, { desc = "OC: list sessions" })

    map("n", "<leader>oni", function()
      require("opencode").command("session.interrupt")
    end, { desc = "OC: interrupt session" })

    map("n", "<leader>onu", function()
      require("opencode").command("session.undo")
    end, { desc = "OC: undo last action" })

    map("n", "<leader>onr", function()
      require("opencode").command("session.redo")
    end, { desc = "OC: redo last undone" })

    ------------------------------------------------------------
    -- Launch opencode in vertical split
    ------------------------------------------------------------
    map("n", "<leader>oo", function()
      vim.cmd("vsplit term://opencode --port | wincmd p")
    end, { desc = "OpenCode: launch server" })

    ------------------------------------------------------------
    -- Scrolling in opencode TUI
    ------------------------------------------------------------
    map("n", "<S-C-u>", function()
      require("opencode").command("session.half.page.up")
    end, { desc = "OC: scroll up" })

    map("n", "<S-C-d>", function()
      require("opencode").command("session.half.page.down")
    end, { desc = "OC: scroll down" })
  end,
}

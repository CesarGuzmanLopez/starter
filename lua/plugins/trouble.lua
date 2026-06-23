return {
  "folke/trouble.nvim",
  cmd = { "Trouble", "TroubleToggle", "TroubleRefresh" },
  keys = {
    { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
    { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics" },
    { "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Symbols (Trouble)" },
    { "<leader>cl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "LSP Definitions/References" },
    { "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Location List" },
    { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List" },
  },
  opts = {
    modes = {
      diagnostics = { auto_open = false },
      symbols = { win = { position = "right", size = 0.3 } },
      lsp = { win = { position = "right", size = 0.3 } },
    },
  },
}
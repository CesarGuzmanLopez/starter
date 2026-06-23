return {
  "folke/persistence.nvim",
  event = "BufReadPre",
  opts = {
    -- Directorio donde guardar las sesiones
    dir = vim.fn.stdpath "data" .. "/sessions/",
    -- Opciones para guardar
    options = { "buffers", "curdir", "tabpages", "winsize", "help", "globals" },
    -- Autoguardar al salir
    pre_save = nil,
    -- Guardar sesión cuando se cambia de directorio o antes de salir
  },
  keys = {
    {
      "<leader>qs",
      function()
        require("persistence").load()
      end,
      desc = "Restore session",
    },
    {
      "<leader>qS",
      function()
        require("persistence").select()
      end,
      desc = "Select session",
    },
    {
      "<leader>ql",
      function()
        require("persistence").load { last = true }
      end,
      desc = "Restore last session",
    },
    {
      "<leader>qd",
      function()
        require("persistence").stop()
      end,
      desc = "Don't save current session",
    },
  },
}

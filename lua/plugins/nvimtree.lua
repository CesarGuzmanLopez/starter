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
    local base = require("nvchad.configs.nvimtree")
    -- No seguir cambios de cwd ni del buffer: raiz fija al arranque.
    base.sync_root_with_cwd = false
    base.respect_buf_cwd = false
    base.prefer_startup_root = true
    base.update_focused_file = { enable = false }
    return base
  end,
}

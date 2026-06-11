return {
  "mikavilpas/yazi.nvim",
  event = "VeryLazy",
  keys = {
    -- <leader>e (espacio + e) para abrir Yazi (reemplaza NvimTree)
    {
      "<leader>e",
      function()
        require("yazi").yazi()
      end,
      desc = "Abrir Yazi (gestor archivos)",
    },
  },
  -- Deshabilitar netrw para que Yazi maneje los directorios limpiamente
  init = function()
    vim.g.loaded_netrwPlugin = 1
    vim.g.loaded_netrw = 1
  end,
  opts = {
    -- Abrir Yazi automáticamente al abrir un directorio (nvim .)
    open_for_directories = true,
    -- Cambiar el CWD de Neovim al cerrar Yazi
    change_neovim_cwd_on_close = true,
    -- Tamaño del floating window
    floating_window_scaling_factor = 0.95,
    -- Abrir en ventana flotante centrada
    open_file_in_same_window = false,
  },
}

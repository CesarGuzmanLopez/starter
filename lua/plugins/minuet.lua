return {
  "milanglacier/minuet-ai.nvim",
  version = "*",
  keys = {
    { "<A-y>", desc = "Minuet: manual completion" },
  },
  config = function()
    -- Solo activar si hay API key configurada
    local api_key = os.getenv "CESAR_PROXY_KEY"
    local end_point = os.getenv "CESAR_PROXY_URL"
    if not api_key or not end_point then
      vim.notify(
        "Minuet: faltan CESAR_PROXY_KEY y/o CESAR_PROXY_URL en .env",
        vim.log.levels.WARN,
        { title = "minuet" }
      )
      return
    end

    require("minuet").setup {
      -- Usa virtual text (ghost text) en lugar de integracion con nvim-cmp
      -- para mantener el menu de completado rapido de NvChad intacto
      provider = "openai_compatible",
      -- Tiempo maximo de espera por respuesta
      request_timeout = 3,
      -- Esperar 600ms desde que se deja de escribir antes de pedir sugerencia
      debounce = 600,
      -- Esperar 1500ms antes de permitir otro request
      throttle = 1500,
      -- No sugerir hasta que haya al menos 3 caracteres escritos
      min_length = 3,
      -- Usar nvim-cmp como fuente de completado
      -- (desactivado: usa virtual text directamente)
      use_cmp = false,
      provider_options = {
        openai_compatible = {
          api_key = api_key,
          end_point = end_point .. "/chat/completions",
          model = "flash",
          name = "Proxy",
          optional = {
            max_tokens = 128,
            top_p = 0.9,
          },
        },
      },
    }
  end,
}
